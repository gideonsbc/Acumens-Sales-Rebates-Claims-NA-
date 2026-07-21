pageextension 14302540 "AQD Cust Rbt Value Entry Ext" extends "Value Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("AQD Customer Rebate"; Rec."AQD Customer Rebate")
            {
                ApplicationArea = All;
            }
        }
    }
}