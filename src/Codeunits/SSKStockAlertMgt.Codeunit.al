namespace SmartStock.Codeunits;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using SmartStock.Enums;
using SmartStock.Tables;
using System.Threading;

/// <summary>
/// Codeunit 50101 "SSK Stock Alert Mgt"
/// ===================================
/// Automated background monitoring engine for inventory safety stock and batch expiration.
/// - Operates either as a scheduled background Job Queue task (TableNo = Job Queue Entry)
///   or triggered interactively from user interfaces (Role Center, Alert Log List).
/// - De-duplicates alerts to ensure warehouse operatives are not overwhelmed with repeated entries.
/// </summary>
codeunit 50101 "SSK Stock Alert Mgt"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        // Invoked automatically when executed by the Business Central Job Queue
        RunStockMonitoring(false);
    end;

    /// <summary>
    /// Executes both low stock and batch expiration inspection routines.
    /// </summary>
    /// <param name="ShowSummary">Set true for interactive UI calls to display a completion dialog.</param>
    /// <returns>Count of newly generated alert records.</returns>
    procedure RunStockMonitoring(ShowSummary: Boolean): Integer
    var
        SmartStockSetup: Record "SSK SmartStock Setup";
        NewAlertsCount: Integer;
    begin
        SmartStockSetup.GetRecordOnce();

        // 1. Inspect inventory for items falling below safety stock
        NewAlertsCount += CheckLowStockLevels(SmartStockSetup);

        // 2. Inspect active lot ledger entries for expired or expiring batches
        NewAlertsCount += CheckBatchExpirations(SmartStockSetup);

        if ShowSummary then
            Message(ScanCompletedMsg, NewAlertsCount);

        exit(NewAlertsCount);
    end;

    /// <summary>
    /// Evaluates managed items against their configured safety threshold.
    /// Flags 'Critical' if completely out of stock; 'Warning' if below reorder threshold.
    /// </summary>
    local procedure CheckLowStockLevels(SmartStockSetup: Record "SSK SmartStock Setup"): Integer
    var
        Item: Record Item;
        AlertLog: Record "SSK Alert Log";
        AvailableStock: Decimal;
        CreatedCount: Integer;
    begin
        Item.SetRange("SSK SmartStock Managed", true);
        if Item.FindSet() then
            repeat
                if Item.SSKIsBelowReorderPoint() then begin
                    AvailableStock := Item.SSKCalcAvailableInventory();

                    // De-duplication check: Skip if an unacknowledged alert already exists for this item
                    AlertLog.SetRange("Item No.", Item."No.");
                    AlertLog.SetRange(Acknowledged, false);
                    if AlertLog.IsEmpty() then begin
                        Clear(AlertLog);
                        AlertLog.Init();
                        AlertLog."Alert DateTime" := CurrentDateTime();
                        AlertLog."Item No." := Item."No.";
                        AlertLog."Item Description" := Item.Description;

                        if AvailableStock <= 0 then begin
                            AlertLog.Severity := AlertLog.Severity::Critical;
                            AlertLog.Message := CopyStr(StrSubstNo(OutOfStockAlertTxt, Item."No.", Item."SSK Min Safety Stock", AvailableStock), 1, MaxStrLen(AlertLog.Message));
                        end else begin
                            AlertLog.Severity := AlertLog.Severity::Warning;
                            AlertLog.Message := CopyStr(StrSubstNo(LowStockAlertTxt, Item."No.", Item."SSK Min Safety Stock", AvailableStock), 1, MaxStrLen(AlertLog.Message));
                        end;

                        AlertLog.Insert(true);
                        CreatedCount += 1;
                    end;
                end;
            until Item.Next() = 0;

        exit(CreatedCount);
    end;

    /// <summary>
    /// Scans open positive Item Ledger Entries with an expiration date.
    /// Creates Critical alerts for expired lots, and Warning alerts for lots expiring
    /// within the configured horizon days (e.g. 30 days).
    /// </summary>
    local procedure CheckBatchExpirations(SmartStockSetup: Record "SSK SmartStock Setup"): Integer
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        AlertLog: Record "SSK Alert Log";
        HorizonDate: Date;
        HorizonDays: Integer;
        CreatedCount: Integer;
    begin
        HorizonDays := SmartStockSetup."Expiry Warning Days";
        if HorizonDays <= 0 then
            HorizonDays := 30;

        HorizonDate := CalcDate(StrSubstNo('+%1D', HorizonDays), Today());

        // Optimize search using primary item tracking key
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetFilter("Expiration Date", '<>%1', 0D);

        if ItemLedgEntry.FindSet() then
            repeat
                // Condition A: Batch is already expired
                if ItemLedgEntry."Expiration Date" < Today() then begin
                    AlertLog.SetRange("Item No.", ItemLedgEntry."Item No.");
                    AlertLog.SetRange(Severity, AlertLog.Severity::Critical);
                    AlertLog.SetRange(Acknowledged, false);
                    if AlertLog.IsEmpty() then begin
                        Clear(AlertLog);
                        AlertLog.Init();
                        AlertLog."Alert DateTime" := CurrentDateTime();
                        AlertLog."Item No." := ItemLedgEntry."Item No.";
                        AlertLog."Location Code" := ItemLedgEntry."Location Code";
                        AlertLog.Severity := AlertLog.Severity::Critical;
                        AlertLog.Message := CopyStr(StrSubstNo(ExpiredLotAlertTxt, ItemLedgEntry."Lot No.", ItemLedgEntry."Item No.", ItemLedgEntry."Expiration Date", ItemLedgEntry."Remaining Quantity"), 1, MaxStrLen(AlertLog.Message));
                        AlertLog.Insert(true);
                        CreatedCount += 1;
                    end;
                // Condition B: Batch is expiring within the warning horizon
                end else if ItemLedgEntry."Expiration Date" <= HorizonDate then begin
                    AlertLog.SetRange("Item No.", ItemLedgEntry."Item No.");
                    AlertLog.SetRange(Severity, AlertLog.Severity::Warning);
                    AlertLog.SetRange(Acknowledged, false);
                    if AlertLog.IsEmpty() then begin
                        Clear(AlertLog);
                        AlertLog.Init();
                        AlertLog."Alert DateTime" := CurrentDateTime();
                        AlertLog."Item No." := ItemLedgEntry."Item No.";
                        AlertLog."Location Code" := ItemLedgEntry."Location Code";
                        AlertLog.Severity := AlertLog.Severity::Warning;
                        AlertLog.Message := CopyStr(StrSubstNo(NearExpiryLotAlertTxt, ItemLedgEntry."Lot No.", ItemLedgEntry."Item No.", ItemLedgEntry."Expiration Date", HorizonDays, ItemLedgEntry."Remaining Quantity"), 1, MaxStrLen(AlertLog.Message));
                        AlertLog.Insert(true);
                        CreatedCount += 1;
                    end;
                end;
            until ItemLedgEntry.Next() = 0;

        exit(CreatedCount);
    end;

    var
        ScanCompletedMsg: Label 'Stock scan completed successfully. %1 new alert(s) generated.', Comment = '%1=Count';
        OutOfStockAlertTxt: Label 'Critical: Item %1 is completely out of stock (Available: %3, Safety Target: %2).', Comment = '%1=Item, %2=Min, %3=Avail';
        LowStockAlertTxt: Label 'Warning: Available stock for Item %1 is %3, falling below safety threshold %2.', Comment = '%1=Item, %2=Min, %3=Avail';
        ExpiredLotAlertTxt: Label 'Critical: Lot %1 for Item %2 expired on %3 (Remaining Quantity: %4).', Comment = '%1=Lot, %2=Item, %3=Date, %4=Qty';
        NearExpiryLotAlertTxt: Label 'Warning: Lot %1 for Item %2 will expire on %3 within %4 days (Qty: %5).', Comment = '%1=Lot, %2=Item, %3=Date, %4=Days, %5=Qty';
}

