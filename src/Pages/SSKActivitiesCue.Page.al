namespace SmartStock.Pages;

using Microsoft.Inventory.Item;
using SmartStock.Enums;
using SmartStock.Tables;

page 50105 "SSK Activities Cue"
{
    Caption = 'SmartStock Activities';
    PageType = CardPart;
    SourceTable = "SSK Activities Cue";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup("Stock Adjustments")
            {
                Caption = 'Stock Adjustments';

                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "SSK Stock Adj. List";
                    ToolTip = 'Specifies the number of adjustment documents awaiting supervisor authorization.';
                }
                field("Draft Adjustments"; Rec."Draft Adjustments")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "SSK Stock Adj. List";
                    ToolTip = 'Specifies the number of adjustment documents currently in draft status.';
                }

                actions
                {
                    action(NewAdjustment)
                    {
                        Caption = 'New Adjustment';
                        Image = NewDocument;
                        ApplicationArea = All;
                        RunObject = page "SSK Stock Adjustment";
                        RunPageMode = Create;
                        ToolTip = 'Creates a new SmartStock inventory adjustment document.';
                    }
                }
            }
            cuegroup("Inventory Health")
            {
                Caption = 'Inventory Health';

                field("Low Stock Items"; Rec."Low Stock Items")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Item List";
                    ToolTip = 'Specifies the count of active items whose available stock has breached their minimum safety stock threshold.';
                }
                field("Out of Stock Items"; Rec."Out of Stock Items")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Item List";
                    ToolTip = 'Specifies the count of managed inventory items with zero or depleted stock.';
                }
            }
            cuegroup("Batch & Expiry Governance")
            {
                Caption = 'Batch & Expiry Governance';

                field("Expired Batches"; Rec."Expired Batches")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "SSK Alert Log List";
                    ToolTip = 'Specifies the number of tracked lots or batches that have exceeded their designated expiration date.';
                }
                field("Batches Expiring in 30 Days"; Rec."Batches Expiring in 30 Days")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "SSK Alert Log List";
                    ToolTip = 'Specifies lots or batches reaching expiration within the next 30 calendar days.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshMetrics)
            {
                Caption = 'Refresh Metrics';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Recalculates inventory cues and alert thresholds in real-time.';

                trigger OnAction()
                begin
                    Rec.CalculateCueValues();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.CalculateCueValues();
    end;
}
