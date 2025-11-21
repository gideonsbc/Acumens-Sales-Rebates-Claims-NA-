tableextension 14301916 "AQD CustRbt Item Charge Ext" extends "Item Charge"
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
            Caption = 'Cust Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code where("AQD Customer Rebate" = const(true));
        }

        field(14301930; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
        }
    }
}