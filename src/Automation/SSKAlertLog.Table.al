namespace SmartStock.Automation;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using SmartStock.Setup;
using System.Security.AccessControl;

table 50105 "SSK Alert Log"
{
    Caption = 'SmartStock Alert Log';
    DataClassification = CustomerContent;
    LookupPageId = 50107;
    DrillDownPageId = 50107;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; "Alert DateTime"; DateTime)
        {
            Caption = 'Alert Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Severity"; Enum "SSK Alert Severity")
        {
            Caption = 'Severity';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Acknowledged"; Boolean)
        {
            Caption = 'Acknowledged';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Acknowledged then begin
                    "Acknowledged By User ID" := CopyStr(UserId(), 1, MaxStrLen("Acknowledged By User ID"));
                    "Acknowledged DateTime" := CurrentDateTime();
                end else begin
                    "Acknowledged By User ID" := '';
                    "Acknowledged DateTime" := 0DT;
                end;
            end;
        }
        field(31; "Acknowledged By User ID"; Code[50])
        {
            Caption = 'Acknowledged By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Acknowledged DateTime"; DateTime)
        {
            Caption = 'Acknowledged Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "Item No.", "Alert DateTime")
        {
        }
        key(Key2; Acknowledged, Severity)
        {
        }
    }
}

