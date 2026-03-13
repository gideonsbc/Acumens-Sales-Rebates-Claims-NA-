tableextension 14302623 "AQD Cust Claim Purch Line Ext" extends "Purchase Line"
{
    fields
    {
        field(14302620; "AQD Claim Sell-to Cust No."; Code[20])
        {
            Caption = 'Claim Bill-To Customer No.';
            Editable = FALSE;
        }
        field(14302630; "AQD Claim Bill-to Cust No."; Code[20])
        {
            Caption = 'Claim Bill-To Customer No.';
            Editable = FALSE;
        }
        field(14302640; "AQD Customer Claim Code"; Code[20])
        {
            Caption = 'Customer Claim Code';
            Editable = FALSE;
        }
        FIELD(14302650; "AQD Claim Line Type"; enum "AQD CustClmPrcMthClaimLineType")
        {
            Caption = 'Claim Line Type';
        }
        field(14302660; "AQD CustClaim Orig Order No."; Code[20])
        {
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302670; "AQD CustClaim Orig OdrLine No."; Integer)
        {
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302680; "AQD CustClaim Claim No."; Code[20])
        {
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302690; "AQD CustClaim Claim Line No."; Integer)
        {
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
    }
}