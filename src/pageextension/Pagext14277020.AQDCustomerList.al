pageextension 14277020 "AQD Customer List" extends "Customer List"
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
                RunObject = Page "AQD Sales Rebates Setup";
                RunPageLink = "Customer Type" = CONST(Customer),
                                  "Customer No." = FIELD("No.");
                RunPageView = SORTING("Customer Type", "Customer No.");
            }
        }
        addlast(Category_Category9)
        {
            actionref(Rebates_Promoted; "AQD Setup Sales Rebates") { }
        }
    }
}