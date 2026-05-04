tableextension 14302631 "AQD Vendor Ledger Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14302509; "AQD CR Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            DataClassification = CustomerContent;
        }
    }
}