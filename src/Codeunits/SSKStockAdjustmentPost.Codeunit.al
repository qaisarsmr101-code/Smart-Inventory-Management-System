namespace SmartStock.Codeunits;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using SmartStock.Enums;
using SmartStock.Tables;

/// <summary>
/// Codeunit 50100 "SSK Stock Adjustment Post"
/// ==========================================
/// Serves as the central transaction posting engine for SmartStock adjustment documents.
/// Adheres to the "Golden Rule" of Business Central AL development:
/// - NEVER directly insert into Item Ledger Entry (Table 32) or Value Entry (Table 5802).
/// - Transforms document lines into memory-based Item Journal Lines and posts them
///   through standard Codeunit 22 ("Item Jnl.-Post Line").
/// - Ensures full General Ledger integrity, inventory costing, and reservation entry creation.
/// </summary>
codeunit 50100 "SSK Stock Adjustment Post"
{
    TableNo = "SSK Adjustment Header";

    trigger OnRun()
    begin
        PostAdjustment(Rec);
    end;

    /// <summary>
    /// Executes validation checks, approval threshold verifications, location permission checks,
    /// and invokes standard posting line-by-line for the specified adjustment header.
    /// </summary>
    procedure PostAdjustment(var Header: Record "SSK Adjustment Header")
    var
        Line: Record "SSK Adjustment Line";
        SmartStockSetup: Record "SSK SmartStock Setup";
        Location: Record Location;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemJnlLine: Record "Item Journal Line";
        LineCount: Integer;
    begin
        // 1. Mandatory Header Field Verifications
        Header.TestField("No.");
        Header.TestField("Posting Date");

        // Prevent double posting of already posted adjustment documents
        if Header.Status = Header.Status::Posted then
            Error(AlreadyPostedErr, Header."No.");

        SmartStockSetup.GetRecordOnce();
        Header.CalcFields("Total Cost Amount");

        // 2. Supervisor Approval Threshold Governance
        // If the document's total cost exceeds the approval threshold set in setup,
        // it cannot be posted unless it has explicitly received supervisor approval.
        if Header.Status <> Header.Status::Approved then
            if (SmartStockSetup."Approval Threshold Amount" > 0) and (Header."Total Cost Amount" > SmartStockSetup."Approval Threshold Amount") then
                Error(NeedsApprovalErr, Header."No.", Header."Total Cost Amount", SmartStockSetup."Approval Threshold Amount");

        // 3. Document Line Integrity Verification
        Line.SetRange("Document No.", Header."No.");
        if Line.IsEmpty() then
            Error(NoLinesErr, Header."No.");

        // Confirmation prompt before committing financial & inventory movements
        if not Confirm(ConfirmPostQst, false, Header."No.") then
            exit;

        // 4. Line-by-Line Transformation & Codeunit 22 Execution
        Line.FindSet();
        repeat
            Line.TestField("Item No.");
            Line.TestField(Quantity);
            if Line.Quantity <= 0 then
                Error(QuantityMustBePositiveErr, Line."Line No.");

            // Guard: Validate that warehouse location allows manual stock movements
            if Line."Location Code" <> '' then begin
                Location.Get(Line."Location Code");
                Location.SSKCheckManualAdjustAllowed();
            end;

            // Prepare in-memory standard Item Journal Line
            Clear(ItemJnlLine);
            ItemJnlLine.Init();
            ItemJnlLine."Document No." := Header."No.";
            ItemJnlLine."Posting Date" := Header."Posting Date";
            ItemJnlLine."Document Date" := Header."Posting Date";

            // Map custom SmartStock movement enum to standard Business Central entry types
            case Line."Adjustment Type" of
                Line."Adjustment Type"::PositiveAdjustment:
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
                Line."Adjustment Type"::NegativeAdjustment:
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
            end;

            // Trigger standard field validations to cascade item costing, dimensions, and accounts
            ItemJnlLine.Validate("Item No.", Line."Item No.");
            ItemJnlLine.Validate("Variant Code", Line."Variant Code");
            ItemJnlLine.Validate("Location Code", Line."Location Code");
            ItemJnlLine.Validate("Unit of Measure Code", Line."Unit of Measure Code");
            ItemJnlLine.Validate(Quantity, Line.Quantity);

            // Apply cost override if specified on line
            if Line."Unit Cost" <> 0 then
                ItemJnlLine.Validate("Unit Cost", Line."Unit Cost");

            // Apply exact cost-application link if specified
            if Line."Applies-to Entry" <> 0 then
                ItemJnlLine.Validate("Applies-to Entry", Line."Applies-to Entry");

            // Carry over line and header descriptions into Item Ledger
            if Line.Description <> '' then
                ItemJnlLine.Description := Line.Description;

            if Header."Posting Description" <> '' then
                ItemJnlLine.Description := Header."Posting Description";

            // 5. Lot/Batch Expiration & Tracking Attachment
            // If tracked by Lot No., generate matching surplus reservation entry
            if Line."Lot No." <> '' then
                CreateLotReservationEntry(ItemJnlLine, Line."Lot No.", Line."Expiration Date", Line.Quantity);

            // 6. Invoke Codeunit 22 to post and update Item Ledger & Value Entries
            ItemJnlPostLine.RunWithCheck(ItemJnlLine);
            LineCount += 1;
        until Line.Next() = 0;

        // 7. Finalize Document Status
        Header.Status := Header.Status::Posted;
        Header.Modify(true);

        Message(PostSuccessMsg, Header."No.", LineCount);
    end;

    /// <summary>
    /// Creates a Reservation Entry (Table 337) attaching Lot Number and Expiration Date
    /// to the unposted Item Journal Line so tracking flows correctly into Item Ledger Entries.
    /// </summary>
    local procedure CreateLotReservationEntry(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; ExpiryDate: Date; Qty: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
        NextEntryNo: Integer;
    begin
        ReservEntry.LockTable();
        if ReservEntry.FindLast() then
            NextEntryNo := ReservEntry."Entry No." + 1
        else
            NextEntryNo := 1;

        ReservEntry.Init();
        ReservEntry."Entry No." := NextEntryNo;
        ReservEntry."Item No." := ItemJnlLine."Item No.";
        ReservEntry."Location Code" := ItemJnlLine."Location Code";
        ReservEntry."Quantity (Base)" := Qty;
        ReservEntry.Quantity := Qty;
        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Surplus;
        ReservEntry."Creation Date" := Today();
        ReservEntry."Source Type" := Database::"Item Journal Line";
        ReservEntry."Source Subtype" := ItemJnlLine."Entry Type".AsInteger();
        ReservEntry."Source ID" := ItemJnlLine."Journal Template Name";
        ReservEntry."Source Batch Name" := ItemJnlLine."Journal Batch Name";
        ReservEntry."Source Ref. No." := ItemJnlLine."Line No.";
        ReservEntry."Lot No." := LotNo;
        ReservEntry."Expiration Date" := ExpiryDate;
        ReservEntry."Item Tracking" := ReservEntry."Item Tracking"::"Lot No.";
        ReservEntry.Insert(true);
    end;

    var
        AlreadyPostedErr: Label 'Document %1 is already posted.', Comment = '%1=Doc No';
        NeedsApprovalErr: Label 'Document %1 has a total value of %2, exceeding the approval threshold of %3. It must be approved before posting.', Comment = '%1=Doc, %2=Val, %3=Threshold';
        NoLinesErr: Label 'Document %1 contains no lines to post.', Comment = '%1=Doc No';
        QuantityMustBePositiveErr: Label 'Line %1 has an invalid quantity. Quantity must be greater than zero.', Comment = '%1=Line No';
        ConfirmPostQst: Label 'Are you sure you want to post SmartStock Adjustment %1 to the Item Ledger?', Comment = '%1=Doc No';
        PostSuccessMsg: Label 'SmartStock Adjustment %1 successfully posted! %2 inventory lines created in Item Ledger.', Comment = '%1=Doc No, %2=Count';
}
