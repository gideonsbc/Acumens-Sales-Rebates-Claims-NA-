enum 14302616 "AQD CustClmPrcMthClaimLineType"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Cost of Good Sold")
    {
        Caption = 'Cost of Good Sold';
    }
    value(2; "Delivery Commission")
    {
        Caption = 'Delivery Commission';
    }
    value(3; "Discount")
    {
        Caption = 'Discount';
    }
    value(4; "Variance")
    {
        Caption = 'Variance';
    }
}