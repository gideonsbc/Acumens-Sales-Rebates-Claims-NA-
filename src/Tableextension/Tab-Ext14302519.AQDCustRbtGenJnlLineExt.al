tableextension 14302519 "AQD CustRbt Gen. Jnl Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(14302510; "AQD Cust Rebate Journal"; Boolean)
        {
            Caption = 'Sales Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302530; "AQD CR Bill-To Customer No."; Code[20])
        {
            Caption = 'Sales Rebate Bill-To Customer No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302540; "AQD Cust Rebate Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Sales Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302550; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Sales Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14302560; "AQD Cust Journal Document No."; Code[20])
        {
            Caption = 'Sales Journal Document No.';
            DataClassification = CustomerContent;
        }
        field(14302570; "AQD CR Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(14302580; "AQD CR Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
    }
}

