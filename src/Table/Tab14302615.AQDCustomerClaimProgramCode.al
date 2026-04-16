table 14302615 "AQD Cust Claim Program Code"
{
    Caption = 'Claim Program Codes';
    LookupPageID = "AQD Cust Claim Program Code";
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
        field(30; "Claim Vendor No."; Code[20])
        {
            Caption = 'Claim Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            BEGIN
                Rec.CalcFields("Claim Vendor Name");
            END;
        }
        field(40; "Claim Vendor Name"; text[100])
        {
            Caption = 'Claim Vendor Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = FIELD("Claim Vendor No.")));
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
    }
}

