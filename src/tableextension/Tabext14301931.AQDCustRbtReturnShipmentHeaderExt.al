tableextension 14301931 "AQD CustRbt ReturnShptHdr Ext" extends "Return Shipment Header"
{
    fields
    {
        field(14301910; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Customer Rebate No.';
            DataClassification = CustomerContent;
        }
    }
}