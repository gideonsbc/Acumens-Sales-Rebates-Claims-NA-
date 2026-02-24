tableextension 14301948 "AQD Cust Rbt ItemLdgrEntry Ext" extends "Item Ledger Entry"
{
    fields
    {
        field(14301910; "AQD Cust Rebate Amount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Customer Rebate Amount';
            DataClassification = CustomerContent;
        }
    }
}

