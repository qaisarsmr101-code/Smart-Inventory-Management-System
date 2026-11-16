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

                group(SSKLiveHealth)
                {
                    Caption = 'Real-Time Health & Reorder';

                    field(SSKAvailableInventory; AvailInventory)
                    {
                        ApplicationArea = All;
                        Caption = 'Available Inventory';
                        ToolTip = 'Displays the net available quantity taking into account inventory on hand, sales orders, purchase orders, and component demand.';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(SSKSuggestedReorderQty; SuggestedReorderQty)
                    {
                        ApplicationArea = All;
                        Caption = 'Suggested Reorder Qty';
                        ToolTip = 'Displays the calculated replenishment quantity needed to restore stock to configured buffer targets.';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        StyleExpr = StockHealthStyle;
                    }
                    field(SSKStockStatus; StockStatusText)
                    {
                        ApplicationArea = All;
                        Caption = 'Stock Health Status';
                        ToolTip = 'Specifies the real-time health of this item evaluated against safety thresholds.';
                        Editable = false;
                        StyleExpr = StockHealthStyle;
                    }
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
                action(SSKAlertHistory)
                {
                    Caption = 'Alert History';
                    Image = Log;
                    ApplicationArea = All;
                    ToolTip = 'Opens the SmartStock Alert Log filtered for this specific item.';
                    RunObject = Page "SSK Alert Log List";
                    RunPageView = sorting("Item No.", "Alert DateTime");
                    RunPageLink = "Item No." = field("No.");
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

    trigger OnAfterGetCurrRecord()
    begin
        UpdateSmartStockMetrics();
    end;

    local procedure UpdateSmartStockMetrics()
    begin
        if not Rec."SSK SmartStock Managed" then begin
            AvailInventory := 0;
            SuggestedReorderQty := 0;
            StockStatusText := 'Not Managed';
            StockHealthStyle := 'Subordinate';
            exit;
        end;

        AvailInventory := Rec.SSKCalcAvailableInventory();
        SuggestedReorderQty := Rec.SSKCalcSuggestedReorderQty();

        if AvailInventory <= 0 then begin
            StockStatusText := 'Out of Stock (Critical)';
            StockHealthStyle := 'Unfavorable';
        end else if Rec.SSKIsBelowReorderPoint() then begin
            StockStatusText := 'Below Safety Stock (Warning)';
            StockHealthStyle := 'Attention';
        end else if (Rec."SSK Max Stock Buffer" > 0) and (AvailInventory > Rec."SSK Max Stock Buffer") then begin
            StockStatusText := 'Overstocked Buffer';
            StockHealthStyle := 'Ambiguous';
        end else begin
            StockStatusText := 'Optimal';
            StockHealthStyle := 'Favorable';
        end;
    end;

    var
        AvailInventory: Decimal;
        SuggestedReorderQty: Decimal;
        StockStatusText: Text[50];
        StockHealthStyle: Text[30];
        StockCriticalMsg: Label 'ATTENTION: Item %1 (%2) is in a CRITICAL reorder state.\Current Available: %3\Safety Threshold: %4', Comment = '%1=No, %2=Desc, %3=Avail, %4=Min';
        StockHealthyMsg: Label 'HEALTHY: Item %1 (%2) is operating above safety threshold.\Current Available: %3\Safety Threshold: %4', Comment = '%1=No, %2=Desc, %3=Avail, %4=Min';
}
