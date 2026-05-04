tableextension 14302631 "AQD CR Vendor Ledger Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14302509; "AQD CR Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code";
        }
    }
}