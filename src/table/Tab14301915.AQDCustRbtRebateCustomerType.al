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
        field(30; "Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.CalcFields("Rebate Customer Name");
            end;
        }
        field(40; "Rebate Customer Name"; Text[100])
        {
            Caption = 'Rebate Customer Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = Field("Rebate Customer No")));
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
        fieldgroup(Dropdown; "Code", Description, "Rebate Customer No")
        {
        }
        fieldgroup(Brick; "Code", Description, "Rebate Customer No")
        {

        }
    }
}