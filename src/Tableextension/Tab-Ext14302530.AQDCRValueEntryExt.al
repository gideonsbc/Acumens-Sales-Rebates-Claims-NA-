tableextension 14302530 "AQD CR Value Entry Ext" extends "Value Entry"
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}