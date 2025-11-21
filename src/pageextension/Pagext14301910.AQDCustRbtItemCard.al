pageextension 14301910 "AQD CustRbt Item Card" extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Enabled';
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
        addafter("Set Special Discounts")
        {
            action("AQD Setup Sales Rebates")
            {
                ApplicationArea = All;
                Caption = 'Setup Sales Rebates';
                Image = LineDiscount;
                RunObject = Page "AQD CustRbt SalesRebates Setup";
                RunPageLink = "Line Type" = filter(Item), "No." = FIELD("No.");
            }
        }
        addlast(Category_Category6)
        {
            actionref("AQD SetSalesRebates"; "AQD Setup Sales Rebates") { }
        }
    }
}


