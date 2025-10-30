tableextension 14301923 "AQD CustRbt VendLdgrEntry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14301910; "AQD Cust Rebate Journal"; Boolean)
        {
            Caption = 'Cust Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Cust Rebate Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD Customer Rebate Type"; Option)
        {
            Caption = 'Customer Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD CustRbt Location Code"; Code[10])
        {
            Caption = 'Customer Rebate Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD CustRbt State"; Text[30])
        {
            Caption = 'Customer Rebate State';
            DataClassification = CustomerContent;
        }
        field(14301960; "AQD Cust Rebate Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Cust Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301970; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Cust Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14301980; "AQD Cust Journal Document No."; Code[20])
        {
            Caption = 'Cust Rebate Journal Document No.';
            DataClassification = CustomerContent;
        }
    }
}

