pageextension 14302633 "AQD CR GPO Membership" extends "AQD CF GPO Membership"
{
    procedure GetSelectionFilter(): Text
    var
        GPOMembership: Record "AQD CF GPO Membership";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(GPOMembership);
        exit(SelectionFilterManagement.GetSelectionFilterForGPOMembership(GPOMembership));
    end;
}