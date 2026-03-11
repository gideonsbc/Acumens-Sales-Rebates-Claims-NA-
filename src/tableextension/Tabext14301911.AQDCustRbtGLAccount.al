tableextension 14301911 "AQD CustRbt G/L Account Ext" extends "G/L Account"
{
    fields
    {
        field(14301910; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Customer Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(14301930; "AQD Cust Rebate G/L Account"; Boolean)
        {
            Caption = 'Customer Rebate G/L Account (Internal UseOnly)';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
    }
}