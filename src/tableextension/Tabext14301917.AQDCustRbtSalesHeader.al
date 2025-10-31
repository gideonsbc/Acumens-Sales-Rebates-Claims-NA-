tableextension 14301917 "AQD CustRbt Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(14301910; "AQD Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
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
        field(14301970; "AQD Customer Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
    }
}

