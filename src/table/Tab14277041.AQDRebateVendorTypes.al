table 14277041 "AQD Rebate Vendor Type"
{
    Caption = 'Rebate Vendor Type';
    LookupPageID = "AQD Rebate Vendor Types";
    DrillDownPageId = "AQD Rebate Vendor Types";
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