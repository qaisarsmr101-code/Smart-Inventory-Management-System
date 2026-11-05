namespace SmartStock.MasterData;

using Microsoft.Inventory.Item;

pageextension 50101 "SSK Item List Ext" extends "Item List"
{
    layout
    {
        addafter(InventoryField)
        {
            field("SSK SmartStock Managed"; Rec."SSK SmartStock Managed")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this item is managed under SmartStock reorder controls.';
            }
            field("SSK Min Safety Stock"; Rec."SSK Min Safety Stock")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the minimum safety stock threshold for this item.';
            }
            field("SSK Velocity Class"; Rec."SSK Velocity Class")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the ABC velocity tier (Fast, Medium, Slow, Non-Moving).';
            }
        }
    }

    actions
    {
        addafter(History)
        {
            group(SSKSmartStock)
            {
                Caption = 'SmartStock';

                action(SSKFilterManagedItems)
                {
                    Caption = 'SmartStock Items Only';
                    Image = FilterLines;
                    ApplicationArea = All;
                    ToolTip = 'Filters the list to display only items governed by SmartStock replenishment rules.';

                    trigger OnAction()
                    begin
                        Rec.SetRange("SSK SmartStock Managed", true);
                        CurrPage.Update(false);
                    end;
                }
                action(SSKClearFilter)
                {
                    Caption = 'Show All Items';
                    Image = ClearFilter;
                    ApplicationArea = All;
                    ToolTip = 'Clears the SmartStock item filter to show all inventory items.';

                    trigger OnAction()
                    begin
                        Rec.SetRange("SSK SmartStock Managed");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
