namespace SmartStock.Setup;

enum 50103 "SSK Alert Severity"
{
    Extensible = true;
    Caption = 'Alert Severity';

    value(0; Info)
    {
        Caption = 'Information';
    }
    value(1; Warning)
    {
        Caption = 'Warning';
    }
    value(2; Critical)
    {
        Caption = 'Critical';
    }
}
