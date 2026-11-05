namespace SmartStock.Tables;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using SmartStock.Enums;
using System.Security.AccessControl;

table 50102 "SSK Adjustment Header"
{
    Caption = 'SmartStock Adjustment Header';
    DataClassification = CustomerContent;
    LookupPageId = 50104;
    DrillDownPageId = 50104;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    SmartStockSetup.GetRecordOnce();
                    NoSeries.TestManual(SmartStockSetup."Adjustment Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Draft);
            end;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                TestField(Status, Status::Draft);
                if "Location Code" <> '' then begin
                    Location.Get("Location Code");
                    Location.TestField("SSK Disallow Manual Adjust", false);
                end;
            end;
        }
        field(4; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            TableRelation = "SSK Adjustment Reason".Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AdjustmentReason: Record "SSK Adjustment Reason";
            begin
                TestField(Status, Status::Draft);
                if "Reason Code" <> '' then begin
                    AdjustmentReason.Get("Reason Code");
                    if AdjustmentReason.Description <> '' then
                        "Posting Description" := CopyStr(AdjustmentReason.Description, 1, MaxStrLen("Posting Description"));
                end;
            end;
        }
        field(10; "Status"; Enum "SSK Document Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Total Cost Amount"; Decimal)
        {
            Caption = 'Total Cost Amount';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("SSK Adjustment Line"."Total Amount" where("Document No." = field("No.")));
            Editable = false;
        }
        field(21; "Total Quantity"; Decimal)
        {
            Caption = 'Total Quantity';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("SSK Adjustment Line".Quantity where("Document No." = field("No.")));
            Editable = false;
        }
        field(30; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
            DataClassification = CustomerContent;
        }
        field(40; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(42; "Approved By User ID"; Code[50])
        {
            Caption = 'Approved By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(43; "Approved DateTime"; DateTime)
        {
            Caption = 'Approved DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key1; "Posting Date", Status)
        {
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            SmartStockSetup.GetRecordOnce();
            SmartStockSetup.TestField("Adjustment Nos.");
#pragma warning disable AL0433
            "No. Series" := SmartStockSetup."Adjustment Nos.";
            if NoSeries.AreRelated(SmartStockSetup."Adjustment Nos.", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
#pragma warning restore AL0433
        end;

        "Created By User ID" := CopyStr(UserId(), 1, MaxStrLen("Created By User ID"));
        "Created DateTime" := CurrentDateTime();
        "Posting Date" := WorkDate();
        Status := Status::Draft;
    end;

    trigger OnDelete()
    var
        AdjustmentLine: Record "SSK Adjustment Line";
    begin
        if not (Status in [Status::Draft, Status::Rejected]) then
            Error(CannotDeleteErr, "No.", Status);

        AdjustmentLine.SetRange("Document No.", "No.");
        if not AdjustmentLine.IsEmpty() then
            AdjustmentLine.DeleteAll(true);
    end;

    var
        SmartStockSetup: Record "SSK SmartStock Setup";
        NoSeries: Codeunit "No. Series";
        CannotDeleteErr: Label 'Cannot delete Adjustment Document %1 because its status is %2. Only Draft or Rejected documents can be deleted.', Comment = '%1 = Document No., %2 = Status';
}
