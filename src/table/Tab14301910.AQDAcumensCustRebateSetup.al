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
        field(50; "Item Charge Rebate Enabled"; Boolean)
        {
            Caption = 'Item Charge Rebate Enabled';
        }
        field(60; "Fixed Asset Rebate Enabled"; Boolean)
        {
            Caption = 'Fixed Asset Rebate Enabled';
        }
        field(70; "Min GP% for Customer Rebate"; Decimal)
        {
            Caption = 'Minimum Gross Profit % for Customer Rebate';
            MaxValue = 100;
            MinValue = 0;
        }
        field(80; "Prevent Negative Cust Rebate"; Boolean)
        {
            Caption = 'Prevent Negative Customer Rebate';
        }
        field(90; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(100; "Pay Customer Rebate On"; Enum "AQD Customer Rebate On Type")
        {
            Caption = 'Pay Customer Rebate On';
        }
        // field(130; "Purch Journal Template Name"; Code[10])
        // {
        //     Caption = 'Rebate Purchase Jnl Template Name';
        //     TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Purchases));
        // }
        // field(140; "Purch Journal Batch Name"; Code[10])
        // {
        //     Caption = 'Rebate Purchase Jnl Batch Name';
        //     TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Purch Journal Template Name"),
        //                                                      "AQD Customer Rebate" = CONST(true));
        // }
        field(150; "Rebate Expense Account"; Code[20])
        {
            Caption = 'Rebate Expense G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                 "Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        // field(160; "Payment Journal Template"; Code[10])
        // {
        //     Caption = 'Payment Journal Template Name';
        //     TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Payments));
        // }
        // field(170; "Payment Journal Batch Name"; Code[10])
        // {
        //     Caption = 'Payment Journal Batch Name';
        //     TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Journal Template"),
        //                                                      "AQD Customer Rebate" = CONST(true));
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
        field(240; "Customer Rebate Nos"; Code[20])
        {
            Caption = 'Customer Rebate Nos';
            TableRelation = "No. Series";
        }
        // field(250; "General Journal Template Name"; Code[10])
        // {
        //     Caption = 'Rebate General Jnl Template Name';
        //     TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(General));
        // }
        // field(260; "General Journal Batch Name"; Code[10])
        // {
        //     Caption = 'Rebate General Jnl Batch Name';
        //     TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("General Journal Template Name"));
        // }
        field(270; "Pay Cust Rebate On"; Enum "AQD Customer Rebate On Type")
        {
            Caption = 'Pay Customer Rebate On';
            trigger OnValidate()
            begin
                IF Rec."Pay Cust Rebate On" <> Rec."Pay Cust Rebate On"::" " THEN
                    Rec."Calculate Cust Rebate using" := Rec."Calculate Cust Rebate using"::"Posted Invoice and Cr Memo";
            end;
        }
        field(275; "Calculate Cust Rebate using"; Enum "AQD Calc Customer Rebate using")
        {
            Caption = 'Calculate Customer Rebate using';

            trigger OnValidate()
            begin
                IF Rec."Calculate Cust Rebate using" <> Rec."Calculate Cust Rebate using"::"Posted Shipment and Return Receipt" then
                    Rec."Pay Customer Rebate On" := Rec."Pay Customer Rebate On"::"All Invoices";
            end;
        }
        // field(280; "Auto Update Rebate Cust Type"; Boolean)
        // {
        //     Caption = 'Auto Update Rebate Customer Type';
        // }
        field(290; AutoCreateSaleRebateRateonShpt; Boolean)
        {
            Caption = 'Auto Create Sale Rebate Rate on Shipment';

            trigger OnValidate()
            begin
                IF Not Rec.AutoCreateSaleRebateRateonShpt then
                    Rec.BlockAutoCreatedSaleRebateRate := FALSE;
            end;
        }
        field(300; BlockAutoCreatedSaleRebateRate; Boolean)
        {
            Caption = 'Block Auto Created Sale Rebate Rate';
        }
        field(340; "Default Rebate Program Code"; Code[10])
        {
            Caption = 'Default Cust Rebate Program Code';
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(350; "Purchase Item Charge No."; Code[20])
        {
            Caption = 'Purchase Item Charge No.';
            TableRelation = "Item Charge";
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
        field(370; "AQD Rebate Batch Frequency"; Enum "AQD CustRebate Batch Frequency")
        {
            Caption = 'Rebate Batch Frequency';
        }
        field(375; "Real Time Customer Rebate"; Boolean)
        {
            Caption = 'Real Time Customer Rebate';
        }
        field(380; "Customer Rebate Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        FIELD(385; "Post Customer Rebate Using"; Enum "AQD Post Cust Rebate Using")
        {
            Caption = 'Post Customer Rebate Using';
        }
        field(390; "Rebate Cr. Memo Posting"; enum "AQD Cust Rebate CrMemo Posting")
        {
            Caption = 'Rebate Cr. Memo Posting';
        }
        field(400; "AutoCreateSalesRbteRateonRcpt"; Boolean)
        {
            Caption = 'Auto Create Sales Rebate Rate on Receipt';
            trigger OnValidate()
            begin
                IF Not Rec.AutoCreateSalesRbteRateonRcpt then
                    Rec.BlockAutoCreatedSalesRbtRate := FALSE;
            end;
        }
        field(410; BlockAutoCreatedSalesRbtRate; Boolean)
        {
            Caption = 'Block Auto Created Sales Rebate Rate';
        }
        field(420; "Customer Rebate Source Code"; Code[10])
        {
            Caption = 'Customer Rebate Source Code';
            TableRelation = "Source Code";
        }
        field(430; "Use Cust Rebate Criteria"; Boolean)
        {
            Caption = 'Use Customer Rebate Criteria';
        }
        //field(440; "Auto Update Rbt Cust Type"; Boolean)
        //{
        //    Caption = 'Auto Update Rebate Customer Type';
        //    
        //}
        field(450; "Auto Post Customer Rebate"; Boolean)
        {
            Caption = 'Auto Post Customer Rebate';
        }
        field(460; "Require Cust Rebate Approval"; Boolean)
        {
            Caption = 'Require Customer Rebate Approval';

            trigger OnValidate()
            begin
                Rec."Job Queue Auto Approve Rebate" := FALSE;
            end;
        }
        field(470; "Job Queue Auto Approve Rebate"; Boolean)
        {
            Caption = 'Job Queue Auto Approve Rebate';
        }
        field(480; "Default Rebate Customer No."; Code[20])
        {
            Caption = 'Default Rebate Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(490; "Customer Accrual Type"; Enum "AQD Customer Accrual Type")
        {
            Caption = 'Customer Accrual Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                IF Rec."Customer Accrual Type" <> xRec."Customer Accrual Type" THEN
                    Rec."Default Rebate Customer No." := '';
            END;
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