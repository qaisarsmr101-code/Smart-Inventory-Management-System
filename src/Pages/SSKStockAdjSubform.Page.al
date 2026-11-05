namespace SmartStock.Pages;

using SmartStock.Tables;

page 50103 "SSK Stock Adj. Subform"
{
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "SSK Adjustment Line";
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item being adjusted.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item variant, if applicable.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the description of the item.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the warehouse location where the stock adjustment takes place.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code for this line item adjustment.';
                }
                field("Adjustment Type"; Rec."Adjustment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this line is a Positive Adjustment (Stock In) or Negative Adjustment (Stock Out).';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity to be adjusted.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the item.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit cost of the item used to calculate the financial impact.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the calculated line amount (Quantity * Unit Cost).';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lot or batch number for lot-tracked inventory items.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expiration date associated with the lot or batch.';
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the specific Item Ledger Entry to apply this negative adjustment against, ensuring exact cost reversal.';
                }
            }
        }
    }
}
