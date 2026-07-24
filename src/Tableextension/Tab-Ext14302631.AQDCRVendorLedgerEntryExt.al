tableextension 14302631 "AQD CR Vendor Ledger Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(14302509; "AQD CR Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(14302510; "AQD CR Rebate Approval Status"; Enum "AQD Rebate Approval Status")
        {
            Caption = 'Sales Rebate Approval Status';
            FieldClass = FlowField;
            CalcFormula = Lookup("AQD Sales Rebate Approvals"."Approval Status" where("Vendor Document No." = field("Document No."), "Rebate Program Code" = field("AQD CR Rebate Program Code")));
            Editable = false;
        }
    }
}