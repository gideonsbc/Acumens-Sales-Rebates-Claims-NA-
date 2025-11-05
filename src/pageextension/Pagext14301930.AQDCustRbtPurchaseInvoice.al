pageextension 14301930 "AQD CustRbt Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addafter("Shipping and Payment")
        {
            group("Acumens Customer Rebates And Claims")
            {
                Caption = 'Acumens Customer Rebates And Claims';
                field("AQD Customer Rebate No"; Rec."AQD Customer Rebate No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}