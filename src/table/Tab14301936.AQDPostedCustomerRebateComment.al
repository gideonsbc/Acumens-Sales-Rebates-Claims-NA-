table 14301936 "AQD Posted Cust Reb Comment"
{
    Caption = 'Posted Customer Rebate Comments';
    DataClassification = CustomerContent;
    //DrillDownPageId = "AQD Posted Cust Reb Comment";
    //LookupPageId = "AQD Posted Cust Reb Comment";

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
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