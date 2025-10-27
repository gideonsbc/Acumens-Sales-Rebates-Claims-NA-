tableextension 14277024 "AQD Item Charge AsgmtPurch Ext" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(14277010; "AQD Rebate Document No."; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14277020; "AQD Rebate Document Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14277030; "AQD Rebate Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}