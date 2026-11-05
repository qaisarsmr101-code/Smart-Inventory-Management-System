namespace SmartStock.Setup;

page 50101 "SSK Adjustment Reasons"
{
    Caption = 'SmartStock Adjustment Reasons';
    PageType = List;
    SourceTable = "SSK Adjustment Reason";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for the stock adjustment reason (e.g. DAMAGE, SCRAP, COUNT).';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the business description of the adjustment reason.';
                }
                field("Default Movement Type"; Rec."Default Movement Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this reason defaults to Positive Adjustment (Stock In) or Negative Adjustment (Stock Out).';
                }
                field("Requires Supervisor Approval"; Rec."Requires Supervisor Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether adjustments tagged with this reason code always mandate supervisor approval regardless of amount.';
                }
                field("Target G/L Account No."; Rec."Target G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general ledger account where write-offs or inventory discrepancy values under this reason should be audited.';
                }
            }
        }
    }
}
