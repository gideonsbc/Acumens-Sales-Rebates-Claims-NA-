codeunit 14302517 "AQD Customer Rebate Install"
{
    Subtype = Install;

    trigger OnRun()
    begin

    end;

    trigger OnInstallAppPerCompany()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        UserSetup: Record "User Setup";
        ModifyRecord: Boolean;
        JobQueueEntry: Record "Job Queue Entry";
        GenCustRebateText: Label 'Generate Customer Rebate';
        CustRebateDetails: Record "AQD Customer Rebate Details";
        PostedCustRebateDetails: Record "AQD Posted Cust Reb Details";
    begin
        ModifyRecord := false;
        IF NOT SalesSetup.GET THEN BEGIN
            SalesSetup.Init();
            SalesSetup.Insert();
        END;
        IF NOT SalesSetup."Return Receipt on Credit Memo" THEN BEGIN
            SalesSetup."Return Receipt on Credit Memo" := TRUE;
            ModifyRecord := TRUE;
        END;
        IF NOT SalesSetup."Shipment on Invoice" THEN BEGIN
            SalesSetup."Shipment on Invoice" := TRUE;
            ModifyRecord := TRUE;
        END;
        IF ModifyRecord THEN
            SalesSetup.Modify();

        UserSetup.RESET;
        UserSetup.SetRange("AQD Cust Rebate Rebate Role", UserSetup."AQD Cust Rebate Rebate Role"::" ");
        UserSetup.ModifyAll("AQD Cust Rebate Rebate Role", UserSetup."AQD Cust Rebate Rebate Role"::Admin);

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

        IF NavApp.GetCurrentModuleInfo(NewAppVersion) THEN
            IF NewAppVersion.AppVersion = Version.Create(25, 1023, 1, 35) then BEGIN
                IF NOT VendorRebateRateNew.FindFirst() THEN BEGIN
                    VendorRebateRate.RESET;
                    IF VendorRebateRate.FindFirst() THEN BEGIN
                        REPEAT
                            VendorRebateRateNew.Init();
                            VendorRebateRateNew."Entry No." := 0;
                            VendorRebateRateNew."Rate Type" := VendorRebateRate."Rate Type";
                            VendorRebateRateNew."Line Type" := VendorRebateRate."Line Type";
                            VendorRebateRateNew."No." := VendorRebateRate."No.";
                            VendorRebateRateNew."Variant Code" := VendorRebateRate."Variant Code";
                            VendorRebateRateNew."Payee Type" := VendorRebateRate."Payee Type";
                            VendorRebateRateNew."Payee No." := VendorRebateRate."Payee No.";
                            VendorRebateRateNew."Program Code" := VendorRebateRate."Program Code";
                            VendorRebateRateNew."Starting Date" := VendorRebateRate."Starting Date";
                            VendorRebateRateNew."Minimum Quantity" := VendorRebateRate."Minimum Quantity";
                            VendorRebateRateNew."Customer Type" := VendorRebateRate."Customer Type";
                            VendorRebateRateNew."Customer No. Filter" := VendorRebateRate."Customer No. Filter New";
                            VendorRebateRateNew."Minimum Amount" := VendorRebateRate."Minimum Amount";
                            VendorRebateRateNew.Description := VendorRebateRate.Description;
                            VendorRebateRateNew."Rebate Type" := VendorRebateRate."Rebate Type";
                            VendorRebateRateNew."Rebate %" := VendorRebateRate."Rebate %";
                            VendorRebateRateNew."Rebate Per Unit" := VendorRebateRate."Rebate Per Unit";
                            VendorRebateRateNew."Ending Date" := VendorRebateRate."Ending Date";
                            VendorRebateRateNew."Unit of Measure Code" := VendorRebateRate."Unit of Measure Code";
                            VendorRebateRateNew."Last Changed DataTime" := VendorRebateRate."Last Changed DataTime";
                            VendorRebateRateNew."Last Changed Changed By" := VendorRebateRate."Last Changed Changed By";
                            VendorRebateRateNew."Last Rebate Type" := VendorRebateRate."Last Rebate Type";
                            VendorRebateRateNew."Last Rebate Per Unit" := VendorRebateRate."Last Rebate Per Unit";
                            VendorRebateRateNew."Last Rebate %" := VendorRebateRate."Last Rebate %";
                            VendorRebateRateNew.Blocked := VendorRebateRate.Blocked;
                            VendorRebateRateNew."Blocked By" := VendorRebateRate."Blocked By";
                            VendorRebateRateNew."Blocked Date Time" := VendorRebateRate."Blocked Date Time";
                            IF VendorRebateRateNew.Insert() THEN;
                        UNTIL VendorRebateRate.Next() = 0;
                    END;
                END;
            END;
    END;

    var
        NewAppVersion: ModuleInfo;
        VendorRebateRate: Record "AQD Sales Rebates Rate";
        VendorRebateRateNew: Record "AQD Sales Rebates Rate New";
}