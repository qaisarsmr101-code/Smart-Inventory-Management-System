namespace SmartStock.Reports;

using SmartStock.Tables;

report 50100 "SSK Stock Adjustment Report"
{
    Caption = 'SmartStock Adjustment Document';
    DefaultRenderingLayout = StandardLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Header; "SSK Adjustment Header")
        {
            RequestFilterFields = "No.", "Posting Date", "Location Code", Status;

            column(DocumentNo; "No.") { }
            column(PostingDate; Format("Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
            column(LocationCode; "Location Code") { }
            column(ReasonCode; "Reason Code") { }
            column(Status; Format(Status)) { }
            column(TotalCostAmount; "Total Cost Amount") { }
            column(TotalQuantity; "Total Quantity") { }
            column(CreatedByUserID; "Created By User ID") { }
            column(ApprovedByUserID; "Approved By User ID") { }
            column(PostingDescription; "Posting Description") { }

            dataitem(Line; "SSK Adjustment Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(LineNo; "Line No.") { }
                column(ItemNo; "Item No.") { }
                column(Description; Description) { }
                column(VariantCode; "Variant Code") { }
                column(AdjustmentType; Format("Adjustment Type")) { }
                column(Quantity; Quantity) { }
                column(UnitOfMeasureCode; "Unit of Measure Code") { }
                column(UnitCost; "Unit Cost") { }
                column(TotalAmount; "Total Amount") { }
                column(LineReasonCode; "Reason Code") { }
                column(LotNo; "Lot No.") { }
                column(ExpirationDate; Format("Expiration Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
            }
        }
    }

    rendering
    {
        layout(StandardLayout)
        {
            Type = RDLC;
            LayoutFile = './src/Reports/SSKStockAdjustment.rdlc';
            Caption = 'Standard Stock Adjustment (RDLC)';
            Summary = 'Default printable layout for SmartStock adjustment vouchers.';
        }
    }
}

