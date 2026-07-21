tableextension 14302532 "AQD CustRbt DropShptInfo Ext" extends "AQD Drop Shipment Information"
{
    fields
    {
        field(14302510; "AQD CustRbt Cust Rbt Amount"; Decimal)
        {
            Caption = 'Sales Rebate Amount';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}