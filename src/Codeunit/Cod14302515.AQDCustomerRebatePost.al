codeunit 14302515 "AQD Customer Rebate Post"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Invoice Header" = rm,
                  tabledata "Return Receipt Header" = rm, tabledata "Sales Cr.Memo Header" = rm;
    trigger OnRun()
    begin
        RebateSetup.GET;
        CASE RunBy OF
            RunBy::"Customer Rebate Batch":
                BEGIN
                    PostCustomerRebateBatch(CustomerRebateBatch);
                END;
            RunBy::"Auto Process Customer Rebate":
                begin
                    AutoPostCustomerRebate(GlobalCustomerRebateHeader);
                end;
        END;
    END;

    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        GlobalCustomerRebateHeader: Record "AQD Customer Rebate Header";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        CustomerRebatecomments: Record "AQD Customer Rebate Comments";
        JnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line";
        TmpInvoicePostingBuffer: Record "Invoice Posting Buffer" Temporary;
        TmpInovoiceBuffer: Record "Invoice Posting Buffer" temporary;
        TmpCrMemoBuffer: Record "Invoice Posting Buffer" temporary;
        SalesInvoice: Record "Sales Header";
        SalesCredirMemo: Record "Sales Header";
        SalesCrMemoLine: Record "Sales Line";
        SalesInvoiceLine: Record "Sales Line";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        PostedCustomerRebateLineDetails: Record "AQD Posted Cust Reb Details";
        CreatedCustomerRebate: Record "AQD Created Customer Rebate";
        InvoicePostingBuffer: Record "Invoice Posting Buffer"; // This is Temporary Table
        GlobalEntityType: Enum "AQD CR Rebate Entity Type";
        CalledFromGenerateCustomerRebate: Boolean;
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        NoSeriesMgt: Codeunit "No. Series";
        TmpPostCustomerRebateByBillTo: Record "Invoice Posting Buffer" temporary;
        RunBy: Enum "AQD Customer Rebate Posting";
        GlobalGroupID: Text[20];
        PurchaseRebateForText: Label 'Purchase Rebate for ';
        SalesRebateForText: Label 'Sales Rebate For';

    procedure SetCustomerRebateBatchParameters(var RunByIn: Enum "AQD Customer Rebate Posting"; var CustomerRebateBatchIn: Record "AQD Customer Rebate Batch"; CalledFromGenerateCustomerRebateIn: Boolean)
    begin
        RunBy := RunByIn;
        CustomerRebateBatch := CustomerRebateBatchIn;
        CalledFromGenerateCustomerRebate := CalledFromGenerateCustomerRebateIn;
        CustomerRebateBatch.SetRecFilter();
    end;

    procedure SetCustomerRebateParameters(var RunByIn: Enum "AQD Customer Rebate Posting"; var CustomerRebateHeaderIn: Record "AQD Customer Rebate Header"; CalledFromGenerateCustomerRebateIn: Boolean)
    begin
        RunBy := RunByIn;
        CalledFromGenerateCustomerRebate := CalledFromGenerateCustomerRebateIn;
        GlobalCustomerRebateHeader := CustomerRebateHeaderIn;
        GlobalCustomerRebateHeader.SetRecFilter();
    end;

    procedure PostCustomerRebateBatch(var CustomerRebateBatch: Record "AQD Customer Rebate Batch")
    var
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        SavedRecords: Boolean;
        SkipRecord: Boolean;
    begin
        RebateSetup.Get();
        SavedRecords := FALSE;

        CustomerRebateBatch.TestField(BatchID);

        CustomerRebateHeader.RESET;
        CustomerRebateHeader.SetCurrentKey(BatchID);
        CustomerRebateHeader.SetRange("Batch Entry No.", CustomerRebateBatch."Entry No.");
        CustomerRebateHeader.SetRange(BatchID, CustomerRebateBatch.BatchID);
        IF CustomerRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                IF CustomerRebateHeader."Posting Date" <> CustomerRebateBatch."Posting Date" then begin
                    CustomerRebateHeader.Validate("Posting Date", CustomerRebateBatch."Posting Date");
                    CustomerRebateHeader.Modify();
                    SavedRecords := TRUE;
                end;
            until CustomerRebateHeader.Next() = 0;
            IF SavedRecords then
                Commit();
        end;

        IF CustomerRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                SkipRecord := FALSE;
                IF CalledFromGenerateCustomerRebate THEN begin
                    CreatedCustomerRebate.RESET;
                    CreatedCustomerRebate.SETRANGE("Rebate No.", CustomerRebateHeader."No.");
                    IF NOT CreatedCustomerRebate.FindFirst() THEN
                        SkipRecord := TRUE;
                end;

                IF NOT SkipRecord THEN BEGIN
                    OnBeforePostCustomerRebates(CustomerRebateHeader);
                    PostCustomerRebate(CustomerRebateHeader, FALSE);
                    OnAfterPostCustomerRebates(CustomerRebateHeader);
                END;
            until CustomerRebateHeader.Next() = 0;
        END
    end;

    procedure AutoPostCustomerRebate(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        SavedRecords: Boolean;
        SkipRecord: Boolean;
    begin
        RebateSetup.Get();
        SavedRecords := FALSE;

        SkipRecord := FALSE;
        IF CalledFromGenerateCustomerRebate THEN begin
            CreatedCustomerRebate.RESET;
            CreatedCustomerRebate.SETRANGE("Rebate No.", CustomerRebateHeader."No.");
            IF NOT CreatedCustomerRebate.FindFirst() THEN
                SkipRecord := TRUE;
        end;

        IF NOT SkipRecord THEN BEGIN
            CustomerRebateHeader.TestField("Posting Date");

            OnBeforePostCustomerRebates(CustomerRebateHeader);
            PostCustomerRebate(CustomerRebateHeader, FALSE);
            OnAfterPostCustomerRebates(CustomerRebateHeader);

        END;
    END;

    procedure PostCustomerRebate(var CustomerRebateHeader: Record "AQD Customer Rebate Header"; ShowDialogue: Boolean)
    var
        UserConfirmLabel: Label 'Do you want to post Customer Rebate %1?';
    begin
        IF ShowDialogue THEN
            IF NOT Confirm(StrSubstNo(UserConfirmLabel, CustomerRebateHeader."No.")) then
                EXIT;

        OnBeforePostCustomerRebates(CustomerRebateHeader);

        TmpPostCustomerRebateByBillTo.RESET;
        IF TmpPostCustomerRebateByBillTo.IsTemporary then
            TmpPostCustomerRebateByBillTo.DeleteAll();

        GlobalGroupID := 'G00000001';

        RebateSetup.Get();

        CustomerRebateHeader.TestField("Posting Date");

        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        IF CustomerRebateLine.FindSet() THEN BEGIN
            REPEAT
                CustomerRebateLine.CalcFields("Customer Rebate Amount", Ineligible);
                IF (CustomerRebateLine."Customer Rebate Amount" = 0) AND
                    CustomerRebateLine.Ineligible
                THEN BEGIN
                    CustomerRebateLine."Do Not Credit" := true;
                    CustomerRebateLine.Modify(true);
                END;
            UNTIL CustomerRebateLine.Next() = 0;
        END;
        UpdatePosted(CustomerRebateHeader);
        UpdateExcluded(CustomerRebateHeader);
        MoveCustomerRebates(CustomerRebateHeader);

        OnAfterPostCustomerRebates(CustomerRebateHeader);
    end;

    local procedure UpdatePosted(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindFirst() then begin
            repeat
                case CustomerRebateLine."Document Type" of
                    CustomerRebateLine."Document Type"::Invoice:
                        begin
                            if SalesInvoiceHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD Customer Rebate Status" := SalesInvoiceHeader."AQD Customer Rebate Status"::Posted;
                                SalesInvoiceHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                SalesInvoiceHeader."AQD Cust Rebate Program Code" := CustomerRebateLine."Cust Rebate Program Code";
                                SalesInvoiceHeader."AQD Marketplace Code" := CustomerRebateLine."Marketplace Code";
                                SalesInvoiceHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD Customer Rebate Status" := SalesCrMemoHeader."AQD Customer Rebate Status"::Posted;
                                SalesCrMemoHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                SalesCrMemoHeader."AQD Cust Rebate Program Code" := CustomerRebateLine."Cust Rebate Program Code";
                                SalesCrMemoHeader."AQD Marketplace Code" := CustomerRebateLine."Marketplace Code";
                                SalesCrMemoHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::Shipment:
                        begin
                            if SalesShipmentHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesShipmentHeader."AQD Customer Rebate Status" := SalesShipmentHeader."AQD Customer Rebate Status"::Posted;
                                SalesShipmentHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                SalesShipmentHeader."AQD Cust Rebate Program Code" := CustomerRebateLine."Cust Rebate Program Code";
                                SalesShipmentHeader."AQD Marketplace Code" := CustomerRebateLine."Marketplace Code";
                                SalesShipmentHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Return Receipt":
                        begin
                            if ReturnReceiptHeader.Get(CustomerRebateLine."Document No.") then begin
                                ReturnReceiptHeader."AQD Customer Rebate Status" := ReturnReceiptHeader."AQD Customer Rebate Status"::Posted;
                                ReturnReceiptHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                ReturnReceiptHeader."AQD Cust Rebate Program Code" := CustomerRebateLine."Cust Rebate Program Code";
                                ReturnReceiptHeader."AQD Marketplace Code" := CustomerRebateLine."Marketplace Code";
                                ReturnReceiptHeader.Modify(true);
                            end;
                        end;
                end;

            // RebateItemLdgrEntry.RESET;
            // RebateItemLdgrEntry.SetRange("AQD Rebate No", CustomerRebateLine."Rebate No.");
            // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", CustomerRebateLine."Line No.");
            // IF RebateItemLdgrEntry.FindFirst() THEN begin
            //     repeat
            //         RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
            //         RebateItemLdgrEntry.Modify();
            //     until RebateItemLdgrEntry.Next() = 0;
            // end;
            until CustomerRebateLine.Next() = 0;
        end;
    end;

    local procedure UpdateExcluded(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        CustomerRebateLine: Record "AQD Customer Rebate Line";
    //RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        CustomerRebateLine.SetRange("Do Not Credit", true);
        if CustomerRebateLine.FindSet() then begin
            repeat
                CustomerRebateLine.CalcFields("Customer Rebate Amount");
                case CustomerRebateLine."Document Type" of
                    CustomerRebateLine."Document Type"::Invoice:
                        begin
                            if SalesInvoiceHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD No Customer Rebate" := true;
                                SalesInvoiceHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD No Customer Rebate" := true;
                                SalesCrMemoHeader.Modify(true);
                            end;
                        end;
                end;

            // RebateItemLdgrEntry.RESET;
            // RebateItemLdgrEntry.SetRange("AQD Rebate No", CustomerRebateLine."Rebate No.");
            // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", CustomerRebateLine."Line No.");
            // IF RebateItemLdgrEntry.FindFirst() THEN begin
            //     repeat
            //         RebateItemLdgrEntry."AQD Do Not Pay Rebate" := CustomerRebateLine.Exclude;
            //         RebateItemLdgrEntry.Modify();
            //     until RebateItemLdgrEntry.Next() = 0;
            // end;
            until CustomerRebateLine.Next() = 0;
        end;
    end;

    local procedure MoveCustomerRebates(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustomerRebateBatch: Record "AQD Posted Cust Rebate Batch";
        LocalCustomerRebateHeader: Record "AQD Customer Rebate Header";
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        BillToCustomer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        GenJnlLine: Record "Gen. Journal Line";
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
        IF GenJnlLine.FindFirst() THEN
            GenJnlLine.DeleteAll();

        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindFirst() then begin
            PostedCustRebateHeader.Init();
            PostedCustRebateHeader.TransferFields(CustomerRebateHeader);
            //PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Posted;
            PostedCustRebateHeader.Insert();

            MoveCustomerRebateLine(CustomerRebateHeader);
            MoveCustomerRebateComments(CustomerRebateHeader);
            TmpPostCustomerRebateByBillTo.RESET;

            TmpInovoiceBuffer.RESET;
            IF TmpInovoiceBuffer.IsTemporary then
                TmpInovoiceBuffer.DeleteAll();

            TmpCrMemoBuffer.RESET;
            IF TmpCrMemoBuffer.IsTemporary then
                TmpCrMemoBuffer.DeleteAll();

            IF TmpPostCustomerRebateByBillTo.FindFirst() THEN BEGIN
                REPEAT
                    BillToCustomer.GET(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
                    Case RebateSetup."Rebate Payable Ac" OF
                        RebateSetup."Rebate Payable Ac"::Customer:
                            BEGIN
                                CreateSalesDocument(PostedCustRebateHeader, false);
                            END;
                        RebateSetup."Rebate Payable Ac"::"Rebate Payable AC":
                            BEGIN
                                CreateSalesJournal(PostedCustRebateHeader);
                            END;
                    END;
                UNTIL TmpPostCustomerRebateByBillTo.Next() = 0;
            END;

            Case RebateSetup."Rebate Payable Ac" OF
                RebateSetup."Rebate Payable Ac"::Customer:
                    BEGIN
                        TmpInovoiceBuffer.RESET;
                        IF TmpInovoiceBuffer.FindFirst() THEN BEGIN
                            REPEAT
                                IF SalesHeader.GET(TmpInovoiceBuffer."Dimension Set ID", // Document Type
                                                   TmpInovoiceBuffer."Job No.")          // Cr/Invoice No.
                                THEN BEGIN
                                    SalesHeader.Ship := TRUE;
                                    SalesHeader.Invoice := TRUE;
                                    SalesPost.Run(SalesHeader);
                                END;
                            UNTIL TmpInovoiceBuffer.Next() = 0;
                        END;

                        TmpCrMemoBuffer.RESET;
                        IF TmpCrMemoBuffer.FindFirst() THEN BEGIN
                            REPEAT
                                IF SalesHeader.GET(TmpCrMemoBuffer."Dimension Set ID", // Document Type
                                                   TmpCrMemoBuffer."Job No.")          // Cr/Invoice No.
                                THEN BEGIN
                                    SalesHeader.Receive := TRUE;
                                    SalesHeader.Invoice := TRUE;
                                    SalesPost.Run(SalesHeader);
                                END;
                            UNTIL TmpCrMemoBuffer.Next() = 0;
                        END;

                        GenJnlLine.RESET;
                        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                        GenJnlLine.SetRange("AQD Cust Rebate Journal", TRUE);
                        IF GenJnlLine.FindFirst() THEN
                            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                    END;
                RebateSetup."Rebate Payable Ac"::"Rebate Payable AC":
                    BEGIN
                        GenJnlLine.RESET;
                        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                        IF GenJnlLine.FindFirst() THEN
                            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                    END;
            END;
            //END;
            //END;

            CustomerRebateDetails.RESET;
            CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateHeader."No.");
            CustomerRebateDetails.DeleteAll();

            CustomerRebateLine.DeleteAll();

            CustomerRebatecomments.Reset();
            CustomerRebatecomments.SetRange("Rebate No.", CustomerRebateHeader."No.");
            CustomerRebatecomments.DeleteAll();

            CustomerRebateHeader.Delete();

            IF CustomerRebateHeader.BatchID <> '' THEN BEGIN
                LocalCustomerRebateHeader.RESET;
                LocalCustomerRebateHeader.SetRange("Batch Entry No.", CustomerRebateHeader."Batch Entry No.");
                LocalCustomerRebateHeader.SetRange(BatchID, CustomerRebateHeader.BatchID);
                IF NOT LocalCustomerRebateHeader.FindFirst() THEN begin
                    CustomerRebateBatch.RESET;
                    CustomerRebateBatch.SetRange("Entry No.", CustomerRebateHeader."Batch Entry No.");
                    CustomerRebateBatch.SETRANGE(BatchID, CustomerRebateHeader.BatchID);
                    IF CustomerRebateBatch.FindFirst() THEN BEGIN
                        PostedCustomerRebateBatch.Init();
                        PostedCustomerRebateBatch.TransferFields(CustomerRebateBatch);
                        PostedCustomerRebateBatch.Insert();
                        CustomerRebateBatch.Delete();
                    END;
                END;
            END;
        END;
    END;

    procedure CreateSalesFromPostedRebateDocument(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialogue: Boolean)
    var
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        GenJnlLine: Record "Gen. Journal Line";
        SalesPost: Codeunit "Sales-Post";
        UserConfirmMsg: Label 'Do you want to create Sales Document for Posted Rebate %1?';
        SuccessfulMsg: Label 'Sales Document is created successfully for Posted Customer Rebate %1.';
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        IF ShowDialogue THEN BEGIN
            IF NOT CONFIRM(StrSubstNo(UserConfirmMsg, PostedCustRebateHeader."No.")) then
                EXIT;
            IF PostedCustRebateHeader."Customer Rebate Status" <> PostedCustRebateHeader."Customer Rebate Status"::" " THEN
                Error(RebateStatusError, PostedCustRebateHeader."Customer Rebate Status");
        END;

        RebateSetup.GET;
        GlobalGroupID := 'G00000001';

        TmpPostCustomerRebateByBillTo.RESET;
        IF TmpPostCustomerRebateByBillTo.IsTemporary THEN
            TmpPostCustomerRebateByBillTo.DeleteAll();

        TmpInovoiceBuffer.RESET;
        IF TmpInovoiceBuffer.IsTemporary then
            TmpInovoiceBuffer.DeleteAll();

        TmpCrMemoBuffer.RESET;
        IF TmpCrMemoBuffer.IsTemporary then
            TmpCrMemoBuffer.DeleteAll();

        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        IF PostedCustRebateLine.FindFirst() THEN BEGIN
            REPEAT
                TmpPostCustomerRebateByBillTo.RESET;
                TmpPostCustomerRebateByBillTo.SetRange("G/L Account", PostedCustRebateLine."Rebate No.");
                TmpPostCustomerRebateByBillTo.SetRange("Gen. Bus. Posting Group", PostedCustRebateLine."Bill-To Customer No.");
                IF NOT TmpPostCustomerRebateByBillTo.FINDFIRST THEN BEGIN
                    TmpPostCustomerRebateByBillTo.Init();
                    TmpPostCustomerRebateByBillTo."Group ID" := GlobalGroupID;
                    TmpPostCustomerRebateByBillTo."G/L Account" := PostedCustRebateLine."Rebate No.";
                    TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group" := PostedCustRebateLine."Bill-To Customer No.";
                    TmpPostCustomerRebateByBillTo.INSERT;
                    GlobalGroupID := IncStr(GlobalGroupID);
                END;
            UNTIL PostedCustRebateLine.Next() = 0;
        END;

        TmpPostCustomerRebateByBillTo.RESET;
        IF TmpPostCustomerRebateByBillTo.FindFirst() THEN BEGIN
            REPEAT
                BillToCustomer.GET(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
                Case RebateSetup."Rebate Payable Ac" OF
                    RebateSetup."Rebate Payable Ac"::Customer:
                        BEGIN
                            CreateSalesDocument(PostedCustRebateHeader, false);
                        END;
                    RebateSetup."Rebate Payable Ac"::"Rebate Payable AC":
                        BEGIN
                            CreateSalesJournal(PostedCustRebateHeader);
                        END;
                END;
            UNTIL TmpPostCustomerRebateByBillTo.Next() = 0;
        END;

        Case RebateSetup."Rebate Payable Ac" OF
            RebateSetup."Rebate Payable Ac"::Customer:
                BEGIN

                    TmpInovoiceBuffer.RESET;
                    IF TmpInovoiceBuffer.FindFirst() THEN BEGIN
                        REPEAT
                            IF SalesHeader.GET(TmpInovoiceBuffer."Dimension Set ID", // Document Type
                                               TmpInovoiceBuffer."Job No.")          // Cr/Invoice No.
                            THEN BEGIN
                                SalesHeader.Ship := TRUE;
                                SalesHeader.Invoice := TRUE;
                                SalesPost.Run(SalesHeader);
                            END;
                        UNTIL TmpInovoiceBuffer.Next() = 0;
                    END;

                    TmpCrMemoBuffer.RESET;
                    IF TmpCrMemoBuffer.FindFirst() THEN BEGIN
                        REPEAT
                            IF SalesHeader.GET(TmpCrMemoBuffer."Dimension Set ID", // Document Type
                                               TmpCrMemoBuffer."Job No.")          // Cr/Invoice No.
                            THEN BEGIN
                                SalesHeader.Receive := TRUE;
                                SalesHeader.Invoice := TRUE;
                                SalesPost.Run(SalesHeader);
                            END;
                        UNTIL TmpCrMemoBuffer.Next() = 0;
                    END;

                    GenJnlLine.RESET;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    GenJnlLine.SetRange("AQD Cust Rebate Journal", TRUE);
                    IF GenJnlLine.FindFirst() THEN
                        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                END;
            RebateSetup."Rebate Payable Ac"::"Rebate Payable AC":
                BEGIN
                    GenJnlLine.RESET;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    GenJnlLine.SetRange("AQD Cust Rebate Journal", TRUE);
                    IF GenJnlLine.FindFirst() THEN
                        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                END;
        END;
        //END;
        IF ShowDialogue then
            Message(StrSubstNo(SuccessfulMsg, PostedCustRebateHeader."No."));
    END;

    local procedure MoveCustomerRebateLine(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        IF CustomerRebateLine.FindFirst() THEN BEGIN
            repeat
                TmpPostCustomerRebateByBillTo.RESET;
                TmpPostCustomerRebateByBillTo.SetRange("G/L Account", CustomerRebateLine."Rebate No.");
                TmpPostCustomerRebateByBillTo.SetRange("Gen. Bus. Posting Group", CustomerRebateLine."Bill-To Customer No.");
                IF NOT TmpPostCustomerRebateByBillTo.FINDFIRST THEN BEGIN
                    TmpPostCustomerRebateByBillTo.Init();
                    TmpPostCustomerRebateByBillTo."Group ID" := GlobalGroupID;
                    TmpPostCustomerRebateByBillTo."G/L Account" := CustomerRebateLine."Rebate No.";
                    TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group" := CustomerRebateLine."Bill-To Customer No.";
                    TmpPostCustomerRebateByBillTo.INSERT;
                    GlobalGroupID := IncStr(GlobalGroupID);
                END;

                MoveCustomerRebateDetails(CustomerRebateLine);

                PostedCustomerRebateLine.Init();
                PostedCustomerRebateLine.TransferFields(CustomerRebateLine);
                //PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateLine."Customer Rebate Status"::Posted;
                PostedCustomerRebateLine.Insert();
            //END;
            until CustomerRebateLine.Next() = 0;
        END;
    END;

    local procedure MoveCustomerRebateDetails(CustomerRebateLine: Record "AQD Customer Rebate Line")
    var
        PostedCustomerRebateDetails: Record "AQD Posted Cust Reb Details";
        DropshipmentInfo: Record "AQD Drop Shipment Information";
    begin
        CustomerRebateDetails.Reset();
        CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateLine."Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", CustomerRebateLine."Line No.");
        IF CustomerRebateDetails.FindSet() THEN BEGIN
            REPEAT
                PostedCustomerRebateDetails.Init();
                PostedCustomerRebateDetails.TransferFields(CustomerRebateDetails);
                //PostedCustomerRebateDetails."Customer Rebate Status" := PostedCustomerRebateDetails."Customer Rebate Status"::Posted;
                PostedCustomerRebateDetails.Insert();

                DropshipmentInfo.RESET;
                DropshipmentInfo.SETRANGE("Sales Order No.", PostedCustomerRebateDetails."Order No.");
                DropshipmentInfo.SETRANGE("Sales Order Line No.", PostedCustomerRebateDetails."Order Line No.");
                IF DropshipmentInfo.FindFirst() THEN BEGIN
                    DropshipmentInfo."AQD CustRbt Cust Rbt Amount" += PostedCustomerRebateDetails."Customer Rebate Amount";
                    DropshipmentInfo.Modify();
                END;
            UNTIL CustomerRebateDetails.Next() = 0;
        END;
    END;

    local procedure MoveCustomerRebateComments(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustomerRebateComments: Record "AQD Posted Cust Reb Comment";
    BEGIN
        CustomerRebatecomments.Reset();
        CustomerRebatecomments.SetRange("Rebate No.", CustomerRebateHeader."No.");
        IF CustomerRebatecomments.FINDFIRST THEN BEGIN
            REPEAT
                PostedCustomerRebateComments.Init();
                PostedCustomerRebateComments.TransferFields(CustomerRebatecomments);
                IF PostedCustomerRebateComments.Insert() THEN
                    CustomerRebatecomments.Delete();
            UNTIL CustomerRebatecomments.Next() = 0;
        END;
    END;

    procedure CreateSalesDocument(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialogue: Boolean)
    begin
        RebateSetup.GET;

        PostedCustomerRebateLine.Reset();
        PostedCustomerRebateLine.SetRange("Rebate No.", PostedCustomerRebateHeader."No.");
        PostedCustomerRebateLine.SetRange("Bill-To Customer No.", TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
        PostedCustomerRebateLine.SetRange(Posted, false);
        PostedCustomerRebateLine.SetRange("Customer Rebate Status", PostedCustomerRebateLine."Customer Rebate Status"::" ");
        PostedCustomerRebateLine.SetRange("Do Not Credit", false);
        If PostedCustomerRebateLine.FindFirst() Then Begin
            Repeat
                PostedCustomerRebateLine.CalcFields("Customer Rebate Amount");
                IF PostedCustomerRebateLine."Customer Rebate Amount" > 0 THEN Begin
                    //Create Sales Credit Memo
                    CreateSalesCrMemoLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END ELSE IF PostedCustomerRebateLine."Customer Rebate Amount" < 0 THEN Begin
                    //Create Sales Invoice
                    CreateSalesInvoiceLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END;
            Until PostedCustomerRebateLine.Next() = 0;
        End;
    End;

    local procedure CreateSalesCrMemoLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        SalesCredirMemo: Record "Sales Header";
        SalesCrMemoLine: Record "Sales Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        NextLineNo: Integer;
        LocalBillToCustomer: Record Customer;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        LocalCustomer: Record Customer;
        LocalCustomerCategory: Record "AQD Rebate Customer Category";
        DocumentNo: Code[20];
        LineNo: Integer;
        ItemChargeNextLineNo: Integer;
        VendLocalRebateAmount, EmpLocalRebateAmount : Decimal;
    begin
        PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)",
                                            "Vendor Commission", "Employee Commission");

        TmpCrMemoBuffer.RESET;
        TmpCrMemoBuffer.SetRange("G/L Account", TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
        IF NOT TmpCrMemoBuffer.FindFirst() THEN begin
            //Create Sales Credit Memo Header
            SalesCredirMemo.INIT;
            SalesCredirMemo.SetHideValidationDialog(TRUE);
            SalesCredirMemo."Document Type" := SalesCredirMemo."Document Type"::"Credit Memo";
            SalesCredirMemo."No." := '';
            SalesCredirMemo.Insert(TRUE);
            SalesCredirMemo.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Bill-To Customer No.");
            SalesCredirMemo.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Rebate Pay-To Customer No.");
            SalesCredirMemo.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."External Document No." := PostedCustomerRebateHeader."No.";
            SalesCredirMemo."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesCredirMemo."AQD Customer Rebate" := TRUE;
            SalesCredirMemo.Modify(TRUE);

            PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            TmpCrMemoBuffer.INIT;
            TmpCrMemoBuffer."Group ID" := GlobalGroupID;
            //BillTo Customer No.
            TmpCrMemoBuffer."G/L Account" := TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group";
            //Credit Memo No
            TmpCrMemoBuffer."Job No." := SalesCredirMemo."No.";
            //Document Type
            TmpCrMemoBuffer."Dimension Set ID" := SalesCredirMemo."Document Type".AsInteger();
            TmpCrMemoBuffer.INSERT;
            GlobalGroupID := IncStr(GlobalGroupID);
        end;

        NextLineNo := 0;
        ItemChargeNextLineNo := 0;
        SalesCrMemoLine.RESET;
        SalesCrMemoLine.SETRANGE("Document Type", SalesCrMemoLine."Document Type"::"Credit Memo");
        SalesCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Job No.");
        IF SalesCrMemoLine.FINDLAST THEN
            NextLineNo := SalesCrMemoLine."Line No."
        ELSE
            NextLineNo := 0;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Inventory);
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Customer);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    SalesCrMemoLine.INIT;
                    SalesCrMemoLine."Document Type" := SalesCrMemoLine."Document Type"::"Credit Memo";
                    SalesCrMemoLine."Document No." := TmpCrMemoBuffer."Job No.";
                    SalesCrMemoLine."Line No." := NextLineNo;
                    SalesCrMemoLine.Insert(TRUE);
                    SalesCrMemoLine.Validate(Type, SalesCrMemoLine.Type::"Charge (Item)");
                    SalesCrMemoLine.Validate("No.", RebateSetup."Sales Item Charge No.");
                    SalesCrMemoLine.Description := CopyStr(SalesRebateForText +
                                                           PostedCustomerRebateLine.Description + ' ' +
                                                           PostedCustomerRebateHeader."Posting Description",
                                                           1, MaxStrLen(SalesCrMemoLine.Description));

                    SalesCrMemoLine."Description 2" := CopyStr(FORMAT(PostedCustomerRebateLineDetails."Entity Type") + ' ' +
                                                                PostedCustomerRebateLineDetails."Entity No." + ' ' +
                                                                FORMAT(PostedCustomerRebateLineDetails.Type) + ' ' +
                                                                PostedCustomerRebateLineDetails."No." + ' ' +
                                                                PostedCustomerRebateLineDetails.Description,
                                                                1, MaxStrLen(SalesCrMemoLine."Description 2"));

                    SalesCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
                    SalesCrMemoLine.Validate(Quantity, 1);
                    SalesCrMemoLine.Validate("Unit Price", PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)");
                    IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                        SalesCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
                    IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                        SalesCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
                    SalesCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    SalesCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
                    SalesCrMemoLine.Modify(TRUE);

                    PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
                    PostedCustomerRebateLine."Rebate Payable A/C" := PostedCustomerRebateLine."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
                    PostedCustomerRebateLine.Modify();

                    ItemChargeNextLineNo += 10000;
                    ItemChargeAssignmentSales.Init();
                    ItemChargeAssignmentSales."Document Type" := SalesCrMemoLine."Document Type";
                    ItemChargeAssignmentSales."Document No." := SalesCrMemoLine."Document No.";
                    ItemChargeAssignmentSales."Document Line No." := SalesCrMemoLine."Line No.";
                    ItemChargeAssignmentSales."Line No." := NextLineNo;
                    ItemChargeAssignmentSales."Item Charge No." := SalesCrMemoLine."No.";
                    ItemChargeAssignmentSales."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentSales.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentSales."Qty. to Assign" := 0;
                    ItemChargeAssignmentSales."Qty. to Handle" := 0;
                    ItemChargeAssignmentSales."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentSales."Amount to Assign" := 0;
                    ItemChargeAssignmentSales."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Payable A/C" := PostedCustomerRebateLineDetails."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLineDetails."Rebate Sales Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Rebate Sales Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Rebate Sales Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify;

                    CLEAR(AssignItemChargeSales);
                    AssignItemChargeSales.AssignItemCharges(SalesCrMemoLine, SalesCrMemoLine.Quantity, SalesCrMemoLine.Amount, SalesCrMemoLine.Quantity, SalesCrMemoLine.Amount, 'By Amount');

                until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;

        IF PostedCustomerRebateLine."customer Rebate Amt (GL)" <> 0 THEN BEGIN
            GlobalEntityType := GlobalEntityType::Customer;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, FALSE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    SalesCrMemoLine.RESET;
                    SalesCrMemoLine.SETRANGE("Document Type", SalesCrMemoLine."Document Type"::"Credit Memo");
                    SalesCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Job No.");
                    IF SalesCrMemoLine.FINDLAST THEN
                        NextLineNo := SalesCrMemoLine."Line No." + 10000
                    ELSE
                        NextLineNo := 10000;

                    LocalCustomer.GET(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");

                    SalesCrMemoLine.INIT;
                    SalesCrMemoLine."Document Type" := SalesCrMemoLine."Document Type"::"Credit Memo";
                    SalesCrMemoLine."Document No." := TmpCrMemoBuffer."Job No.";
                    SalesCrMemoLine."Line No." := NextLineNo;
                    SalesCrMemoLine.Insert(TRUE);
                    SalesCrMemoLine.Validate(Type, SalesCrMemoLine.Type::"G/L Account");
                    //SalesCrMemoLine.Validate("No.", LocalCustomerCategory."G/L Account No.");
                    SalesCrMemoLine.Validate("No.", InvoicePostingBuffer."G/L Account");
                    SalesCrMemoLine.Description := CopyStr(SalesRebateForText +
                                                              PostedCustomerRebateLine.Description + ' ' +
                                                              PostedCustomerRebateHeader."Posting Description",
                                                              1, MaxStrLen(SalesCrMemoLine.Description));

                    SalesCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
                    SalesCrMemoLine.Validate(Quantity, 1);
                    //SalesCrMemoLine.Validate("Unit Price", PostedCustomerRebateLine."customer Rebate Amt (GL)");
                    SalesCrMemoLine.Validate("Unit Price", InvoicePostingBuffer.Amount);
                    IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                        SalesCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
                    IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                        SalesCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
                    SalesCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    SalesCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
                    SalesCrMemoLine.Modify(TRUE);

                    PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
                    PostedCustomerRebateLine."Rebate Payable A/C" := PostedCustomerRebateLine."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
                    PostedCustomerRebateLine.Modify();

                    PostedCustomerRebateLineDetails.RESET;
                    PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
                    PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
                    PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
                    PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Expense);
                    PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
                    PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Customer);
                    IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                        Repeat
                            PostedCustomerRebateLineDetails."Rebate Payable A/C" := PostedCustomerRebateLineDetails."Rebate Payable A/C"::Customer;
                            PostedCustomerRebateLineDetails."Rebate Sales Document No." := SalesCrMemoLine."Document No.";
                            PostedCustomerRebateLineDetails."Rebate Sales Document Line No." := SalesCrMemoLine."Line No.";
                            PostedCustomerRebateLineDetails."Rebate Sales Line No." := 0;
                            PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                            PostedCustomerRebateLineDetails.Modify;
                        Until PostedCustomerRebateLineDetails.Next() = 0;
                    END;
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;

        IF PostedCustomerRebateLine."Vendor Commission" <> 0 THEN BEGIN
            LocalBillToCustomer.Get(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group"); // Bill-To Customer No.
            GlobalEntityType := GlobalEntityType::Vendor;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, TRUE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    if GenJnlLine.FINDLAST() then
                        LineNo := GenJnlLine."Line No." + 10000
                    ELSE
                        LineNo := 10000;

                    Clear(DocumentNo);

                    CLEAR(GenJnlLine);
                    GenJnlLine.Init;
                    GeneralJournalInit(DocumentNo);
                    GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                    GenJnlLine."Document No." := DocumentNo;
                    GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                    GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine.Insert(true);

                    IF GenJnlLine."Document No." = '' then BEGIN
                        GenJnlLine."Document No." := PostedCustomerRebateHeader."No.";
                        IF InvoicePostingBuffer.Count > 1 THEN
                            GenJnlLine."Document No." += '-' + FORMAT(LineNo);
                    END;

                    GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                    GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                    GenJnlLine.UpdateJournalBatchID();
                    GenJnlLine.SetHideValidation(true);
                    GenJnlLine."Posting Date" := PostedCustomerRebateHeader."Posting Date";
                    GenJnlLine.Description := 'Rebate No: ' + PostedCustomerRebateHeader."No." + ' Vendor Commission ' + PostedCustomerRebateLine."Order No.";
                    VendLocalRebateAmount := -InvoicePostingBuffer.Amount;
                    if VendLocalRebateAmount > 0 then
                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                    else
                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                    //GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    //GenJnlLine.Validate("Account No.", InvoicePostingBuffer."G/L Account");
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                    GenJnlLine.Validate("Account No.", InvoicePostingBuffer."Job No.");

                    GenJnlLine.Validate("Currency Code", PostedCustomerRebateLine."Currency Code");
                    //GenJnlLine.Validate(Amount, PostedCustomerRebateLine."Vendor Commission");
                    GenJnlLine.Validate(Amount, VendLocalRebateAmount);
                    GenJnlLine."Shortcut Dimension 1 Code" := PostedCustomerRebateLine."Shortcut Dimension 1 Code";
                    GenJnlLine.Validate("Shortcut Dimension 1 Code");
                    GenJnlLine."Shortcut Dimension 2 Code" := PostedCustomerRebateLine."Shortcut Dimension 2 Code";
                    GenJnlLine.Validate("Shortcut Dimension 2 Code");
                    IF PostedCustomerRebateHeader."External Document No." <> '' THEN
                        GenJnlLine."External Document No." := PostedCustomerRebateHeader."External Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                    if GenJnlLine."External Document No." = '' then
                        GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");

                    //GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    //GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."Job No.");
                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."G/L Account");

                    GenJnlLine."AQD Cust Rebate Document Type" := PostedCustomerRebateLine."Document Type";
                    GenJnlLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    GenJnlLine."AQD CR Rebate Program Code" := PostedCustomerRebateLine."Cust Rebate Program Code";
                    GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                    GenJnlLine."Source Code" := RebateSetup."Customer Rebate Source Code";
                    GenJnlLine."AQD Cust Rebate Journal" := TRUE;
                    //To Flow Source Type and Source No.
                    GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                    GenJnlLine."Source No." := PostedCustomerRebateLine."Rebate Pay-To Customer No.";
                    GenJnlLine."AQD CR Bill-To Customer No." := PostedCustomerRebateLine."Bill-To Customer No.";
                    GenJnlLine.Modify(TRUE);
                    if GenJnlLine.Amount = 0 then
                        GenJnlLine.Delete();

                    PostedCustomerRebateLineDetails.RESET;
                    PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
                    PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
                    PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
                    PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Expense);
                    PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
                    PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Vendor);
                    PostedCustomerRebateLineDetails.SetRange("Entity No.", GenJnlLine."Account No.");
                    IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                        Repeat
                            case GenJnlLine."Document Type" of
                                GenJnlLine."Document Type"::"Credit Memo":
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::"Credit Memo";
                                GenJnlLine."Document Type"::Invoice:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Invoice;
                                GenJnlLine."Document Type"::Payment:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Payment;
                                GenJnlLine."Document Type"::Refund:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Refund;
                            end;
                            PostedCustomerRebateLineDetails."Vendor Document No." := GenJnlLine."Document No.";
                            PostedCustomerRebateLineDetails.Modify(false);
                        Until PostedCustomerRebateLineDetails.Next() = 0;
                    end;
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;

        IF PostedCustomerRebateLine."Employee Commission" <> 0 THEN BEGIN
            LocalBillToCustomer.Get(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group"); // Bill-To Customer No.
            GlobalEntityType := GlobalEntityType::Employee;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, TRUE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    if GenJnlLine.FINDLAST() then
                        LineNo := GenJnlLine."Line No." + 10000
                    ELSE
                        LineNo := 10000;

                    Clear(DocumentNo);

                    CLEAR(GenJnlLine);
                    GenJnlLine.Init;
                    GeneralJournalInit(DocumentNo);
                    GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                    GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                    GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine.Insert(true);

                    GenJnlLine."Document No." := DocumentNo;
                    IF GenJnlLine."Document No." = '' then BEGIN
                        GenJnlLine."Document No." := PostedCustomerRebateHeader."No.";
                        IF InvoicePostingBuffer.Count > 1 THEN
                            GenJnlLine."Document No." += '-' + FORMAT(LineNo);
                    END;

                    GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                    GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                    GenJnlLine.UpdateJournalBatchID();
                    GenJnlLine.SetHideValidation(true);
                    GenJnlLine."Posting Date" := PostedCustomerRebateHeader."Posting Date";
                    GenJnlLine.Description := 'Rebate No: ' + PostedCustomerRebateHeader."No." + ' Employee Commission ' + PostedCustomerRebateLine."Order No.";
                    //if PostedCustomerRebateHeader."Employee Commission" > 0 then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                    //else
                    //    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);

                    //GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    //GenJnlLine.Validate("Account No.", InvoicePostingBuffer."G/L Account");
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Employee;
                    GenJnlLine.Validate("Account No.", InvoicePostingBuffer."Job No.");

                    GenJnlLine.Validate("Currency Code", PostedCustomerRebateLine."Currency Code");
                    //GenJnlLine.Validate(Amount, PostedCustomerRebateLine."Employee Commission");
                    EmpLocalRebateAmount := -InvoicePostingBuffer.Amount;
                    GenJnlLine.Validate(Amount, EmpLocalRebateAmount);
                    GenJnlLine."Shortcut Dimension 1 Code" := PostedCustomerRebateLine."Shortcut Dimension 1 Code";
                    GenJnlLine.Validate("Shortcut Dimension 1 Code");
                    GenJnlLine."Shortcut Dimension 2 Code" := PostedCustomerRebateLine."Shortcut Dimension 2 Code";
                    GenJnlLine.Validate("Shortcut Dimension 2 Code");
                    IF PostedCustomerRebateHeader."External Document No." <> '' THEN
                        GenJnlLine."External Document No." := PostedCustomerRebateHeader."External Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                    if GenJnlLine."External Document No." = '' then
                        GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");

                    //GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    //GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."Job No.");
                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."G/L Account");

                    GenJnlLine."AQD Cust Rebate Document Type" := PostedCustomerRebateLine."Document Type";
                    GenJnlLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                    GenJnlLine."Source Code" := RebateSetup."Customer Rebate Source Code";
                    GenJnlLine."AQD Cust Rebate Journal" := TRUE;
                    //To Flow Source Type and Source No.
                    GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                    GenJnlLine."Source No." := PostedCustomerRebateLine."Rebate Pay-To Customer No.";
                    GenJnlLine."AQD CR Bill-To Customer No." := PostedCustomerRebateLine."Bill-To Customer No.";
                    GenJnlLine.Modify(TRUE);
                    if GenJnlLine.Amount = 0 then
                        GenJnlLine.Delete();
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;
    END;

    local procedure CreateSalesInvoiceLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        SalesInvoice: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        NextLineNo: Integer;
        LocalBillToCustomer: Record Customer;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        //LocalCustomer: Record Customer;
        DocumentNo: Code[20];
        LineNo: Integer;
        ItemChargeNextLineNo: Integer;
        LocalRebateAmount: Decimal;
    begin
        PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)",
                                            "Vendor Commission", "Employee Commission");

        TmpInovoiceBuffer.RESET;
        TmpInovoiceBuffer.SetRange("G/L Account", TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
        IF NOT TmpInovoiceBuffer.FindFirst() THEN begin
            //Create Sales Invoice Header
            SalesInvoice.INIT;
            SalesInvoice."Document Type" := SalesInvoice."Document Type"::Invoice;
            SalesInvoice."No." := '';
            SalesInvoice.Insert(TRUE);

            SalesInvoice.SetHideValidationDialog(TRUE);
            SalesInvoice.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Bill-To Customer No.");
            SalesInvoice.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Rebate Pay-To Customer No.");
            SalesInvoice.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."External Document No." := PostedCustomerRebateHeader."No.";
            SalesInvoice."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesInvoice."AQD Customer Rebate" := TRUE;
            SalesInvoice.Modify(TRUE);

            PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            //"G/L Account"		    - Bill Customer No.
            //"Dimension Set ID" 	- Sales Document Typ
            //"Job No."		        - Sales Order No.
            TmpInovoiceBuffer.INIT;
            TmpInovoiceBuffer."G/L Account" := GlobalGroupID;
            // Bill-To CCustomer No.
            TmpInovoiceBuffer."G/L Account" := TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group";
            // Document Type
            TmpInovoiceBuffer."Dimension Set ID" := SalesInvoice."Document Type".AsInteger();
            // Document No.
            TmpInovoiceBuffer."Job No." := SalesInvoice."No.";
            TmpInovoiceBuffer.INSERT;
            GlobalGroupID := IncStr(GlobalGroupID);
        end;

        NextLineNo := 0;
        ItemChargeNextLineNo := 0;
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document Type", SalesInvoiceLine."Document Type"::Invoice);
        SalesInvoiceLine.SETRANGE("Document No.", TmpInovoiceBuffer."Job No.");
        IF SalesInvoiceLine.FINDLAST THEN
            NextLineNo := SalesInvoiceLine."Line No."
        ELSE
            NextLineNo := 0;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Inventory);
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Customer);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    SalesInvoiceLine.INIT;
                    SalesInvoiceLine."Document Type" := SalesInvoiceLine."Document Type"::Invoice;
                    SalesInvoiceLine."Document No." := TmpInovoiceBuffer."Job No.";
                    SalesInvoiceLine."Line No." := NextLineNo;
                    SalesInvoiceLine.Insert(TRUE);

                    SalesInvoiceLine.Validate(Type, SalesInvoiceLine.Type::"Charge (Item)");
                    SalesInvoiceLine.Validate("No.", RebateSetup."Sales Item Charge No.");
                    SalesInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                            PostedCustomerRebateHeader."Posting Description",
                                                            1, MaxStrLen(SalesInvoiceLine.Description));

                    SalesInvoiceLine."Description 2" := CopyStr(FORMAT(PostedCustomerRebateLineDetails."Entity Type") + ' ' +
                                                                PostedCustomerRebateLineDetails."Entity No." + ' ' +
                                                                FORMAT(PostedCustomerRebateLineDetails.Type) + ' ' +
                                                                PostedCustomerRebateLineDetails."No." + ' ' +
                                                                PostedCustomerRebateLineDetails.Description,
                                                                1, MaxStrLen(SalesInvoiceLine."Description 2"));


                    SalesInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
                    SalesInvoiceLine.Validate(Quantity, 1);
                    SalesInvoiceLine.Validate("Unit Price", ABS(PostedCustomerRebateLineDetails."Customer Rebate Amount"));
                    IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                        SalesInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
                    IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                        SalesInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
                    SalesInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    SalesInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
                    SalesInvoiceLine.Modify(TRUE);

                    PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
                    PostedCustomerRebateLine."Rebate Payable A/C" := PostedCustomerRebateLine."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLine."Credit Document No." := SalesInvoiceLine."Document No.";
                    //PostedCustomerRebateLine."Credit Document Line No." := SalesInvoiceLine."Line No.";
                    PostedCustomerRebateLine.Modify();

                    ItemChargeNextLineNo += 10000;
                    ItemChargeAssignmentSales.Init();
                    ItemChargeAssignmentSales."Document Type" := SalesInvoiceLine."Document Type";
                    ItemChargeAssignmentSales."Document No." := SalesInvoiceLine."Document No.";
                    ItemChargeAssignmentSales."Document Line No." := SalesInvoiceLine."Line No.";
                    ItemChargeAssignmentSales."Line No." := ItemChargeNextLineNo;
                    ItemChargeAssignmentSales."Item Charge No." := SalesInvoiceLine."No.";
                    ItemChargeAssignmentSales."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentSales.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentSales."Qty. to Assign" := 0;
                    ItemChargeAssignmentSales."Qty. to Handle" := 0;
                    ItemChargeAssignmentSales."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentSales."Amount to Assign" := 0;
                    ItemChargeAssignmentSales."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Payable A/C" := PostedCustomerRebateLineDetails."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLineDetails."Rebate Sales Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Rebate Sales Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Rebate Sales Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();

                    CLEAR(AssignItemChargeSales);
                    AssignItemChargeSales.AssignItemCharges(SalesInvoiceLine, SalesInvoiceLine.Quantity, SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity, SalesInvoiceLine.Amount, 'By Amount');
                until PostedCustomerRebateLineDetails.Next() = 0;
            end;
        END;

        IF PostedCustomerRebateLine."Customer Rebate Amt (GL)" <> 0 THEN BEGIN
            GlobalEntityType := GlobalEntityType::Customer;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, FALSE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    SalesInvoiceLine.RESET;
                    SalesInvoiceLine.SETRANGE("Document Type", SalesInvoiceLine."Document Type"::Invoice);
                    SalesInvoiceLine.SETRANGE("Document No.", TmpCrMemoBuffer."Job No.");
                    IF SalesInvoiceLine.FINDLAST THEN
                        NextLineNo := SalesInvoiceLine."Line No." + 10000
                    ELSE
                        NextLineNo := 10000;

                    //LocalCustomer.GET(SalesCredirMemo."Bill-To Customer No.");

                    SalesInvoiceLine.INIT;
                    SalesInvoiceLine."Document Type" := SalesInvoiceLine."Document Type"::Invoice;
                    SalesInvoiceLine."Document No." := TmpInovoiceBuffer."Job No.";
                    SalesInvoiceLine."Line No." := NextLineNo;
                    SalesInvoiceLine.Insert(TRUE);

                    SalesInvoiceLine.Validate(Type, SalesInvoiceLine.Type::"G/L Account");
                    SalesInvoiceLine.Validate("No.", InvoicePostingBuffer."G/L Account");
                    SalesInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                            PostedCustomerRebateHeader."Posting Description",
                                                            1, MaxStrLen(SalesInvoiceLine.Description));
                    SalesInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
                    SalesInvoiceLine.Validate(Quantity, 1);
                    //SalesInvoiceLine.Validate("Unit Price", ABS(PostedCustomerRebateLine."Customer Rebate Amt (GL)"));
                    SalesInvoiceLine.Validate("Unit Price", ABS(InvoicePostingBuffer.Amount));
                    IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                        SalesInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
                    IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                        SalesInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
                    SalesInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    SalesInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
                    SalesInvoiceLine.Modify(TRUE);

                    PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
                    PostedCustomerRebateLine."Rebate Payable A/C" := PostedCustomerRebateLine."Rebate Payable A/C"::Customer;
                    PostedCustomerRebateLine."Credit Document No." := SalesInvoiceLine."Document No.";
                    PostedCustomerRebateLine.Modify();

                    PostedCustomerRebateLineDetails.RESET;
                    PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
                    PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
                    PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
                    PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Expense);
                    PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
                    PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Customer);
                    IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                        Repeat
                            PostedCustomerRebateLineDetails."Rebate Payable A/C" := PostedCustomerRebateLineDetails."Rebate Payable A/C"::Customer;
                            PostedCustomerRebateLineDetails."Rebate Sales Document No." := SalesInvoiceLine."Document No.";
                            PostedCustomerRebateLineDetails."Rebate Sales Document Line No." := SalesInvoiceLine."Line No.";
                            PostedCustomerRebateLineDetails."Rebate Sales Line No." := 0;
                            PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                            PostedCustomerRebateLineDetails.Modify();
                        Until PostedCustomerRebateLineDetails.Next() = 0;
                    END;
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;

        IF PostedCustomerRebateLine."Vendor Commission" <> 0 THEN BEGIN
            LocalBillToCustomer.Get(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group"); // Bill-To Customer No.
            GlobalEntityType := GlobalEntityType::Vendor;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, TRUE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    if GenJnlLine.FINDLAST() then
                        LineNo := GenJnlLine."Line No." + 10000
                    ELSE
                        LineNo := 10000;

                    Clear(DocumentNo);

                    CLEAR(GenJnlLine);
                    GenJnlLine.Init;
                    GeneralJournalInit(DocumentNo);
                    GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                    GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                    GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine.Insert(true);

                    GenJnlLine."Document No." := DocumentNo;
                    IF GenJnlLine."Document No." = '' THEN BEGIN
                        GenJnlLine."Document No." := PostedCustomerRebateHeader."No.";
                        IF InvoicePostingBuffer.Count > 1 THEN
                            GenJnlLine."Document No." += '-' + FORMAT(LineNo);
                    END;

                    GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                    GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                    GenJnlLine.UpdateJournalBatchID();
                    GenJnlLine.SetHideValidation(true);
                    GenJnlLine."Posting Date" := PostedCustomerRebateHeader."Posting Date";
                    GenJnlLine.Description := 'Rebate No: ' + PostedCustomerRebateHeader."No." + ' Vendor Commission ' + PostedCustomerRebateLine."Order No.";
                    LocalRebateAmount := -InvoicePostingBuffer.Amount;
                    if LocalRebateAmount > 0 then
                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                    else
                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);

                    //GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    //GenJnlLine.Validate("Account No.", InvoicePostingBuffer."G/L Account");
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                    GenJnlLine.Validate("Account No.", InvoicePostingBuffer."Job No.");

                    GenJnlLine.Validate("Currency Code", PostedCustomerRebateLine."Currency Code");
                    //GenJnlLine.Validate(Amount, PostedCustomerRebateLine."Vendor Commission");
                    GenJnlLine.Validate(Amount, LocalRebateAmount);
                    GenJnlLine."Shortcut Dimension 1 Code" := PostedCustomerRebateLine."Shortcut Dimension 1 Code";
                    GenJnlLine.Validate("Shortcut Dimension 1 Code");
                    GenJnlLine."Shortcut Dimension 2 Code" := PostedCustomerRebateLine."Shortcut Dimension 2 Code";
                    GenJnlLine.Validate("Shortcut Dimension 2 Code");
                    IF PostedCustomerRebateHeader."External Document No." <> '' THEN
                        GenJnlLine."External Document No." := PostedCustomerRebateHeader."External Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                    if GenJnlLine."External Document No." = '' then
                        GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");

                    //GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    //GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."Job No.");
                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."G/L Account");

                    GenJnlLine."AQD Cust Rebate Document Type" := PostedCustomerRebateLine."Document Type";
                    GenJnlLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    GenJnlLine."AQD CR Rebate Program Code" := PostedCustomerRebateLine."Cust Rebate Program Code";
                    GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                    GenJnlLine."Source Code" := RebateSetup."Customer Rebate Source Code";
                    GenJnlLine."AQD Cust Rebate Journal" := TRUE;
                    //To Flow Source Type and Source No.
                    GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                    GenJnlLine."Source No." := PostedCustomerRebateLine."Rebate Pay-To Customer No.";
                    GenJnlLine."AQD CR Bill-To Customer No." := PostedCustomerRebateLine."Bill-To Customer No.";
                    GenJnlLine.Modify(TRUE);
                    if GenJnlLine.Amount = 0 then
                        GenJnlLine.Delete();

                    PostedCustomerRebateLineDetails.RESET;
                    PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
                    PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
                    PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
                    PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::Expense);
                    PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
                    PostedCustomerRebateLineDetails.SetRange("Entity Type", PostedCustomerRebateLineDetails."Entity Type"::Vendor);
                    PostedCustomerRebateLineDetails.SetRange("Entity No.", GenJnlLine."Account No.");
                    IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                        Repeat
                            case GenJnlLine."Document Type" of
                                GenJnlLine."Document Type"::"Credit Memo":
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::"Credit Memo";
                                GenJnlLine."Document Type"::Invoice:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Invoice;
                                GenJnlLine."Document Type"::Payment:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Payment;
                                GenJnlLine."Document Type"::Refund:
                                    PostedCustomerRebateLineDetails."Vendor Document Type" := PostedCustomerRebateLineDetails."Vendor Document Type"::Refund;
                            end;
                            PostedCustomerRebateLineDetails."Vendor Document No." := GenJnlLine."Document No.";
                            PostedCustomerRebateLineDetails.Modify();
                        Until PostedCustomerRebateLineDetails.Next() = 0;
                    end;
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;

        IF PostedCustomerRebateLine."Employee Commission" <> 0 THEN BEGIN
            LocalBillToCustomer.Get(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group"); // Bill-To Customer No.
            GlobalEntityType := GlobalEntityType::Employee;
            GetCustomerRebateAmountByGLAccount(PostedCustomerRebateLine, GlobalEntityType, TRUE);

            InvoicePostingBuffer.RESET;
            InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
            IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                REPEAT
                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                    if GenJnlLine.FINDLAST() then
                        LineNo := GenJnlLine."Line No." + 10000
                    ELSE
                        LineNo := 10000;

                    Clear(DocumentNo);

                    CLEAR(GenJnlLine);
                    GenJnlLine.Init;
                    GeneralJournalInit(DocumentNo);
                    GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                    GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                    GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                    GenJnlLine."Line No." := LineNo;
                    GenJnlLine.Insert(true);

                    GenJnlLine."Document No." := DocumentNo;
                    IF GenJnlLine."Document No." = '' then begin
                        GenJnlLine."Document No." := PostedCustomerRebateHeader."No.";
                        IF InvoicePostingBuffer.Count > 1 THEN
                            GenJnlLine."Document No." += '-' + FORMAT(LineNo);
                    END;

                    GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                    GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                    GenJnlLine.UpdateJournalBatchID();
                    GenJnlLine.SetHideValidation(true);
                    GenJnlLine."Posting Date" := PostedCustomerRebateHeader."Posting Date";
                    GenJnlLine.Description := 'Rebate No: ' + PostedCustomerRebateHeader."No." + ' Employee Commission ' + PostedCustomerRebateLine."Order No.";
                    //if PostedCustomerRebateHeader."Employee Commission" > 0 then
                    //    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                    //else
                    //    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                    //GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    //GenJnlLine.Validate("Account No.", InvoicePostingBuffer."G/L Account");
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Employee;
                    GenJnlLine.Validate("Account No.", InvoicePostingBuffer."Job No.");

                    GenJnlLine.Validate("Currency Code", PostedCustomerRebateLine."Currency Code");
                    GenJnlLine.Validate(Amount, InvoicePostingBuffer.Amount);
                    GenJnlLine."Shortcut Dimension 1 Code" := PostedCustomerRebateLine."Shortcut Dimension 1 Code";
                    GenJnlLine.Validate("Shortcut Dimension 1 Code");
                    GenJnlLine."Shortcut Dimension 2 Code" := PostedCustomerRebateLine."Shortcut Dimension 2 Code";
                    GenJnlLine.Validate("Shortcut Dimension 2 Code");
                    IF PostedCustomerRebateHeader."External Document No." <> '' THEN
                        GenJnlLine."External Document No." := PostedCustomerRebateHeader."External Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                    if GenJnlLine."External Document No." = '' then
                        GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");

                    //GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    //GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."Job No.");
                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."G/L Account");

                    GenJnlLine."AQD Cust Rebate Document Type" := PostedCustomerRebateLine."Document Type";
                    GenJnlLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
                    GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                    GenJnlLine."Source Code" := RebateSetup."Customer Rebate Source Code";
                    GenJnlLine."AQD Cust Rebate Journal" := TRUE;
                    //To Flow Source Type and Source No.
                    GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                    GenJnlLine."Source No." := PostedCustomerRebateLine."Rebate Pay-To Customer No.";
                    GenJnlLine."AQD CR Bill-To Customer No." := PostedCustomerRebateLine."Bill-To Customer No.";
                    GenJnlLine.Modify(TRUE);
                    if GenJnlLine.Amount = 0 then
                        GenJnlLine.Delete();
                UNTIL InvoicePostingBuffer.Next() = 0;
            END;
        END;
    END;

    local procedure CreateSalesJournal(var PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
        LocalBillToCustomer: Record Customer;
        DocumentNo: Code[20];
        LineNo: Integer;
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        RebateSetup.TestField("Sales Journal Template Name");
        RebateSetup.TestField("Sales Journal Batch Name");

        IF PostedCustRebateHeader."Customer Rebate Status" <> PostedCustRebateHeader."Customer Rebate Status"::" " THEN
            Error(RebateStatusError, PostedCustRebateHeader."Customer Rebate Status");

        TmpPostCustomerRebateByBillTo.TestField("Gen. Bus. Posting Group"); // Bill-To Customer No.

        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateLine.SetRange("Bill-To Customer No.", TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group");
        PostedCustRebateLine.SetRange(Posted, false);
        PostedCustRebateLine.SetRange("Customer Rebate Status", PostedCustRebateLine."Customer Rebate Status"::" ");
        PostedCustRebateLine.SetRange("Do Not Credit", false);
        if PostedCustRebateLine.FindSet() then begin
            repeat
                LocalBillToCustomer.Get(TmpPostCustomerRebateByBillTo."Gen. Bus. Posting Group"); // Bill-To Customer No.
                PostedCustRebateLine.CalcFields("Customer Rebate Amount", "Vendor Commission", "Employee Commission");
                GetCustomerRebateAmountByGLAccount(PostedCustRebateLine, GlobalEntityType, TRUE);

                InvoicePostingBuffer.RESET;
                InvoicePostingBuffer.SetFilter(Amount, '<>%1', 0);
                IF InvoicePostingBuffer.FINDFIRST THEN BEGIN
                    REPEAT
                        Evaluate(PostedCustRebateDetailLine."Entity Type", Format(InvoicePostingBuffer."Dimension Set ID"));

                        GenJnlLine.Reset;
                        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                        if GenJnlLine.FINDLAST() then
                            LineNo := GenJnlLine."Line No." + 10000
                        ELSE
                            LineNo := 10000;

                        Clear(DocumentNo);

                        CLEAR(GenJnlLine);
                        GenJnlLine.Init;
                        GeneralJournalInit(DocumentNo);
                        GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                        GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                        GenJnlLine."Line No." := LineNo;
                        GenJnlLine.Insert(true);
                        LineNo += 10000;

                        GenJnlLine."Document No." := DocumentNo;
                        IF GenJnlLine."Document No." = '' then begin
                            GenJnlLine."Document No." := PostedCustRebateHeader."No.";
                            IF InvoicePostingBuffer.Count > 1 THEN
                                GenJnlLine."Document No." += '-' + FORMAT(LineNo);
                        END;

                        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                        GenJnlLine.UpdateJournalBatchID();
                        GenJnlLine.SetHideValidation(true);
                        GenJnlLine."Posting Date" := PostedCustRebateHeader."Posting Date";
                        GenJnlLine.Description := PostedCustRebateHeader."Posting Description";

                        //GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        //GenJnlLine.Validate("Account No.", InvoicePostingBuffer."G/L Account");
                        Case PostedCustRebateDetailLine."Entity Type" of
                            PostedCustRebateDetailLine."Entity Type"::Customer:
                                begin
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                                    if InvoicePostingBuffer.Amount > 0 then
                                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                                    else
                                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                                end;
                            PostedCustRebateDetailLine."Entity Type"::Employee:
                                BEGIN
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Employee;
                                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                                END;
                            PostedCustRebateDetailLine."Entity Type"::Vendor:
                                BEGIN
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                                    if InvoicePostingBuffer.Amount > 0 then
                                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                                    else
                                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                                END;
                        END;
                        GenJnlLine.Validate("Account No.", InvoicePostingBuffer."Job No.");

                        GenJnlLine.Validate("Currency Code", PostedCustRebateLine."Currency Code");
                        //GenJnlLine.Validate(Amount, PostedCustRebateLine."Customer Rebate Amount");
                        GenJnlLine.Validate(Amount, InvoicePostingBuffer.Amount);
                        GenJnlLine."Shortcut Dimension 1 Code" := PostedCustRebateLine."Shortcut Dimension 1 Code";
                        GenJnlLine.Validate("Shortcut Dimension 1 Code");
                        GenJnlLine."Shortcut Dimension 2 Code" := PostedCustRebateLine."Shortcut Dimension 2 Code";
                        GenJnlLine.Validate("Shortcut Dimension 2 Code");
                        IF PostedCustRebateHeader."External Document No." <> '' THEN
                            GenJnlLine."External Document No." := PostedCustRebateHeader."External Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                        if GenJnlLine."External Document No." = '' then
                            GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");

                        //GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                        //GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."Job No.");
                        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                        GenJnlLine.Validate("Bal. Account No.", InvoicePostingBuffer."G/L Account");

                        GenJnlLine."AQD Cust Rebate Document Type" := PostedCustRebateLine."Document Type";
                        GenJnlLine."AQD Cust Rebate Document No." := PostedCustRebateLine."Rebate No.";
                        GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                        GenJnlLine."Source Code" := RebateSetup."Customer Rebate Source Code";
                        GenJnlLine."AQD Cust Rebate Journal" := TRUE;
                        //To Flow Source Type and Source No.
                        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                        GenJnlLine."Source No." := PostedCustRebateLine."Rebate Pay-To Customer No.";
                        GenJnlLine."AQD CR Bill-To Customer No." := PostedCustRebateLine."Bill-To Customer No.";
                        GenJnlLine.Modify(TRUE);
                        if GenJnlLine.Amount = 0 then
                            GenJnlLine.Delete();
                        PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Created;
                        PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::"Rebate Payable AC";
                        PostedCustRebateLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                        PostedCustRebateLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                        PostedCustRebateLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                        PostedCustRebateLine.Modify();

                        PostedCustRebateDetailLine.RESET;
                        PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                        PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                        PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                        PostedCustRebateDetailLine.SetRange("Entity Type", PostedCustRebateDetailLine."Entity Type"::Customer);
                        If PostedCustRebateDetailLine.FindFirst() THEN begin
                            repeat
                                PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Created;
                                PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateDetailLine."Rebate Payable A/C"::"Rebate Payable AC";
                                PostedCustRebateDetailLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                                PostedCustRebateDetailLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                                PostedCustRebateDetailLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                                PostedCustRebateDetailLine.Modify();

                            // RebateItemLdgrEntry.RESET;
                            // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                            // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                            // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                            // IF RebateItemLdgrEntry.FindFirst() THEN begin
                            //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Created;
                            //     RebateItemLdgrEntry.Modify;
                            // end;
                            until PostedCustRebateDetailLine.Next() = 0;
                        END;
                    UNTIL InvoicePostingBuffer.Next() = 0;
                END;
            UNTIL PostedCustRebateLine.Next() = 0;
        END;

        PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Created;
        PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::"Rebate Payable AC";
        PostedCustRebateHeader."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
        PostedCustRebateHeader."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        PostedCustRebateHeader."Sales Jnl Line No." := 0;
        PostedCustRebateHeader.Modify();
    end;

    local procedure GetCustomerRebateAmountByGLAccount(var PostedCustRebateLine: Record "AQD Posted Cust Rebate Line"; EntityTypeIn: Enum "AQD CR Rebate Entity Type"; CalledFromSalesJournal: Boolean)
    var
        LocalPostedCustRebateLineDetail: Record "AQD Posted Cust Reb Details";
        LocalRebateProgramCode: Record "AQD Cust Rebate Program Code";
        LocalGroupID: Text[100];
    begin
        IF InvoicePostingBuffer.IsTemporary THEN
            InvoicePostingBuffer.DeleteAll();

        LocalGroupID := 'GRP00001';
        LocalPostedCustRebateLineDetail.RESET;
        LocalPostedCustRebateLineDetail.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
        LocalPostedCustRebateLineDetail.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
        LocalPostedCustRebateLineDetail.SetRange("AQD Cust Rebate Posting Type",
          LocalPostedCustRebateLineDetail."AQD Cust Rebate Posting Type"::Expense);
        LocalPostedCustRebateLineDetail.SetRange("Do Not Credit", false);
        LocalPostedCustRebateLineDetail.SetRange(Ineligible, FALSE);
        IF GlobalEntityType <> GlobalEntityType::" " THEN
            LocalPostedCustRebateLineDetail.SetRange("Entity Type", EntityTypeIn);
        IF LocalPostedCustRebateLineDetail.FindFirst() THEN begin
            REPEAT
                IF LocalRebateProgramCode.GET(LocalPostedCustRebateLineDetail."Rebate Program Code") THEN BEGIN
                    LocalRebateProgramCode.TestField("Rebate Expense AC");
                    //IF CalledFromSalesJournal THEN
                    //    LocalRebateProgramCode.TestField("Rebate Payable AC");

                    InvoicePostingBuffer.RESET;
                    InvoicePostingBuffer.SetRange("G/L Account", LocalRebateProgramCode."Rebate Expense AC");
                    InvoicePostingBuffer.SetRange("Dimension Set ID", LocalPostedCustRebateLineDetail."Entity Type".AsInteger());
                    //IF CalledFromSalesJournal THEN
                    //    InvoicePostingBuffer.SetRange("Job No.", LocalRebateProgramCode."Rebate Payable AC");
                    IF CalledFromSalesJournal THEN
                        InvoicePostingBuffer.SetRange("Job No.", LocalPostedCustRebateLineDetail."Entity No.");
                    IF InvoicePostingBuffer.FindFirst() THEN BEGIN
                        InvoicePostingBuffer.Amount += LocalPostedCustRebateLineDetail."Customer Rebate Amount";
                        InvoicePostingBuffer.Modify();
                    END ELSE BEGIN
                        InvoicePostingBuffer.INIT;
                        InvoicePostingBuffer."Group ID" := LocalGroupID;
                        InvoicePostingBuffer."Dimension Set ID" := LocalPostedCustRebateLineDetail."Entity Type".AsInteger();
                        InvoicePostingBuffer."G/L Account" := LocalRebateProgramCode."Rebate Expense AC";
                        //IF CalledFromSalesJournal THEN
                        //    InvoicePostingBuffer."Job No." := LocalRebateProgramCode."Rebate Payable AC";
                        IF CalledFromSalesJournal THEN
                            InvoicePostingBuffer."Job No." := LocalPostedCustRebateLineDetail."Entity No.";
                        InvoicePostingBuffer.Amount := LocalPostedCustRebateLineDetail."Customer Rebate Amount";
                        InvoicePostingBuffer.Insert();
                        LocalGroupID := IncStr(LocalGroupID);
                    END;
                    LocalGroupID := IncStr(LocalGroupID);
                END;
            UNTIL LocalPostedCustRebateLineDetail.Next() = 0;
        END;
    END;

    local procedure GeneralJournalInit(var DocumentNo: Code[20])
    begin
        JnlBatch.Init;
        JnlBatch."Journal Template Name" := RebateSetup."Sales Journal Template Name";
        JnlBatch.Name := RebateSetup."Sales Journal Batch Name";
        if not JnlBatch.Get(RebateSetup."Sales Journal Template Name", RebateSetup."Sales Journal Batch Name") then
            JnlBatch.Insert;

        IF JnlBatch."No. Series" = '' then
            EXIT;

        DocumentNo := NoSeriesMgt.GetNextNo(JnlBatch."No. Series", Today, true);
    end;
    //<< Create Sales Journal

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab38_SalesHeader_OnBeforeDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF NOT Rec."AQD Customer Rebate" THEN
            EXIT;

        IF PostedCustRebateHeader.GET(Rec."AQD Customer Rebate No") THEN begin
            PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::" ";
            PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::" ";
            PostedCustRebateHeader.Modify();
        end;

        SalesLine.RESET;
        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        IF SalesLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine.RESET;
                PostedCustRebateLine.SetRange("Rebate No.", SalesLine."AQD Cust Rebate Document No.");
                PostedCustRebateLine.SetRange("Line No.", SalesLine."AQD Cust Rebate Doc Line No");
                PostedCustRebateLine.SetRange("Do Not Credit", FALSE);
                PostedCustRebateLine.SetRange("Credit Document No.", SalesLine."Document No.");
                //PostedCustRebateLine.SetRange("Credit Document Line No.", SalesLine."Line No.");
                IF PostedCustRebateLine.FindFirst() THEN BEGIN
                    REPEAT
                        PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::" ";
                        PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::Customer;
                        PostedCustRebateLine."Credit Document No." := '';
                        //PostedCustRebateLine."Credit Document Line No." := 0;
                        PostedCustRebateLine.Modify();

                        PostedCustRebateDetailLine.RESET;
                        PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                        PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                        PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                        If PostedCustRebateDetailLine.FindFirst() THEN begin
                            REPEAT
                                PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::" ";
                                PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::Customer;
                                PostedCustRebateDetailLine."Rebate Sales Document No." := '';
                                PostedCustRebateDetailLine."Rebate Sales Document Line No." := 0;
                                PostedCustRebateDetailLine.Modify();
                            UNTIL PostedCustRebateDetailLine.Next() = 0;
                        end;
                    UNTIL PostedCustRebateLine.Next() = 0;
                END;
            Until SalesLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge Assignment (Sales)", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab5805_ItemChargeAssignmentSales_OnBeforeDelete(var Rec: Record "Item Charge Assignment (Sales)"; RunTrigger: Boolean)
    var
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Cust Rebate Doc No." = '' THEN
            EXIT;

        PostedCustomerRebateLineDetails.RESET;
        PostedCustomerRebateLineDetails.SETRANGE("Rebate Sales Document No.", ItemChargeAssignmentSales."Document No.");
        PostedCustomerRebateLineDetails.SETRANGE("Rebate Sales Document Line No.", ItemChargeAssignmentSales."Document Line No.");
        PostedCustomerRebateLineDetails.SETRANGE("Rebate Sales Line No.", ItemChargeAssignmentSales."Line No.");
        IF PostedCustomerRebateLineDetails.FindFirst() then begin
            PostedCustomerRebateLineDetails."Rebate Sales Document No." := '';
            PostedCustomerRebateLineDetails."Rebate Sales Document Line No." := 0;
            PostedCustomerRebateLineDetails."Rebate Sales Line No." := 0;
            PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::" ";
            PostedCustomerRebateLineDetails.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnCheckAndUpdateOnAfterSetSourceCode, '', false, false)]
    local procedure Cod80_SalesPost_OnCheckAndUpdateOnAfterSetSourceCode(var SalesHeader: Record "Sales Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        RebateSetup.GET;
        IF SalesHeader."AQD Customer Rebate" then
            SrcCode := RebateSetup."Customer Rebate Source Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure Cod80_SalesPost_OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        //SalesShptHdrNo,RetRcpHdrNo,SalesInvHdrNo,SalesCrMemoHdrNo
        SourceCodeSetup.GET;
        IF SalesInvHdrNo <> '' THEN begin
            SalesInvHdr.get(SalesInvHdrNo);
            IF (SalesInvHdr."Source Code" <> SourceCodeSetup."Deleted Document") AND
              (SalesInvHdr."AQD Customer Rebate")
            then begin
                SalesInvLine.RESET;
                SalesInvLine.SetRange("Document No.", SalesInvHdrNo);
                SalesInvLine.SetFilter(Type, '%1|%2',
                    SalesInvLine.Type::"Charge (Item)",
                    SalesInvLine.Type::"G/L Account");
                SalesInvLine.SetFilter("No.", '<>%1', '');
                IF SalesInvLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedCustRebateLine.GET(SalesInvLine."AQD Cust Rebate Document No.",
                                                    SalesInvLine."AQD Cust Rebate Doc Line No") AND
                           (NOT PostedCustRebateLine."Do Not Credit")
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(SalesInvLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::Customer;
                            PostedCustRebateLine."Credit Document No." := SalesInvLine."Document No.";
                            //PostedCustRebateLine."Credit Document Line No." := SalesInvLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateDetailLine."Rebate Payable A/C"::Customer;
                                    PostedCustRebateDetailLine."Rebate Sales Document No." := SalesInvLine."Document No.";
                                    PostedCustRebateDetailLine."Rebate Sales Document Line No." := SalesInvLine."Line No.";
                                    PostedCustRebateDetailLine.Modify();
                                until PostedCustRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until SalesInvLine.Next() = 0;
                end;
            end;
        end;

        if SalesCrMemoHdrNo <> '' then begin
            SalesCrMemoHeader.GET(SalesCrMemoHdrNo);
            IF (SalesCrMemoHeader."Source Code" <> SourceCodeSetup."Deleted Document") AND
               (SalesCrMemoHeader."AQD Customer Rebate")
            then begin
                SalesCrMemoLine.RESET;
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHdrNo);
                SalesCrMemoLine.SetFilter(Type, '%1|%2',
                  SalesCrMemoLine.Type::"Charge (Item)",
                  SalesCrMemoLine.Type::"G/L Account");
                SalesCrMemoLine.SetFilter("No.", '<>%1', '');
                IF SalesCrMemoLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedCustRebateLine.GET(SalesCrMemoLine."AQD Cust Rebate Document No.",
                                                    SalesCrMemoLine."AQD Cust Rebate Doc Line No") AND
                           (NOT PostedCustRebateLine."Do Not Credit")
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(SalesCrMemoLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::Customer;
                            PostedCustRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
                            //PostedCustRebateLine."Credit Document Line No." := SalesCrMemoLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateDetailLine."Rebate Payable A/C"::Customer;
                                    PostedCustRebateDetailLine."Rebate Sales Document No." := SalesCrMemoLine."Document No.";
                                    PostedCustRebateDetailLine."Rebate Sales Document Line No." := SalesCrMemoLine."Line No.";
                                    PostedCustRebateDetailLine.Modify();
                                until PostedCustRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until SalesCrMemoLine.Next() = 0;
                end;
            end;
        end;
    end;
    //<< Create Purchase Invoice/Credit Memo and Post using Charge Assignment

    [IntegrationEvent(false, false)]
    procedure OnBeforePostCustomerRebates(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostCustomerRebates(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInitValueEntryOnAfterSetValueEntryInventoriable, '', false, false)]
    local procedure Cod22_ItemJnlPostLine_OnInitValueEntryOnAfterSetValueEntryInventoriable(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //Original Condition for Inventoriable is change for Rebate
        IF NOT ItemJournalLine."AQD Customer Rebate Journal" then
            EXIT;

        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") OR
           (ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Output, ItemJournalLine."Entry Type"::"Assembly Output"]) OR
           ItemJournalLine.Adjustment
       then begin
            IF Item.GET(ItemJournalLine."Item No.") then
                ValueEntry.Inventoriable := Item.Type = Item.Type::Inventory;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostItemJnlLineOnAfterCopyDocumentFields, '', false, false)]
    local procedure Cod80_Salesost_OnPostItemJnlLineOnAfterCopyDocumentFields(var ItemJournalLine: Record "Item Journal Line"; SalesLine: Record "Sales Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        ItemJournalLine."AQD Customer Rebate Journal" := SalesLine."AQD Customer Rebate";
        ItemJournalLine."AQD Cust Rebate Document No." := SalesLine."AQD Cust Rebate Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", OnRunCheckOnBeforeTestFieldAppliesToEntry, '', false, false)]
    local procedure Cod21_ItemJnlCheckLine_OnRunCheckOnBeforeTestFieldAppliesToEntry(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") AND (ItemJournalLine."Item Charge No." <> '') then
            IF ItemJournalLine."Inventory Value Per" = ItemJournalLine."Inventory Value Per"::" " then
                ItemJournalLine."Inventory Value Per" := ItemJournalLine."Inventory Value Per"::Item
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterCopyGenJnlLineFromSalesHeader, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnAfterCopyGenJnlLineFromSalesHeader(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    BEGIN
        IF NOT SalesHeader."AQD Customer Rebate" THEN
            EXIT;

        GenJournalLine."AQD Cust Rebate Journal" := SalesHeader."AQD Customer Rebate";
        GenJournalLine."AQD CR Bill-To Customer No." := SalesHeader."Sell-to Customer No.";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostCustOnAfterInitCustLedgEntry, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnPostCustOnAfterInitCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var CustLedgEntry: Record "Cust. Ledger Entry"; Cust: Record Customer; CustPostingGr: Record "Customer Posting Group")
    BEGIN
        IF NOT GenJnlLine."AQD Cust Rebate Journal" THEN
            EXIT;

        CustLedgEntry."AQD Customer Rebate" := GenJnlLine."AQD Cust Rebate Journal";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlobalGLEntry, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; FiscalYearStartDate: Date)
    BEGIN
        IF NOT GenJournalLine."AQD Cust Rebate Journal" THEN
            EXIT;

        GlobalGLEntry."AQD Customer Rebate" := GenJournalLine."AQD Cust Rebate Journal";
        GlobalGLEntry."AQD CR Bill-To Customer No." := GenJournalLine."AQD CR Bill-To Customer No.";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnAfterPostGenJournalLine, '', false, false)]
    local procedure Cod13_GenJnlPostBatch_OnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")

    var
        PostedRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF GenJournalLine.IsTemporary THEN
            EXIT;

        IF GenJournalLine."AQD Cust Rebate Document No." = '' THEN
            EXIT;

        IF PostedRebateHeader.GET(GenJournalLine."AQD Cust Rebate Document No.") THEN begin
            PostedRebateHeader."Customer Rebate Status" := PostedRebateHeader."Customer Rebate Status"::Posted;
            PostedRebateHeader."Rebate Payable AC" := PostedRebateHeader."Rebate Payable AC"::" ";
            PostedRebateHeader."Sales Jnl Template Name" := '';
            PostedRebateHeader."Sales Jnl Batch Name" := '';
            PostedRebateHeader."Sales Jnl Line No." := 0;
            PostedRebateHeader.Modify();
        end;

        PostedCustRebateLine.RESET;
        PostedCustRebateLine.SetRange("Rebate No.", GenJournalLine."AQD Cust Rebate Document No.");
        PostedCustRebateLine.SetRange("Sales Jnl Template Name", GenJournalLine."Journal Template Name");
        PostedCustRebateLine.SetRange("Sales Jnl Batch Name", GenJournalLine."Journal Batch Name");
        PostedCustRebateLine.SetFilter("Sales Jnl Line No.", '%1|%2', 0, GenJournalLine."Line No.");
        IF PostedCustRebateLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::" ";
                PostedCustRebateLine."Sales Jnl Template Name" := '';
                PostedCustRebateLine."Sales Jnl Batch Name" := '';
                PostedCustRebateLine."Sales Jnl Line No." := 0;
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                        PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateDetailLine."Rebate Payable A/C"::" ";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Line No." := 0;
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                    //     RebateItemLdgrEntry.Modify;
                    // end;
                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            Until PostedCustRebateLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnBeforeDelete(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Cust Rebate Document No." = '' THEN
            EXIT;

        IF PostedCustRebateHeader.GET(Rec."AQD Cust Rebate Document No.") THEN begin
            PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::" ";
            PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::" ";
            PostedCustRebateHeader."Sales Jnl Template Name" := '';
            PostedCustRebateHeader."Sales Jnl Batch Name" := '';
            PostedCustRebateHeader."Sales Jnl Line No." := 0;
            PostedCustRebateHeader.Modify();
        end;

        PostedCustRebateLine.RESET;
        PostedCustRebateLine.SetRange("Rebate No.", Rec."AQD Cust Rebate Document No.");
        IF PostedCustRebateLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::" ";
                PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::" ";
                PostedCustRebateLine."Sales Jnl Template Name" := '';
                PostedCustRebateLine."Sales Jnl Batch Name" := '';
                PostedCustRebateLine."Sales Jnl Line No." := 0;
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::" ";
                        PostedCustRebateDetailLine."Rebate Payable A/C" := PostedCustRebateDetailLine."Rebate Payable A/C"::" ";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Line No." := 0;
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::" ";
                    //     RebateItemLdgrEntry."AQD Rebate Entry Created" := FALSE;
                    //     RebateItemLdgrEntry."AQD Rebate Last Changed By" := '';
                    //     RebateItemLdgrEntry."AQD Rebate LastChangd DateTime" := 0DT;
                    //     RebateItemLdgrEntry."AQD Rebate No" := '';
                    //     RebateItemLdgrEntry."AQD Rebate Line No" := 0;
                    //     RebateItemLdgrEntry."AQD Rebate Detail Line No." := 0;
                    //     RebateItemLdgrEntry.Modify;
                    // end;

                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            Until PostedCustRebateLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnBeforeCheckLine, '', FALSE, FALSE)]
    local procedure Cod13_GenJnlPostBatch_OnBeforeCheckLine(var GenJournalLine: Record "Gen. Journal Line"; var PostingAfterWorkingDateConfirmed: Boolean; var IsHandled: Boolean)
    begin
        IF GenJournalLine."AQD Cust Rebate Journal" THEN
            PostingAfterWorkingDateConfirmed := TRUE;
    end;
}