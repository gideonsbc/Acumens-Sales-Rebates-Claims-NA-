table 14302708 "AQD Tiered Rebate Rates"
{
    Caption = 'Tiered Rebate Rates';
    DataClassification = CustomerContent;
    DrillDownPageID = "AQD Tiered Rebate Rates";
    LookupPageID = "AQD Tiered Rebate Rates";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            TableRelation = "AQD Sales Rebates Rate New";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Rebate Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rebate Rate Type';
        }
        field(11; "Program Code"; Code[20])
        {
            Caption = 'Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(24; Basis; Enum "AQD Rebate Rate Basis Type")
        {
            Caption = 'Basis';

        }
        field(30; "Base Amount %"; Decimal)
        {
            Caption = 'Base Amount %';
            DecimalPlaces = 2 : 2;
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;


        }
        field(200; "Lower Limit"; Decimal)
        {
            caption = 'Lower Limit';
            DataClassification = customerContent;
        }
        field(210; "Upper Limit"; Decimal)
        {
            caption = 'Upper Limit';
            DataClassification = customerContent;
        }
        field(50; "Rebate %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate %';
            DecimalPlaces = 2 : 2;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                // if Rec."Manager Commission %" = 0 then
                //     Rec.Validate("Manager Commission %", Rec."Commission %");
                //CopyCommissionSetupFromSalesperson1ToSalesperson2();
            end;
        }
    }
    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Rebate Rate Type", "Program Code", "Basis")
        {
        }
    }
}