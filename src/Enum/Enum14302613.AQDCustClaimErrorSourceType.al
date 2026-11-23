enum 14302613 "AQD CustClaim Error SourceType"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;

    value(0; "")
    {
        Caption = '';
    }
    value(1; "Order Posting")
    {
        Caption = 'Order Posting';
    }
    value(2; "Claim Creation")
    {
        Caption = 'Claim Creation';
    }
    value(3; "Claim Export")
    {
        Caption = 'Claim Export';
    }
    value(4; "Claim Rejected")
    {
        Caption = 'Claim Rejected';
    }
    value(5; "Claim Credit Creation")
    {
        Caption = 'Claim Credit Creation';
    }
}