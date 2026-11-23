pageextension 14302619 "AQD CustClaim Sales Inv Subpg" extends "Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            Field("AQD Customer Claim Code"; Rec."AQD Customer Claim Code")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
                Visible = false;
            }
            Field("AQD Claim Line Type"; Rec."AQD Claim Line Type")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
                Visible = false;
            }
        }
        addlast(Control1)
        {
            Field("AQD CustClaim Orig Order No."; Rec."AQD CustClaim Orig Order No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Original Order No. field.', Comment = '%';
                Visible = false;
            }
            Field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Original Order Line No. field.', Comment = '%';
                Visible = false;
            }
        }
    }
    [Obsolete('The Claims functionality has been discontinued and will be removed in a future release.', 'Deprecated in v25.1023.1.45')]
    procedure SetPriceMatchFieldsvisibility(PriceMatchFieldsvisibilityIn: Boolean)
    begin
        PriceMatchFieldsvisibility := PriceMatchFieldsvisibilityIn;
    end;

    var
        PriceMatchFieldsvisibility: Boolean;
}