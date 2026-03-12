pageextension 14302541 "AQD CustRbt ItemLdgrEntries" extends "Item Ledger Entries"
{
    layout
    {
        addafter("Sales Amount (Actual)")
        {
            field("AQD Customer Rebate Amount"; Rec."AQD Cust Rebate Amount")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}