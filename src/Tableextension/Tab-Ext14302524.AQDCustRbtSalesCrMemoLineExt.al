tableextension 14302524 "AQD CustRbt SalesCrMemoLineExt" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(14302510; "AQD Cust Rebate Document No."; Code[20])
        {
            Caption = 'Sales Rebate Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302520; "AQD Cust Rebate Doc Line No"; Integer)
        {
            Caption = 'Sales Rebate Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14302530; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302705; "AQD Off-Invoice Rebate"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}