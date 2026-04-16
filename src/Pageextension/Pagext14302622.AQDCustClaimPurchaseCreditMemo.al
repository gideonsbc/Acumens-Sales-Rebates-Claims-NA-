pageextension 14302622 "AQD CustClm Purch Credit Memo" extends "Purchase Credit Memo"
{
    layout
    {

        addafter("Shipping and Payment")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                Editable = false;

                field("AQD CustClaim Claim Type"; Rec."AQD CustClaim Claim Type")
                {
                    ApplicationArea = All;
                }
                field("AQD CustRbt LinkToSupplInvoice"; Rec."AQD CustRbt LinkToSupplInvoice")
                {
                    ApplicationArea = All;
                }
                field("AQD Customer Claim No."; Rec."AQD Customer Claim No.")
                {
                    ApplicationArea = All;
                }
                field("AQD CustClaim Sales Order No."; Rec."AQD CustClaim Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("AQD Claim Sell-to Cust No."; Rec."AQD Claim Sell-to Cust No.")
                {
                    ApplicationArea = All;
                }
                field("AQD Claim Bill-to Cust No."; Rec."AQD Claim Bill-to Cust No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}