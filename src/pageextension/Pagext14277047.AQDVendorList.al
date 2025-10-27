pageextension 14277047 "AQD Vendor List" extends "Vendor List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Line Discounts")
        {
            action("AQD Set Purchase Rebates")
            {
                ApplicationArea = All;
                Caption = 'Rebates';
                Image = Setup;
                RunObject = Page "AQD Vendor Rebate Rates";
                RunPageLink = "Vendor No." = field("No.");
                RunPageView = sorting("Vendor No.");
            }
        }
        addlast("Category_Prices & Discounts")
        {
            actionref("AQD SetPurchaseRebates"; "AQD Set Purchase Rebates") { }
        }
    }
}