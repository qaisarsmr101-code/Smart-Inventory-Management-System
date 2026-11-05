namespace SmartStock.MasterData;

using Microsoft.Inventory.Location;

pageextension 50102 "SSK Location Card Ext" extends "Location Card"
{
    layout
    {
        addafter(Warehouse)
        {
            group(SSKSmartStock)
            {
                Caption = 'SmartStock Operations';

                field("SSK Is Distribution Hub"; Rec."SSK Is Distribution Hub")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this warehouse acts as a central regional distribution center.';
                }
                field("SSK Storekeeper User ID"; Rec."SSK Storekeeper User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user primarily responsible for cycle counts and stock control at this location.';
                }
                field("SSK Disallow Manual Adjust"; Rec."SSK Disallow Manual Adjust")
                {
                    ApplicationArea = All;
                    ToolTip = 'If enabled, manual stock adjustments at this location are restricted to prevent unauthorized inventory alterations.';
                }
            }
        }
    }
}
