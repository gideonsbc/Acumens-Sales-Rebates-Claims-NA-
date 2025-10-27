table 14277056 "AQD RebateVendorTypeElig"
{
    Caption = 'Rebate Vendor Type Eligibility';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Rebate Vendor Type Eligib";
    LookupPageId = "AQD Rebate Vendor Type Eligib";

    fields
    {
        field(1; "Rebate Vendor Type"; Code[20])
        {
            Caption = 'Rebate Vendor Code';
            TableRelation = "AQD Rebate Vendor Type".Code;

            trigger OnValidate()
            var
                RebateVendorType: Record "AQD Rebate Vendor Type";
            begin
                IF Rec."Rebate Vendor Type" <> xRec."Rebate Vendor Type" then begin
                    IF RebateVendorType.GET(Rec."Rebate Vendor Type") then
                        Description := RebateVendorType.Description;
                end;
            end;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(30; "Purchase Amount Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Purchase Amount Threshold';
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
        key(Key1; "Rebate Vendor Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Rebate Vendor Type")
        {
        }
        fieldgroup(Brick; "Rebate Vendor Type")
        {
        }
    }
}