enum 14302615 "AQD CustClmPrcMthCreateClaimOn"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;

    value(0; "Manual")
    {
        Caption = 'Manual';
    }
    value(1; "Invoicing Order")
    {
        Caption = 'Invoicing Order';
    }
    value(2; "Batch Execution")
    {
        Caption = 'Batch Execution';
    }
}