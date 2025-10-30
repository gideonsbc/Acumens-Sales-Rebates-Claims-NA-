tableextension 14301926 "AQD CustRbt PurchCrMemoLineExt" extends "Purch. Cr. Memo Line"
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