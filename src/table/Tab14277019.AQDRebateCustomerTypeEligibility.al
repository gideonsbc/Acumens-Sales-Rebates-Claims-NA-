table 14277019 "AQD RebateCustTypeEligibility"
{
    Caption = 'Rebate Customer Type Eligibility';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Rebate Cust Type Eligib";
    LookupPageId = "AQD Rebate Cust Type Eligib";

    fields
    {
        field(1; "Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            TableRelation = "AQD Rebate Customer Type".Code;

            trigger OnValidate()
            var
                RebateCustomerType: Record "AQD Rebate Customer Type";
            begin
                IF Rec."Rebate Customer Type" <> xRec."Rebate Customer Type" then begin
                    IF RebateCustomerType.GET(Rec."Rebate Customer Type") then
                        Description := RebateCustomerType.Description;
                end;
            end;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(30; "Sales Amount Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Amount Threshold';
        }
        field(950; "Blocked"; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if Blocked then begin
                    "Blocked By" := UserId;
                    "Blocked Date Time" := CurrentDateTime;
                end else begin
                    Clear("Blocked By");
                    Clear("Blocked Date Time");
                end;
            end;
        }
        field(960; "Blocked By"; Code[50])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(970; "Blocked Date Time"; DateTime)
        {
            Caption = 'Blocked Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Rebate Customer Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Rebate Customer Type")
        {
        }
        fieldgroup(Brick; "Rebate Customer Type")
        {
        }
    }
}