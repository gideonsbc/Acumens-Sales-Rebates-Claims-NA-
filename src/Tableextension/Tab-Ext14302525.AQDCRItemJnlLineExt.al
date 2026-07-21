tableextension 14302525 "AQD CR Item Jnl Line Ext" extends "Item Journal Line"
{
    fields
    {
        field(14302510; "AQD Customer Rebate Journal"; Boolean)
        {
            Caption = 'Sales Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Cust Rebate Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Sales Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302530; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Sales Rebate Document No.';
            DataClassification = CustomerContent;
        }
    }
}