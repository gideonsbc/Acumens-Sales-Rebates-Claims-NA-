tableextension 14301943 "AQD CR G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        field(14301910; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD CR Bill-To Customer No."; Code[20])
        {
            Caption = 'Customer Rebate Bill-To Customer No.';
            Editable = false;
        }
    }
}