pageextension 14302631 "AQD CR Customer Posting Groups" extends "Customer Posting Groups"
{
    procedure GetSelectionFilter(): Text
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(CustomerPostingGroup);
        exit(SelectionFilterManagement.GetSelectionFilterForCustomerPostingGroups(CustomerPostingGroup));
    end;
}