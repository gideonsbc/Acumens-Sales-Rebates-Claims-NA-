tableextension 14301927 "AQD CustRbt PurchCrMemoHdr Ext" extends "Purch. Cr. Memo Hdr."
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