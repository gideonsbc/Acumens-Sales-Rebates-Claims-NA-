tableextension 14301921 "AQD CustRbt Gen. Jnl Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(14301910; "AQD Cust Rebate Journal"; Boolean)
        {
            Caption = 'Cust Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Type"; Option)
        {
            Caption = 'Cust Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD Cust Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD CustRbt Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD CustRbt Location Name"; Text[100])
        {
            CalcFormula = Lookup(Location.Name WHERE(Code = FIELD("AQD CustRbt Location Code")));
            Caption = 'Location Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14301960; "AQD CustRbt State"; Text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(14301970; "AQD CustRbt Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301980; "AQD CustRbt Profit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Customer Rebate Profit Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301990; "AQD Cust Rebate Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Cust Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302000; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Cust Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14302010; "AQD Cust Journal Document No."; Code[20])
        {
            Caption = 'Cust Journal Document No.';
            DataClassification = CustomerContent;
        }
        field(14302020; "AQD Cust Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Cust Rebate Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

