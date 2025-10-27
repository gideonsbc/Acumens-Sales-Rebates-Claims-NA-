table 14277013 "AQD Rebate Customer Type"
{
    Caption = 'Rebate Customer Type';
    LookupPageID = "AQD Rebate Customer Types";
    DrillDownPageId = "AQD Rebate Customer Types";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
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
        fieldgroup(Dropdown; "Code", Description)
        {
        }
        fieldgroup(Brick; "Code", Description)
        {

        }
    }
}