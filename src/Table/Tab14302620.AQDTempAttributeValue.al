table 14302620 "AQD Temp Attribute Value"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Value; Text[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Value)
        {
            Clustered = true;
        }
    }
}