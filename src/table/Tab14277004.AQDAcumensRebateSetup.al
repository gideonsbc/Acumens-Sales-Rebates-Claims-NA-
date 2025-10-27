table 14277004 "AQD Acumens Rebate Setup"
{
    Caption = 'Acumens Claims & Rebates Setup';
    DrillDownPageId = "AQD Acumens Rebate Setup";
    LookupPageId = "AQD Acumens Rebate Setup";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "Primary Key"; Code[10])
        {
        }
        field(14277005; "Item Rebatable"; Boolean)
        {
            Caption = 'Item Rebate Enabled';
        }
        field(14277006; "Resource Rebatable"; Boolean)
        {
            Caption = 'Resource Rebate Enabled';
        }
        field(14277007; "G/L Account Rebatable"; Boolean)
        {
            Caption = 'G/L Account Rebate Enabled';
        }
        field(14277008; "Item Charge Rebatable"; Boolean)
        {
            Caption = 'Item Charge Rebate Enabled';
        }
        field(14277009; "Fixed Asset Rebatable"; Boolean)
        {
            Caption = 'Fixed Asset Rebate Enabled';
        }
        field(14277010; "Min GP% for Rebate"; Decimal)
        {
            Caption = 'Minimum Gross Profit % for Rebate';
            MaxValue = 100;
            MinValue = 0;
        }
        field(14277011; "Prevent Negative Rebate"; Boolean)
        {
            Caption = 'Prevent Negative Rebate';
        }
        field(14277012; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(14277013; "Pay Customer Rebate On"; Enum "AQD Customer Rebate On Type")
        {
            Caption = 'Pay Customer Rebate On';
        }
        field(14277014; "Def. Rebate Payment Method"; Option)
        {
            Caption = 'Default Rebate Payment Method';
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
        }
        field(14277015; "Default Rebate %"; Decimal)
        {
            Caption = 'Default Rebate %';
            MaxValue = 100;
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Default Rebate Type");
            end;
        }
        field(14277016; "Purch Journal Template Name"; Code[10])
        {
            Caption = 'Rebate Purchase Jnl Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Purchases));
        }
        field(14277017; "Purch Journal Batch Name"; Code[10])
        {
            Caption = 'Rebate Purchase Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Purch Journal Template Name"),
                                                             "AQD Rebate" = CONST(true));
        }
        field(14277018; "Rebate Expense Account"; Code[20])
        {
            Caption = 'Rebate Expense G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                 "Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(14277019; "Payment Journal Template"; Code[10])
        {
            Caption = 'Payment Journal Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Payments));
        }
        field(14277020; "Payment Journal Batch Name"; Code[10])
        {
            Caption = 'Payment Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Journal Template"),
                                                             "AQD Rebate" = CONST(true));
        }
        field(14277021; "Sales Journal Template Name"; Code[10])
        {
            Caption = 'Rebate Sales Jnl Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(Sales));
        }
        field(14277022; "Sales Journal Batch Name"; Code[10])
        {
            Caption = 'Rebate Sales Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Sales Journal Template Name"),
                                                             "AQD Rebate" = CONST(true));
        }
        field(14277023; "Old Documents Updated"; Boolean)
        {
            Caption = 'Old Documents Updated';
            Editable = false;
        }
        field(14277024; "Min GP% for Vendor Rebate"; Decimal)
        {
            Caption = 'Minimum Gross Profit % for Rebate';
            MaxValue = 100;
            MinValue = 0;
        }
        field(14277025; "Prevent Negative Vendor Rebate"; Boolean)
        {
            Caption = 'Prevent Negative Rebate';
        }
        field(14277026; "Vendor Rebate Expense G/L"; Code[20])
        {
            Caption = 'Rebate Expense G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                 "Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(14277027; "Vendor Rebate Nos"; Code[20])
        {
            Caption = 'Vendor Rebate Nos';
            TableRelation = "No. Series";
        }
        field(14277028; "General Journal Template Name"; Code[10])
        {
            Caption = 'Rebate General Jnl Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = FILTER(General));
        }
        field(14277029; "General Journal Batch Name"; Code[10])
        {
            Caption = 'Rebate General Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("General Journal Template Name"));
        }
        field(14277030; "Pay Vendor Rebate On"; Enum "AQD Vendor Rebate On Type")
        {
            Caption = 'Pay Vendor Rebate On';
            trigger OnValidate()
            begin
                IF Rec."Pay Vendor Rebate On" <> Rec."Pay Vendor Rebate On"::" " THEN
                    Rec."Calculate Vendor Rebate using" := Rec."Calculate Vendor Rebate using"::"Posted Invoice and Cr Memo";
            end;
        }
        field(14277031; "Auto Update Rebate Cust Type"; Boolean)
        {
            Caption = 'Auto Update Rebate Customer Type';
        }
        field(14277032; AutoCreateSaleRebateRateonRcpt; Boolean)
        {
            Caption = 'Auto Create Sale Rebate Rate on Shipment';

            trigger OnValidate()
            begin
                IF Not Rec.AutoCreateSaleRebateRateonRcpt then
                    Rec.BlockAutoCreatedSaleRebateRate := FALSE;
            end;
        }
        field(14277033; BlockAutoCreatedSaleRebateRate; Boolean)
        {
            Caption = 'Block Auto Created Sale Rebate Rate';
        }
        field(14277134; "Customer Rebate Source Code"; Code[10])
        {
            Caption = 'Customer Rebate Source Code';
            TableRelation = "Source Code";
        }
        field(14277040; "Default Rebate Type"; Option)
        {
            Caption = 'Default Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;

            trigger OnValidate()
            begin
                IF Rec."Default Rebate Type" <> xRec."Default Rebate Type" THEN BEGIN
                    Rec."Default Rebate %" := 0;
                    Rec."Default Rebate Per Quantity" := 0;
                END;
            end;
        }
        field(14277041; "Default Rebate Per Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Rebate Per Quantity';
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Default Rebate Type");
            end;
        }
        field(14277045; "Default Rebate Program Code"; Code[10])
        {
            Caption = 'Default Rebate Program Code';
            TableRelation = "AQD Rebate Program Code";
        }
        field(14277050; "Default Item Charge No."; Code[20])
        {
            Caption = 'Default Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(14277055; "Default Setup Rebate Type"; Enum "AQD Vendor Rebate Line Type")
        {
            Caption = 'Default Setup Rebate Type';
        }
        field(14277058; "AQD Rebate Batch Frequency"; Enum "AQD Rebate Batch Frequency")
        {
            Caption = 'Rebate Batch Frequency';
        }
        field(14277060; "Calculate Vendor Rebate using"; Enum "AQD Calc Vendor Rebate using")
        {
            Caption = 'Calculate Vendor Rebate using';

            trigger OnValidate()
            begin
                IF Rec."Calculate Vendor Rebate using" <> Rec."Calculate Vendor Rebate using"::"Posted Receipt and Return Shipment" then
                    Rec."Pay Vendor Rebate On" := Rec."Pay Vendor Rebate On"::"All Invoices";
            end;
        }
        field(14277070; "Vendor Item Rebatable"; Boolean)
        {
            Caption = 'Item Rebate Enabled';
        }
        field(14277071; "Vendor Resource Rebatable"; Boolean)
        {
            Caption = 'Resource Rebate Enabled';
        }
        field(14277072; "Vendor G/L Account Rebatable"; Boolean)
        {
            Caption = 'G/L Account Rebate Enabled';
        }
        field(14277073; "Vendor Item Charge Rebatable"; Boolean)
        {
            Caption = 'Item Charge Rebate Enabled';
        }
        field(14277074; "Vendor Fixed Asset Rebatable"; Boolean)
        {
            Caption = 'Fixed Asset Rebate Enabled';
        }
        field(14277075; "Vendor Rebate Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(14277090; "Rebate Cr. Memo Posting"; enum "AQD Rebate Cr. Memo Posting")
        {
            Caption = 'Rebate Cr. Memo Posting';
        }
        field(14277100; "AutoCreatePurRebateRateonRcpt"; Boolean)
        {
            Caption = 'Auto Create Purchase Rebate Rate on Receipt';
            trigger OnValidate()
            begin
                IF Not Rec.AutoCreatePurRebateRateonRcpt then
                    Rec.BlockAutoCreatedPurRebateRate := FALSE;
            end;
        }
        field(14277110; "BlockAutoCreatedPurRebateRate"; Boolean)
        {
            Caption = 'Block Auto Created Purchase Rebate Rate';
        }
        field(14277120; "Vendor Rebate Source Code"; Code[10])
        {
            Caption = 'Vendor Rebate Source Code';
            TableRelation = "Source Code";
        }
        field(14277130; "Use Vendor Rebate Criteria"; Boolean)
        {
            Caption = 'Use Vendor Rebate Criteria';
        }
        field(14277140; "Auto Update Rebate Vendor Type"; Boolean)
        {
            Caption = 'Auto Update Rebate Vendor Type';
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