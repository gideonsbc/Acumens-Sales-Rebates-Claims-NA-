table 14302617 "AQD Marketplace"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Marketplace";
    LookupPageId = "AQD Marketplace";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}