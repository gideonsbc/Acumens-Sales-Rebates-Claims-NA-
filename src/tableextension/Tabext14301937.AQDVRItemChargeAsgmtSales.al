tableextension 14301937 "AQD CR ItemChrgAsgmtSales Ext" extends "Item Charge Assignment (Sales)"
{
    fields
    {
        field(19301910; "AQD Cust Rebate Doc No."; Code[20])
        {
            Caption = 'Customer Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19301920; "AQD Cust Rebate Doc Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Customer Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19301930; "AQD Cust Rebate Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Customer Rebate Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}