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

    actions
    {
        area(Processing)
        {
            group(FilterGroup)
            {
                Caption = 'Filter';

                action(FilterDraft)
                {
                    Caption = 'Drafts';
                    Image = FilterLines;
                    ApplicationArea = All;
                    ToolTip = 'Filters the list to display only draft documents.';

                    trigger OnAction()
                    begin
                        Rec.SetRange(Status, Rec.Status::Draft);
                        CurrPage.Update(false);
                    end;
                }
                action(FilterPendingApproval)
                {
                    Caption = 'Pending Approval';
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    ToolTip = 'Filters the list to display only documents awaiting supervisor approval.';

                    trigger OnAction()
                    begin
                        Rec.SetRange(Status, Rec.Status::PendingApproval);
                        CurrPage.Update(false);
                    end;
                }
                action(FilterApproved)
                {
                    Caption = 'Ready to Post';
                    Image = Approve;
                    ApplicationArea = All;
                    ToolTip = 'Filters the list to display only approved documents ready for posting.';

                    trigger OnAction()
                    begin
                        Rec.SetRange(Status, Rec.Status::Approved);
                        CurrPage.Update(false);
                    end;
                }
                action(FilterPosted)
                {
                    Caption = 'Posted Archive';
                    Image = Archive;
                    ApplicationArea = All;
                    ToolTip = 'Filters the list to display posted adjustment history.';

                    trigger OnAction()
                    begin
                        Rec.SetRange(Status, Rec.Status::Posted);
                        CurrPage.Update(false);
                    end;
                }
                action(ShowAll)
                {
                    Caption = 'Show All';
                    Image = ClearFilter;
                    ApplicationArea = All;
                    ToolTip = 'Clears status filters and displays all adjustment documents.';

                    trigger OnAction()
                    begin
                        Rec.Reset();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Reporting)
        {
            action(PrintSelected)
            {
                Caption = 'Print Document';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Report;
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
