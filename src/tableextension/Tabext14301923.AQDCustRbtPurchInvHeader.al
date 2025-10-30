tableextension 14301923 "AQD CustRbt Purch Inv Hdr Ext" extends "Purch. Inv. Header"
{
    fields
    {
        field(14301910; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Customer Rebate No.';
            DataClassification = CustomerContent;
        }
    }
}