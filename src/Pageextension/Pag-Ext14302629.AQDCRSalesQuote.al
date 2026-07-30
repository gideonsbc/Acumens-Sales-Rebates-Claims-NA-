pageextension 14302629 "AQD CR Sales Quote" extends "Sales Quote"
{
    layout
    {
        addafter(SalesLines)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
                    field("AQD Customer Rebate Order Date"; Rec."AQD Customer Rebate Order Date")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}