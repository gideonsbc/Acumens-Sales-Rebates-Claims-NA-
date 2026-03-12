table 14302513 "AQD Cust Rebate Category Lines"
{
    Caption = 'Customer Rebate Category Lines';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(20; "Rebate Program Code"; Code[10])
        {
            Caption = 'Rebate Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(30; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(40; "Entity Type"; Enum "AQD CR Rebate Entity Type")
        {
            Caption = 'Entity Type';
            Editable = false;
        }
        field(7050; "AQD Use Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From'; // As Temporary Used
        }
        field(7060; "AQD Cust Rebate Posting Type"; enum "AQD CustRebate CostPostingType")
        {
            Caption = 'Cust Rebate Cost Type'; // As Temporary Used
        }
    }
    keys
    {
        key(Key1; "Rebate Category Code", "Line No.")
        {
            Clustered = true;
        }
    }
}