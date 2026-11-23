pageextension 14302617 "AQD CustClaim SalesOrd Subform" extends "Sales Order Subform"
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

    trigger OnOpenPage()
    begin
        if not ClaimSetup.GET then
            exit;
        ShowProgramCodeMandatory := ClaimSetup."Price Match ClaimProgCode Mand";
        ShowServiceCodeMandatory := ClaimSetup."Price Match ClaimServCode Mand";
    end;

    trigger OnAfterGetCurrRecord()
    BEGIN
    END;

    trigger OnAfterGetRecord()
    BEGIN
    END;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        PriceMatchFieldsvisibility: Boolean;
        ShowProgramCodeMandatory: Boolean;
        ShowServiceCodeMandatory: Boolean;
}