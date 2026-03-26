table 14302617 "AQD Customer Contract Prices"
{

    fields
    {
        field(1; "Item No"; Code[25])
        {
            Caption = 'Nº';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Customer No"; Code[20])
        {
            NotBlank = true;
            TableRelation = Customer;
        }
        field(3; "Contract Price CA"; Decimal)
        {
        }
        field(4; "Contract Price AZ"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Item No", "Customer No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}