tableextension 14302529 "AQD CR Vendor Ext" extends Vendor
{
    fields
    {
        field(14302510; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Sales Rebate Enabled';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'To be removed';
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
        field(14302610; "AQD Claim Vendor"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim Vendor';
            DataClassification = CustomerContent;
        }
        field(14302620; "AQD Claim From Customer No."; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim From Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
    }
}