enum 14301913 "AQD Customer Rebate Line Type"
{
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(2; "Resource")
    {
        Caption = 'Resource';
    }
    value(3; "Fixed Asset")
    {
        //Caption = 'Fixed Asset';
        Caption = '';
        ObsoleteState = Pending;
        ObsoleteReason = 'Removed from Page to Disable User Access';
        ObsoleteTag = '25.1023.0.10';
    }
    value(4; "Charge (Item)")
    {
        //Caption = 'Charge (Item)';
        Caption = '';
        ObsoleteState = Pending;
        ObsoleteReason = 'Removed from Page to Disable User Access';
        ObsoleteTag = '25.1023.0.10';
    }
    value(5; "Rebate Category")
    {
        Caption = 'Rebate Category';
    }
}