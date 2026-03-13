tableextension 14302614 "AQD Cust Claim Location Ext" extends Location
{
    fields
    {
        field(14302610; "AQM CustFullPriceClaim Enabled"; Boolean)
        {
            Caption = 'Full Price Claim Enabled';
            DataClassification = CustomerContent;
        }
        field(14302620; "AQM CustPriceMatchClaimEnabled"; Boolean)
        {
            Caption = 'Price Match Claim Enabled';
            DataClassification = CustomerContent;
        }
    }
}