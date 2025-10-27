tableextension 14277023 "AQD Purch. Cr. Memo Line Ext" extends "Purch. Cr. Memo Line"
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
    }
}