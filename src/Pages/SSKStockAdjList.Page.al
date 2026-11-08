namespace SmartStock.Pages;

using SmartStock.Reports;
using SmartStock.Tables;

page 50104 "SSK Stock Adj. List"
{
    Caption = 'SmartStock Adjustments';
    PageType = List;
    SourceTable = "SSK Adjustment Header";
    CardPageId = "SSK Stock Adjustment";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the adjustment document number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date of the adjustment.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the warehouse location.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the operational reason code.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current approval/posting status.';
                }
                field("Total Cost Amount"; Rec."Total Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the total financial inventory impact of the adjustment.';
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the aggregate quantity across all adjustment lines.';
                }
                field("Created By User ID"; Rec."Created By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the originator of this adjustment document.';
                }
                field("Approved By User ID"; Rec."Approved By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who approved this adjustment.';
                }
            }
        }
    }

    views
    {
        view(PendingApprovalView)
        {
            Caption = 'Pending Approval';
            Filters = where(Status = const(PendingApproval));
        }
        view(DraftView)
        {
            Caption = 'Drafts';
            Filters = where(Status = const(Draft));
        }
        view(ApprovedView)
        {
            Caption = 'Ready to Post (Approved)';
            Filters = where(Status = const(Approved));
        }
        view(PostedView)
        {
            Caption = 'Posted Archive';
            Filters = where(Status = const(Posted));
        }
    }

    actions
    {
        area(Reporting)
        {
            action(PrintSelected)
            {
                Caption = 'Print Document';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Generates an audit-ready printable report for the selected stock adjustment document.';

                trigger OnAction()
                var
                    AdjHeader: Record "SSK Adjustment Header";
                begin
                    AdjHeader := Rec;
                    AdjHeader.SetRecFilter();
                    Report.Run(Report::"SSK Stock Adjustment Report", true, false, AdjHeader);
                end;
            }
        }
    }
}
