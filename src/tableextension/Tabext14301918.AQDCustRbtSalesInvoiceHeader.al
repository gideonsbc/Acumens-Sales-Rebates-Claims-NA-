tableextension 14301918 "AQD CustRbt Sales Inv Hdr Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(14301910; "AQD Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor WHERE("AQD Cust Rbt Vendor Type" = CONST("Rebate Vendor"));
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD Cust Rebate Entry Created"; Boolean)
        {
            Caption = 'Rebate Entry Created';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Cust Rebate LastChangedBy"; Code[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD CustRbt LastChangdDateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
    }
}