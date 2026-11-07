namespace SmartStock.Pages;

using SmartStock.Codeunits;
using SmartStock.Reports;
using SmartStock.Tables;

page 50102 "SSK Stock Adjustment"
{
    Caption = 'SmartStock Adjustment Document';
    PageType = Document;
    SourceTable = "SSK Adjustment Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique document number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which the adjustment will be registered in the Item Ledger.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default warehouse location for this adjustment document.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the operational reason code driving this stock adjustment.';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an explanatory comment that will be passed into the Item Ledger Entry description.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the workflow status of this adjustment document.';
                }
            }
            part(Lines; "SSK Stock Adj. Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(ApprovalAndTotals)
            {
                Caption = 'Approval & Totals';

                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the aggregate quantity across all adjustment lines.';
                }
                field("Total Cost Amount"; Rec."Total Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the total financial inventory impact of this adjustment.';
                }
                field("Created By User ID"; Rec."Created By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who originated this stock adjustment.';
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when this document was created.';
                }
                field("Approved By User ID"; Rec."Approved By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the supervisor who authorized this adjustment.';
                }
                field("Approved DateTime"; Rec."Approved DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this document was approved.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubmitForApproval)
            {
                Caption = 'Submit for Approval';
                Image = SendApprovalRequest;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Submits the document for supervisor review or auto-approves if within the authorized threshold.';

                trigger OnAction()
                var
                    SmartStockSetup: Record "SSK SmartStock Setup";
                    AdjReason: Record "SSK Adjustment Reason";
                    RequiresApproval: Boolean;
                begin
                    Rec.TestField(Status, Rec.Status::Draft);
                    Rec.CalcFields("Total Cost Amount");

                    SmartStockSetup.GetRecordOnce();
                    if (SmartStockSetup."Approval Threshold Amount" > 0) and (Rec."Total Cost Amount" > SmartStockSetup."Approval Threshold Amount") then
                        RequiresApproval := true;

                    if Rec."Reason Code" <> '' then
                        if AdjReason.Get(Rec."Reason Code") and AdjReason."Requires Supervisor Approval" then
                            RequiresApproval := true;

                    if RequiresApproval then begin
                        Rec.Status := Rec.Status::PendingApproval;
                        Rec.Modify(true);
                        Message(SubmittedForApprovalMsg, Rec."No.");
                    end else begin
                        Rec.Status := Rec.Status::Approved;
                        Rec."Approved By User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."Approved By User ID"));
                        Rec."Approved DateTime" := CurrentDateTime();
                        Rec.Modify(true);
                        Message(AutoApprovedMsg, Rec."No.");
                    end;
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                Image = Approve;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Authorizes the stock adjustment for posting.';

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::PendingApproval);
                    Rec.Status := Rec.Status::Approved;
                    Rec."Approved By User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."Approved By User ID"));
                    Rec."Approved DateTime" := CurrentDateTime();
                    Rec.Modify(true);
                    Message(ApprovedMsg, Rec."No.");
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                Image = Reject;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Rejects the adjustment request, preventing it from being posted.';

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::PendingApproval);
                    Rec.Status := Rec.Status::Rejected;
                    Rec.Modify(true);
                    Message(RejectedMsg, Rec."No.");
                end;
            }
            action(Reopen)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                ApplicationArea = All;
                ToolTip = 'Reopens a rejected or approved document back to Draft status for amendments.';

                trigger OnAction()
                begin
                    if Rec.Status = Rec.Status::Posted then
                        Error(CannotReopenPostedErr);

                    Rec.Status := Rec.Status::Draft;
                    Rec."Approved By User ID" := '';
                    Rec."Approved DateTime" := 0DT;
                    Rec.Modify(true);
                end;
            }
            action(Post)
            {
                Caption = 'Post';
                Image = PostOrder;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'F9';
                ToolTip = 'Posts the adjustment document through the standard Business Central Item Ledger pipeline.';

                trigger OnAction()
                var
                    PostCodeunit: Codeunit "SSK Stock Adjustment Post";
                begin
                    PostCodeunit.PostAdjustment(Rec);
                end;
            }
            action(Print)
            {
                Caption = 'Print Document';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Generates an audit-ready printable report for this stock adjustment document.';

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

    var
        SubmittedForApprovalMsg: Label 'Adjustment %1 submitted for supervisor approval.', Comment = '%1=Doc No';
        AutoApprovedMsg: Label 'Adjustment %1 is within threshold and has been auto-approved for posting.', Comment = '%1=Doc No';
        ApprovedMsg: Label 'Adjustment %1 has been approved.', Comment = '%1=Doc No';
        RejectedMsg: Label 'Adjustment %1 has been rejected.', Comment = '%1=Doc No';
        CannotReopenPostedErr: Label 'Posted adjustments cannot be reopened.';
}
