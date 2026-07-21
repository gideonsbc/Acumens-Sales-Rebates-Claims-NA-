tableextension 14302528 "AQD CR Employee Ext" extends "Employee"
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14302520; "AQD Territory Filter"; Boolean)
        {
            Caption = 'Territory Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Territory Filt" WHERE(Type = Const(Employee), "No." = FIELD("No.")));
            Editable = false;
        }

        field(14302530; "AQD Customer Filter"; Boolean)
        {
            Caption = 'Customer Filter';
            FieldClass = FlowField;
            CalcFormula = exist("AQD CR Vend Emp Customer Filt" WHERE(Type = Const(Employee), "No." = FIELD("No.")));
            Editable = false;
        }
    }
}