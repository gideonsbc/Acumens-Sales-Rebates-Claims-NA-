table 14277008 "AQD Rebate Cues"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Vendor Rebates"; Integer)
        {
            Caption = 'Vendor Rebates';
            CalcFormula = count("AQD Vendor Rebate Header" where("Posting Date" = field("Date Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(3; "Posted Vendor Rebates"; Integer)
        {
            Caption = 'Posted Vendor Rebates';
            CalcFormula = count("AQD Posted Vend Rebate Header" where("Posting Date" = field("Date Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(4; "Vendor Rebate Details"; Integer)
        {
            Caption = 'Vendor Rebate Details';
            CalcFormula = count("AQD Vendor Rebate Details");
            FieldClass = FlowField;
            Editable = false;
        }
        field(5; "Posted Vendor Rebate Details"; Integer)
        {
            Caption = 'Posted Vendor Rebate Details';
            CalcFormula = count("AQD Posted Ven Reb Details");
            FieldClass = FlowField;
            Editable = false;
        }
        field(20; "Rebate Document Entries"; Integer)
        {
            Caption = 'Rebate Document Entries';
            CalcFormula = count("AQD Rebate Document Entry" where("Document Posting Date" = field("Date Filter"), "Salesperson Code" = field("Salesperson Code Filter"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), State = field("State Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(21; "Rebate Entries"; Integer)
        {
            Caption = 'Rebate Entries';
            CalcFormula = count("AQD Rebate Entry" where("Document Posting Date" = field("Date Filter"), "Salesperson Code" = field("Salesperson Code Filter"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), "State" = field("State Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(22; "Rebate Register"; Integer)
        {
            Caption = 'Rebate Register';
            CalcFormula = count("AQD Rebate Register");
            FieldClass = FlowField;
            Editable = false;
        }
        field(50; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(51; "Salesperson Code Filter"; Code[250])
        {
            Caption = 'Salesperson Code Filter';
            FieldClass = FlowFilter;
        }
        field(52; "Global Dimension 1 Filter"; Code[250])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
        }
        field(53; "Global Dimension 2 Filter"; Code[250])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
        }
        field(54; "Location Filter"; Code[250])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
        }
        field(55; "State Filter"; Text[250])
        {
            Caption = 'State Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}