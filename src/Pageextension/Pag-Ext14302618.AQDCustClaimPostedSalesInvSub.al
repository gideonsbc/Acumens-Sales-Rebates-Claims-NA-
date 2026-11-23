pageextension 14302618 "AQD CustClaimPostedSalesInvSub" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            Field("AQD CustClaim Mfg Product Code"; Rec."AQD CustClaim Mfg Product Code")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
        }
        addafter(Description)
        {
            field("AQD CustClaim Service Code"; Rec."AQD CustClaim Service Code")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Program Code"; Rec."AQD CustClaim Program Code")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Vendor No."; Rec."AQD CustClaim Vendor No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Vendor Name"; Rec."AQD CustClaim Vendor Name")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Width = 30;
                Visible = false;
            }
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
            field("AQD Customer Claim Line"; Rec."AQD Customer Claim Line")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Manual Line"; Rec."AQD CustClaim Manual Line")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Orig Order No."; Rec."AQD CustClaim Orig Order No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Editable = FALSE;
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