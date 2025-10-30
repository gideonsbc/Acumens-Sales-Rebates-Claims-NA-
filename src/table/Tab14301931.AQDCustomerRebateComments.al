table 14301931 "AQD Customer Rebate Comments"
{
    Caption = 'Vendor Rebate Comments';
    DataClassification = CustomerContent;
    //DrillDownPageId = "AQD Customer Rebate Comments";
    //LookupPageId = "AQD Customer Rebate Comments";

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            AutoIncrement = true;
        }
        field(20; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(30; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(40; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; "Rebate No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}