tableextension 14302513 "AQD CustRbt Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(14302510; "AQD No Customer Rebate"; Boolean)
        {
            Caption = 'Do Not Credit';
            //Editable = false; // To Edit By User
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                IF Rec."AQD No Customer Rebate" THEN BEGIN
                    Rec."AQD Rebate Last Changed By" := UserId;
                    Rec."AQD Rebate LastChangd DateTime" := CurrentDateTime;
                END ELSE BEGIN
                    Rec."AQD Rebate Last Changed By" := '';
                    Rec."AQD Rebate LastChangd DateTime" := 0DT;
                END;
            END;
        }
        field(14302520; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302540; "AQD Rebate Last Changed By"; Code[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14302550; "AQD Rebate LastChangd DateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14302570; "AQD Customer Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
        field(14302580; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Sales Rebate No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302610; "AQD CustClaim Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
            DataClassification = CustomerContent;
            Editable = FALSE;

            trigger OnValidate()
            var
                CustomerClaimVendors: Record "AQD Customer Claim Vendors";
            BEGIN
                IF Rec."AQD CustClaim Claim Type" <> xRec."AQD CustClaim Claim Type" THEN BEGIN
                    CheckClaimStatus();

                    CustomerClaimVendors.RESET;
                    CustomerClaimVendors.SetRange("Bill-to Customer No.", Rec."Bill-to Customer No.");
                    CustomerClaimVendors.SetRange("Claim Type", Rec."AQD CustClaim Claim Type");
                    IF CustomerClaimVendors.FINDFIRST THEN
                        Rec."AQD Claim Vendor No." := CustomerClaimVendors."Vendor No.";
                END;
            END;
        }
        field(14302620; "AQD Claim Vendor No."; Code[20])
        {
            Caption = 'Claim Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            BEGIN
                CheckClaimStatus();
            END;
        }
        field(14302625; "AQD Customer Claim No."; Code[20])
        {
            Caption = 'Customer Claim No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302630; "AQD Vendor Cr. Memo No."; Code[20])
        {
            Caption = 'Vendor Cr. Memo No.';
            DataClassification = CustomerContent;
        }
        field(14302640; "AQD Claim Approved Amount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Claim Approved Amount';
            DataClassification = CustomerContent;
        }
        field(14302650; "AQD Claim Delivery Commission"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Claim Delivery Commission';
            DataClassification = CustomerContent;
        }
        field(14302660; "AQD Claim Purchase Discount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Claim Purchase Discount';
            DataClassification = CustomerContent;
        }
        field(14302680; "AQD Claim Status"; Enum "AQD Cust Claim Claim Status")
        {
            Caption = 'Claim Status';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("AQD Customer Claim Header".Status WHERE("Order No." = FIELD("No.")));
        }
        field(14302690; "AQD Claim Errors"; Boolean)
        {
            Caption = 'Claim Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("AQD Customer Claim Errors" WHERE("Order No." = FIELD("No.")));
        }
        field(14302700; "AQD CustClaim Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302701; "AQD CustClaim Purch CrMemo No."; Code[20])
        {
            Caption = 'Purch Cr Memo No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302704; "AQD Cust Rebate Category"; Code[20])
        {
            Caption = 'Sales Rebate Category';
            DataClassification = CustomerContent;
            TableRelation = "AQD Rebate Customer Category";
        }
        field(14302705; "AQD Disallow Off-Inv Rebate"; Boolean)
        {
            Caption = 'Disallow Off-Invoice Rebate';
            DataClassification = CustomerContent;
        }
        field(14302706; "AQD Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Marketplace";
        }
        field(14302707; "AQD Cust Rebate Program Code"; Code[10])
        {
            Caption = 'Sales Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code" where("Entity Type" = const("Vendor Commission"));
        }
    }
    LOCAL procedure CheckClaimStatus()
    var
        ClaimHeader: Record "AQD Customer Claim Header";
    BEGIN
        ClaimHeader.RESET;
        ClaimHeader.SetRange("Order No.", Rec."No.");
        ClaimHeader.SetRange("Claim Submitted", TRUE);
        IF ClaimHeader.FINDFIRST THEN
            ERROR(ClaimSubmittedError, Rec."No.", Rec."AQD Claim Vendor No.");
    END;

    var
        ClaimSubmittedError: Label 'Claim is already submmited for Order %1. %2 cannot be changed.';
}