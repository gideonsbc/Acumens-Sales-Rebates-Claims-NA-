pageextension 14277022 "AQD Cust Lder Entries Ext" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Sales (LCY)")
        {
            field("AQD Customer Rebate Amount"; Rec."AQD Customer Rebate Amount")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}