tableextension 14302510 "AQD CustRbt G/L Account Ext" extends "G/L Account"
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
        field(14302530; "AQD Cust Rebate G/LAcct Type"; Enum "AQD Cust Rebate G/L Acc Type")
        {
            Caption = 'Sales Rebate G/L Account Type (Internal UseOnly)';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302610; "AQD Customer Claim Enabled"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim Enabled';
            DataClassification = CustomerContent;
        }
        field(14302620; "AQD Cust Rebate Acct Group"; Enum "AQD Cust Rebate Acct Group")
        {
            Caption = 'Sales Rebate Account Group';
            DataClassification = CustomerContent;
        }
    }
}