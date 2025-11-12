pageextension 14301928 "AQD CustRbtCustLderEntries Ext" extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("AQD Customer Rebate"; Rec."AQD Customer Rebate")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}