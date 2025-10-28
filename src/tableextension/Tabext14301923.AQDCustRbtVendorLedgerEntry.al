tableextension 14301923 "AQD CustRbt VendLdgrEntry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14277004; "AQD Rebate Journal"; Boolean)
        {
            Caption = 'Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277005; "AQD Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277006; "AQD Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
            DataClassification = CustomerContent;
        }
        field(14277007; "AQD Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
            DataClassification = CustomerContent;
        }
        field(14277008; "AQD Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14277009; "AQD State"; Text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(14277010; "AQD Rebate Document Type"; Enum "AQD Rebate Document Type")
        {
            Caption = 'Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277011; "AQD Rebate Document No."; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14277012; "AQD Journal Document No."; Code[20])
        {
            Caption = 'AEC Journal Document No.';
            DataClassification = CustomerContent;
        }
    }
}

