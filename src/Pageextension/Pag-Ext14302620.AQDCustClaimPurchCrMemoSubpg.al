pageextension 14302620 "AQD CustClaim PurchCrMemoSubpg" extends "Purch. Cr. Memo Subform"
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
                Visible = false;
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
            }
            Field("AQD Claim Line Type"; Rec."AQD Claim Line Type")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                Visible = false;
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Line Type field.', Comment = '%';
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
}