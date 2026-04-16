pageextension 14302615 "AQD Cust Claim Location Card" extends "Location Card"
{
    layout
    {
        addafter("Address & Contact")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                field("AQM Vendor Claim Enabled"; Rec."AQM CustFullPriceClaim Enabled")
                {
                    ApplicationArea = All;
                }
                field("AQM CustPriceMatchClaimEnabled"; Rec."AQM CustPriceMatchClaimEnabled")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}