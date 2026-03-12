tableextension 14302513 "AQD CustRbt Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(14302510; "AQD No Customer Rebate"; Boolean)
        {
            Caption = 'Do Not Credit';
            //Editable = false; // To Edit By User
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                IF Rec."AQD No Customer Rebate" THEN BEGIN
                    Rec."AQD Rebate Last Changed By" := UserId;
                    Rec."AQD Rebate LastChangd DateTime" := CurrentDateTime;
                END ELSE BEGIN
                    Rec."AQD Rebate Last Changed By" := '';
                    Rec."AQD Rebate LastChangd DateTime" := 0DT;
                END;
            END;
        }
        field(14302520; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
            Editable = FALSE;
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
    }
}