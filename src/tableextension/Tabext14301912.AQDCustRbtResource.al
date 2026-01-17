tableextension 14301912 "AQD CustRbt Resource Ext" extends Resource
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