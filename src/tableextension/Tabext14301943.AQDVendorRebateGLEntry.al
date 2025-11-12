tableextension 14301943 "AQD CR G/L Entry Ext" extends "G/L Entry"
{
    fields
    {
        field(14277004; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277016; "AQD CR Sell-To Customer No."; Code[20])
        {
            Caption = 'Customer Rebate Sell-To Customer No.';
            Editable = false;
        }
        field(14277017; "AQD CR Bill-To Customer No."; Code[20])
        {
            Caption = 'Customer Rebate Bill-To Customer No.';
            Editable = false;
        }
    }
}