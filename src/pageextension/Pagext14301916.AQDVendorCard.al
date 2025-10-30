pageextension 14301916 "AQD CustRbt Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                group(CustomerRebate)
                {
                    Caption = 'Rebate';
                    field("AQD Cust Rbt Vendor Type"; Rec."AQD Cust Rbt Vendor Type")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD AER Payee Type"; Rec."AQD Payee Type")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD AQD Rebate Payment Method"; Rec."AQD Rebate Payment Method")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                }
            }
        }
    }
}