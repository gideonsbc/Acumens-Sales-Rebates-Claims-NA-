table 14301910 "AQD Acumens CustRbtClaim Setup"
{
    Caption = 'Acumens Customer Rebates & Claims Setup';
    DrillDownPageId = "AQD Acumens CustRbtClaim Setup";
    LookupPageId = "AQD Acumens CustRbtClaim Setup";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(20; "Item Rebate Enabled"; Boolean)
        {
            Caption = 'Item Rebate Enabled';
        }
        field(30; "Resource Rebate Enabled"; Boolean)
        {
            Caption = 'Resource Rebate Enabled';
        }
        field(40; "G/L Account Rebate Enabled"; Boolean)
        {
            Caption = 'G/L Account Rebate Enabled';
        }
        field(70; "Min GP% for Customer Rebate"; Decimal)
        {
            Caption = 'Minimum Gross Profit % for Customer Rebate';
            MaxValue = 100;
            MinValue = 0;
        }
        field(80; "Exclude Credit Memo"; Boolean)
        {
            Caption = 'Exclude Credit Memo';
        }
        field(90; "Start Date"; Date)
        {
            Caption = 'Start Date';
            ObsoleteState = Pending;
            ObsoleteReason = 'Duplicate Field';
            ObsoleteTag = 'Discontined from 25.1023.0.7';
        }
        field(180; "Sales Journal Template Name"; Code[10])
        {
            Caption = 'Rebate Sales Jnl Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Sales));
        }
        field(190; "Sales Journal Batch Name"; Code[10])
        {
            Caption = 'Rebate Sales Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Sales Journal Template Name"),
                                                             "AQD Customer Rebate" = CONST(true));
        }
        field(200; "Old Documents Updated"; Boolean)
        {
            Caption = 'Old Documents Updated';
            Editable = false;
        }
        field(240; "Customer Rebate Document Nos"; Code[20])
        {
            Caption = 'Customer Rebate Document Nos';
            TableRelation = "No. Series";
        }
        field(270; "Post Customer Rebates for"; Enum "AQD Post Customer Rebates for")
        {
            Caption = 'Post Customer Rebates for';
        }
        field(340; "Default Rebate Program Code"; Code[10])
        {
            Caption = 'Default Cust Rebate Program Code';
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(355; "Sales Item Charge No."; Code[20])
        {
            Caption = 'Sales Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(360; "Default Setup Rebate Type"; Enum "AQD Customer Rebate Line Type")
        {
            Caption = 'Default Setup Rebate Type';
        }
        field(375; "Auto Process Customer Rebates"; Boolean)
        {
            Caption = 'Auto Process Customer Rebates';
            InitValue = true;
        }
        field(378; "Post Rebates by Bill-To Cust"; Boolean)
        {
            Caption = 'Post Rebates by Bill-To Customer';
        }
        field(380; "Customer Rebate Start Date"; Date)
        {
            Caption = 'Rebate Calculation Start Date';
        }
        field(381; "Rebate Calc Start Invoice No."; Code[20])
        {
            Caption = 'Rebate Calculation Start Invoice #';
        }
        field(382; "Rebate Calc Start CM No."; Code[20])
        {
            Caption = 'Rebate Calculation Start CM #';
        }
        field(385; "Rebate Payable Ac"; Enum "AQD Rebate Payable AC")
        {
            Caption = 'Rebate Payable A/C';
        }
        field(420; "Customer Rebate Source Code"; Code[10])
        {
            Caption = 'Customer Rebate Source Code';
            TableRelation = "Source Code";
        }
        field(490; "Bill-To Rebate Customer"; Enum "AQD Bill-To Rebate Customer")
        {
            Caption = 'Bill-To Rebate Customer';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF Rec."Bill-To Rebate Customer" <> Rec."Bill-To Rebate Customer"::"Customer Card Setup" THEN
                    Rec."Default Rebate Customer No" := '';
            end;
        }
        field(500; "Default Rebate Posting Type"; enum "AQD CustRebate CostPostingType")
        {
            Caption = 'Rebate Posting Type';
            DataClassification = CustomerContent;
        }
        field(510; "Default Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Bill-To Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
}