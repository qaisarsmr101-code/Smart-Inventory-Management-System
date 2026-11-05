namespace SmartStock.Pages;

using SmartStock.Tables;

page 50100 "SSK SmartStock Setup"
{
    Caption = 'SmartStock Setup';
    PageType = Card;
    SourceTable = "SSK SmartStock Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Adjustment Nos."; Rec."Adjustment Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series code used to assign numbers to Stock Adjustment documents.';
                }
                field("Default In-Transit Location"; Rec."Default In-Transit Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default in-transit location used for inter-warehouse inventory transfers.';
                }
                field("Auto-Notify Low Stock"; Rec."Auto-Notify Low Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the system automatically generates alert log entries when item inventory falls below safety thresholds.';
                }
            }
            group(Approvals)
            {
                Caption = 'Approval Controls';

                field("Approval Threshold Amount"; Rec."Approval Threshold Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cost threshold. Adjustments with a total value exceeding this amount require supervisor approval before posting.';
                }
                field("Supervisor User ID"; Rec."Supervisor User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default user authorized to approve high-value stock adjustments.';
                }
            }
            group(ExpiryAndFEFO)
            {
                Caption = 'Batch Expiry & FEFO Governance';

                field("Expiry Warning Days"; Rec."Expiry Warning Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lookahead window in days to detect batches approaching their expiration date.';
                }
                field("Enable FEFO Guidance"; Rec."Enable FEFO Guidance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether First-Expired, First-Out (FEFO) picking suggestions are enforced across warehouse documents.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec."Expiry Warning Days" := 30;
            Rec."Enable FEFO Guidance" := true;
            Rec.Insert(true);
        end;
    end;
}
