table 14301915 "AQD Rebate Customer Category"
{
    Caption = 'Rebate Customer Category';
    LookupPageID = "AQD Rebate Customer Categories";
    DrillDownPageId = "AQD Rebate Customer Categories";
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
            CalcFormula = lookup(Customer.Name where("No." = Field("Rebate Customer No")));
        }
        field(45; "Rebate Vendor No."; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.CalcFields("Rebate Vendor Name");
            end;
        }
        field(46; "Rebate Vendor Name"; Text[100])
        {
            Caption = 'Rebate Vendor Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = Field("Rebate Vendor No.")));
        }
        field(50; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
            ObsoleteReason = 'Removed';
            ObsoleteState = Pending;
            ObsoleteTag = 'Discontinued from 25.1023.0.3';
        }
        field(60; "Bal. G/L Account No."; Code[20])
        {
            Caption = 'Bal. G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
            ObsoleteReason = 'Removed';
            ObsoleteState = Pending;
            ObsoleteTag = 'Discontinued from 25.1023.0.3';
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