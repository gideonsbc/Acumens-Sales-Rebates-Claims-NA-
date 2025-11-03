tableextension 14301936 "AQD CR ItemChrgAsgmtPurch Ext" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(19301910; "AQD Rebate Document No."; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19301920; "AQD Rebate Document Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19301930; "AQD Rebate Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}