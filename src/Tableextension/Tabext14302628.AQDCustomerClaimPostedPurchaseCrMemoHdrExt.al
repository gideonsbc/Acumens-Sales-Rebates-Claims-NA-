tableextension 14302628 "AQD Cust Clm PurCrMemoHdr Ext" extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(14302610; "AQD CustClaim Sales Order No."; Code[20])
        {
            Caption = 'Customer Claim Sales Order No.';
            Editable = false;
        }
        field(14302620; "AQD Claim Sell-to Cust No."; Code[20])
        {
            Caption = 'Claim Sell-To Customer No.';
            Editable = FALSE;
        }
        field(14302630; "AQD Claim Bill-to Cust No."; Code[20])
        {
            Caption = 'Claim Bill-To Customer No.';
            Editable = FALSE;
        }
        field(14302640; "AQD Customer Claim No."; Code[20])
        {
            Caption = 'Customer Claim No.';
            Editable = false;
        }
        Field(14302650; "AQD CustRbt LinkToSupplInvoice"; Boolean)
        {
            Caption = 'Link To Supplementary Invoice';
        }
        FIELD(14302660; "AQD CustClaim Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
            Editable = FALSE;
        }
    }
}