pageextension 14302615 "AQD Cust Claim Location Card" extends "Location Card"
{
    layout
    {
        addafter("Address & Contact")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                Visible = false;
                Caption = 'Acumens Sales Rebates & Claims';
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