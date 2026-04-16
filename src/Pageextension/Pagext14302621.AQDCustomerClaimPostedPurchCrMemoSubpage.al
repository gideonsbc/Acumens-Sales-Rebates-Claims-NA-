pageextension 14302621 "AQD CustClm PstdPurCrMemoSubpg" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
            Field("AQD Customer Claim Code"; Rec."AQD Customer Claim Code")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Claim Code field.', Comment = '%';
            }
            Field("AQD Claim Line Type"; Rec."AQD Claim Line Type")
            {
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
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Original Order No. field.', Comment = '%';
                Visible = false;
            }
            Field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ApplicationArea = All;
                Editable = FALSE;
                Enabled = FALSE;
                ToolTip = 'Specifies the value of the Customer Original Order Line No. field.', Comment = '%';
                Visible = false;
            }
        }
    }
}