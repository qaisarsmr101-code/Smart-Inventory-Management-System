namespace SmartStock.Setup;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using System.Security.AccessControl;

table 50100 "SSK SmartStock Setup"
{
    Caption = 'SmartStock Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Adjustment Nos."; Code[20])
        {
            Caption = 'Adjustment Document Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(20; "Auto-Notify Low Stock"; Boolean)
        {
            Caption = 'Auto-Notify on Low Stock';
            DataClassification = CustomerContent;
        }
        field(21; "Default In-Transit Location"; Code[10])
        {
            Caption = 'Default In-Transit Location';
            TableRelation = Location.Code where("Use As In-Transit" = const(true));
            DataClassification = CustomerContent;
        }
        field(30; "Approval Threshold Amount"; Decimal)
        {
            Caption = 'Approval Threshold Amount';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(31; "Supervisor User ID"; Code[50])
        {
            Caption = 'Supervisor User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(40; "Expiry Warning Days"; Integer)
        {
            Caption = 'Expiry Warning Horizon (Days)';
            MinValue = 1;
            InitValue = 30;
            DataClassification = CustomerContent;
        }
        field(41; "Enable FEFO Guidance"; Boolean)
        {
            Caption = 'Enable FEFO Guidance';
            InitValue = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;

        Get();
        RecordHasBeenRead := true;
    end;
}

