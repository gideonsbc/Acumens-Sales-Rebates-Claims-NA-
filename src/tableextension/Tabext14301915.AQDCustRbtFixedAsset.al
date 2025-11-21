tableextension 14301915 "AQD CustRbt Fixed Asset Ext" extends "Fixed Asset"
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
            TableRelation = "Item Category".Code where("AQD Customer Rebate" = const(true));
        }
    }
}

