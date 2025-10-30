tableextension 14301921 "AQD CustRbt Purchase Hdr Ext" extends "Purchase Header"
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