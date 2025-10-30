tableextension 14301924 "AQD CustRbt Purch Inv Line Ext" extends "Purch. Inv. Line"
{
    fields
    {
        field(14277010; "AQD Cust Rebate Document No."; Code[20])
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