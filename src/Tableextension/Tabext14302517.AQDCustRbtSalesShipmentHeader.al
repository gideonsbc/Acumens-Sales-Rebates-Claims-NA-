tableextension 14302517 "AQD CustRbt Sales Shpt Hdr Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(14302510; "AQD No Customer Rebate"; Boolean)
        {
            Caption = 'Do Not Credit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302530; "AQD Rebate Entry Created"; Boolean)
        {
            Caption = 'Rebate Entry Created';
            Editable = false;
            DataClassification = CustomerContent;
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
        field(14302560; "AQD Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Customer Rebate Status';
            DataClassification = CustomerContent;
        }
        field(14302570; "AQD Customer Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
        field(14302580; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Customer Rebate No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302590; "AQD Comm Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302610; "AQD Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
            DataClassification = CustomerContent;
            Editable = FALSE;

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
        field(14302700; "AQD CustClaim Orig Order No."; Code[20])
        {
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302710; "AQD CustClaim Purch CrMemo No."; Code[20])
        {
            Caption = 'Purch Cr Memo No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        FIELD(14302720; "AQD CustClaim Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
            Editable = FALSE;
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