namespace SmartStock.Setup;

using Microsoft.Finance.GeneralLedger.Account;

table 50101 "SSK Adjustment Reason"
{
    Caption = 'SmartStock Adjustment Reason';
    DataClassification = CustomerContent;
    LookupPageId = 50101;
    DrillDownPageId = 50101;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Default Movement Type"; Enum "SSK Stock Movement Type")
        {
            Caption = 'Default Movement Type';
            DataClassification = CustomerContent;
        }
        field(11; "Requires Supervisor Approval"; Boolean)
        {
            Caption = 'Requires Supervisor Approval';
            DataClassification = CustomerContent;
        }
        field(20; "Target G/L Account No."; Code[20])
        {
            Caption = 'Target G/L Account No.';
            TableRelation = "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Description", "Default Movement Type")
        {
        }
    }
}
