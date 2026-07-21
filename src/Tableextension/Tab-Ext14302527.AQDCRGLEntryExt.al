tableextension 14302527 "AQD CR G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302530; "AQD CR Bill-To Customer No."; Code[20])
        {
            Caption = 'Sales Rebate Bill-To Customer No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}