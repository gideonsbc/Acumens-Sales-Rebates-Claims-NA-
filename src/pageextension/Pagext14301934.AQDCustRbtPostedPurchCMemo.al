pageextension 14301934 "AQD CustRbt PostedPurchCrMemo" extends "Posted Purchase Credit Memo"
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