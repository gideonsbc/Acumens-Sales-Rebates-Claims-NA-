tableextension 14302630 "AQD CustRbt Sales Price Ext" extends "Sales Price"
{
    fields
    {
        field(14302750; "AQD POD Customer"; Code[20])
        {
            Caption = 'POD Customer';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer;
        }
    }
}