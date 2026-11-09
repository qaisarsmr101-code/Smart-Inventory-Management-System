namespace SmartStock.Pages;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using SmartStock.Codeunits;
using SmartStock.Reports;
using SmartStock.Tables;

page 50106 "SSK Role Center"
{
    Caption = 'SmartStock Inventory Manager';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(ActivitiesCue; "SSK Activities Cue")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(NewAdjustment)
            {
                Caption = 'New Stock Adjustment';
                Image = NewDocument;
                ApplicationArea = All;
                RunObject = page "SSK Stock Adjustment";
                RunPageMode = Create;
                ToolTip = 'Create a new stock adjustment document.';
            }
        }
        area(Processing)
        {
            action(ScanAlerts)
            {
                Caption = 'Scan Inventory Alerts';
                Image = Calculate;
                ApplicationArea = All;
                RunObject = codeunit "SSK Stock Alert Mgt";
                ToolTip = 'Scan inventory for low stock levels and expiring batches.';
            }
        }
        area(Reporting)
        {
            action(AdjustmentReport)
            {
                Caption = 'Stock Adjustment Document';
                Image = "Report";
                ApplicationArea = All;
                RunObject = report "SSK Stock Adjustment Report";
                ToolTip = 'Generate and print stock adjustment documentation.';
            }
        }
        area(Embedding)
        {
            action(Adjustments)
            {
                Caption = 'Stock Adjustments';
                ApplicationArea = All;
                RunObject = page "SSK Stock Adj. List";
                ToolTip = 'View all stock adjustment documents.';
            }
            action(Items)
            {
                Caption = 'Items';
                ApplicationArea = All;
                RunObject = page "Item List";
                ToolTip = 'View all inventory items.';
            }
            action(Locations)
            {
                Caption = 'Locations';
                ApplicationArea = All;
                RunObject = page "Location List";
                ToolTip = 'View warehouse locations and distribution hubs.';
            }
            action(AlertLog)
            {
                Caption = 'Alert Log';
                ApplicationArea = All;
                RunObject = page "SSK Alert Log List";
                ToolTip = 'View automated low-stock and batch expiry alerts.';
            }
        }
        area(Sections)
        {
            group(SetupGroup)
            {
                Caption = 'Setup & Administration';

                action(SmartStockSetup)
                {
                    Caption = 'SmartStock Setup';
                    ApplicationArea = All;
                    RunObject = page "SSK SmartStock Setup";
                    ToolTip = 'Configure thresholds, warning horizons, and number series.';
                }
                action(AdjustmentReasons)
                {
                    Caption = 'Adjustment Reasons';
                    ApplicationArea = All;
                    RunObject = page "SSK Adjustment Reasons";
                    ToolTip = 'Maintain adjustment reason codes and approval policies.';
                }
            }
        }
    }
}

