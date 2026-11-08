namespace SmartStock.Pages;

using Microsoft.Inventory.Location;

pageextension 50103 "SSK Location List Ext" extends "Location List"
{
    layout
    {
        addlast(Control1)
        {
            field("SSK Is Distribution Hub"; Rec."SSK Is Distribution Hub")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this location functions as a primary regional distribution hub.';
            }
            field("SSK Storekeeper User ID"; Rec."SSK Storekeeper User ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the user assigned to supervise inventory and cycle counts at this facility.';
            }
            field("SSK Disallow Manual Adjust"; Rec."SSK Disallow Manual Adjust")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if manual inventory adjustment documents are prohibited for this location.';
            }
        }
    }
}

