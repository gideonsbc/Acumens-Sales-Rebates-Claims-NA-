pageextension 14301917 "AQD CustRbt Item List" extends "Item List"
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