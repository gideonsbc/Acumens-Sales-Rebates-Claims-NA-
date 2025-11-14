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
                field("AQD Rebate Customer Type"; Rec."AQD Rebate Customer Type")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate";
                    Enabled = Rec."AQD Enroll for Cust Rebate";
                }
                FIELD("AQD Cust RebatePosting SrcType"; Rec."AQD Cust RebatePosting SrcType")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate";
                    Enabled = Rec."AQD Enroll for Cust Rebate";
                }
                field("AQD Cust Rebate Customer No"; Rec."AQD Cust Rebate Customer No")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Cust Rebate" AND
                               (Rec."AQD Cust RebatePosting SrcType" = Rec."AQD Cust RebatePosting SrcType"::"Customer Card");
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
                RunPageLink = "Customer Type" = CONST(Customer),
                              "Customer No." = FIELD("No.");
                RunPageView = SORTING("Customer Type", "Customer No.");
            }
        }
        addlast(Category_Category7)
        {
            actionref(Rebates_Promoted; "AQD Rebates") { }
        }
    }
}

