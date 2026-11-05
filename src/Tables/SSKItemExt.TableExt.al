namespace SmartStock.Tables;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using SmartStock.Enums;

tableextension 50100 "SSK Item Ext" extends Item
{
    fields
    {
        field(50100; "SSK SmartStock Managed"; Boolean)
        {
            Caption = 'SmartStock Managed';
            DataClassification = CustomerContent;
        }
        field(50101; "SSK Min Safety Stock"; Decimal)
        {
            Caption = 'Min Safety Stock Level';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(50102; "SSK Max Stock Buffer"; Decimal)
        {
            Caption = 'Max Stock Buffer Level';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(50103; "SSK Velocity Class"; Enum "SSK Inventory Velocity")
        {
            Caption = 'Velocity Classification (ABC)';
            DataClassification = CustomerContent;
        }
        field(50104; "SSK Reorder Cycle"; DateFormula)
        {
            Caption = 'Replenishment Reorder Cycle';
            DataClassification = CustomerContent;
        }
        field(50105; "SSK Date Filter"; Date)
        {
            Caption = 'SmartStock Date Filter';
            FieldClass = FlowFilter;
        }
        field(50106; "SSK Total Expired Qty"; Decimal)
        {
            Caption = 'Total Expired Quantity';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry"."Remaining Quantity" where(
                "Item No." = field("No."),
                Open = const(true),
                Positive = const(true),
                "Expiration Date" = field("SSK Date Filter")
            ));
            Editable = false;
        }
    }

    procedure SSKCalcAvailableInventory(): Decimal
    var
        AvailableQty: Decimal;
    begin
        Rec.CalcFields(Inventory, "Qty. on Sales Order", "Qty. on Component Lines", "Qty. on Purchasing");
        AvailableQty := Rec.Inventory - Rec."Qty. on Sales Order" - Rec."Qty. on Component Lines" + Rec."Qty. on Purchasing";
        exit(AvailableQty);
    end;

    procedure SSKIsBelowReorderPoint(): Boolean
    begin
        if not Rec."SSK SmartStock Managed" then
            exit(false);

        if Rec."SSK Min Safety Stock" <= 0 then
            exit(false);

        exit(SSKCalcAvailableInventory() <= Rec."SSK Min Safety Stock");
    end;
}
