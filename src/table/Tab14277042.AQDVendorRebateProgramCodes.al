table 14277042 "AQD Rebate Program Code"
{
    Caption = 'Rebate Program Codes';
    LookupPageID = "AQD Rebate Program Codes";
    DrillDownPageId = "AQD Rebate Program Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Rebate Posting Type"; enum "AQD Rebate Posting Type")
        {
            Caption = 'Rebate Posting Type';
        }
        field(5; "Vendor Default Rebate %"; Decimal)
        {
            Caption = 'Default Rebate %';
            MaxValue = 100;
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Vendor Default Rebate Type");
            end;
        }
        field(6; "Vendor Default Rebate Type"; Option)
        {
            Caption = 'Default Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;

            trigger OnValidate()
            begin
                IF Rec."Vendor Default Rebate Type" <> xRec."Vendor Default Rebate Type" THEN BEGIN
                    Rec."Vendor Default Rebate %" := 0;
                    Rec."Vendor Def Rebate Per Quantity" := 0;
                END;
            end;
        }
        field(7; "Vendor Def Rebate Per Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Rebate Per Quantity';
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Vendor Default Rebate Type");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Rebate Posting Type")
        {
        }

        fieldgroup(Brick; "Code", Description, "Rebate Posting Type")
        {
        }
    }
}