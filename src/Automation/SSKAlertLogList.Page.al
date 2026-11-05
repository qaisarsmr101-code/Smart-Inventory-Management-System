namespace SmartStock.Automation;

page 50107 "SSK Alert Log List"
{
    Caption = 'SmartStock Alert Log';
    PageType = List;
    SourceTable = "SSK Alert Log";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique log entry identifier.';
                }
                field("Alert DateTime"; Rec."Alert DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the alert was triggered.';
                }
                field("Severity"; Rec."Severity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity of the alert: Info, Warning, or Critical.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the affected inventory item.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the item description.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location where the threshold or expiry breach was detected.';
                }
                field("Message"; Rec."Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Detailed description of the stock anomaly or alert.';
                }
                field("Acknowledged"; Rec."Acknowledged")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a warehouse supervisor has reviewed and acknowledged this warning.';
                }
                field("Acknowledged By User ID"; Rec."Acknowledged By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who acknowledged the alert.';
                }
                field("Acknowledged DateTime"; Rec."Acknowledged DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the alert was acknowledged.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AcknowledgeSelected)
            {
                Caption = 'Acknowledge';
                Image = Approve;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Marks the selected alert entries as acknowledged.';

                trigger OnAction()
                var
                    AlertLog: Record "SSK Alert Log";
                begin
                    CurrPage.SetSelectionFilter(AlertLog);
                    if AlertLog.FindSet() then
                        repeat
                            AlertLog.Validate(Acknowledged, true);
                            AlertLog.Modify(true);
                        until AlertLog.Next() = 0;
                end;
            }
            action(PurgeAcknowledged)
            {
                Caption = 'Purge Acknowledged Alerts';
                Image = Delete;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Permanently cleans up acknowledged historical alert entries to optimize database storage.';

                trigger OnAction()
                var
                    AlertLog: Record "SSK Alert Log";
                begin
                    if Confirm(ConfirmPurgeQst, false) then begin
                        AlertLog.SetRange(Acknowledged, true);
                        AlertLog.DeleteAll(true);
                        Message(PurgeSuccessMsg);
                    end;
                end;
            }
        }
    }

    var
        ConfirmPurgeQst: Label 'Are you sure you want to permanently delete all acknowledged alert log entries?';
        PurgeSuccessMsg: Label 'Acknowledged alert entries successfully purged.';
}
