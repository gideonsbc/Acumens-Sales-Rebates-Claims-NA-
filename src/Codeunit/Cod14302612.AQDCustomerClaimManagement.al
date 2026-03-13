codeunit 14302612 "AQD Customer Claim Management"
{
    trigger OnRun()
    BEGIN
        CASE TRUE OF
            RunForFullPriceClaims:
                BEGIN
                    CreateFullPriceClaims();
                END;
            RunForPriceMatchClaims:
                BEGIN
                    CreatePriceMatchClaims();
                END;
        END;
    END;

    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ClaimHeader: Record "AQD Customer Claim Header";
        Location: Record Location;
        ClaimError: Record "AQD Customer Claim Errors";
        ClaimProcesing: Codeunit "AQD Customer Claim Process";
        CustomerClaimSingleInstance: Codeunit "AQD CustRbtClaim SngleInstance";
        RecreateClaim: Boolean;
        RecreateClaimMemo: Boolean;
        ShowResult: Boolean;
        RunForFullPriceClaims: Boolean;
        RunForPriceMatchClaims: Boolean;
        RunForFullPriceClaimMemos: Boolean;
        CurrentRecord: Boolean;
        Window: Dialog;
        TotalCount: Integer;
        SuccessfulCount: Integer;
        ErrorCount: Integer;
        ObjectTypetoRun: Option ,,,Report,,Codeunit;
        ClaimErrorSourceType: Enum "AQD CustClaim Error SourceType";
        ResultMessage: Text[250];
        Text001: Label 'Total Records: %1  Successful: %2  Errors: %3';
        Text002: Label 'Creating Claim No. #1##############';
        Text003: Label 'Creating Credit for Claim No. #1##############';

    procedure SetCreateFullPriceClaimsParameters(VAR SalesHeaderIn: Record "Sales Header"; CurrentRecordIn: Boolean; RecreateClaimIn: Boolean; ShowResultIn: Boolean)
    BEGIN
        IF CurrentRecordIn THEN BEGIN
            SalesHeader := SalesHeaderIn;
            SalesHeader.SetRecFilter();
        END ELSE
            SalesHeader.COPYFILTERS(SalesHeaderIn);
        CurrentRecord := CurrentRecordIn;
        RecreateClaim := RecreateClaimIn;
        ShowResult := ShowResultIn;
        RunForFullPriceClaims := TRUE;
    END;

    procedure SetCreatePriceMatchClaimsParameters(VAR SalesInvoiceHeaderIn: Record "Sales Invoice Header"; CurrentRecordIn: Boolean; RecreateClaimIn: Boolean; ShowResultIn: Boolean)
    BEGIN
        IF CurrentRecordIn THEN BEGIN
            SalesInvoiceHeader := SalesInvoiceHeaderIn;
            SalesInvoiceHeader.SetRecFilter();
        END ELSE
            SalesInvoiceHeader.COPYFILTERS(SalesInvoiceHeaderIn);
        CurrentRecord := CurrentRecordIn;
        RecreateClaim := RecreateClaimIn;
        ShowResult := ShowResultIn;
        RunForPriceMatchClaims := TRUE;
    END;

    local procedure CreateFullPriceClaims()
    var
        LocalSalesHeader: Record "Sales Header";
        LocalClaimHeader: Record "AQD Customer Claim Header";
    BEGIN
        InitializeVariables();
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SETRANGE("AQD CustClaim Claim Type", SalesHeader."AQD CustClaim Claim Type"::"Full Price");
        SalesHeader.SETRANGE("AQD Claim Status", SalesHeader."AQD Claim Status"::" ");
        IF RecreateClaim THEN
            SalesHeader.SETFILTER("AQD Claim Status", '%1|%2|%3',
              SalesHeader."AQD Claim Status"::" ",
              SalesHeader."AQD Claim Status"::Created,
              SalesHeader."AQD Claim Status"::Rejected);
        IF SalesHeader.FINDFIRST THEN BEGIN
            OpenWindow(Text002);

            TotalCount := SalesHeader.COUNT;
            REPEAT
                CLEARLASTERROR;
                UpdateWindow(1, SalesHeader."No.");

                IF OrderHasClaimLine(SalesHeader) THEN BEGIN
                    LocalSalesHeader.GET(SalesHeader."Document Type", SalesHeader."No.");
                    IF Location.GET(LocalSalesHeader."Location Code") AND
                      Location."AQM CustFullPriceClaim Enabled"
                    THEN BEGIN
                        CLEAR(ClaimProcesing);
                        ClaimProcesing.SetCreateFullPriceClaimsParameters(LocalSalesHeader, RecreateClaim, RunForFullPriceClaims);
                        IF ClaimProcesing.RUN THEN
                            SuccessfulCount += 1
                        ELSE BEGIN
                            ClaimProcesing.InsertClaimError(LocalSalesHeader."No.",
                                LocalSalesHeader."No.",
                                0,
                                '',
                                COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(ClaimError.Description)),
                                TRUE,
                                ClaimErrorSourceType::"Claim Creation",
                                FALSE);
                            ErrorCount += 1
                        END;

                        COMMIT;
                    END ELSE
                        TotalCount := TotalCount - 1;
                END ELSE
                    TotalCount := TotalCount - 1;
            UNTIL SalesHeader.NEXT = 0;
            CloseWindow();
        END;

        IF ShowResult THEN
            ShowProcessResult(ObjectTypetoRun::Report, REPORT::"AQD Create CustFullPriceClaims");
    END;

    local procedure CreatePriceMatchClaims()
    var
        LocalSalesInvoiceHeader: Record "Sales Invoice Header";
        LocalClaimHeader: Record "AQD Customer Claim Header";
    BEGIN
        InitializeVariables();
        SalesInvoiceHeader.SETRANGE("AQD CustClaim Claim Type", SalesInvoiceHeader."AQD CustClaim Claim Type"::"Price Match");
        SalesInvoiceHeader.SETRANGE("AQD Claim Status", SalesInvoiceHeader."AQD Claim Status"::" ");
        IF RecreateClaim THEN
            SalesInvoiceHeader.SETFILTER("AQD Claim Status", '%1|%2',
                 SalesInvoiceHeader."AQD Claim Status"::" ",
                 SalesInvoiceHeader."AQD Claim Status"::Rejected);
        IF SalesInvoiceHeader.FINDFIRST THEN BEGIN
            OpenWindow(Text002);

            TotalCount := SalesInvoiceHeader.COUNT;
            REPEAT
                CLEARLASTERROR;
                UpdateWindow(1, SalesInvoiceHeader."No.");

                IF InvoiceHasClaimLine(SalesInvoiceHeader) THEN BEGIN
                    LocalSalesInvoiceHeader.GET(SalesInvoiceHeader."No.");
                    IF Location.GET(LocalSalesInvoiceHeader."Location Code") AND
                      Location."AQM CustFullPriceClaim Enabled"
                    THEN BEGIN
                        CLEAR(ClaimProcesing);
                        ClaimProcesing.SetCreatePriceMatchClaimsParameters(LocalSalesInvoiceHeader, CurrentRecord, RecreateClaim, ShowResult);
                        IF ClaimProcesing.RUN THEN
                            SuccessfulCount += 1
                        ELSE BEGIN
                            ClaimProcesing.InsertClaimError(LocalSalesInvoiceHeader."No.",
                                LocalSalesInvoiceHeader."No.",
                                0,
                                '',
                                COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(ClaimError.Description)),
                                TRUE,
                                ClaimErrorSourceType::"Claim Creation",
                                FALSE);
                            ErrorCount += 1
                        END;

                        COMMIT;
                    END ELSE
                        TotalCount := TotalCount - 1;
                END ELSE
                    TotalCount := TotalCount - 1;
            UNTIL SalesInvoiceHeader.NEXT = 0;
            CloseWindow();
        END;

        IF ShowResult THEN
            ShowProcessResult(ObjectTypetoRun::Report, REPORT::"AQD Create CustPriceMatchClaim");
    END;

    LOCAL procedure OrderHasClaimLine(LocalSalesHeader: Record "Sales Header"): Boolean
    var
        LocalSalesLine: Record "Sales Line";
        ClaimLineExist: Boolean;
    BEGIN
        LocalSalesLine.RESET;
        LocalSalesLine.SETRANGE("Document Type", LocalSalesHeader."Document Type");
        LocalSalesLine.SETRANGE("Document No.", LocalSalesHeader."No.");
        IF LocalSalesLine.FINDFIRST THEN BEGIN
            REPEAT
                ClaimLineExist := ClaimProcesing.IsSalesLineClaimable(LocalSalesLine, TRUE);
            UNTIL (LocalSalesLine.NEXT = 0) OR ClaimLineExist;
        END;

        EXIT(ClaimLineExist);
    END;

    LOCAL procedure InvoiceHasClaimLine(LocalSalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        LocalSalesInvoiceLine: Record "Sales Invoice Line";
        ClaimLineExist: Boolean;
    BEGIN
        LocalSalesInvoiceLine.RESET;
        LocalSalesInvoiceLine.SETRANGE("Document No.", LocalSalesInvoiceHeader."No.");
        IF LocalSalesInvoiceLine.FINDFIRST THEN BEGIN
            REPEAT
                ClaimLineExist := ClaimProcesing.IsSalesInvoiceLineClaimable(LocalSalesInvoiceLine, TRUE);
            UNTIL (LocalSalesInvoiceLine.NEXT = 0) OR ClaimLineExist;
        END;

        EXIT(ClaimLineExist);
    END;

    LOCAL procedure OpenWindow(Message: Text[80])
    BEGIN
        IF GUIALLOWED THEN
            Window.OPEN(Message);
    END;

    LOCAL procedure UpdateWindow(UpdateNumber: Integer; UpdateValue: Text[80])
    begin
        IF GUIALLOWED THEN
            Window.UPDATE(UpdateNumber, UpdateValue);
    end;

    LOCAL procedure CloseWindow()
    begin
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    LOCAL procedure InitializeVariables()
    begin
        TotalCount := 0;
        SuccessfulCount := 0;
        ErrorCount := 0;
        ResultMessage := '';
    end;

    local procedure ShowProcessResult(ObjectTypetoRun_P: Option ,,,"Report",,"Codeunit"; ObjectIDToRun_P: Integer)
    begin
        ResultMessage := StrSubstNo(Text001, TotalCount, SuccessfulCount, ErrorCount);
        IF GuiAllowed THEN BEGIN
            IF ShowResult THEN
                Message(ResultMessage)
        END ELSE
            CustomerClaimSingleInstance.SetCustomerClaimBatchResult(ResultMessage);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', false, false)]
    local procedure Cod472_JobQueueEntry_OnBeforeModifyLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry"; var JobQueueEntry: Record "Job Queue Entry")
    var
        LocalJobQueueLogEntry: Record "Job Queue Log Entry";
        LocalResultMessage: Text[250];
    begin
        CustomerClaimSingleInstance.GetCustomerClaimBatchResult(LocalResultMessage);
        JobQueueLogEntry."Error Message" := LocalResultMessage;
    end;
}