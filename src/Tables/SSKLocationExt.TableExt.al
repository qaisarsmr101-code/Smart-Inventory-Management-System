namespace SmartStock.Tables;

using Microsoft.Inventory.Location;
using System.Security.AccessControl;

/// <summary>
/// TableExtension 50101 "SSK Location Ext" extends Location (Table 14)
/// ==============================================================
/// Enhances warehouse locations with operational attributes:
/// - Identification of central regional distribution hubs.
/// - Responsible storekeeper user identification.
/// - Manual adjustment restriction switch to prevent unscheduled floor adjustments.
/// </summary>
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

    /// <summary>
    /// Guard procedure: Throws an error if manual stock movements are restricted on this location.
    /// Used by adjustment headers, lines, and the posting codeunit to maintain warehouse compliance.
    /// </summary>
    procedure SSKCheckManualAdjustAllowed()
    begin
        Rec.TestField("SSK Disallow Manual Adjust", false);
    end;
}
