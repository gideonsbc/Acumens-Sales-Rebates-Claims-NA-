tableextension 14302511 "AQD CustRbt Resource Ext" extends Resource
{
    fields
    {
        field(14302510; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Sales Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Sales Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(14302610; "AQD Customer Claim Enabled"; Boolean)
        {
            Caption = 'Claim Enabled';
            DataClassification = CustomerContent;
        }
    }
}