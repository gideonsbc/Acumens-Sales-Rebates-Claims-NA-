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
                field("AQD Rebate Customer Type"; Rec."AQD Customer Rebate Category")
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
        addafter("Line Discounts")
        {
            action("AQD Rebates")
            {
                ApplicationArea = All;
                Caption = 'Sales Rebates Setup';
                Image = LineDiscount;
                RunObject = Page "AQD CustRbt SalesRebates Setup";
                RunPageLink = "Entity Type" = CONST(Customer),
                              "Entity No." = FIELD("No.");
                RunPageView = SORTING("Entity Type", "Entity No.");
            }
        }
        addlast(Category_Category7)
        {
            actionref(Rebates_Promoted; "AQD Rebates") { }
        }
    }
}

