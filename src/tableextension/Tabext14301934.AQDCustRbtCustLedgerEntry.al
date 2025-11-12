tableextension 14301934 "AQD CustRbt CustLdgrEntry Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        field(14301910; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

