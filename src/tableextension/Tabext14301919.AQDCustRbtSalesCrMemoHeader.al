tableextension 14301919 "AQD CustRbt SalesCrMemoHdr Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(14301910; "AQD No Customer Rebate"; Boolean)
        {
            Caption = 'Do Not Credit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14301930; "AQD Rebate Entry Created"; Boolean)
        {
            Caption = 'Rebate Entry Created';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Rebate Last Changed By"; Code[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Rebate LastChangd DateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14301960; "AQD Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Customer Rebate Status';
            DataClassification = CustomerContent;
        }
        field(14301970; "AQD Customer Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
        field(14301980; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Customer Rebate No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14301990; "AQD CR Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
    }
}