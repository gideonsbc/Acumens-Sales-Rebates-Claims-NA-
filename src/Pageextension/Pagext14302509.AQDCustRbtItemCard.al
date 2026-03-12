pageextension 14302509 "AQD CustRbt Item Card" extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rebate Category Code"; Rec."AQD Cust Rebate Category Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Customer Rebate Enabled";
                    Enabled = Rec."AQD Customer Rebate Enabled";
                }
            }
        }
    }
    actions
    {
        addafter(PricesandDiscounts)
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
        addafter(Category_Category6)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Customer Rebate';
                actionref(AQDCustomerRebateRatesRef; "AQD Customer Rebate Rates") { }
            }
        }
    }
}