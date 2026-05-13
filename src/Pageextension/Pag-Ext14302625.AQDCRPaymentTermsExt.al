pageextension 14302625 "AQD CR Payment Terms Ext" extends "Payment Terms"
{
    procedure GetSelectionFilter(): Text
    var
        PaymentTerms: Record "Payment Terms";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(PaymentTerms);
        exit(SelectionFilterManagement.GetSelectionFilterForPaymentTerms(PaymentTerms));
    end;
}