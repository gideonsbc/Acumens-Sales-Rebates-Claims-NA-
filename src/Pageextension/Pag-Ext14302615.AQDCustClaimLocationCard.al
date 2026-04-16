pageextension 14302615 "AQD Cust Claim Location Card" extends "Location Card"
{
    layout
    {
        addafter("Address & Contact")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                field("AQD Vendor Claim Enabled"; Rec."AQD CustFullPriceClaim Enabled")
                {
                    ApplicationArea = All;
                }
                field("AQD CustPriceMatchClaimEnabled"; Rec."AQD CustPriceMatchClaimEnabled")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}