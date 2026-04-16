tableextension 14302522 "AQD CustRbt Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(14302510; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Customer Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302520; "AQD Cust Rebate Doc Line No"; Integer)
        {
            Caption = 'Customer Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302530; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302610; "AQD Customer Claim Line"; Boolean)
        {
            Caption = 'Customer Claim Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302620; "AQD CustClaim Manual Line"; Boolean)
        {
            Caption = 'Customer Claim Manual Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302630; "AQD CustClaim Mfg Product Code"; Code[20])
        {
            Caption = 'Mfg. Product Code';
            DataClassification = CustomerContent;
        }
        field(14302640; "AQD CustClaim Vendor No."; Code[20])
        {
            Caption = 'Claim Vendor No.';
            DataClassification = CustomerContent;
            //TableRelation = Vendor."No.";
            TableRelation = "AQD Customer Claim Vendors"."Vendor No." where("Bill-to Customer No." = field("Bill-to Customer No."));//,
            ValidateTableRelation = false;

            trigger OnValidate()
            BEGIN
                //CheckClaimStatus();
                Rec.CalcFields("AQD CustClaim Vendor Name");
            END;
        }
        field(14302650; "AQD CustClaim Vendor Name"; text[100])
        {
            Caption = 'Claim Vendor Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = FIELD("AQD CustClaim Vendor No.")));
        }
        field(14302660; "AQD CustClaim Program Code"; Code[20])
        {
            Caption = 'Program Code';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            TableRelation = "AQD Cust Claim Program Code".Code;

            trigger OnValidate()
            var
                CustClaimProgramCode: Record "AQD Cust Claim Program Code";
            begin
                IF CustClaimProgramCode.Get("AQD CustClaim Program Code") THEN BEGIN
                    Validate("AQD CustClaim Vendor No.", CustClaimProgramCode."Claim Vendor No.");
                END;
            end;
        }
        field(14302670; "AQD CustClaim Service Code"; Code[20])
        {
            Caption = 'Claim Service Code';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            TableRelation = "AQD Claim Service Codes"."Service Code";
        }
        field(14302680; "AQD CustClaim Orig Order No."; Code[20])
        {
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302690; "AQD CustClaim Orig OdrLine No."; Integer)
        {
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302700; "AQD Customer Claim Code"; Code[20])
        {
            Caption = 'Customer Claim Code';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        FIELD(14302701; "AQD Claim Line Type"; enum "AQD CustClmPrcMthClaimLineType")
        {
            Caption = 'Claim Line Type';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        field(14302702; "AQD CustClaim Claim No."; Code[20])
        {
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302703; "AQD CustClaim Claim Line No."; Integer)
        {
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
    }
}