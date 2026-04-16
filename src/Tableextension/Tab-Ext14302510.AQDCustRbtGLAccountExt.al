tableextension 14302510 "AQD CustRbt G/L Account Ext" extends "G/L Account"
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
        field(14302530; "AQD Cust Rebate G/LAcct Type"; Enum "AQD Cust Rebate G/L Acc Type")
        {
            Caption = 'Customer Rebate G/L Account Type (Internal UseOnly)';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302610; "AQD Customer Claim Enabled"; Boolean)
        {
            Caption = 'Claim Enabled';
            DataClassification = CustomerContent;
        }
    }
}