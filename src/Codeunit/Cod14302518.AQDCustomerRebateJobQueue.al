codeunit 14302518 "AQD Customer Rebate Job Queue"
{
    Permissions = tabledata "Job Queue Entry" = RIMD;

    procedure EnsureJobQueueRunning()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"AQD Post Customer Rebates");
        if JobQueueEntry.FindFirst() then begin
            if JobQueueEntry.Status in [JobQueueEntry.Status::Error, JobQueueEntry.Status::"On Hold"] then
                JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
            exit;
        end;

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
        JobQueueEntry."Object ID to Run" := Report::"AQD Post Customer Rebates";
        JobQueueEntry.Description := 'Post Customer Rebates';
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry."Report Output Type" := JobQueueEntry."Report Output Type"::"None (Processing only)";
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Insert(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;
}