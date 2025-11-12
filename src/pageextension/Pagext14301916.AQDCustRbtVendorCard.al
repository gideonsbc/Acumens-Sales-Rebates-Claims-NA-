pageextension 14301916 "AQD CustRbt Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                field("AQD Cust Rbt Vendor Type"; Rec."AQD Cust Rbt Vendor Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}