tableextension 14301927 "AQD CustRbt PurchRcptHdr Ext" extends "Purch. Rcpt. Header"
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