tableextension 14301936 "AQD CR ItemChrgAsgmtPurch Ext" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(19301910; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Cust Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19301920; "AQD Cust Rebate Doc Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Cust Rebate Document Line No.';
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