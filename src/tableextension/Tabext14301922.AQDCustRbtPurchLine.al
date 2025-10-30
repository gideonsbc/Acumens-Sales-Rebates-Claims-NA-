tableextension 14301922 "AQD CustRbt Purchase Line Ext" extends "Purchase Line"
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
            Caption = 'Customer Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}