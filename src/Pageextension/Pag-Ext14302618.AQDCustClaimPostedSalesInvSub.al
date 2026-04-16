pageextension 14302618 "AQD CustClaimPostedSalesInvSub" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            Field("AQD CustClaim Mfg Product Code"; Rec."AQD CustClaim Mfg Product Code")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = PriceMatchFieldsvisibility;
            }
        }
        addafter(Description)
        {
            field("AQD CustClaim Service Code"; Rec."AQD CustClaim Service Code")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Program Code"; Rec."AQD CustClaim Program Code")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = PriceMatchFieldsvisibility;
            }
            field("AQD CustClaim Vendor No."; Rec."AQD CustClaim Vendor No.")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = PriceMatchFieldsvisibility;
            }
            field("AQD CustClaim Vendor Name"; Rec."AQD CustClaim Vendor Name")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Width = 30;
                Visible = PriceMatchFieldsvisibility;
            }
            Field("AQD Customer Claim Code"; Rec."AQD Customer Claim Code")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
                Visible = PriceMatchFieldsvisibility;
            }
            Field("AQD Claim Line Type"; Rec."AQD Claim Line Type")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
                Visible = PriceMatchFieldsvisibility;
            }
        }
        addlast(Control1)
        {
            field("AQD Customer Claim Line"; Rec."AQD Customer Claim Line")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Manual Line"; Rec."AQD CustClaim Manual Line")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Orig Order No."; Rec."AQD CustClaim Orig Order No.")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
            field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Visible = false;
            }
        }
    }
    procedure SetPriceMatchFieldsvisibility(PriceMatchFieldsvisibilityIn: Boolean)
    begin
        PriceMatchFieldsvisibility := PriceMatchFieldsvisibilityIn;
    end;

    var
        PriceMatchFieldsvisibility: Boolean;
}