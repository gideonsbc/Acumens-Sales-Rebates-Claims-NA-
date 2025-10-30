tableextension 14301923 "AQD CustRbt VendLdgrEntry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14301910; "AQD Rebate Journal"; Boolean)
        {
            Caption = 'Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD State"; Text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(14301960; "AQD Rebate Document Type"; Enum "AQD Rebate Document Type")
        {
            Caption = 'Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301970; "AQD Rebate Document No."; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14301980; "AQD Journal Document No."; Code[20])
        {
            Caption = 'AEC Journal Document No.';
            DataClassification = CustomerContent;
        }
    }
}

