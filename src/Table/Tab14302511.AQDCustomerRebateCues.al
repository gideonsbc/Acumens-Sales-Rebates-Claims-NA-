table 14302511 "AQD Customer Rebate Cues"
{
    Caption = 'Sales Rebate Cues';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(20; "Rebate Documents"; Integer)
        {
            Caption = 'Rebate Document';
            CalcFormula = count("AQD Customer Rebate Header" where("Salesperson Code" = field("Salesperson Code Filter"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), "Territory Code" = field("State Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(25; "Posted Rebate Documents"; Integer)
        {
            Caption = 'Posted Rebate Document';
            CalcFormula = count("AQD Posted Cust Rebate Header" where("Salesperson Code" = field("Salesperson Code Filter"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), "Territory Code" = field("State Filter")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(30; "Full Price Claims - Created"; Integer)
        {
            Caption = 'Created';
            CalcFormula = count("AQD Customer Claim Header" Where("Claim Type" = const("Full Price"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Created)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(31; "Full Price Claims - Submitted"; Integer)
        {
            Caption = 'Submitted';
            CalcFormula = count("AQD Customer Claim Header" Where("Claim Type" = const("Full Price"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Submitted)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(32; "Full Price Claims - Approved"; Integer)
        {
            Caption = 'Approved';
            CalcFormula = count("AQD Customer Claim Header" where("Claim Type" = const("Full Price"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Approved)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(33; "Full Price Claims - Completed"; Integer)
        {
            Caption = 'Completed';
            CalcFormula = count("AQD Customer Claim Header" where("Claim Type" = const("Full Price"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const("Credit Posted")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(40; "Price Match Claims - Created"; Integer)
        {
            Caption = 'Created';
            CalcFormula = count("AQD Customer Claim Header" Where("Claim Type" = const("Price Match"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Created)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(41; "Price Match Claims - Submitted"; Integer)
        {
            Caption = 'Submitted';
            CalcFormula = count("AQD Customer Claim Header" Where("Claim Type" = const("Price Match"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Submitted)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(42; "Price Match Claims - Approved"; Integer)
        {
            Caption = 'Approved';
            CalcFormula = count("AQD Customer Claim Header" where("Claim Type" = const("Price Match"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const(Approved)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(43; "Price Match Claims - Completed"; Integer)
        {
            Caption = 'Completed';
            CalcFormula = count("AQD Customer Claim Header" where("Claim Type" = const("Price Match"), "Shortcut Dimension 1 Code" = field("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = field("Global Dimension 2 Filter"), "Location Code" = field("Location Filter"), Status = const("Credit Posted")));
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
            Caption = 'Territory Filter';
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