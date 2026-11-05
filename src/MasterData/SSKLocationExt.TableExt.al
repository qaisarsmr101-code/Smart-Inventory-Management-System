namespace SmartStock.MasterData;

using Microsoft.Inventory.Location;
using System.Security.AccessControl;

tableextension 50101 "SSK Location Ext" extends Location
{
    fields
    {
        field(50100; "SSK Is Distribution Hub"; Boolean)
        {
            Caption = 'Is Distribution Hub';
            DataClassification = CustomerContent;
        }
        field(50101; "SSK Storekeeper User ID"; Code[50])
        {
            Caption = 'Storekeeper User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(50102; "SSK Disallow Manual Adjust"; Boolean)
        {
            Caption = 'Disallow Manual Adjustments';
            DataClassification = CustomerContent;
        }
    }
}

