tableextension 14302614 "AQD Cust Claim Location Ext" extends Location
{
    fields
    {
        field(14302610; "AQD CustFullPriceClaim Enabled"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Full Price Claim Enabled';
            DataClassification = CustomerContent;
        }
        field(14302620; "AQD CustPriceMatchClaimEnabled"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Price Match Claim Enabled';
            DataClassification = CustomerContent;
        }
    }
}