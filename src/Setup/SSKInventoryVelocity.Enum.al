namespace SmartStock.Setup;

enum 50100 "SSK Inventory Velocity"
{
    Extensible = true;
    Caption = 'Inventory Velocity';

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; FastMoving)
    {
        Caption = 'A - Fast Moving';
    }
    value(2; MediumMoving)
    {
        Caption = 'B - Medium Moving';
    }
    value(3; SlowMoving)
    {
        Caption = 'C - Slow Moving';
    }
    value(4; NonMoving)
    {
        Caption = 'D - Non-Moving / Dead Stock';
    }
}
