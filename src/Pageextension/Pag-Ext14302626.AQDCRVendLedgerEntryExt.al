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
            field("AQD CF Commission Payable Date"; Rec."AQD CF Commission Payable Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date the commission becomes due for payment, based on the Payment Frequency of the rebate program.';
            }
        }
    }
}
