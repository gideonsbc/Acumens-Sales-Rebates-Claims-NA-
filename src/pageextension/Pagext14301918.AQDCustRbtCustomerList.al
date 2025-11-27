pageextension 14301918 "AQD CustRbt Customer List" extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(Sales_LineDiscounts)
        {
            action("AQD Setup Sales Rebates")
            {
                ApplicationArea = All;
                Caption = 'Setup Sales Rebates';
                Image = LineDiscount;
                RunObject = Page "AQD CustRbt SalesRebates Setup";
                RunPageLink = "Entity Type" = CONST(Customer),
                                  "Entity No." = FIELD("No.");
                RunPageView = SORTING("Entity Type", "Entity No.");
            }
        }
        addlast(Category_Category9)
        {
            actionref(Rebates_Promoted; "AQD Setup Sales Rebates") { }
        }
    }
}