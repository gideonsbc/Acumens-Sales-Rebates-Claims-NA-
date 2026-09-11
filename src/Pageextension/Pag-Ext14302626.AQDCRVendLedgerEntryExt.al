pageextension 14302626 "AQD CR Vend. Ledger Entry Ext" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("On Hold")
        {
            field("AQD CR Rebate Approval Status"; Rec."AQD CR Rebate Approval Status")
            {
                ApplicationArea = All;
                Caption = 'Sales Rebate Approval Status';
                Visible = false;
                Editable = false;
            }
        }
        addafter("External Document No.")
        {
            Field("AQD CR Rebate Program Code"; Rec."AQD CR Rebate Program Code")
            {
                ToolTip = 'Specifies the value of the Rebate Program Code field.';
                ApplicationArea = all;
            }
            field("AQD CR Rebate Customer No."; Rec."AQD CR Rebate Customer No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
