pageextension 14301916 "AQD CustRbt Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                field("AQD Cust Rbt Vendor Type"; Rec."AQD Cust Rbt Vendor Type")
                {
                    ApplicationArea = All;
                }
                group(CustomerRebate)
                {
                    Caption = 'Customer Rebate';

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