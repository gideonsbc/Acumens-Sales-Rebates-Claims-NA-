pageextension 14302617 "AQD CustClaim SalesOrd Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter("No.")
        {
            Field("AQD CustClaim Mfg Product Code"; Rec."AQD CustClaim Mfg Product Code")
            {
                ApplicationArea = All;
            }
        }
        addafter(Description)
        {
            field("AQD CustClaim Service Code"; Rec."AQD CustClaim Service Code")
            {
                ApplicationArea = All;
                Visible = PriceMatchFieldsvisibility;
                ShowMandatory = ShowServiceCodeMandatory;
            }
            field("AQD CustClaim Program Code"; Rec."AQD CustClaim Program Code")
            {
                ApplicationArea = All;
                Visible = PriceMatchFieldsvisibility;
                ShowMandatory = ShowProgramCodeMandatory;
            }
            field("AQD CustClaim Vendor No."; Rec."AQD CustClaim Vendor No.")
            {
                ApplicationArea = All;
                Visible = PriceMatchFieldsvisibility;
            }
            field("AQD CustClaim Vendor Name"; Rec."AQD CustClaim Vendor Name")
            {
                ApplicationArea = All;
                Width = 30;
                Visible = PriceMatchFieldsvisibility;
            }
        }
        addlast(Control1)
        {
            field("AQD Customer Claim Line"; Rec."AQD Customer Claim Line")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Manual Line"; Rec."AQD CustClaim Manual Line")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Orig Order No."; Rec."AQD CustClaim Orig Order No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("AQD CustClaim Orig OdrLine No."; Rec."AQD CustClaim Orig OdrLine No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ClaimSetup.GET;
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