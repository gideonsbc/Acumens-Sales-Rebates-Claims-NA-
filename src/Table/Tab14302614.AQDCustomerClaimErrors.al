table 14302614 "AQD Customer Claim Errors"
{
    Caption = 'Customer Claim Errors';
    DataClassification = CustomerContent;
    LookupPageId = "AQD Customer Claim Errors";
    DrillDownPageId = "AQD Customer Claim Errors";
    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(2; "Claim No."; Code[20])
        {
            Caption = 'Claim No.';
            DataClassification = CustomerContent;
        }
        field(3; "Claim Line No."; Integer)
        {
            Caption = 'Claim Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = CustomerContent;
        }
        field(50; "Source Type"; Enum "AQD CustClaim Error SourceType")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(60; "Error Date Time"; DateTime)
        {
            Caption = 'Error Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Order No.", "Claim No.", "Claim Line No.", "Line No.")
        {
            Clustered = true;
        }
    }
}