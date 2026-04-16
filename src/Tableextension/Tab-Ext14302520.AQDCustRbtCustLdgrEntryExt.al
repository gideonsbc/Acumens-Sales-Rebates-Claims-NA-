tableextension 14302520 "AQD CustRbt CustLdgrEntry Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

