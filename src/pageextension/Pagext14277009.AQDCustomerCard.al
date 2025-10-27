pageextension 14277009 "AQD Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                // field("AQD Customer Type"; Rec."AQD Customer Type")
                // {
                //     ApplicationArea = All;
                // }
                // field("AQD Payee Type"; Rec."AQD Payee Type")
                // {
                //     ApplicationArea = All;
                // }
                field("AQD Enroll for Rebate"; Rec."AQD Enroll for Rebate")
                {
                    ApplicationArea = All;
                }
                FIELD("AQD Rebate Customer Type"; Rec."AQD Rebate Customer Type")
                {
                    ApplicationArea = All;
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
                field("AQD Rebate Type"; Rec."AQD Rebate Type")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Rebate";
                    Enabled = Rec."AQD Enroll for Rebate";
                }
                field("AQD Rebate %"; Rec."AQD Rebate %")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Rebate" and (Rec."AQD Rebate Type" = Rec."AQD Rebate Type"::Percentage);
                    Enabled = Rec."AQD Enroll for Rebate" and (Rec."AQD Rebate Type" = Rec."AQD Rebate Type"::Percentage);
                }
                field("AQD AER Rebate Per Quantity"; Rec."AQD Rebate Per Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Enroll for Rebate" and (Rec."AQD Rebate Type" = Rec."AQD Rebate Type"::"Per Quantity");
                    Enabled = Rec."AQD Enroll for Rebate" and (Rec."AQD Rebate Type" = Rec."AQD Rebate Type"::"Per Quantity");
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
                RunObject = Page "AQD Sales Rebates Setup";
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

