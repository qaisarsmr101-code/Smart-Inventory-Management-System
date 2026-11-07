namespace SmartStock.Tables;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using SmartStock.Enums;

table 50104 "SSK Activities Cue"
{
    Caption = 'SmartStock Activities Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Pending Approvals"; Integer)
        {
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            CalcFormula = count("SSK Adjustment Header" where(Status = const(PendingApproval)));
            Editable = false;
        }
        field(11; "Draft Adjustments"; Integer)
        {
            Caption = 'Draft Adjustments';
            FieldClass = FlowField;
            CalcFormula = count("SSK Adjustment Header" where(Status = const(Draft)));
            Editable = false;
        }
        field(20; "Low Stock Items"; Integer)
        {
            Caption = 'Items Below Reorder Point';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Out of Stock Items"; Integer)
        {
            Caption = 'Out of Stock Items';
            FieldClass = FlowField;
            CalcFormula = count(Item where("SSK SmartStock Managed" = const(true), Inventory = filter(<= 0)));
            Editable = false;
        }
        field(30; "Expired Batches"; Integer)
        {
            Caption = 'Expired Batches';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31; "Batches Expiring in 30 Days"; Integer)
        {
            Caption = 'Batches Expiring in 30 Days';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure CalculateCueValues()
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        "Low Stock Items" := 0;
        Item.SetRange("SSK SmartStock Managed", true);
        if Item.FindSet() then
            repeat
                if Item.SSKIsBelowReorderPoint() then
                    "Low Stock Items" += 1;
            until Item.Next() = 0;

        ItemLedgEntry.Reset();
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetFilter("Expiration Date", '<>%1&<%2', 0D, Today());
        "Expired Batches" := ItemLedgEntry.Count();

        ItemLedgEntry.Reset();
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange("Expiration Date", Today(), Today() + 30);
        "Batches Expiring in 30 Days" := ItemLedgEntry.Count();
    end;
}
