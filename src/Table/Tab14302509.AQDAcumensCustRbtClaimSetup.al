table 14302509 "AQD Acumens CustRbtClaim Setup"
{
    Caption = 'Acumens Sales Rebates & Claims Setup';
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
        // field(90; "Start Date"; Date)
        // {
        //     Caption = 'Start Date';
        //     ObsoleteState = Pending;
        //     ObsoleteReason = 'Duplicate Field';
        //     ObsoleteTag = 'Discontined from 25.1023.0.7';
        // }
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
            Caption = 'Sales Rebate Document Nos';
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
            Caption = 'Auto Process Sales Rebates';
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
            Caption = 'Start Rebate After Invoice #';
            TableRelation = "Sales Invoice Header"."No.";
            ValidateTableRelation = false;
        }
        field(382; "Rebate Calc Start CM No."; Code[20])
        {
            Caption = 'Start Rebate After Credit Memo #';
            TableRelation = "Sales Cr.Memo Header"."No.";
            ValidateTableRelation = false;
        }
        field(385; "Rebate Payable Ac"; Enum "AQD Rebate Payable AC")
        {
            Caption = 'Rebate Payable A/C';
        }
        field(420; "Customer Rebate Source Code"; Code[10])
        {
            Caption = 'Sales Rebate Source Code';
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

        field(600; "Purch Journal Template Name"; Code[10])
        {
            Caption = 'Commission Purchase Jnl Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Purchases));
        }
        field(610; "Purch Journal Batch Name"; Code[10])
        {
            Caption = 'Commission Purchase  Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Purch Journal Template Name"),
                                                             "AQD Customer Rebate" = CONST(true));
        }

        //>> Customer Claims
        field(2000; "Item Claim Enabled"; Boolean)
        {
            Caption = 'Item Claim Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF CONFIRM(STRSUBSTNO(UserConfirmMsg, Item.TABLECAPTION)) THEN
                    Item.MODIFYALL("AQD Customer Claim Enabled", Rec."Item Claim Enabled");
            end;
        }
        field(2010; "Resource Claim Enabled"; Boolean)
        {
            Caption = 'Resource Claim Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF CONFIRM(STRSUBSTNO(UserConfirmMsg, Resource.TABLECAPTION)) THEN
                    Resource.MODIFYALL("AQD Customer Claim Enabled", Rec."Resource Claim Enabled");
            end;
        }
        field(2040; "G/L Account Claim Enabled"; Boolean)
        {
            Caption = 'G/L Account Claim Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF CONFIRM(STRSUBSTNO(UserConfirmMsg, GLAccount.TABLECAPTION)) THEN
                    GLAccount.MODIFYALL("AQD Customer Claim Enabled", Rec."G/L Account Claim Enabled");
            end;
        }
        field(2050; "Claim No. is Order No."; Boolean)
        {
            Caption = 'Claim No. is Order No.';
            DataClassification = CustomerContent;
        }
        field(2060; "Insert Comment Lines on Claim"; Boolean)
        {
            Caption = 'Insert Comment Lines on Claim';
            DataClassification = CustomerContent;
        }
        field(2070; "Full Price Default Pyt Method"; Code[10])
        {
            Caption = 'Full Price Claim Default Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";

            trigger OnValidate()
            var
                PaymentMethod: Record "Payment Method";
            begin
                IF PaymentMethod.GET(Rec."Full Price Default Pyt Method") THEN
                    PaymentMethod.TestField("Bal. Account No.");
            end;
        }
        field(2080; AllowToPostOrdAfterClaimApprov; Boolean)
        {
            Caption = 'Allow To Post Order After Claim Approval';
            DataClassification = CustomerContent;
        }
        field(2090; "Create Claim On"; Enum "AQD CustClaim Create Claim On")
        {
            Caption = 'Create Claim On';
            DataClassification = CustomerContent;
        }
        FIELD(2100; "Claim Delivery Commission Acct"; Code[20])
        {
            Caption = 'Claim Delivery Commission G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2120; "Claim Variance G/L Account"; Code[20])
        {
            Caption = 'Claim Variance G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2130; "Full Price Claims G/L Account"; Code[20])
        {
            Caption = 'Claims G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2140; "Claim Discount G/L Account"; Code[20])
        {
            Caption = 'Claim Discount G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2160; PostCreditMemoOnOrderInvoicing; Boolean)
        {
            Caption = 'Post Credit Memo On Order Invoicing';
            DataClassification = CustomerContent;
        }

        field(2300; "Price Match Default Pyt Method"; Code[10])
        {
            Caption = 'Price Match Claim Default Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";

            trigger OnValidate()
            var
                PaymentMethod: Record "Payment Method";
            begin
                IF PaymentMethod.GET(Rec."Price Match Default Pyt Method") THEN
                    PaymentMethod.TestField("Bal. Account No.");
            end;
        }
        FIELD(2310; "Price Match Claims G/L Account"; Code[20])
        {
            Caption = 'Claims G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2320; "Price Match Claim DelComm Acct"; Code[20])
        {
            Caption = 'Claim Delivery Commission G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2340; "Price Match Claim Vari G/LAcct"; Code[20])
        {
            Caption = 'Claim Variance G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2350; "Price Match Claim Disc G/LAcct"; Code[20])
        {
            Caption = 'Claim Discount G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        FIELD(2360; "PriceMatch ClmCostDiff G/LAcct"; Code[20])
        {
            Caption = 'Claim Cost Difference G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        field(2370; "Price Match Create Claim On"; Enum "AQD CustClmPrcMthCreateClaimOn")
        {
            Caption = 'Create Claim On';
            DataClassification = CustomerContent;
        }
        field(2380; "Price Match ClaimServCode Mand"; Boolean)
        {
            Caption = 'Claim Service Code Mandatory';
            DataClassification = CustomerContent;
        }
        field(2390; "Price Match ClaimProgCode Mand"; Boolean)
        {
            Caption = 'Claim Program Code Mandatory';
            DataClassification = CustomerContent;
        }
        FIELD(2400; "Price Match Always CreCostDiff"; Boolean)
        {
            Caption = 'Always Create Cost Different Line';
            DataClassification = CustomerContent;
        }
        FIELD(2410; "Price Match Always CreCommLine"; Boolean)
        {
            Caption = 'Always Create Delivery Commission Line';
            DataClassification = CustomerContent;
        }
        field(2490; "Full Price Claim Nos."; Code[20])
        {
            Caption = 'Full Price Claim Nos.';
            TableRelation = "No. Series";
        }
        FIELD(2500; "Price Match Claim Nos."; Code[20])
        {
            Caption = 'Price Match Claim Nos.';
            TableRelation = "No. Series";
        }
        field(2510; "Supplementary Invoice Nos."; Code[20])
        {
            Caption = 'Supplementary Invoice Nos.';
            TableRelation = "No. Series";
        }
        FIELD(2520; "Claim Purchase Cr Memo Nos."; Code[20])
        {
            Caption = 'Claim Purchase Credit Memo Nos.';
            TableRelation = "No. Series";
        }
        //<< Customer Claims
        field(3000; "Enable Rebate Approvals"; Boolean)
        {
            Caption = 'Enable Sales Rebate Line Approvals';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(3010; "Default Pay Cycle Code"; Code[20])
        {
            Caption = 'Default Pay Cycle Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD CR Pay Cycle"."Cycle Code";
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

    var
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        UserConfirmMsg: Label 'Do you want to update all %1?';
}