tableextension 14301926 "AQD CustRbt PurchCrMemoLineExt" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(14301910; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Customer Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14301920; "AQD Cust Rebate Doc Line No"; Integer)
        {
            Caption = 'Customer Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}