codeunit 14302516 "AQD Customer Rebate Post Mgt"
{
    trigger OnRun()
    begin
        CASE RunBy OF
            RunBy::"Customer Rebate Batch":
                PostCustomerRebateBatch();
            RunBy::"Auto Process Customer Rebate":
                AutoProcesssCustomerRebate();
        END;
    END;

    procedure SetCustomerRebateBatchParameters(var RunByIn: Enum "AQD Customer Rebate Posting"; var CustomerRebateBatchIn: Record "AQD Customer Rebate Batch"; ShowResultIn: Boolean; CalledFromGenerateCustomerRebateIn: Boolean)
    begin
        RunBy := RunByIn;
        ShowResult := ShowResultIn;
        CalledFromGenerateCustomerRebate := CalledFromGenerateCustomerRebateIn;
        CustomerRebateBatch.CopyFilters(CustomerRebateBatchIn);
    end;

    procedure SetCustomerRebateParameters(var RunByIn: Enum "AQD Customer Rebate Posting"; var CustomerRebateHeaderIn: Record "AQD Customer Rebate Header"; CalledFromGenerateCustomerRebateIn: Boolean)
    begin
        RunBy := RunByIn;
        GlobalCustomerRebateHeader.COPYFILTERS(CustomerRebateHeaderIn);
        CalledFromGenerateCustomerRebate := CalledFromGenerateCustomerRebateIn;
    end;

    local procedure PostCustomerRebateBatch()
    var
        UpdateRecord: Boolean;
    begin
        OpenWindow(Text002);

        InitializeVariables();

        TotalCount := CustomerRebateBatch.Count;

        IF CustomerRebateBatch.FindFirst() THEN BEGIN
            REPEAT
                COMMIT; // There is nothing to commit except real time transaction

                ClearLastError();
                UpdateWindow(1, CustomerRebateBatch.BatchID);


                if CustomerRebateBatch."Last Processing Error Message" <> '' then begin
                    CustomerRebateBatch."Last Processing Error Message" := '';
                    UpdateRecord := true;
                end;

                Clear(CustomerRebatePost);
                CustomerRebatePost.SetCustomerRebateBatchParameters(RunBy, CustomerRebateBatch, CalledFromGenerateCustomerRebate);
                if CustomerRebatePost.Run() then begin
                    SuccessfulCount += 1;
                    UpdateRecord := false;
                end else begin
                    CustomerRebateBatch.GET(CustomerRebateBatch."Entry No."); // Read Agin
                    CustomerRebateBatch."Last Processing Error Message" := COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(CustomerRebateBatch."Last Processing Error Message"));
                    UpdateRecord := true;
                    ErrorCount += 1;
                end;
                if UpdateRecord then
                    CustomerRebateBatch.Modify();
                Commit();
            UNTIL CustomerRebateBatch.Next() = 0;
        END;

        CloseWindow();
        ShowProcessResult(ObjectTypetoRun::Report, REPORT::"AQD Post Cust Rebate Batches");
    end;

    local procedure AutoProcesssCustomerRebate()
    var
        UpdateRecord: Boolean;
    begin
        OpenWindow(Text003);

        InitializeVariables();

        TotalCount := GlobalCustomerRebateHeader.Count;

        IF GlobalCustomerRebateHeader.FindFirst() THEN BEGIN
            COMMIT; // There is nothing to commit except real time transaction
            ClearLastError();

            Clear(CustomerRebatePost);
            CustomerRebatePost.SetCustomerRebateParameters(RunBy, GlobalCustomerRebateHeader, CalledFromGenerateCustomerRebate);
            if CustomerRebatePost.Run() then
                SuccessfulCount += 1
            else
                ErrorCount += 1;
            Commit();
        END;

        CloseWindow();
        ShowProcessResult(ObjectTypetoRun::Report, 0);
    end;

    local procedure OpenWindow(Message: Text[80])
    begin
        if GuiAllowed then
            Window.Open(Message);
    end;

    local procedure UpdateWindow(UpdateNumber: Integer; UpdateValue: Text[80])
    begin
        if GuiAllowed then
            Window.Update(UpdateNumber, UpdateValue);
    end;

    local procedure CloseWindow()
    begin
        if GuiAllowed then
            Window.Close();
    end;

    local procedure ShowProcessResult(ObjectTypetoRun_P: Option ,,,"Report",,"Codeunit"; ObjectIDToRun_P: Integer)
    begin
        ResultMessage := StrSubstNo(Text005, TotalCount, SuccessfulCount, ErrorCount);
        IF GuiAllowed THEN BEGIN
            IF ShowResult THEN
                Message(ResultMessage)
        END ELSE
            VendorRebateSingleInstance.SetCustomerRebateBatchResult(ResultMessage);
    end;

    local procedure InitializeVariables()
    begin
        TotalCount := 0;
        SuccessfulCount := 0;
        ErrorCount := 0;
        ResultMessage := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', false, false)]
    local procedure CU_472_JobQueueEntry_OnBeforeModifyLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry"; var JobQueueEntry: Record "Job Queue Entry")
    var
        LocalJobQueueLogEntry: Record "Job Queue Log Entry";
        LocalResultMessage: Text[250];
    begin
        VendorRebateSingleInstance.GetCustomerRebateBatchResult(LocalResultMessage);
        JobQueueLogEntry."Error Message" := LocalResultMessage;
    end;

    var
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        VendorRebateSingleInstance: Codeunit "AQD CustRbtClaim SngleInstance";
        RunBy: Enum "AQD Customer Rebate Posting";
        Window: Dialog;
        ObjectTypetoRun: Option ,,,"Report",,"Codeunit";
        ResultMessage: Text[250];
        Text005: Label 'Total Records: %1  Successful: %2  Errors: %3';
        Text002: Label 'Processing Customer Rebate Batch #1##############';
        Text003: Label 'Processing Customer Rebate';
        TotalCount: Integer;
        SuccessfulCount: Integer;
        ErrorCount: Integer;
        ShowResult: Boolean;
        CalledFromGenerateCustomerRebate: Boolean;
        GlobalCustomerRebateHeader: Record "AQD Customer Rebate Header";
}