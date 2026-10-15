
codeunit 14302511 "AQD rebates journal Mgt"
{
    trigger OnRun()
    begin
        OpenRebateSalesJournal();
    end;

    procedure OpenRebateSalesJournal()
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        RebateSetup.Get();
        RebateSetup.TestField("Sales Journal Template Name");
        RebateSetup.TestField("Sales Journal Batch Name");

        GenJournalBatch.Get(RebateSetup."Sales Journal Template Name", RebateSetup."Sales Journal Batch Name");

        // Secure filters in FilterGroup 2 so Rec.GetRangeMin passes in OnOpenPage
        GenJournalLine.FilterGroup(2);
        GenJournalLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
        GenJournalLine.FilterGroup(0);

        PAGE.Run(PAGE::"AQD Rebate Adjustment Journal", GenJournalLine);
    end;
}
