table 14301941 "AQD Created Customer Rebate"
{
    Caption = 'Created Customer Rebates';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            NotBlank = true;
        }
        field(20; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            Editable = false;
        }
        field(30; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-To Customer No.';
            Editable = false;
        }
        field(35; "Rebate-To Customer No."; Code[20])
        {
            Caption = 'Rebate-To Customer No.';
            Editable = false;
        }
        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Editable = false;
        }
        field(50; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
        }
        field(60; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            Editable = false;
        }
        field(80; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            Editable = false;
        }
        field(90; GlobalBatchID; Code[50])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Rebate No.", "Bill-To Customer No.", "Sell-To Customer No.", "Responsibility Center", "Location Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", GlobalBatchID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Rebate No.", "Bill-To Customer No.")
        {
        }
    }
}