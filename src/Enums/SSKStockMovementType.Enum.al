namespace SmartStock.Enums;

enum 50101 "SSK Stock Movement Type"
{
    Extensible = true;
    Caption = 'Stock Movement Type';

    value(0; PositiveAdjustment)
    {
        Caption = 'Positive Adjustment (Stock In)';
    }
    value(1; NegativeAdjustment)
    {
        Caption = 'Negative Adjustment (Stock Out)';
    }
}
