tableextension 14277017 "AQD Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(14277004; "AQD Rebate Journal"; Boolean)
        {
            Caption = 'Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277005; "AQD Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
            DataClassification = CustomerContent;
        }
        field(14277006; "AQD Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
            DataClassification = CustomerContent;
        }
        field(14277007; "AQD Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14277008; "AQD Location Name"; Text[100])
        {
            CalcFormula = Lookup(Location.Name WHERE(Code = FIELD("AQD Location Code")));
            Caption = 'Location Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277009; "AQD State"; Text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(14277010; "AQD Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277011; "AQD Profit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Profit Amount';
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
        field(14277014; "AQD Journal Document No."; Code[20])
        {
            Caption = 'Journal Document No.';
            DataClassification = CustomerContent;
        }
        field(14277015; "AQD Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

