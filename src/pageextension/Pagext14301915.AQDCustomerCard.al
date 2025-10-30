pageextension 14301915 "AQD Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';

                field("AQD Enroll for Rebate"; Rec."AQD Enroll for Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Customer Type"; Rec."AQD Rebate Customer Type")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Rebate";
                    Enabled = Rec."AQD Enroll for Rebate";
                }
                field("AQD Rebate Vendor No"; Rec."AQD Rebate Vendor No")
                {
                    ApplicationArea = All;
                    Editable = (Rec."AQD Enroll for Rebate") and (Rec."AQD Rebate Payment Method" = Rec."AQD Rebate Payment Method"::Check);
                }
                field("AQD Rebate Payment Method"; Rec."AQD Rebate Payment Method")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Rebate";
                    Enabled = Rec."AQD Enroll for Rebate";
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

