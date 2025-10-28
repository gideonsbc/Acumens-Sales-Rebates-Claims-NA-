table 14301924 "AQD Customer Rebate Register"
{
    Caption = 'Customer Rebate Register';
    DrillDownPageID = "AQD Rebate Register";
    LookupPageID = "AQD Rebate Register";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "AQDEntry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(14277005; "AQDRebate Type"; Option)
        {
            Caption = 'Pay-To Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
        }
        field(14277006; "AQDRebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
        }
        field(14277007; "AQDLocation Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(14277008; "AQDShortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(14277009; "AQDShortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14277010; AQDState; Text[30])
        {
            Caption = 'State';
        }
        field(14277011; "AQDDocument Type"; Enum "AQD Rebate Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(14277012; "AQDDocument No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = IF ("AQDDocument Type" = CONST(Invoice)) "Sales Invoice Header"."No."
            ELSE
            IF ("AQDDocument Type" = CONST("Credit Memo")) "Sales Cr.Memo Header"."No.";
        }
        field(14277013; "AQDPayee Type"; Option)
        {
            Caption = 'Payee Type';
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Vendor,W2 Employee';
            OptionMembers = " ","1099 Vendor","W2 Employee";
        }
        field(14277014; "AQDExternal Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(14277015; "AQDPayment Date"; Date)
        {
            Caption = 'Payment Date';
        }
        field(14277016; "AQDPayment Ref. No."; Code[20])
        {
            Caption = 'Payment Ref. No';
        }
        field(14277017; "AQDStart Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(14277018; "AQDEnd Date"; Date)
        {
            Caption = 'End Date';
        }
        field(14277019; "AQDBase Amount"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Base Amount" WHERE("Rebate Register No." = FIELD("AQDEntry No.")));
            Caption = 'Base Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277020; "AQDRebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Rebate Amount" WHERE("Rebate Register No." = FIELD("AQDEntry No.")));
            Caption = 'Rebate Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277021; "AQDProfit Amount"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Profit Amount" WHERE("Rebate Register No." = FIELD("AQDEntry No.")));
            Caption = 'Profit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277022; "AQDBatch Name"; Code[50])
        {
            Caption = 'Batch Name';
        }
        field(14277023; "AQDCreation DateTime"; DateTime)
        {
            Caption = 'Creation DateTime';
            Editable = false;
        }
        field(14277024; "AQDCreated By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            Editable = false;
            TableRelation = User."User Name";
        }
        field(14277025; AQDStatus; Option)
        {
            CalcFormula = Min("AQD Cust Rebate Document Entry"."Payment Status" WHERE("Rebate Register No." = FIELD("AQDEntry No.")));
            Caption = 'Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Approved,Journal,Posted,Paid';
            OptionMembers = " ",Approved,Journal,Posted,Paid;
        }
        field(14277026; AQDVoided; Boolean)
        {
            Caption = 'Voided';
            Editable = false;
        }
        field(14277027; "AQDVoided DateTime"; DateTime)
        {
            Caption = 'Voided DateTime';
            Editable = false;
        }
        field(14277028; "AQDVoided By User ID"; Code[50])
        {
            Caption = 'Voided By User ID';
            Editable = false;
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(Key1; "AQDEntry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

