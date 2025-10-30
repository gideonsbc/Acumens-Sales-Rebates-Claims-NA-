pageextension 14301910 "AQD Item Card" extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                group("Customer Rebate")
                {
                    Caption = 'Customer Rebate';

                    field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Enabled';
                    }
                    field("AQD Rebate Cost Posting Type"; Rec."AQD Cust Rebate Posting Type")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate Enabled" AND (Rec."AQD Use Cust Rebate Setup From" = Rec."AQD Use Cust Rebate Setup From"::Item);
                        Enabled = Rec."AQD Customer Rebate Enabled" AND (Rec."AQD Use Cust Rebate Setup From" = Rec."AQD Use Cust Rebate Setup From"::Item);
                    }
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


