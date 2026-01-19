pageextension 14301918 "AQD CustRbt Customer List" extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(ActionGroupCRM)
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Customer Rebate';

                action("AQD Customer Rebate Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebates Rates';
                    Image = LineDiscount;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
                    RunPageLink = "Entity Type" = CONST(Customer),
                                  "Entity No." = FIELD("No.");
                    RunPageView = SORTING("Entity Type", "Entity No.");
                }
            }
        }
        addafter(Category_Synchronize)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Customer Rebate';
                actionref(CustomerRebateSetup_Promoted; "AQD Customer Rebate Setup") { }
            }
        }
    }
}