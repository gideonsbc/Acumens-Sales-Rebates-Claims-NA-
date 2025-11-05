pageextension 14301933 "AQD CustRbt Posted PurchInv" extends "Posted Purchase Invoice"
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