tableextension 14277025 "AQD Item Journal Line Ext" extends "Item Journal Line"
{
    fields
    {
        field(14277004; "AQD Rebate Journal"; Boolean)
        {
            Caption = 'Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277012; "AQD Rebate Document Type"; Enum "AQD Rebate Document Type")
        {
            Caption = 'Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277013; "AQD Rebate Document No."; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = CustomerContent;
        }
    }
}

