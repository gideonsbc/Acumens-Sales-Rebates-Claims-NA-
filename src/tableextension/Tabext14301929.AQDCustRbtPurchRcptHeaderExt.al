tableextension 14301929 "AQD CustRbt PurchRcptHdr Ext" extends "Purch. Rcpt. Header"
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