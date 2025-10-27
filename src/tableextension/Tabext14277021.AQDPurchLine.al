tableextension 14277021 "AQD Purchase Line Ext" extends "Purchase Line"
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
            Caption = 'Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}