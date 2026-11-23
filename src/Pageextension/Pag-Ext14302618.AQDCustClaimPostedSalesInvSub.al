pageextension 14302618 "AQD CustClaimPostedSalesInvSub" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
        }
        addafter(Description)
        {
        }
        addlast(Control1)
        {
        }
    }

    var
        PriceMatchFieldsvisibility: Boolean;
}