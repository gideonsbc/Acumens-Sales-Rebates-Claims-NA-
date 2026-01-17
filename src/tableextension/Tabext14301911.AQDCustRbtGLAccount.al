tableextension 14301911 "AQD CustRbt G/L Account Ext" extends "G/L Account"
{
    fields
    {
        field(14301910; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
    }
}