tableextension 14302515 "AQD CustRbt SalesCrMemoHdr Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(14302510; "AQD No Customer Rebate"; Boolean)
        {
            Caption = 'Do Not Credit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302530; "AQD Rebate Entry Created"; Boolean)
        {
            Caption = 'Rebate Entry Created';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14302540; "AQD Rebate Last Changed By"; Code[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14302550; "AQD Rebate LastChangd DateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14302560; "AQD Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Customer Rebate Status';
            DataClassification = CustomerContent;
        }
        field(14302570; "AQD Customer Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
        field(14302580; "AQD Customer Rebate No"; Code[20])
        {
            Caption = 'Customer Rebate No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302590; "AQD CR Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(14302706; "AQD Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Marketplace";
        }
        field(14302707; "AQD Cust Rebate Program Code"; Code[10])
        {
            Caption = 'Customer Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code";
        }
    }
}