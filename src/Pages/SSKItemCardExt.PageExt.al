namespace SmartStock.Pages;

using Microsoft.Inventory.Item;
using SmartStock.Tables;

pageextension 50100 "SSK Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter(InventoryGrp)
        {
            group(SSKSmartStock)
            {
                Caption = 'SmartStock Controls';

                field("SSK SmartStock Managed"; Rec."SSK SmartStock Managed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this item is monitored by SmartStock automated replenishment and low-stock alerts.';
                }
                field("SSK Min Safety Stock"; Rec."SSK Min Safety Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum threshold quantity. If available stock falls to or below this level, reorder alerts are triggered.';
                }
                field("SSK Max Stock Buffer"; Rec."SSK Max Stock Buffer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum target stock level to prevent capital lockup and overstocking.';
                }
                field("SSK Velocity Class"; Rec."SSK Velocity Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the velocity classification (ABC analysis: Fast-moving, Medium, Slow, or Non-Moving).';
                }
                field("SSK Reorder Cycle"; Rec."SSK Reorder Cycle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how frequently this item should be evaluated for purchase or transfer replenishment (e.g. 1W, 1M).';
                }
                field("SSK Total Expired Qty"; Rec."SSK Total Expired Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the total on-hand quantity of this item across all expired lots.';
                }
            }
        }
    }

    actions
    {
        addafter(History)
        {
            group(SSKSmartStockActions)
            {
                Caption = 'SmartStock';

                action(SSKCheckStockHealth)
                {
                    Caption = 'Check Stock Health';
                    Image = CheckList;
                    ApplicationArea = All;
                    ToolTip = 'Evaluates current physical, demand, and incoming quantities against SmartStock safety thresholds.';

                    trigger OnAction()
                    var
                        AvailQty: Decimal;
                    begin
                        AvailQty := Rec.SSKCalcAvailableInventory();
                        if Rec.SSKIsBelowReorderPoint() then
                            Message(StockCriticalMsg, Rec."No.", Rec.Description, AvailQty, Rec."SSK Min Safety Stock")
                        else
                            Message(StockHealthyMsg, Rec."No.", Rec.Description, AvailQty, Rec."SSK Min Safety Stock");
                    end;
                }
                action(SSKNewAdjustment)
                {
                    Caption = 'New Stock Adjustment';
                    Image = AdjustEntries;
                    ApplicationArea = All;
                    ToolTip = 'Creates a new SmartStock stock adjustment request pre-populated for this item.';

                    trigger OnAction()
                    var
                        AdjHeader: Record "SSK Adjustment Header";
                        AdjLine: Record "SSK Adjustment Line";
                        AdjCard: Page "SSK Stock Adjustment";
                    begin
                        AdjHeader.Init();
                        AdjHeader.Insert(true);

                        AdjLine.Init();
                        AdjLine."Document No." := AdjHeader."No.";
                        AdjLine."Line No." := 10000;
                        AdjLine.Validate("Item No.", Rec."No.");
                        AdjLine.Insert(true);

                        AdjCard.SetRecord(AdjHeader);
                        AdjCard.Run();
                    end;
                }
            }
        }
    }

    var
        StockCriticalMsg: Label 'ATTENTION: Item %1 (%2) is in a CRITICAL reorder state.\Current Available: %3\Safety Threshold: %4', Comment = '%1=No, %2=Desc, %3=Avail, %4=Min';
        StockHealthyMsg: Label 'HEALTHY: Item %1 (%2) is operating above safety threshold.\Current Available: %3\Safety Threshold: %4', Comment = '%1=No, %2=Desc, %3=Avail, %4=Min';
}
