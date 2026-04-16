table 14302542 "AQD CR Vend Emp Customer Filt"
{
    Caption = 'Vendor Employee Customer Filter';
    DataClassification = CustomerContent;
    LookupPageId = "AQD CR Vend Emp Customer Filt";
    DrillDownPageId = "AQD CR Vend Emp Customer Filt";

    fields
    {
        field(1; Type; Enum "AQD CR Vend Emp Filter Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No." where(Blocked = const(" "));

            trigger OnValidate()
            begin
                Rec.CalcFields("Customer Name")
            end;
        }
        field(25; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer."Name" where("No." = field("Customer No.")));
        }
    }
    keys
    {
        key(PK; "Type", "No.", "Customer No.")
        {
            Clustered = true;
        }
    }
}