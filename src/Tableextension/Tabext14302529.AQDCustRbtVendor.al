tableextension 14302529 "AQD CR Vendor Ext" extends Vendor
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Territory Filter"; Boolean)
        {
            Caption = 'Territory Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Territory Filt" WHERE(Type = Const(Vendor), "No." = FIELD("No.")));
            Editable = false;
        }
        field(14302530; "AQD Customer Filter"; Boolean)
        {
            Caption = 'Customer Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Customer Filt" WHERE(Type = Const(Vendor), "No." = FIELD("No.")));
            Editable = false;
        }
    }
}