pageextension 14277019 "AQD Item List" extends "Item List"
{
    layout
    {
        // Add changes to page layout here
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
                RunObject = Page "AQD Sales Rebates Setup";
                RunPageLink = "Line Type" = filter(Item), "No." = FIELD("No.");
            }
            action("AQD Setup Purchase Rebates")
            {
                ApplicationArea = All;
                Caption = 'Setup Purchase Rebates';
                Image = Setup;
                RunObject = Page "AQD Vendor Rebate Rates";
                RunPageLink = "No." = field("No.");
                RunPageView = sorting("No.");
            }
        }
        addlast(Category_Category6)
        {
            actionref("AQD SetSalesRebates"; "AQD Setup Sales Rebates") { }
            actionref("AQD SetPurchaseRebates"; "AQD Setup Purchase Rebates") { }
        }
    }
}