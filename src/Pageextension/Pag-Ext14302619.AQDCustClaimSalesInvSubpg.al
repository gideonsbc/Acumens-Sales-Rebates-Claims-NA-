pageextension 14302619 "AQD CustClaim Sales Inv Subpg" extends "Sales Invoice Subform"
{
    layout
    {
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