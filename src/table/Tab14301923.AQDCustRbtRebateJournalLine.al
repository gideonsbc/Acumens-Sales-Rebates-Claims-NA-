table 14301923 "AQD Cust Rebate Journal Line"
{
    DataClassification = CustomerContent;
    fields
    {
        field(14277004; "AQDUser ID"; Code[50])
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
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(14277005; "AQDLine No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(14277006; "AQDRebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
            end;
        }
        field(14277007; "AQDRebate Type"; Option)
        {
            Caption = 'Pay-To Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
        }
        field(14277008; AQDName; Text[100])
        {
            Caption = 'Name';
        }
        field(14277009; AQDState; Text[30])
        {
            Caption = 'State';
        }
        field(14277010; "AQDLocation Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(14277011; "AQDLocation Name"; Text[100])
        {
            CalcFormula = Lookup(Location.Name WHERE(Code = FIELD("AQDLocation Code")));
            Caption = 'Location Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277012; "AQDShortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(14277013; "AQDShortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14277014; "AQDDocument Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = ' ,Invoice,Credit Memo,Adjustment';
            OptionMembers = " ",Invoice,"Credit Memo",Adjustment;
        }
        field(14277015; "AQDDocument No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(14277016; "AQDCustomer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(14277017; "AQDCustomer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(14277018; "AQDBill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(14277019; "AQDBill-to Customer Name"; Text[100])
        {
            Caption = 'Bill-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
        }
        field(14277020; "AQDBase Amount"; Decimal)
        {
            Caption = 'Base Amount';
            Editable = false;
        }
        field(14277021; "AQDRebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Rebate Amount';
            Editable = false;
        }
        field(14277022; "AQDProfit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Profit Amount';
            Editable = false;
        }
        field(14277023; "AQDStart Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(14277024; "AQDEnd Date"; Date)
        {
            Caption = 'End Date';
        }
        field(14277025; "AQDRun For"; Option)
        {
            Caption = 'Run For';
            OptionCaption = 'Review,Process';
            OptionMembers = Review,Process;
        }
        field(14277026; "AQDPayee Type"; Option)
        {
            Caption = 'Payee Type';
            Editable = false;
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Vendor,W2 Employee';
            OptionMembers = " ","1099 Vendor","W2 Employee";
        }
    }

    keys
    {
        key(Key1; "AQDUser ID", "AQDLine No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

