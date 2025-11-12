table 14301916 "AQD Cust Rebate Program Code"
{
    Caption = 'Customer Rebate Program Codes';
    LookupPageID = "AQD Cust Rebate Program Codes";
    DrillDownPageId = "AQD Cust Rebate Program Codes";
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
        field(4; "Customer Rebate Posting Type"; enum "AQD Cust Rebate Posting Type")
        {
            Caption = 'Customer Rebate Posting Type';
        }
        field(5; "Customer Default Rebate %"; Decimal)
        {
            Caption = 'Default Rebate %';
            MaxValue = 100;
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Customer Default Rebate Type");
            end;
        }
        field(6; "Customer Default Rebate Type"; Option)
        {
            Caption = 'Default Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;

            trigger OnValidate()
            begin
                IF Rec."Customer Default Rebate Type" <> xRec."Customer Default Rebate Type" THEN BEGIN
                    Rec."Customer Default Rebate %" := 0;
                    Rec."Customer Def Rebate Per Unit" := 0;
                END;
            end;
        }
        field(7; "Customer Def Rebate Per Unit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Rebate Per Unit';
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Customer Default Rebate Type");
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
        fieldgroup(DropDown; "Code", Description, "Customer Rebate Posting Type")
        {
        }

        fieldgroup(Brick; "Code", Description, "Customer Rebate Posting Type")
        {
        }
    }
}