table 14302620 "AQD Trade Agreement"
{
    Caption = 'Trade Agreement';
    DataClassification = CustomerContent;
    LookupPageId = "AQD Trade Agreements";
    DrillDownPageId = "AQD Trade Agreements";
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to the base app';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
        fieldgroup(Brick; Code, Description)
        {
        }
    }
}
