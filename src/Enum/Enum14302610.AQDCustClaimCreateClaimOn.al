enum 14302610 "AQD CustClaim Create Claim On"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;

    value(0; "Manual")
    {
        Caption = 'Manual';
    }
    value(1; "Order Release")
    {
        Caption = 'Order Release';
    }
    value(2; "Batch Execution")
    {
        Caption = 'Batch Execution';
    }
}