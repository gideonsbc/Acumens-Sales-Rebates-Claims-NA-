pageextension 14301915 "AQD CustRbt Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Enroll for Rebate"; Rec."AQD Enroll for Cust Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rebate Customer No."; Rec."AQD Cust Rebate Customer No.")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate";
                    Enabled = Rec."AQD Enroll for Cust Rebate";
                }
                field("AQD Customer Rebate Category"; Rec."AQD Cust Rebate Category Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate";
                    Enabled = Rec."AQD Enroll for Cust Rebate";
                }
                field("AQD Calculation Date"; Rec."AQD CustRbt Calculation Date")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate";
                    Enabled = Rec."AQD Enroll for Cust Rebate";
                }
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                }
            }
        }
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

