pageextension 14302514 "AQD CustRbt Item List" extends "Item List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(Reports)
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Sales Rebate';

                action("AQD Customer Rebate Rates")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebate Rates';
                    Image = Setup;
                    RunObject = Page "AQD Sales Rebates Rate Setup";
                    RunPageLink = "Line Type" = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = sorting("No.");
                }
            }
        }
        addafter(Category_Report)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Sales Rebate';
                actionref(AQDCustomerRebateRatesRef; "AQD Customer Rebate Rates") { }
            }
        }
    }
}