pageextension 14302617 "AQD CustClaim SalesOrd Subform" extends "Sales Order Subform"
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
                Visible = false;
                ApplicationArea = All;
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
                ShowMandatory = ShowServiceCodeMandatory;
            }
            field("AQD CustClaim Program Code"; Rec."AQD CustClaim Program Code")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
                ShowMandatory = ShowProgramCodeMandatory;
            }
            field("AQD CustClaim Vendor No."; Rec."AQD CustClaim Vendor No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Vendor Name"; Rec."AQD CustClaim Vendor Name")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Width = 30;
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
                Visible = false;
            }
            field("AQD CustClaim Manual Line"; Rec."AQD CustClaim Manual Line")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Orig Order No."; Rec."AQD CustClaim Orig Order No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                ObsoleteTag = 'Deprecated in v25.1023.1.45';
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not ClaimSetup.GET then
            exit;
        ShowProgramCodeMandatory := ClaimSetup."Price Match ClaimProgCode Mand";
        ShowServiceCodeMandatory := ClaimSetup."Price Match ClaimServCode Mand";
    end;

    trigger OnAfterGetCurrRecord()
    BEGIN
        Rec.CalcFields("AQD CustClaim Vendor Name");
    END;

    trigger OnAfterGetRecord()
    BEGIN
        Rec.CalcFields("AQD CustClaim Vendor Name");
    END;

    [Obsolete('The Claims functionality has been discontinued and will be removed in a future release.', 'Deprecated in v25.1023.1.45')]
    procedure SetPriceMatchFieldsvisibility(PriceMatchFieldsvisibilityIn: Boolean)
    begin
        PriceMatchFieldsvisibility := PriceMatchFieldsvisibilityIn;
    end;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        PriceMatchFieldsvisibility: Boolean;
        ShowProgramCodeMandatory: Boolean;
        ShowServiceCodeMandatory: Boolean;
}