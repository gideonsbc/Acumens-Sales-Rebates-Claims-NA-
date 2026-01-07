tableextension 14301947 "AQD CR Value Entry Ext" extends "Value Entry"
{
    fields
    {
        field(14301910; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}