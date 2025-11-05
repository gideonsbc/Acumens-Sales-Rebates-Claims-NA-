table 14301915 "AQD CustRbt RebateCustomerType"
{
    Caption = 'Rebate Customer Type';
    LookupPageID = "AQD Cust Rebate Customer Types";
    DrillDownPageId = "AQD Cust Rebate Customer Types";
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