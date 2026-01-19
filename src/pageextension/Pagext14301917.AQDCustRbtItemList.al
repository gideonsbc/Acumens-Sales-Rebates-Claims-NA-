pageextension 14301917 "AQD CustRbt Item List" extends "Item List"
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
                Caption = 'Acumens Customer Rebate';

                action("AQD Customer Rebate Rates")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Rates';
                    Image = Setup;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
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
                Caption = 'Acumens Customer Rebate';
                actionref(AQDCustomerRebateRatesRef; "AQD Customer Rebate Rates") { }
            }
        }
    }
}