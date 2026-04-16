pageextension 14302536 "AQD Cust Rbt GL Entry Ext" extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("AQD Customer Rebate"; Rec."AQD Customer Rebate")
            {
                ApplicationArea = All;
            }
            // field("AQD CR Sell-To Customer No."; Rec."AQD CR Sell-To Customer No.")
            // {
            //     ApplicationArea = All;
            // }
            field("AQD CR Bill-To Customer No."; Rec."AQD CR Bill-To Customer No.")
            {
                ApplicationArea = All;
            }
        }
    }
}