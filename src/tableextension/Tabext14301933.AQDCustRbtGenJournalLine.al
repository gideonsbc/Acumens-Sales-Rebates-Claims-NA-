tableextension 14301933 "AQD CustRbt Gen. Jnl Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(14301910; "AQD Cust Rebate Journal"; Boolean)
        {
            Caption = 'Cust Rebate Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        // field(14301920; "AQD CR Sell-To Customer No."; Code[20])
        // {
        //     Caption = 'Customer Rebate Sell-To Customer No.';
        //     Editable = false;
        // }
        field(14301930; "AQD CR Bill-To Customer No."; Code[20])
        {
            Caption = 'Customer Rebate Bill-To Customer No.';
            Editable = false;
        }
        field(14301940; "AQD Cust Rebate Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Cust Rebate Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Cust Rebate Document No.';
            DataClassification = CustomerContent;
        }
        field(14301960; "AQD Cust Journal Document No."; Code[20])
        {
            Caption = 'Cust Journal Document No.';
            DataClassification = CustomerContent;
        }
    }
}

