pageextension 14302632 "AQD CR Corporate Affiliation" extends "AQD CF Corporate Affiliation"
{
    procedure GetSelectionFilter(): Text
    var
        CorporateAffiliation: Record "AQD CF Corporate Affiliation";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(CorporateAffiliation);
        exit(SelectionFilterManagement.GetSelectionFilterForCorporateAffiliation(CorporateAffiliation));
    end;
}