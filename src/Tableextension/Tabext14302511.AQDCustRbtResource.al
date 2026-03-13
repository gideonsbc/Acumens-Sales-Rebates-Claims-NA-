tableextension 14302511 "AQD CustRbt Resource Ext" extends Resource
{
    fields
    {
        field(14302510; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Customer Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(14302610; "AQM Customer Claim Enabled"; Boolean)
        {
            Caption = 'Claim Enabled';
            DataClassification = CustomerContent;
        }
    }
}