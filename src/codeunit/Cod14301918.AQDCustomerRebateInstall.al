codeunit 14301918 "AQD Customer Rebate Install"
{
    Subtype = Install;

    trigger OnRun()
    begin

    end;

    trigger OnInstallAppPerCompany()
    var
        JobQueueEntry: Record "Job Queue Entry";
        GenCustRebateText: Label 'Generate Customer Rebate';
        CustRebateDetails: Record "AQD Customer Rebate Details";
        PostedCustRebateDetails: Record "AQD Posted Cust Reb Details";
    begin
        // CustRebateDetails.ModifyAll("Entity Type", CustRebateDetails."Entity Type"::Customer);
        // PostedCustRebateDetails.ModifyAll("Entity Type", PostedCustRebateDetails."Entity Type"::Customer);

        JobQueueEntry.RESET;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"AQD Generate Customer Rebates");
        IF NOT JobQueueEntry.FindFirst() THEN begin
            JobQueueEntry.Init();
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
            JobQueueEntry."Object ID to Run" := Report::"AQD Generate Customer Rebates";
            JobQueueEntry.Description := GenCustRebateText;
            JobQueueEntry."Starting Time" := Time;
            JobQueueEntry."Ending Time" := Time;
            JobQueueEntry.Validate("Run on Mondays", TRUE);
            JobQueueEntry.Validate("Run on Tuesdays", TRUE);
            JobQueueEntry.Validate("Run on Wednesdays", TRUE);
            JobQueueEntry.Validate("Run on Thursdays", TRUE);
            JobQueueEntry.Validate("Run on Fridays", TRUE);
            JobQueueEntry.Validate("Run on Saturdays", TRUE);
            JobQueueEntry.Validate("Run on Sundays", TRUE);
            JobQueueEntry."No. of Minutes between Runs" := 1;
            JobQueueEntry.Insert(true);
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        END;
    END;
}