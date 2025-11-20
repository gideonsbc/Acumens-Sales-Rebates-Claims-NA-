pageextension 14301937 "AQD Cust Rbt Item Category Ext" extends "Item Categories"
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