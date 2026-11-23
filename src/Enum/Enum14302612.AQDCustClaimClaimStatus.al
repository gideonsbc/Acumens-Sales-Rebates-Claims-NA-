enum 14302612 "AQD Cust Claim Claim Status"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Created)
    {
        Caption = 'Created';
    }
    value(2; Submitted)
    {
        Caption = 'Submitted';
    }
    value(3; Approved)
    {
        Caption = 'Approved';
    }
    value(4; "Rejected")
    {
        Caption = 'Rejected';
    }
    value(5; "Order Posted")
    {
        Caption = 'Order Posted';
    }
    value(6; "Credit Posted")
    {
        Caption = 'Credit Posted';
    }
}