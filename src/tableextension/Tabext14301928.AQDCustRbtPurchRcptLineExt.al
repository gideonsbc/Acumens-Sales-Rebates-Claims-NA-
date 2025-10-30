tableextension 14301928 "AQD CustRbt PurchRcptLineExt" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(14277010; "AQD Cust Rebate Doc No."; Code[20])
        {
            Caption = 'Customer Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14277020; "AQD Cust Rebate Doc Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Customer Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}