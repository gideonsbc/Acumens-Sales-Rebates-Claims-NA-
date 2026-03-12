table 14302543 "AQD CR Vend Emp Territory Filt"
{
    Caption = 'Vendor Employee Territory Filter';
    DataClassification = CustomerContent;
    LookupPageId = "AQD CR Vend Emp Territory Filt";
    DrillDownPageId = "AQD CR Vend Emp Territory Filt";

    fields
    {
        field(1; "Type"; Enum "AQD CR Vend Emp Filter Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(20; "Territory Code"; Code[20])
        {
            Caption = 'Territory Code';
            DataClassification = CustomerContent;
            TableRelation = "Territory"."Code";

            trigger OnValidate()
            begin
                Rec.CalcFields("Territory Name")
            end;
        }
        field(25; "Territory Name"; Text[100])
        {
            Caption = 'Territory Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Territory."Name" where("Code" = field("Territory Code")));
        }
    }
    keys
    {
        key(PK; "Type", "No.", "Territory Code")
        {
            Clustered = true;
        }
    }
}