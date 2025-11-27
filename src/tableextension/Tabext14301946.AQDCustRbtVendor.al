tableextension 14301946 "AQD CR Vendor Ext" extends Vendor
{
    fields
    {
        field(14301910; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Territory Filter"; Boolean)
        {
            Caption = 'Territory Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Territory Filt" WHERE(Type = Const(employee), "No." = FIELD("No.")));
            Editable = false;
        }
        field(14301930; "AQD Customer Filter"; Boolean)
        {
            Caption = 'Customer Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Customer Filt" WHERE(Type = Const(employee), "No." = FIELD("No.")));
            Editable = false;
        }
    }
}