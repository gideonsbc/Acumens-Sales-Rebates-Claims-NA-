table 14301911 "AQD Customer Rebate User Setup"
{
    Caption = 'Customer Rebate User Setup';
    DrillDownPageId = "AQD Customer Rebate User Setup";
    LookupPageId = "AQD Customer Rebate User Setup";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.DisplayUserInformation("User ID");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Selection";
            begin
                UserMgt.ValidateUserName("User ID");
            end;
        }
        field(14277005; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            Editable = false;
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
            end;
        }
        field(14277006; "Rebate Role"; Option)
        {
            Caption = 'Rebate Role';
            OptionCaption = 'Salesperson,Sales Manager,Admin';
            OptionMembers = Salesperson,"Sales Manager",Admin;
        }
        field(14277007; "Global Dimension 1 Filter"; Code[250])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = false;
        }
        field(14277008; "Global Dimension 2 Filter"; Code[250])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;
        }
        field(14277009; "Location Filter"; Code[250])
        {
            Caption = 'Location Filter';
        }
        field(14277010; "Salesperson Code Filter"; Code[250])
        {
            Caption = 'Salesperson/Purch. Code Filter';
        }
        field(14277011; "State Filter"; Text[250])
        {
            Caption = 'State Filter';
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}