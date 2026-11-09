namespace SmartStock.Tables;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using SmartStock.Enums;

/// <summary>
/// Table 50104 "SSK Activities Cue"
/// ================================
/// Singleton cue table serving as the data source for Role Center activities.
/// Combines:
/// - FlowFields for real-time document counts (Pending Approvals, Drafts, Out of Stock).
/// - Dynamic metric calculation for complex criteria (Low Stock Items, Expired Batches, Expiring Lots).
/// </summary>
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
        // FlowField: Tracks count of adjustments awaiting supervisor review
        field(10; "Pending Approvals"; Integer)
        {
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            CalcFormula = count("SSK Adjustment Header" where(Status = const(PendingApproval)));
            Editable = false;
        }
        // FlowField: Tracks count of draft adjustments currently in progress
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
        // FlowField: Tracks count of items where physical inventory is zero or negative
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

    /// <summary>
    /// Computes non-FlowField operational metrics across items and item ledger lots.
    /// Called OnOpenPage and during manual metric refreshes from the Activities Cue.
    /// </summary>
    procedure CalculateCueValues()
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // Count items currently operating below their minimum safety stock buffer
        "Low Stock Items" := 0;
        Item.SetRange("SSK SmartStock Managed", true);
        if Item.FindSet() then
            repeat
                if Item.SSKIsBelowReorderPoint() then
                    "Low Stock Items" += 1;
            until Item.Next() = 0;

        // Count open lots that have already passed their expiration date
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetFilter("Expiration Date", '<>%1&<%2', 0D, Today());
        "Expired Batches" := ItemLedgEntry.Count();

        // Count open lots reaching expiration within the next 30 days
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange("Expiration Date", Today(), Today() + 30);
        "Batches Expiring in 30 Days" := ItemLedgEntry.Count();
    end;
}
