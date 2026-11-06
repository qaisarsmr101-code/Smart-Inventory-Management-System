namespace SmartStock.Tables;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Tracking;
using SmartStock.Enums;

table 50103 "SSK Adjustment Line"
{
    Caption = 'SmartStock Adjustment Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "SSK Adjustment Header"."No.";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                Header: Record "SSK Adjustment Header";
            begin
                TestStatusDraft();
                if "Item No." = '' then begin
                    Clear(Rec);
                    "Document No." := xRec."Document No.";
                    "Line No." := xRec."Line No.";
                    exit;
                end;

                Item.Get("Item No.");
                Item.TestField(Blocked, false);
                Description := Item.Description;
                "Unit of Measure Code" := Item."Base Unit of Measure";
                "Unit Cost" := Item."Unit Cost";

                if Header.Get("Document No.") then begin
                    if Header."Location Code" <> '' then
                        "Location Code" := Header."Location Code";
                    if Header."Reason Code" <> '' then
                        Validate("Reason Code", Header."Reason Code");
                end;

                UpdateTotalAmount();
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
            end;
        }
        field(12; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(13; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                TestStatusDraft();
                if "Location Code" <> '' then begin
                    Location.Get("Location Code");
                    Location.SSKCheckManualAdjustAllowed();
                end;
            end;
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
            end;
        }
        field(20; "Adjustment Type"; Enum "SSK Stock Movement Type")
        {
            Caption = 'Adjustment Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
                VerifyAvailableStock();
            end;
        }
        field(21; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
                VerifyAvailableStock();
                UpdateTotalAmount();
            end;
        }
        field(22; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 2 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
                UpdateTotalAmount();
            end;
        }
        field(23; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            TableRelation = "SSK Adjustment Reason".Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AdjReason: Record "SSK Adjustment Reason";
            begin
                TestStatusDraft();
                if "Reason Code" <> '' then begin
                    AdjReason.Get("Reason Code");
                    "Adjustment Type" := AdjReason."Default Movement Type";
                end;
            end;
        }
        field(40; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
            TableRelation = "Item Ledger Entry"."Entry No." where(
                "Item No." = field("Item No."),
                Open = const(true),
                Positive = const(true)
            );
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                TestStatusDraft();
                if "Applies-to Entry" <> 0 then begin
                    ItemLedgEntry.Get("Applies-to Entry");
                    "Unit Cost" := ItemLedgEntry."Cost Amount (Actual)" / ItemLedgEntry.Quantity;
                    "Lot No." := ItemLedgEntry."Lot No.";
                    "Expiration Date" := ItemLedgEntry."Expiration Date";
                    UpdateTotalAmount();
                end;
            end;
        }
        field(50; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                TestStatusDraft();
                if ("Lot No." <> '') and ("Item No." <> '') then begin
                    ItemLedgEntry.SetRange("Item No.", "Item No.");
                    ItemLedgEntry.SetRange("Lot No.", "Lot No.");
                    ItemLedgEntry.SetFilter("Expiration Date", '<>%1', 0D);
                    if ItemLedgEntry.FindFirst() then
                        "Expiration Date" := ItemLedgEntry."Expiration Date";
                end;
            end;
        }
        field(51; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusDraft();
            end;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "Item No.", "Location Code")
        {
        }
    }

    local procedure TestStatusDraft()
    var
        Header: Record "SSK Adjustment Header";
    begin
        if Header.Get("Document No.") then
            Header.TestField(Status, Header.Status::Draft);
    end;

    local procedure UpdateTotalAmount()
    begin
        "Total Amount" := Round(Quantity * "Unit Cost", 0.01);
    end;

    local procedure VerifyAvailableStock()
    var
        Item: Record Item;
    begin
        if ("Adjustment Type" = "Adjustment Type"::NegativeAdjustment) and ("Item No." <> '') and (Quantity > 0) then begin
            Item.Get("Item No.");
            if "Location Code" <> '' then
                Item.SetRange("Location Filter", "Location Code");
            Item.CalcFields(Inventory);
            if Item.Inventory < Quantity then
                Message(StockWarningMsg, "Item No.", "Location Code", Item.Inventory, Quantity);
        end;
    end;

    var
        StockWarningMsg: Label 'Warning: Available inventory for Item %1 at Location "%2" is %3, which is less than requested reduction %4.', Comment = '%1=Item, %2=Location, %3=Current, %4=Requested';
}
