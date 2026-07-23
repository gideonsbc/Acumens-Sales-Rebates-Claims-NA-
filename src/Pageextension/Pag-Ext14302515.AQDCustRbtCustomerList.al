pageextension 14302515 "AQD CustRbt Customer List" extends "Customer List"
{
    actions
    {
        addafter(ActionGroupCRM)
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Sales Rebate';

                action("AQD Customer Rebate Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebates Rates';
                    Image = LineDiscount;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
                    RunPageLink = "Entity Type" = CONST(Customer),
                                  "Customer No. Filter" = FIELD("No.");
                    RunPageView = SORTING("Entity Type", "Customer No. Filter");
                }
            }
        }
        addafter(Category_Synchronize)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Sales Rebate';
                actionref("AQD CustomerRebateSetup_Promoted"; "AQD Customer Rebate Setup") { }
            }
        }
    }
}