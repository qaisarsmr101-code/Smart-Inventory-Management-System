namespace SmartStock.Setup;

enum 50102 "SSK Document Status"
{
    Extensible = true;
    Caption = 'Document Status';

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; PendingApproval)
    {
        Caption = 'Pending Approval';
    }
    value(2; Approved)
    {
        Caption = 'Approved';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
    value(4; Posted)
    {
        Caption = 'Posted';
    }
}

