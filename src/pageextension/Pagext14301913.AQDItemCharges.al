pageextension 14301913 "AQD Item Charges" extends "Item Charges"
{
    layout
    {
        addafter("Search Description")
        {
            field("AQD Customer Rebatable"; Rec."AQD Customer Rebate Enabled")
            {
                ApplicationArea = All;
            }
            field("AQD Rebate Option"; Rec."AQD Customer Rebate")
            {
                ApplicationArea = All;
            }
            field("AQD Cust Rebate Category Code"; Rec."AQD Cust Rebate Category Code")
            {
                ApplicationArea = All;
                Editable = Rec."AQD Customer Rebate Enabled";
                Enabled = Rec."AQD Customer Rebate Enabled";
            }
            field("AQD Use Cust Rebate Setup From"; Rec."AQD Use Cust Rebate Setup From")
            {
                ApplicationArea = All;
                Editable = Rec."AQD Customer Rebate Enabled";
                Enabled = Rec."AQD Customer Rebate Enabled";
            }
        }
    }
}