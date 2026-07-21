tableextension 14302531 "AQD Cust Rbt ItemLdgrEntry Ext" extends "Item Ledger Entry"
{
    fields
    {
        field(14302510; "AQD Cust Rebate Amount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Rebate Amount';
            DataClassification = CustomerContent;
        }
    }
}

