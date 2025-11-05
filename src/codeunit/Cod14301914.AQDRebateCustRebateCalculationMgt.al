codeunit 14301914 "AQD Cust Rebate Calc Mgt"
{
    Permissions = TableData "Cust. Ledger Entry" = rm,
                  TableData "Item Ledger Entry" = rm,
                  TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm;

    trigger OnRun()
    begin
    end;

    var
        RebateUserSetup: Record "AQD Customer Rebate User Setup";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        TempCustomerRebateHeader: Record "AQD Customer Rebate Header";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";

        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustLdgrEntry: Record "Cust. Ledger Entry";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        SalesPerson: Record "Salesperson/Purchaser";
        Vendor: Record Vendor;
        Customer: Record Customer;
        CreatedCustomerRebate: Record "AQD Created Customer Rebate";
        NoSeriesMgt: Codeunit "No. Series";
        RebateCheck: Boolean;
        DetailMode: Boolean;
        ARPaid: Boolean;
        ShowByLoc: Boolean;
        ShowByCounty: Boolean;
        ShowByShortDim1Code: Boolean;
        ShowByShortDim2Code: Boolean;
        DonotPayRebate: Boolean;
        ModifyRecord: Boolean;
        FirstTime: Boolean;
        FirstRecord: Boolean;
        VendorRebateCacl: Boolean;
        JournalDocumentNo: Code[20];
        TemplateName: Code[20];
        BatchName: Code[20];
        OrderText: Label 'Order ';
        ReturnOrderText: Label 'Return Order ';
        NextJournalDocumentNo: Code[20];
        StartDate: Date;
        EndDate: Date;
        NextJnlLineNo: Integer;
        LastRebateLdgrEntryNo: Integer;
        SourceDocumentType: Option Invoice,"Credit Memo";
        CalledFromDocumentType: Option Invoice,"Credit Memo","Rebate Summary";
        DocumentType: Option " ",Invoice,"Credit Memo";
        RunFor: Option Review,Process;
        RebateType: Option " ",Vendor,Customer;
        LocationFilter: Text[250];
        ShortcutDim1CodeFilter: Text[250];
        ShortcutDim2CodeFilter: Text[250];
        CountyFilter: Text[250];
        RebateCodeName: Text[100];
        RebatePeriodText: Label 'Rebate Period: %1..%2';
        PostingDescrptionText: Text;
        GlobalBatchID: Code[50];
        GlobalBatchEntryNo: Integer;
        GlobalBatchStartDate: Date;
        GlobalBatchEndDate: Date;
        GlobalRebateBatchFrequency: Enum "AQD Rebate Batch Frequency";

    procedure UpdateOldDocumentsNonRebateEnable()
    var
        UserConfirmMsg: Label 'Do you want to update Old Posted Invoices and Credit Memo non-rebatable?';
        OldDocAlreadyUpdatedError: Label 'Old Posted Invoices and Credit Memos are already updated.';
        OldDocAlreadyUpdatedSuccessfully: Label 'Old Posted Invoices and Credit Memos are updated successfully.';
    begin
        RebateSetup.Get;
        RebateSetup.TestField("Start Date");

        if RebateSetup."Old Documents Updated" then
            Error(OldDocAlreadyUpdatedError);

        if not Confirm(UserConfirmMsg) then
            exit;

        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetFilter("Posting Date", '<%1', RebateSetup."Start Date");
        SalesInvoiceHeader.ModifyAll("AQD No Customer Rebate", true);

        SalesCrMemoHeader.Reset;
        SalesCrMemoHeader.SetFilter("Posting Date", '<%1', RebateSetup."Start Date");
        SalesCrMemoHeader.ModifyAll("AQD No Customer Rebate", true);

        RebateSetup."Old Documents Updated" := true;
        RebateSetup.Modify;
        Message(OldDocAlreadyUpdatedSuccessfully);
    end;

    local procedure "===Calculation==="()
    begin
    end;

    procedure CalculateRebate(var CustomerIn: Record Customer; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean; RegenerateEntries: Boolean)
    var
        LocalCustomer: Record Customer;
    //UpdateRebateCustomerType: Report "AQD Udt Rebate Customer Type";
    begin
        RebateSetup.Get;
        RebateSetup.TestField("Customer Rebate Nos");

        if not CustomerIn."AQD Enroll for Cust Rebate" then
            exit;

        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then
            if CustomerIn."AQD Cust Rebate Vendor No" = '' then
                exit;

        // IF RebateSetup."Auto Update Rebate Cust Type" THEN BEGIN
        //     Commit();  // There is nothing to Commit
        //     LocalCustomer.GET(CustomerIn."No.");
        //     LocalCustomer.SetRecFilter();

        //     CLEAR(UpdateRebateCustomerType);
        //     UpdateRebateCustomerType.SetTableView(LocalCustomer);
        //     UpdateRebateCustomerType.SetDoNotShowDialog(TRUE);
        //     UpdateRebateCustomerType.UseRequestPage(FALSE);
        //     UpdateRebateCustomerType.Run();
        //     COMMIT;
        // END;

        CreatedCustomerRebate.RESET;
        CreatedCustomerRebate.DeleteAll();

        Clear(PostingDescrptionText);
        PostingDescrptionText := StrSubstNo(RebatePeriodText, DateArray[1], DateArray[2]);

        SourceCodeSetup.Get;

        if RegenerateEntries then begin
            // RebateDocEntry.Reset;
            // RebateDocEntry.SetFilter("Document Type", '%1|%2',
            //   RebateDocEntry."Document Type"::Invoice,
            //   RebateDocEntry."Document Type"::"Credit Memo");
            // RebateDocEntry.SetRange("Sell-to Customer No.", CustomerIn."No.");
            // RebateDocEntry.SetRange(Open, true);
            // RebateDocEntry.SetRange(Payable, false);
            // RebateDocEntry.SetRange("Rebate Approved", false);
            // RebateDocEntry.SetRange("Payment Status", RebateDocEntry."Payment Status"::" ");
            // if RebateDocEntry.FindFirst then begin
            //     repeat
            //         RebateDocEntry.Delete(true);
            //     until RebateDocEntry.Next = 0;
            // end;
        end;

        Case RebateSetup."Calculate Cust Rebate using" of
            RebateSetup."Calculate Cust Rebate using"::"Posted Invoice and Cr Memo":
                BEGIN
                    // Calculate Rebate for Posted Sales Invoices
                    BuildInvoiceRebate(CustomerIn, DateArray, SummaryArray);

                    // Calculate Rebate for Posted Sales Credit memos
                    if not RebateSetup."Prevent Negative Cust Rebate" then
                        BuildCrMemoRebate(CustomerIn, DateArray, SummaryArray);
                END;
            RebateSetup."Calculate Cust Rebate using"::"Posted Shipment and Return Receipt":
                BEGIN
                    // Calculate Rebate for Posted Purchase Receipt,Invoice,Cr Memo, Return Shipment from ILE
                    //BuildShipmentReturnReceiptRebate(CustomerIn, DateArray, SummaryArray);
                END;
        END;

        //CLEAR(PostCustomerRebateBatches);
        //PostCustomerRebateBatches.UseRequestPage(false);
        //PostCustomerRebateBatches.Run();
    end;

    local procedure BuildInvoiceRebate(var CustomerIn: Record Customer; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        SkipRecord: Boolean;
        DummySalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        Clear(StartDate);
        if DateArray[1] <> 0D then
            StartDate := DateArray[1];
        IF (StartDate = 0D) or (StartDate < RebateSetup."Start Date") then
            StartDate := RebateSetup."Start Date";

        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetCurrentKey("Bill-to Customer No.", "Posting Date");
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", CustomerIn."No.");
        SalesInvoiceHeader.SetRange("AQD No Customer Rebate", false);
        SalesInvoiceHeader.SetRange("AQD Cust Rebate Entry Created", false);
        SalesInvoiceHeader.SetRange("AQD Customer Rebate Status", SalesInvoiceHeader."AQD Customer Rebate Status"::" ");
        SalesInvoiceHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then begin
            CASE CustomerIn."AQD Calculation Date" OF
                CustomerIn."AQD Calculation Date"::" ",
                CustomerIn."AQD Calculation Date"::"Shipment Date":
                    SalesInvoiceHeader.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
                CustomerIn."AQD Calculation Date"::"Rebate Order Date":
                    SalesInvoiceHeader.SetFilter("AQD Customer Rebate Order Date", '%1..%2', StartDate, DateArray[2])
            END;
        end;
        if SalesInvoiceHeader.FindFirst then
            repeat
                SkipRecord := false;

                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then
                    if not Vendor.Get(CustomerIn."AQD Cust Rebate Vendor No") then
                        SkipRecord := true;

                if IsPayRebateOnlyOnPaidInvoices() then begin
                    SalesInvoiceHeader.CalcFields(Closed);
                    if not SalesInvoiceHeader.Closed then
                        SkipRecord := true;
                end;

                SalesInvoiceHeader.CalcFields(Cancelled);
                IF SalesInvoiceHeader.Cancelled then
                    SkipRecord := true;

                IF NOT IsRebataEnabledLineExist(SourceDocumentType::Invoice, SalesInvoiceHeader, DummySalesCrMemoHeader, CustomerIn) THEN
                    SkipRecord := true;

                //RebateDocEntry.Reset;
                //RebateDocEntry.SetRange("Document Type", RebateDocEntry."Document Type"::Invoice);
                //RebateDocEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
                //if RebateDocEntry.FindFirst then
                //    SkipRecord := true;

                SalesInvLine.Reset;
                SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                SalesInvLine.SetFilter(Type, '%1|%2|%3|%4|%5',
                  SalesInvLine.Type::Item,
                  SalesInvLine.Type::"G/L Account",
                  SalesInvLine.Type::Resource,
                  SalesInvLine.Type::"Fixed Asset",
                  SalesInvLine.Type::"Charge (Item)");
                SalesInvLine.SetFilter("No.", '<>%1', '');
                SalesInvLine.SetFilter(Quantity, '<>0');
                OnAfterApplyInvoiceLineFilter(SalesInvoiceHeader, SalesInvLine);
                if SalesInvLine.IsEmpty then
                    SkipRecord := true;

                if not SkipRecord then
                    BuildInvoiceRebateDetail(SalesInvoiceHeader, CustomerIn, SummaryArray);
            until SalesInvoiceHeader.Next = 0;
    end;

    local procedure BuildInvoiceRebateDetail(var SalesInvHeaderIn: Record "Sales Invoice Header"; CustomerIn: Record Customer; SummaryArray: array[5] of Boolean)
    var
        Vendor: Record Vendor;
        SalesInvLine: Record "Sales Invoice Line";
        CustLdgrEntry: Record "Cust. Ledger Entry";
        VendorTypeError: Label 'Vendor Type must be %1.';
        Counter: Integer;
        IsHandled: Boolean;
        RebateNo: Code[20];
        RebateLineNo: Integer;
    begin
        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            Clear(Vendor);
            Vendor.Get(CustomerIn."AQD Cust Rebate Vendor No");
            if Vendor."AQD Cust Rbt Vendor Type" <> Vendor."AQD Cust Rbt Vendor Type"::"Rebate Vendor" then
                Error(VendorTypeError, Vendor."AQD Cust Rbt Vendor Type");
        end;

        IsHandled := false;
        OnBeforeStartCalculatingInvoiceRebate(SalesInvHeaderIn, CustomerIn, Vendor, IsHandled);
        if IsHandled then
            exit;

        if IsRebataEnabledLineExist(SourceDocumentType::Invoice, SalesInvHeaderIn, SalesCrMemoHeader, CustomerIn) then begin
            //Document
            InsertRebateHeader(DocumentType::Invoice, SalesInvHeaderIn, SalesCrMemoHeader, CustomerIn, RebateNo, SummaryArray);
            //Line
            InsertRebateLine(DocumentType::Invoice, SalesInvHeaderIn, SalesCrMemoHeader, RebateNo, RebateLineNo);

            SalesInvLine.Reset;
            SalesInvLine.SetRange("Document No.", SalesInvHeaderIn."No.");
            SalesInvLine.SetFilter(Type, '%1|%2|%3|%4|%5',
              SalesInvLine.Type::Item,
              SalesInvLine.Type::"G/L Account",
              SalesInvLine.Type::Resource,
              SalesInvLine.Type::"Fixed Asset",
              SalesInvLine.Type::"Charge (Item)");
            SalesInvLine.SetFilter("No.", '<>%1', '');
            SalesInvLine.SetFilter(Quantity, '<>0');
            OnAfterApplyInvoiceLineFilter(SalesInvHeaderIn, SalesInvLine);
            if SalesInvLine.FindFirst then begin
                repeat
                    if IsLineRebateEnabled(
                        CustomerIn."No.",
                        SalesInvLine.Type,
                        SalesInvLine."No.",
                        SalesInvHeaderIn."Posting Date")
                    then
                        InsertRebateDetail(DocumentType::Invoice, SalesInvHeaderIn, SalesInvLine, SalesCrMemoHeader, SalesCrMemoLine, CustomerIn, RebateNo, RebateLineNo);
                until SalesInvLine.Next = 0;

                // IF CustLdgrEntry.GET(SalesInvHeaderIn."Cust. Ledger Entry No.") then begin
                //     RebateDocEntry.CalcFields("Remaining Rebate Amount");
                //     CustLdgrEntry."AQD Customer Rebate Amount" := RebateDocEntry."Remaining Rebate Amount";
                //     CustLdgrEntry.Modify();
                // END
            end;
        end;
    end;

    local procedure BuildCrMemoRebate(var CustomerIn: Record Customer; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        SkipRecord: Boolean;
        LocalSalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Clear(StartDate);
        if DateArray[1] <> 0D then
            StartDate := DateArray[1];
        IF (StartDate = 0D) or (StartDate < RebateSetup."Start Date") then
            StartDate := RebateSetup."Start Date";

        SalesCrMemoHeader.Reset;
        SalesCrMemoHeader.SetCurrentKey("Bill-to Customer No.", "Posting Date");
        SalesCrMemoHeader.SetRange("Bill-to Customer No.", CustomerIn."No.");
        SalesCrMemoHeader.SetRange("AQD No Customer Rebate", false);
        SalesCrMemoHeader.SetRange("AQD Customer Rebate Status", SalesCrMemoHeader."AQD Customer Rebate Status"::" ");
        SalesCrMemoHeader.SetRange("AQD Rebate Entry Created", false);
        SalesCrMemoHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then begin
            CASE CustomerIn."AQD Calculation Date" OF
                CustomerIn."AQD Calculation Date"::" ",
                CustomerIn."AQD Calculation Date"::"Shipment Date":
                    SalesCrMemoHeader.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
                CustomerIn."AQD Calculation Date"::"Rebate Order Date":
                    SalesCrMemoHeader.SetFilter("AQD Customer Rebate Order Date", '%1..%2', StartDate, DateArray[2])
            END;
        end;
        if SalesCrMemoHeader.FindFirst then begin
            repeat
                SkipRecord := false;

                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then
                    if not Vendor.Get(CustomerIn."AQD Cust Rebate Vendor No") then
                        SkipRecord := true;

                if IsPayRebateOnlyOnPaidInvoices() then begin
                    SalesCrMemoHeader.CalcFields(Paid);
                    if not SalesCrMemoHeader.Paid then
                        SkipRecord := true;
                end;

                //if SalesCrMemoHeader."AQD Rebate %" = 0 then
                IF NOT IsRebataEnabledLineExist(SourceDocumentType::"Credit Memo", LocalSalesInvoiceHeader, SalesCrMemoHeader, CustomerIn) THEN
                    SkipRecord := true;

                SalesCrMemoHeader.CalcFields(Cancelled);
                IF SalesCrMemoHeader.Cancelled then
                    SkipRecord := true;

                CustomerRebateLine.Reset;
                CustomerRebateLine.SetRange("Document Type", CustomerRebateLine."Document Type"::"Credit Memo");
                CustomerRebateLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                if CustomerRebateLine.FindFirst then
                    SkipRecord := true;

                SalesCrMemoLine.Reset;
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetFilter(Type, '%1|%2|%3|%4|%5',
                  SalesCrMemoLine.Type::Item,
                  SalesCrMemoLine.Type::"G/L Account",
                  SalesCrMemoLine.Type::Resource,
                  SalesCrMemoLine.Type::"Fixed Asset",
                  SalesCrMemoLine.Type::"Charge (Item)");
                SalesCrMemoLine.SetFilter("No.", '<>%1', '');
                SalesCrMemoLine.SetFilter(Quantity, '<>0');
                OnAfterApplyCreditMemoLineFilter(SalesCrMemoHeader, SalesCrMemoLine);
                if SalesCrMemoLine.IsEmpty then
                    SkipRecord := true;

                if not SkipRecord then
                    BuildCreditMemoRebateDetail(SalesCrMemoHeader, CustomerIn, SummaryArray);
            until SalesCrMemoHeader.Next = 0;
        end;
    end;

    local procedure BuildCreditMemoRebateDetail(SalesCrMHeaderIn: Record "Sales Cr.Memo Header"; CustomerIn: Record Customer; SummaryArray: array[5] of Boolean)
    var
        Vendor: Record Vendor;
        IsHandled: Boolean;
        RebateNo: Code[20];
        RebateLineNo: Integer;
        VendorTypeError: Label 'Vendor Type must be %1.';
    begin

        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            Clear(Vendor);
            Vendor.Get(CustomerIn."AQD Cust Rebate Vendor No");
            IF Vendor."AQD Cust Rbt Vendor Type" <> Vendor."AQD Cust Rbt Vendor Type"::"Rebate Vendor" THEN
                Error(VendorTypeError, Vendor."AQD Cust Rbt Vendor Type");
        end;

        IsHandled := false;
        OnBeforeStartCalculatingCrMemoRebate(SalesCrMHeaderIn, CustomerIn, Vendor, IsHandled);
        if IsHandled then
            exit;

        if IsRebataEnabledLineExist(SourceDocumentType::"Credit Memo", SalesInvoiceHeader, SalesCrMHeaderIn, CustomerIn) then begin
            //Document
            InsertRebateHeader(DocumentType::"Credit Memo", SalesInvoiceHeader, SalesCrMHeaderIn, CustomerIn, RebateNo, SummaryArray);
            //Line
            InsertRebateLine(DocumentType::"Credit Memo", SalesInvoiceHeader, SalesCrMHeaderIn, RebateNo, RebateLineNo);

            SalesCrMemoLine.Reset;
            SalesCrMemoLine.SetRange("Document No.", SalesCrMHeaderIn."No.");
            SalesCrMemoLine.SetFilter(Type, '%1|%2|%3|%4|%5',
              SalesCrMemoLine.Type::Item,
              SalesCrMemoLine.Type::"G/L Account",
              SalesCrMemoLine.Type::Resource,
              SalesCrMemoLine.Type::"Fixed Asset",
              SalesCrMemoLine.Type::"Charge (Item)");
            SalesCrMemoLine.SetFilter("No.", '<>%1', '');
            SalesCrMemoLine.SetFilter(Quantity, '<>0');
            OnAfterApplyCreditMemoLineFilter(SalesCrMHeaderIn, SalesCrMemoLine);
            if SalesCrMemoLine.FindFirst then
                repeat
                    if IsLineRebateEnabled(
                        CustomerIn."No.",
                        SalesCrMemoLine.Type,
                        SalesCrMemoLine."No.",
                        SalesCrMHeaderIn."Posting Date")
                    then
                        InsertRebateDetail(DocumentType::"Credit Memo", SalesInvoiceHeader, SalesInvLine, SalesCrMHeaderIn, SalesCrMemoLine, CustomerIn, RebateNo, RebateLineNo);
                until SalesCrMemoLine.Next = 0;

            // IF CustLdgrEntry.GET(SalesCrMHeaderIn."Cust. Ledger Entry No.") then begin
            //     RebateDocEntry.CalcFields("Remaining Rebate Amount");
            //     CustLdgrEntry."AQD Customer Rebate Amount" := RebateDocEntry."Remaining Rebate Amount";
            //     CustLdgrEntry.Modify();
            // END;
        end;
    end;

    local procedure IsRebataEnabledLineExist(SourceDocType: Option "Posted Invoice","Posted Credit Memo"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CustomerIn: Record Customer): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        IsHandled: Boolean;
        LineRebatable: Boolean;
    begin
        LineRebatable := false;
        if SourceDocType = SourceDocType::"Posted Invoice" then begin
            SalesInvoiceLine.Reset;
            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
            SalesInvoiceLine.SetFilter(Type, '%1|%2|%3|%4|%5',
              SalesInvoiceLine.Type::Item,
              SalesInvoiceLine.Type::Resource,
              SalesInvoiceLine.Type::"G/L Account",
              SalesInvoiceLine.Type::"Fixed Asset",
              SalesInvoiceLine.Type::"Charge (Item)");
            SalesInvoiceLine.SetFilter("No.", '<>%1', '');
            SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
            OnAfterApplyInvoiceLineFilter(SalesInvoiceHeader, SalesInvoiceLine);
            if SalesInvoiceLine.FindFirst then begin
                Repeat
                    IsHandled := false;
                    OnBeforeFindRebateRate(SourceDocType, SalesInvoiceHeader, SalesInvoiceLine, SalesCrMemoHeader, SalesCrMemoLine, IsHandled);
                    if not IsHandled then
                        LineRebatable := IsLineRebateEnabled(CustomerIn."No.",
                                                             SalesInvoiceLine.Type,
                                                             SalesInvoiceLine."No.",
                                                             SalesInvoiceHeader."Posting Date");
                Until (SalesInvoiceLine.Next = 0) OR LineRebatable;
                EXIT(LineRebatable);
            end;
        end else
            if SourceDocType = SourceDocType::"Posted Credit Memo" then begin
                SalesCrMemoLine.Reset;
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetFilter(Type, '%1|%2|%3|%4|%5',
                  SalesCrMemoLine.Type::Item,
                  SalesCrMemoLine.Type::Resource,
                  SalesCrMemoLine.Type::"Fixed Asset",
                  SalesCrMemoLine.Type::"G/L Account",
                  SalesCrMemoLine.Type::"Charge (Item)");
                SalesCrMemoLine.SetFilter("No.", '<>%1', '');
                SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                OnAfterApplyCreditMemoLineFilter(SalesCrMemoHeader, SalesCrMemoLine);
                If SalesCrMemoLine.FindFirst then begin
                    Repeat
                        IsHandled := false;
                        OnBeforeFindRebateRate(SourceDocType, SalesInvoiceHeader, SalesInvoiceLine, SalesCrMemoHeader, SalesCrMemoLine, IsHandled);
                        if not IsHandled then
                            LineRebatable := IsLineRebateEnabled(CustomerIn."No.",
                                                                 SalesCrMemoLine.Type,
                                                                 SalesCrMemoLine."No.",
                                                                 SalesCrMemoHeader."Posting Date");
                    Until (SalesCrMemoLine.Next = 0) OR LineRebatable;
                    EXIT(LineRebatable);
                end;
            end;
        exit(false);
    end;

    local procedure IsLineRebateEnabled(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; PostingDate: Date): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        ItemRebateCategory: Record "AQD Cust Rebate Item Category";
        RebateCategoryLines: Record "AQD Cust Rebate Category Lines";
        ItemVendorRebateMatrix: Record "AQD Cust Item Rebate Matrix";
        TempRebateCategoryLines: Record "AQD Cust Rebate Category Lines" temporary;
        ChkCustItemRbtMatrixMgt: Codeunit "AQD ChkCustItemRbt Matrix Mgt";
        LocalRebateCategoryCode: Code[20];
        IsHandled: Boolean;
        IsRebateEnabled: Boolean;
    begin
        IsRebateEnabled := FALSE;
        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    Item.GET(DocumentLine_No);
                    LocalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                    IsRebateEnabled := Item."AQD Customer Rebate Enabled";
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GLAccount.GET(DocumentLine_No);
                    LocalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                    IsRebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                end;
            DocumentLine_Type::Resource:
                begin
                    Resource.GET(DocumentLine_No);
                    LocalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                    IsRebateEnabled := Resource."AQD Customer Rebate Enabled";
                end;
            DocumentLine_Type::"Charge (Item)":
                begin
                    ItemCharge.GET(DocumentLine_No);
                    LocalRebateCategoryCode := ItemCharge."AQD Cust Rebate Category Code";
                    IsRebateEnabled := ItemCharge."AQD Customer Rebate Enabled";
                end;
            DocumentLine_Type::"Fixed Asset":
                begin
                    FixedAsset.GET(DocumentLine_No);
                    LocalRebateCategoryCode := FixedAsset."AQD Cust Rebate Category Code";
                    IsRebateEnabled := FixedAsset."AQD Customer Rebate Enabled";
                end;
            else begin
                IsHandled := FALSE;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebateEnabled, IsHandled);
                IF IsHandled THEN
                    EXIT(IsRebateEnabled);
            end;
        end;

        IF IsRebateEnabled then begin
            IF LocalRebateCategoryCode <> '' THEN BEGIN
                TempRebateCategoryLines.Init();
                TempRebateCategoryLines."Rebate Category Code" := LocalRebateCategoryCode;

                RebateCategoryLines.RESET;
                RebateCategoryLines.SetRange("Rebate Category Code", LocalRebateCategoryCode);
                IF RebateCategoryLines.FindFirst() THEN begin
                    repeat
                        TempRebateCategoryLines."Line No." := RebateCategoryLines."Line No.";
                        TempRebateCategoryLines."Rebate Program Code" := RebateCategoryLines."Rebate Program Code";
                        TempRebateCategoryLines.Insert();
                    until RebateCategoryLines.Next() = 0;
                end ELSE BEGIN
                    TempRebateCategoryLines."Line No." := 10000;
                    TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
                    TempRebateCategoryLines.INSERT;
                END;

                TempRebateCategoryLines.RESET;
                IF TempRebateCategoryLines.FindFirst() THEN BEGIN
                    Repeat
                        IsRebateEnabled := ChkCustItemRbtMatrixMgt.IsBillToCustomerEligibleForRebate(
                                                                    ItemVendorRebateMatrix,
                                                                    CustomerNo,
                                                                    DocumentLine_Type,
                                                                    DocumentLine_No,
                                                                    PostingDate,
                                                                    TempRebateCategoryLines."Rebate Program Code");
                    Until (TempRebateCategoryLines.Next() = 0) OR IsRebateEnabled;
                END;
            END;
        end;
        EXIT(IsRebateEnabled);
    end;
    //>>New Functions

    local procedure InsertRebateHeader(DocumentType: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; CustomerIn: Record Customer; var RebateNo: code[20]; SummaryArray: array[5] of Boolean)
    var
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        SellToCustomerRec: Record Customer;
        BillToCustomerRec: Record Customer;
        PayToVendor: Record Vendor;
        RebateVendorRec: Record Vendor;
        PayToVendorCode: Code[20];
        DocumentPostingDate: Date;
    begin
        Clear(CustomerRebateHeader);

        CreatedCustomerRebate.Reset();
        case DocumentType of
            DocumentType::Invoice:
                begin
                    IF RebateSetup."AQD Rebate Batch Frequency" <> RebateSetup."AQD Rebate Batch Frequency"::" " then BEGIN
                        CASE CustomerIn."AQD Calculation Date" OF
                            CustomerIn."AQD Calculation Date"::" ",
                            CustomerIn."AQD Calculation Date"::"Shipment Date":
                                GlobalBatchID := GetBatchID(SalesInvHeaderIn."Posting Date");
                            CustomerIn."AQD Calculation Date"::"Rebate Order Date":
                                GlobalBatchID := GetBatchID(SalesInvHeaderIn."AQD Customer Rebate Order Date");
                        END;
                    END;

                    BillToCustomerRec.GET(SalesInvHeaderIn."Bill-to Customer No.");
                    SellToCustomerRec.GET(SalesInvHeaderIn."Sell-to Customer No.");

                    DocumentPostingDate := SalesInvHeaderIn."Posting Date";

                    CreatedCustomerRebate.SetRange("Bill-To Customer No.", SalesInvHeaderIn."Bill-to Customer No.");
                    if SummaryArray[1] then
                        CreatedCustomerRebate.SetRange("Sell-To Customer No.", SalesInvHeaderIn."Sell-To Customer No.")
                    ELSE
                        CreatedCustomerRebate.SetRange("Sell-To Customer No.", SalesInvHeaderIn."Bill-to Customer No.");
                    if SummaryArray[2] then
                        CreatedCustomerRebate.SetRange("Responsibility Center", SalesInvHeaderIn."Responsibility Center");
                    if SummaryArray[3] then
                        CreatedCustomerRebate.SetRange("Location Code", SalesInvHeaderIn."Location Code");
                    if SummaryArray[4] then
                        CreatedCustomerRebate.SetRange("Shortcut Dimension 1 Code", SalesInvHeaderIn."Shortcut Dimension 1 Code");
                    if SummaryArray[5] then
                        CreatedCustomerRebate.SetRange("Shortcut Dimension 2 Code", SalesInvHeaderIn."Shortcut Dimension 2 Code");
                    IF GlobalBatchID <> '' then
                        CreatedCustomerRebate.SetRange(GlobalBatchID, GlobalBatchID);
                end;
            DocumentType::"Credit Memo":
                begin
                    IF RebateSetup."AQD Rebate Batch Frequency" <> RebateSetup."AQD Rebate Batch Frequency"::" " then BEGIN
                        //GlobalBatchID := GetBatchID(SalesCrMemoHeaderIn."Posting Date");
                        CASE CustomerIn."AQD Calculation Date" OF
                            CustomerIn."AQD Calculation Date"::" ",
                            CustomerIn."AQD Calculation Date"::"Shipment Date":
                                GlobalBatchID := GetBatchID(SalesCrMemoHeaderIn."Posting Date");
                            CustomerIn."AQD Calculation Date"::"Rebate Order Date":
                                GlobalBatchID := GetBatchID(SalesCrMemoHeaderIn."AQD Customer Rebate Order Date");
                        END;
                    END;

                    BillToCustomerRec.GET(SalesCrMemoHeaderIn."Bill-To Customer No.");
                    SellToCustomerRec.GET(SalesCrMemoHeaderIn."Sell-to Customer No.");
                    DocumentPostingDate := SalesCrMemoHeaderIn."Posting Date";

                    CreatedCustomerRebate.SetRange("Bill-To Customer No.", SalesCrMemoHeaderIn."Bill-to Customer No.");
                    if SummaryArray[1] then
                        CreatedCustomerRebate.SetRange("Sell-To Customer No.", SalesCrMemoHeaderIn."Sell-To Customer No.")
                    ELSE
                        CreatedCustomerRebate.SetRange("Bill-To Customer No.", SalesCrMemoHeaderIn."Bill-to Customer No.");
                    if SummaryArray[2] then
                        CreatedCustomerRebate.SetRange("Responsibility Center", SalesCrMemoHeaderIn."Responsibility Center");
                    if SummaryArray[3] then
                        CreatedCustomerRebate.SetRange("Location Code", SalesCrMemoHeaderIn."Location Code");
                    if SummaryArray[4] then
                        CreatedCustomerRebate.SetRange("Shortcut Dimension 1 Code", SalesCrMemoHeaderIn."Shortcut Dimension 1 Code");
                    if SummaryArray[5] then
                        CreatedCustomerRebate.SetRange("Shortcut Dimension 2 Code", SalesCrMemoHeaderIn."Shortcut Dimension 2 Code");
                    IF GlobalBatchID <> '' then
                        CreatedCustomerRebate.SetRange(GlobalBatchID, GlobalBatchID);
                end;
        end;

        IF BillToCustomerRec."AQD Cust Rebate Vendor No" <> '' THEN
            PayToVendor.GET(BillToCustomerRec."AQD Cust Rebate Vendor No");

        IF NOT CreatedCustomerRebate.FindFirst() then begin
            IF GlobalBatchID <> '' THEN BEGIN
                CustomerRebateBatch.RESET;
                CustomerRebateBatch.SetRange(BatchID, GlobalBatchID);
                IF NOT CustomerRebateBatch.FindFirst() THEN BEGIN
                    CustomerRebateBatch.INIT;
                    CustomerRebateBatch.BatchID := GlobalBatchID;
                    CustomerRebateBatch."Posting Date" := TODAY;
                    CustomerRebateBatch."Created By" := UserId;
                    CustomerRebateBatch."Created Date" := Today;
                    CustomerRebateBatch."Start Date" := GlobalBatchStartDate;
                    CustomerRebateBatch."End Date" := GlobalBatchEndDate;
                    CustomerRebateBatch."AQD Rebate Batch Frequency" := GlobalRebateBatchFrequency;
                    CustomerRebateBatch.INSERT();
                    GlobalBatchEntryNo := CustomerRebateBatch."Entry No.";
                END ELSE
                    GlobalBatchEntryNo := CustomerRebateBatch."Entry No.";
            END;

            CustomerRebateHeader.Init;
            CustomerRebateHeader."No." := NoSeriesMgt.GetNextNo(RebateSetup."Customer Rebate Nos", Today, true);

            case DocumentType of
                DocumentType::Invoice:
                    begin
                        IF SummaryArray[1] THEN BEGIN
                            CustomerRebateHeader."Sell-To Customer No." := SalesInvHeaderIn."Sell-to Customer No.";
                            CustomerRebateHeader."Sell-To Customer Name" := SalesInvHeaderIn."Sell-to Customer Name";
                            CustomerRebateHeader."Sell-To Customer Name 2" := SalesInvHeaderIn."Sell-to Customer Name 2";
                            CustomerRebateHeader."Sell-To Address" := SalesInvHeaderIn."Sell-to Address";
                            CustomerRebateHeader."Sell-To Address 2" := SalesInvHeaderIn."Sell-to Address 2";
                            CustomerRebateHeader."Sell-To City" := SalesInvHeaderIn."Sell-to City";
                            CustomerRebateHeader."Sell-To Contact" := SalesInvHeaderIn."Sell-to Contact";
                            CustomerRebateHeader."Sell-To Post Code" := SalesInvHeaderIn."Sell-to Post Code";
                            CustomerRebateHeader."Sell-To County" := SalesInvHeaderIn."Sell-to County";
                            CustomerRebateHeader."Sell-To Country/Region Code" := SalesInvHeaderIn."Sell-to Country/Region Code";
                        END ELSE BEGIN
                            CustomerRebateHeader."Sell-To Customer No." := SalesInvHeaderIn."Bill-to Customer No.";
                            CustomerRebateHeader."Sell-To Customer Name" := SalesInvHeaderIn."Bill-to Name";
                            CustomerRebateHeader."Sell-To Customer Name 2" := SalesInvHeaderIn."Bill-to Name 2";
                            CustomerRebateHeader."Sell-To Address" := SalesInvHeaderIn."Bill-to Address";
                            CustomerRebateHeader."Sell-To Address 2" := SalesInvHeaderIn."Bill-to Address 2";
                            CustomerRebateHeader."Sell-To City" := SalesInvHeaderIn."Bill-to City";
                            CustomerRebateHeader."Sell-To Contact" := SalesInvHeaderIn."Bill-to Contact";
                            CustomerRebateHeader."Sell-To Post Code" := SalesInvHeaderIn."Bill-to Post Code";
                            CustomerRebateHeader."Sell-To County" := SalesInvHeaderIn."Bill-to County";
                            CustomerRebateHeader."Sell-To Country/Region Code" := SalesInvHeaderIn."Bill-To Country/Region Code";
                        END;

                        CustomerRebateHeader."Bill-To Customer No." := SalesInvHeaderIn."Bill-to Customer No.";
                        CustomerRebateHeader."Bill-To Name" := SalesInvHeaderIn."Bill-to Name";
                        CustomerRebateHeader."Bill-To Name 2" := SalesInvHeaderIn."Bill-to Name 2";
                        CustomerRebateHeader."Bill-To Address" := SalesInvHeaderIn."Bill-to Address";
                        CustomerRebateHeader."Bill-To Address 2" := SalesInvHeaderIn."Bill-to Address 2";
                        CustomerRebateHeader."Bill-To City" := SalesInvHeaderIn."Bill-to City";
                        CustomerRebateHeader."Bill-To Contact" := SalesInvHeaderIn."Bill-to Contact";
                        CustomerRebateHeader."Bill-To Post Code" := SalesInvHeaderIn."Bill-to Post Code";
                        CustomerRebateHeader."Bill-To County" := SalesInvHeaderIn."Bill-to County";
                        CustomerRebateHeader."Bill-To Country/Region Code" := SalesInvHeaderIn."Bill-To Country/Region Code";

                        CustomerRebateHeader."Salesperson Code" := SalesInvHeaderIn."Salesperson Code";
                        CustomerRebateHeader."External Document No." := SalesInvHeaderIn."External Document No.";
                        CustomerRebateHeader.State := SalesInvHeaderIn."Ship-to County";
                        if SummaryArray[2] then
                            CustomerRebateHeader."Responsibility Center" := SalesInvHeaderIn."Responsibility Center";
                        if SummaryArray[3] then
                            CustomerRebateHeader."Location Code" := SalesInvHeaderIn."Location Code";
                        if SummaryArray[4] then
                            CustomerRebateHeader."Shortcut Dimension 1 Code" := SalesInvHeaderIn."Shortcut Dimension 1 Code";
                        if SummaryArray[5] then
                            CustomerRebateHeader."Shortcut Dimension 2 Code" := SalesInvHeaderIn."Shortcut Dimension 2 Code";
                    end;
                DocumentType::"Credit Memo":
                    begin
                        IF SummaryArray[1] THEN BEGIN
                            CustomerRebateHeader."Sell-To Customer No." := SalesCrMemoHeaderIn."Sell-to Customer No.";
                            CustomerRebateHeader."Sell-To Customer Name" := SalesCrMemoHeaderIn."Sell-to Customer Name";
                            CustomerRebateHeader."Sell-To Customer Name 2" := SalesCrMemoHeaderIn."Sell-to Customer Name 2";
                            CustomerRebateHeader."Sell-To Address" := SalesCrMemoHeaderIn."Sell-to Address";
                            CustomerRebateHeader."Sell-To Address 2" := SalesCrMemoHeaderIn."Sell-to Address 2";
                            CustomerRebateHeader."Sell-To City" := SalesCrMemoHeaderIn."Sell-to City";
                            CustomerRebateHeader."Sell-To Contact" := SalesCrMemoHeaderIn."Sell-to Contact";
                            CustomerRebateHeader."Sell-To Post Code" := SalesCrMemoHeaderIn."Sell-to Post Code";
                            CustomerRebateHeader."Sell-To County" := SalesCrMemoHeaderIn."Sell-to County";
                            CustomerRebateHeader."Sell-To Country/Region Code" := SalesCrMemoHeaderIn."Sell-to Country/Region Code";
                        END ELSE BEGIN
                            CustomerRebateHeader."Sell-To Customer No." := SalesCrMemoHeaderIn."Bill-to Customer No.";
                            CustomerRebateHeader."Sell-To Customer Name" := SalesCrMemoHeaderIn."Bill-to Name";
                            CustomerRebateHeader."Sell-To Customer Name 2" := SalesCrMemoHeaderIn."Bill-to Name 2";
                            CustomerRebateHeader."Sell-To Address" := SalesCrMemoHeaderIn."Bill-to Address";
                            CustomerRebateHeader."Sell-To Address 2" := SalesCrMemoHeaderIn."Bill-to Address 2";
                            CustomerRebateHeader."Sell-To City" := SalesCrMemoHeaderIn."Bill-to City";
                            CustomerRebateHeader."Sell-To Contact" := SalesCrMemoHeaderIn."Bill-to Contact";
                            CustomerRebateHeader."Sell-To Post Code" := SalesCrMemoHeaderIn."Bill-to Post Code";
                            CustomerRebateHeader."Sell-To County" := SalesCrMemoHeaderIn."Bill-to County";
                            CustomerRebateHeader."Sell-To Country/Region Code" := SalesCrMemoHeaderIn."Bill-To Country/Region Code";
                        END;

                        CustomerRebateHeader."Bill-To Customer No." := SalesCrMemoHeaderIn."Bill-to Customer No.";
                        CustomerRebateHeader."Bill-To Name" := SalesCrMemoHeaderIn."Bill-to Name";
                        CustomerRebateHeader."Bill-To Name 2" := SalesCrMemoHeaderIn."Bill-to Name 2";
                        CustomerRebateHeader."Bill-To Address" := SalesCrMemoHeaderIn."Bill-to Address";
                        CustomerRebateHeader."Bill-To Address 2" := SalesCrMemoHeaderIn."Bill-to Address 2";
                        CustomerRebateHeader."Bill-To City" := SalesCrMemoHeaderIn."Bill-to City";
                        CustomerRebateHeader."Bill-To Contact" := SalesCrMemoHeaderIn."Bill-to Contact";
                        CustomerRebateHeader."Bill-To Post Code" := SalesCrMemoHeaderIn."Bill-to Post Code";
                        CustomerRebateHeader."Bill-To County" := SalesCrMemoHeaderIn."Bill-to County";
                        CustomerRebateHeader."Bill-To Country/Region Code" := SalesCrMemoHeaderIn."Bill-To Country/Region Code";

                        CustomerRebateHeader."Salesperson Code" := SalesCrMemoHeaderIn."Salesperson Code";
                        CustomerRebateHeader.State := SalesCrMemoHeaderIn."Ship-to County";
                        if SummaryArray[2] then
                            CustomerRebateHeader."Responsibility Center" := SalesCrMemoHeaderIn."Responsibility Center";
                        if SummaryArray[3] then
                            CustomerRebateHeader."Location Code" := SalesCrMemoHeaderIn."Location Code";
                        CustomerRebateHeader."External Document No." := SalesCrMemoHeaderIn."External Document No.";
                        if SummaryArray[4] then
                            CustomerRebateHeader."Shortcut Dimension 1 Code" := SalesCrMemoHeaderIn."Shortcut Dimension 1 Code";
                        if SummaryArray[5] then
                            CustomerRebateHeader."Shortcut Dimension 2 Code" := SalesCrMemoHeaderIn."Shortcut Dimension 2 Code";
                    end;
            end;

            CustomerRebateHeader."Pay-To Vendor No." := PayToVendor."No.";
            CustomerRebateHeader."Pay-To Name" := PayToVendor.Name;
            CustomerRebateHeader."Pay-To Name 2" := PayToVendor."Name 2";
            CustomerRebateHeader."Pay-To Address" := PayToVendor.Address;
            CustomerRebateHeader."Pay-To Address 2" := PayToVendor."Address 2";
            CustomerRebateHeader."Pay-To City" := PayToVendor.City;
            CustomerRebateHeader."Pay-To Contact" := PayToVendor.Contact;
            CustomerRebateHeader."Pay-To Post Code" := PayToVendor."Post Code";
            CustomerRebateHeader."Pay-To County" := PayToVendor.County;
            CustomerRebateHeader."Pay-To Country/Region Code" := PayToVendor."Country/Region Code";

            CustomerRebateHeader."Posting Description" := PostingDescrptionText;
            CustomerRebateHeader."Posting Date" := Today;
            CustomerRebateHeader."Document Date" := Today;
            CustomerRebateHeader."Created By" := UserId;
            CustomerRebateHeader."Created Date" := Today;
            CustomerRebateHeader.BatchID := GlobalBatchID;
            CustomerRebateHeader."Batch Entry No." := CustomerRebateBatch."Entry No.";
            CustomerRebateHeader."AQD Calculation Date" := CustomerIn."AQD Calculation Date";
            CustomerRebateHeader.Insert;
            RebateNo := CustomerRebateHeader."No.";

            CreatedCustomerRebate.Init();
            CreatedCustomerRebate."Rebate No." := CustomerRebateHeader."No.";
            CreatedCustomerRebate."Bill-To Customer No." := CustomerRebateHeader."Bill-To Customer No.";
            CreatedCustomerRebate."Sell-To Customer No." := CustomerRebateHeader."Sell-To Customer No.";
            CreatedCustomerRebate."Location Code" := CustomerRebateHeader."Location Code";
            CreatedCustomerRebate."Responsibility Center" := CustomerRebateHeader."Responsibility Center";
            CreatedCustomerRebate."Shortcut Dimension 1 Code" := CustomerRebateHeader."Shortcut Dimension 1 Code";
            CreatedCustomerRebate."Shortcut Dimension 2 Code" := CustomerRebateHeader."Shortcut Dimension 2 Code";
            CreatedCustomerRebate.GlobalBatchID := GlobalBatchID;
            CreatedCustomerRebate.INSERT;
        end else begin
            RebateNo := CreatedCustomerRebate."Rebate No.";
            CustomerRebateHeader.GET(RebateNo);
        end;
    end;

    local procedure InsertRebateLine(DocumentType: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; RebateNo: Code[20]; var RebateLineNo: Integer)
    var
        LocalCustomerRebateLine: Record "AQD Customer Rebate Line";
    begin
        LocalCustomerRebateLine.Reset();
        LocalCustomerRebateLine.SetRange("Rebate No.", RebateNo);
        if LocalCustomerRebateLine.FindLast() then
            RebateLineNo := LocalCustomerRebateLine."Line No." + 10000
        else
            RebateLineNo := 10000;

        Clear(CustomerRebateLine);
        CustomerRebateLine.Init;
        case DocumentType of
            DocumentType::Invoice:
                begin
                    SalesInvHeaderIn.CalcFields(Amount, "Amount Including VAT");
                    CustomerRebateLine."Rebate No." := RebateNo;
                    CustomerRebateLine."Line No." := RebateLineNo;
                    CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::Invoice;
                    CustomerRebateLine."Document No." := SalesInvHeaderIn."No.";
                    CustomerRebateLine."Order No." := SalesInvHeaderIn."Order No.";
                    CustomerRebateLine.Description := SalesInvHeaderIn."Posting Description";
                    CustomerRebateLine."Order Date" := SalesInvHeaderIn."Order Date";
                    CustomerRebateLine."Rebate Order Date" := SalesInvHeaderIn."Order Date";
                    CustomerRebateLine."Posting Date" := SalesInvHeaderIn."Posting Date";
                    CustomerRebateLine."Order No." := SalesInvHeaderIn."Order No.";
                    CustomerRebateLine."External Document No." := SalesInvHeaderIn."External Document No.";
                    CustomerRebateLine.Amount := SalesInvHeaderIn.Amount;
                    CustomerRebateLine."Amount Including VAT" := SalesInvHeaderIn."Amount Including VAT";
                    CustomerRebateLine."Salesperson Code" := SalesInvHeaderIn."Salesperson Code";
                    CustomerRebateLine."Responsibility Center" := SalesInvHeaderIn."Responsibility Center";
                    CustomerRebateLine."Location Code" := SalesInvHeaderIn."Location Code";
                    CustomerRebateLine."Currency Code" := SalesInvHeaderIn."Currency Code";
                    CustomerRebateLine."Shortcut Dimension 1 Code" := SalesInvHeaderIn."Shortcut Dimension 1 Code";
                    CustomerRebateLine."Shortcut Dimension 2 Code" := SalesInvHeaderIn."Shortcut Dimension 2 Code";
                    CustomerRebateLine."Sell-To Customer No." := SalesInvHeaderIn."Sell-To Customer No.";
                    CustomerRebateLine."Bill-To Customer No." := SalesInvHeaderIn."Bill-To Customer No.";
                end;
            DocumentType::"Credit Memo":
                begin
                    SalesCrMemoHeaderIn.CalcFields(Amount, "Amount Including VAT");
                    CustomerRebateLine."Rebate No." := RebateNo;
                    CustomerRebateLine."Line No." := RebateLineNo;
                    CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::"Credit Memo";
                    CustomerRebateLine."Document No." := SalesCrMemoHeaderIn."No.";
                    CustomerRebateLine."Order No." := SalesCrMemoHeaderIn."Return Order No.";
                    CustomerRebateLine.Description := SalesCrMemoHeaderIn."Posting Description";
                    CustomerRebateLine."Posting Date" := SalesCrMemoHeaderIn."Posting Date";
                    CustomerRebateLine."External Document No." := SalesCrMemoHeaderIn."External Document No.";
                    CustomerRebateLine.Amount := -1 * SalesCrMemoHeaderIn.Amount;
                    CustomerRebateLine."Amount Including VAT" := -1 * SalesCrMemoHeaderIn."Amount Including VAT";
                    CustomerRebateLine."Salesperson Code" := SalesCrMemoHeaderIn."Salesperson Code";
                    CustomerRebateLine."Responsibility Center" := SalesCrMemoHeaderIn."Responsibility Center";
                    CustomerRebateLine."Location Code" := SalesCrMemoHeaderIn."Location Code";
                    CustomerRebateLine."Currency Code" := SalesCrMemoHeaderIn."Currency Code";
                    CustomerRebateLine."Shortcut Dimension 1 Code" := SalesCrMemoHeaderIn."Shortcut Dimension 1 Code";
                    CustomerRebateLine."Shortcut Dimension 2 Code" := SalesCrMemoHeaderIn."Shortcut Dimension 2 Code";
                    CustomerRebateLine."Sell-To Customer No." := SalesCrMemoHeaderIn."Sell-To Customer No.";
                    CustomerRebateLine."Bill-To Customer No." := SalesCrMemoHeaderIn."Bill-To Customer No.";
                end;
        end;
        //CustomerRebateLine.Exclude := false;
        CustomerRebateLine."Pay-To Vendor No." := CustomerRebateHeader."Pay-To Vendor No.";
        CustomerRebateLine.BatchID := GlobalBatchID;
        CustomerRebateLine."Batch Entry No." := GlobalBatchEntryNo;
        CustomerRebateLine.Insert;
    end;

    local procedure InsertRebateDetail(DocumentTypeIn: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesInvLineIn: Record "Sales Invoice Line"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; SalesCrMemoLineIn: Record "Sales Cr.Memo Line"; Customer: Record Customer; RebateNo: Code[20]; RebateLineNo: Integer)
    var
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        Location: Record Location;
        RebateCategoryLines: Record "AQD Cust Rebate Category Lines";
        TempRebateCategoryLines: Record "AQD Cust Rebate Category Lines" temporary;
        LocalDocumentLine_Type: Enum "Purchase Line Type";
        LocalDocumentLine_No: Code[20];
        LineNo: Integer;
        IsHandled: Boolean;
        PostingDate: Date;
        CustomerRebateDetailsLoc: Record "AQD Customer Rebate Details";
        ItemCustRebateMatrix: Record "AQD Cust Item Rebate Matrix";
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
        TempReturnReceiptLine: Record "Return Receipt Line" temporary;
        RebateProgramCodeRec: Record "AQD Cust Rebate Program Code";
        ChkCustItemRbtMatrixMgt: Codeunit "AQD ChkCustItemRbt Matrix Mgt";
        LocalRebateCategoryCode: Code[20];
        IsRebateEnabled: Boolean;
        UseRebateCostSetupFrom: Enum "AQD Use Cust Rebate Setup From";
        RebateCostPostingType: Enum "AQD Cust Rebate Posting Type";
    begin
        Clear(CustomerRebateDetails);
        LineNo := 1;

        IsHandled := false;
        //OnBeforeInitRebateEntry(CustomerRebateDetailsLoc, IsHandled);
        if IsHandled then
            exit;

        CASE DocumentTypeIn OF
            DocumentTypeIn::Invoice:
                begin
                    PostingDate := SalesInvHeaderIn."Posting Date";
                    LocalDocumentLine_Type := SalesInvLineIn.Type;
                    LocalDocumentLine_No := SalesInvLineIn."No.";
                end;
            DocumentTypeIn::"Credit Memo":
                begin
                    PostingDate := SalesCrMemoHeaderIn."Posting Date";
                    LocalDocumentLine_Type := SalesCrMemoLineIn.Type;
                    LocalDocumentLine_No := SalesCrMemoLineIn."No.";
                end;
        END;

        CASE LocalDocumentLine_Type OF
            LocalDocumentLine_Type::Item:
                BEGIN
                    Item.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                    UseRebateCostSetupFrom := Item."AQD Use Cust Rebate Setup From";
                    RebateCostPostingType := Item."AQD Cust Rebate Posting Type";
                END;
            LocalDocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                    UseRebateCostSetupFrom := GLAccount."AQD Use Cust Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                    UseRebateCostSetupFrom := Resource."AQD Use Cust Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := ItemCharge."AQD Cust Rebate Category Code";
                    UseRebateCostSetupFrom := ItemCharge."AQD Use Cust Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := FixedAsset."AQD Cust Rebate Category Code";
                    UseRebateCostSetupFrom := FixedAsset."AQD Use Cust Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
        END;

        CustomerRebateDetailsLoc.Reset();
        CustomerRebateDetailsLoc.SetRange("Rebate No.", RebateNo);
        CustomerRebateDetailsLoc.SetRange("Rebate Line No.", RebateLineNo);
        if CustomerRebateDetailsLoc.FindLast() then
            LineNo := CustomerRebateDetailsLoc."Line No." + 10000
        else
            LineNo := 10000;

        TempRebateCategoryLines.RESET;
        IF TempRebateCategoryLines.IsTemporary then
            TempRebateCategoryLines.DeleteAll();

        IF LocalRebateCategoryCode <> '' THEN BEGIN
            TempRebateCategoryLines.Init();
            TempRebateCategoryLines."Rebate Category Code" := LocalRebateCategoryCode;

            TempRebateCategoryLines."AQD Use Rebate Setup From" := UseRebateCostSetupFrom;
            TempRebateCategoryLines."AQD Cust Rebate Posting Type" := RebateCostPostingType;

            RebateCategoryLines.RESET;
            RebateCategoryLines.SetRange("Rebate Category Code", LocalRebateCategoryCode);
            IF RebateCategoryLines.FindFirst() THEN begin
                repeat
                    TempRebateCategoryLines."Line No." := RebateCategoryLines."Line No.";
                    TempRebateCategoryLines."Rebate Program Code" := RebateCategoryLines."Rebate Program Code";

                    IF TempRebateCategoryLines."AQD Cust Rebate Posting Type" = TempRebateCategoryLines."AQD Cust Rebate Posting Type"::" " THEN begin
                        IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                            TempRebateCategoryLines."AQD Cust Rebate Posting Type" := RebateProgramCodeRec."Customer Rebate Posting Type";
                        end;
                    end;

                    IF TempRebateCategoryLines."AQD Cust Rebate Posting Type" = TempRebateCategoryLines."AQD Cust Rebate Posting Type"::" " THEN
                        TempRebateCategoryLines."AQD Cust Rebate Posting Type" := TempRebateCategoryLines."AQD Cust Rebate Posting Type"::"G/L Account";

                    TempRebateCategoryLines.Insert();
                until RebateCategoryLines.Next() = 0;
            end ELSE BEGIN
                TempRebateCategoryLines."Line No." := 10000;
                TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";

                IF TempRebateCategoryLines."AQD Cust Rebate Posting Type" = TempRebateCategoryLines."AQD Cust Rebate Posting Type"::" " THEN begin
                    IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                        TempRebateCategoryLines."AQD Cust Rebate Posting Type" := RebateProgramCodeRec."Customer Rebate Posting Type";
                    end;
                end;

                IF TempRebateCategoryLines."AQD Cust Rebate Posting Type" = TempRebateCategoryLines."AQD Cust Rebate Posting Type"::" " THEN
                    TempRebateCategoryLines."AQD Cust Rebate Posting Type" := TempRebateCategoryLines."AQD Cust Rebate Posting Type"::"G/L Account";

                TempRebateCategoryLines.INSERT;
            END;

            TempRebateCategoryLines.RESET;
            IF TempRebateCategoryLines.FindFirst() THEN BEGIN
                Repeat
                    IsRebateEnabled := FALSE;
                    IsRebateEnabled := ChkCustItemRbtMatrixMgt.IsBillToCustomerEligibleForRebate(
                                                                ItemCustRebateMatrix,
                                                                Customer."No.",
                                                                LocalDocumentLine_Type,
                                                                LocalDocumentLine_No,
                                                                PostingDate,
                                                                TempRebateCategoryLines."Rebate Program Code");
                    IF IsRebateEnabled THEN BEGIN
                        CustomerRebateDetails.Init;
                        case DocumentTypeIn of
                            DocumentTypeIn::Invoice:
                                begin
                                    CustomerRebateDetails.INIT;
                                    CustomerRebateDetails."Rebate No." := RebateNo;
                                    CustomerRebateDetails."Rebate Line No." := RebateLineNo;
                                    CustomerRebateDetails."Line No." := LineNo;
                                    CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::Invoice;
                                    CustomerRebateDetails."Document No." := SalesInvLineIn."Document No.";
                                    CustomerRebateDetails."Document Line No." := SalesInvLineIn."Line No.";
                                    case SalesInvLineIn.Type of
                                        SalesInvLineIn.Type::"Charge (Item)":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"Charge (Item)";
                                        SalesInvLineIn.Type::"Fixed Asset":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"Fixed Asset";
                                        SalesInvLineIn.Type::"G/L Account":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"G/L Account";
                                        SalesInvLineIn.Type::Item:
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::Item;
                                        SalesInvLineIn.Type::Resource:
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::Resource;
                                    end;
                                    CustomerRebateDetails."No." := SalesInvLineIn."No.";
                                    CustomerRebateDetails.Description := SalesInvLineIn.Description;
                                    CustomerRebateDetails.Quantity := SalesInvLineIn.Quantity;
                                    CustomerRebateDetails."Unit Cost" := SalesInvLineIn."Unit Cost";
                                    CustomerRebateDetails."Unit Price" := SalesInvLineIn."Unit Price";
                                    CustomerRebateDetails.Amount := SalesInvLineIn.Amount;
                                    CustomerRebateDetails."Amount Including VAT" := SalesInvLineIn."Amount Including VAT";
                                    CustomerRebateDetails."Rebate Type" := CustomerRebateDetails."Rebate Type"::" ";
                                    CustomerRebateDetails."Rebate %" := 0;
                                    CustomerRebateDetails."Rebate Per Quantity" := 0;
                                    CustomerRebateDetails."Salesperson Code" := SalesInvHeaderIn."Salesperson Code";
                                    CustomerRebateDetails."Responsibility Center" := SalesInvLineIn."Responsibility Center";
                                    CustomerRebateDetails."Location Code" := SalesInvLineIn."Location Code";
                                    CustomerRebateDetails."Shortcut Dimension 1 Code" := SalesInvLineIn."Shortcut Dimension 1 Code";
                                    CustomerRebateDetails."Shortcut Dimension 2 Code" := SalesInvLineIn."Shortcut Dimension 2 Code";
                                    CustomerRebateDetails.State := SalesInvHeaderIn."Ship-to County";
                                    SalesInvLineIn.GetSalesShptLines(TempSalesShptLine);
                                    IF TempSalesShptLine.FindFirst() THEN BEGIN
                                        CustomerRebateDetails."Applies-to Doc. Type" := CustomerRebateDetails."Applies-to Doc. Type"::Shipment;
                                        CustomerRebateDetails."Applies-to Doc. No." := TempSalesShptLine."Document No.";
                                        CustomerRebateDetails."Applies-to Doc. Line No." := TempSalesShptLine."Line No.";
                                    END ELSE BEGIN
                                        CustomerRebateDetails."Applies-to Doc. Type" := CustomerRebateDetails."Applies-to Doc. Type"::Invoice;
                                        CustomerRebateDetails."Applies-to Doc. No." := SalesInvLineIn."Document No.";
                                        CustomerRebateDetails."Applies-to Doc. Line No." := SalesInvLineIn."Line No.";
                                    END;
                                END;
                            DocumentTypeIn::"Credit Memo":
                                BEGIN
                                    CustomerRebateDetails.INIT;
                                    CustomerRebateDetails."Rebate No." := RebateNo;
                                    CustomerRebateDetails."Rebate Line No." := RebateLineNo;
                                    CustomerRebateDetails."Line No." := LineNo;
                                    CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::"Credit Memo";
                                    CustomerRebateDetails."Document No." := SalesCrMemoLineIn."Document No.";
                                    CustomerRebateDetails."Document Line No." := SalesCrMemoLineIn."Line No.";
                                    case SalesCrMemoLineIn.Type of
                                        SalesCrMemoLineIn.Type::"Charge (Item)":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"Charge (Item)";
                                        SalesCrMemoLineIn.Type::"Fixed Asset":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"Fixed Asset";
                                        SalesCrMemoLineIn.Type::"G/L Account":
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::"G/L Account";
                                        SalesCrMemoLineIn.Type::Item:
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::Item;
                                        SalesCrMemoLineIn.Type::Resource:
                                            CustomerRebateDetails.Type := CustomerRebateDetails.Type::Resource;
                                    END;
                                    CustomerRebateDetails."No." := SalesCrMemoLineIn."No.";
                                    CustomerRebateDetails.Description := SalesCrMemoLineIn.Description;
                                    CustomerRebateDetails.Quantity := -1 * SalesCrMemoLineIn.Quantity;
                                    CustomerRebateDetails."Unit Cost" := SalesCrMemoLineIn."Unit Cost";
                                    CustomerRebateDetails."Unit Price" := SalesCrMemoLineIn."Unit Price";
                                    CustomerRebateDetails."Rebate Type" := CustomerRebateDetails."Rebate Type"::" ";
                                    CustomerRebateDetails."Rebate %" := 0;
                                    CustomerRebateDetails."Rebate Per Quantity" := 0;
                                    CustomerRebateDetails.Amount := -1 * SalesCrMemoLineIn.Amount;
                                    CustomerRebateDetails."Amount Including VAT" := -1 * SalesCrMemoLineIn."Amount Including VAT";
                                    CustomerRebateDetails."Salesperson Code" := SalesCrMemoHeaderIn."Salesperson Code";
                                    CustomerRebateDetails."Responsibility Center" := SalesCrMemoLineIn."Responsibility Center";
                                    CustomerRebateDetails."Location Code" := SalesCrMemoLineIn."Location Code";
                                    CustomerRebateDetails."Shortcut Dimension 1 Code" := SalesCrMemoLineIn."Shortcut Dimension 1 Code";
                                    CustomerRebateDetails."Shortcut Dimension 2 Code" := SalesCrMemoLineIn."Shortcut Dimension 2 Code";
                                    CustomerRebateDetails.State := SalesCrMemoHeaderIn."Ship-to County";
                                    SalesCrMemoLineIn.GetReturnRcptLines(TempReturnReceiptLine);
                                    IF TempReturnReceiptLine.FindFirst() THEN BEGIN
                                        CustomerRebateDetails."Applies-to Doc. Type" := CustomerRebateDetails."Applies-to Doc. Type"::"Return Receipt";
                                        CustomerRebateDetails."Applies-to Doc. No." := TempReturnReceiptLine."Document No.";
                                        CustomerRebateDetails."Applies-to Doc. Line No." := TempReturnReceiptLine."Line No.";
                                    END ELSE BEGIN
                                        CustomerRebateDetails."Applies-to Doc. Type" := CustomerRebateDetails."Applies-to Doc. Type"::"Credit Memo";
                                        CustomerRebateDetails."Applies-to Doc. No." := SalesCrMemoLineIn."Document No.";
                                        CustomerRebateDetails."Applies-to Doc. Line No." := SalesCrMemoLineIn."Line No.";
                                    END;
                                END;
                        END;
                        CustomerRebateDetails."Sell-To Customer No." := CustomerRebateLine."Sell-To Customer No.";
                        CustomerRebateDetails."Bill-To Customer No." := CustomerRebateLine."Bill-To Customer No.";
                        CustomerRebateDetails."Pay-To Vendor No." := CustomerRebateLine."Pay-To Vendor No.";

                        // Calculate and Vendor Rebate Amount
                        CustomerRebateDetails."Rebate Item Category Code" := TempRebateCategoryLines."Rebate Category Code";
                        CustomerRebateDetails."Rebate Program Code" := TempRebateCategoryLines."Rebate Program Code";
                        CustomerRebateDetails."Posting Date" := CustomerRebateLine."Posting Date";
                        CustomerRebateDetails."Rebate Order Date" := CustomerRebateLine."Rebate Order Date";
                        GetRebateCategoryCode(CustomerRebateDetails);
                        GetSalesRebateDetails(CustomerRebateDetails);
                        CustomerRebateDetails."Profit %" := CalculateProfitPercentage(CustomerRebateDetails);
                        CalculateRebateAmount(CustomerRebateDetails);
                        CustomerRebateDetails."Calculated Line Rebate Amount" := CustomerRebateDetails."Customer Rebate Amount";
                        CustomerRebateDetails."Do Not Credit" := false;
                        CustomerRebateDetails.BatchID := GlobalBatchID;
                        CustomerRebateDetails."Batch Entry No." := GlobalBatchEntryNo;
                        CustomerRebateDetails."AQD Use Cust Rebate Setup From" := TempRebateCategoryLines."AQD Use Rebate Setup From";
                        CustomerRebateDetails."AQD Cust Rebate Posting Type" := TempRebateCategoryLines."AQD Cust Rebate Posting Type";
                        IF CustomerRebateDetails."Rebate Type" <> CustomerRebateDetails."Rebate Type"::" " then
                            CustomerRebateDetails.Insert();
                    END;
                Until (TempRebateCategoryLines.Next() = 0);
            END;
        END;
    END;

    local procedure GetBatchID(DocumentPostingDate: Date): Code[50];
    var
        LocalCustomerRebateBatch: Record "AQD Customer Rebate Batch";
        DateRec: Record Date;
        LocalBatchID: Code[50];
    begin
        IF RebateSetup."AQD Rebate Batch Frequency" = RebateSetup."AQD Rebate Batch Frequency"::" " then
            exit;

        DateRec.RESET;
        DateRec.SetFilter("Period Start", '<=%1', DocumentPostingDate);
        DateRec.SetFilter("Period End", '>=%1', DocumentPostingDate);
        Case RebateSetup."AQD Rebate Batch Frequency" of
            RebateSetup."AQD Rebate Batch Frequency"::Day:
                begin
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Date);
                    IF DateRec.FindFirst() then begin
                        LocalBatchID := FORMAT(DateRec."Period End");
                        LocalBatchID := DelChr(LocalBatchID, '=', '/');
                        LocalBatchID := DelChr(LocalBatchID, '=', '-');
                        LocalBatchID := 'DATE ' + LocalBatchID;
                        GlobalBatchStartDate := DateRec."Period Start";
                        GlobalBatchEndDate := DateRec."Period End";
                        GlobalRebateBatchFrequency := RebateSetup."AQD Rebate Batch Frequency";
                        PostingDescrptionText := StrSubstNo(RebatePeriodText,
                                                    FORMAT(RebateSetup."AQD Rebate Batch Frequency") + ' ' + FORMAT(DateRec."Period Start"),
                                                    DateRec."Period End");
                    end;
                end;
            RebateSetup."AQD Rebate Batch Frequency"::Week:
                begin
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Week);
                    IF DateRec.FindFirst() then begin
                        LocalBatchID := FORMAT(Date2DMY(DateRec."Period End", 3));
                        LocalBatchID := FORMAT(DateRec."Period Type") + FORMAT(DateRec."Period Name") + ' ' + LocalBatchID;
                        GlobalBatchStartDate := DateRec."Period Start";
                        GlobalBatchEndDate := DateRec."Period End";
                        GlobalRebateBatchFrequency := RebateSetup."AQD Rebate Batch Frequency";
                        PostingDescrptionText := StrSubstNo(RebatePeriodText,
                                                    FORMAT(RebateSetup."AQD Rebate Batch Frequency") + ' ' + FORMAT(DateRec."Period Start"),
                                                    DateRec."Period End");
                    end;
                end;
            RebateSetup."AQD Rebate Batch Frequency"::Month:
                begin
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Month);
                    IF DateRec.FindFirst() then begin
                        LocalBatchID := FORMAT(Date2DMY(DateRec."Period End", 3));
                        LocalBatchID := FORMAT(DateRec."Period Name") + ' ' + LocalBatchID;
                        GlobalBatchStartDate := DateRec."Period Start";
                        GlobalBatchEndDate := DateRec."Period End";
                        GlobalRebateBatchFrequency := RebateSetup."AQD Rebate Batch Frequency";
                        PostingDescrptionText := StrSubstNo(RebatePeriodText,
                                                    FORMAT(RebateSetup."AQD Rebate Batch Frequency") + ' ' + FORMAT(DateRec."Period Start"),
                                                    DateRec."Period End");
                    end;
                end;
            RebateSetup."AQD Rebate Batch Frequency"::Quarter:
                begin
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Quarter);
                    IF DateRec.FindFirst() then begin
                        LocalBatchID := FORMAT(Date2DMY(DateRec."Period End", 3));
                        LocalBatchID := FORMAT(DateRec."Period Type") + FORMAT(DateRec."Period Name") + ' ' + LocalBatchID;
                        GlobalBatchStartDate := DateRec."Period Start";
                        GlobalBatchEndDate := DateRec."Period End";
                        GlobalRebateBatchFrequency := RebateSetup."AQD Rebate Batch Frequency";
                        PostingDescrptionText := StrSubstNo(RebatePeriodText,
                                                    FORMAT(RebateSetup."AQD Rebate Batch Frequency") + ' ' + FORMAT(DateRec."Period Start"),
                                                    DateRec."Period End");
                    end;
                end;
        End;

        LocalCustomerRebateBatch.RESET;
        LocalCustomerRebateBatch.SetRange(BatchID, LocalBatchID);
        IF LocalCustomerRebateBatch.FindFirst() THEN
            GlobalBatchEntryNo := LocalCustomerRebateBatch."Entry No.";
        exit(LocalBatchID);
    end;

    local procedure GetRebateCategoryCode(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalGLAccount: Record "G/L Account";
        LocalFixesAsset: Record "Fixed Asset";
        LocalItemCharge: Record "Item Charge";
    begin
        case CustomerRebateDetailsLocIn.Type OF
            CustomerRebateDetailsLocIn.Type::Item:
                begin
                    IF LocalItem.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalItem."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::Resource:
                begin
                    IF LocalResource.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalResource."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::"G/L Account":
                begin
                    IF LocalGLAccount.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalGLAccount."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::"Fixed Asset":
                begin
                    IF LocalFixesAsset.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalFixesAsset."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::"Charge (Item)":
                begin
                    IF LocalItemCharge.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalItemCharge."AQD Cust Rebate Category Code";
                end;
        end;
    end;

    local procedure GetSalesRebateDetails(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalFixedAsset: Record "Fixed Asset";
        LocalGLAccount: Record "G/L Account";
        LocalItemCharge: Record "Item Charge";
        LocalVendor: Record Vendor;
        SalesRebateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
        VendRebateCategoryCode: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeGetSalesRebateDetail(CustomerRebateDetailsLocIn, IsHandled);
        IF IsHandled THEN
            EXIT;

        SalesRebateCalcMgt.FindSalesLineRebateRate(CustomerRebateDetailsLocIn);

        OnAfterGetSalesRebateDetail(CustomerRebateDetailsLocIn);
    end;

    local procedure CalculateRebateAmount(var CustomerRebateDetailsIn: Record "AQD Customer Rebate Details")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateRebateAmount(CustomerRebateDetailsIn, IsHandled);
        if IsHandled then
            exit;

        if (RebateSetup."Min GP% for Customer Rebate" <> 0) and
           (RebateSetup."Min GP% for Customer Rebate" > Abs(CustomerRebateDetailsIn."Profit %"))
        then begin
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Quantity" := 0;
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            exit;
        end;

        if (CustomerRebateDetailsIn."Document Type" = CustomerRebateDetailsIn."Document Type"::Invoice) and
           (CustomerRebateDetailsIn."Profit %" < 0)
        then begin
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Quantity" := 0;
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            exit;
        end;

        case CustomerRebateDetailsIn."Rebate Type" of
            CustomerRebateDetailsIn."Rebate Type"::"Per Quantity":
                begin
                    CustomerRebateDetailsIn."Customer Rebate Amount" := Round(CustomerRebateDetailsIn."Rebate Per Quantity" * CustomerRebateDetailsIn.Quantity, 0.01);
                    CustomerRebateDetailsIn."Rebate %" := 0;
                end;
            CustomerRebateDetailsIn."Rebate Type"::Percentage:
                begin
                    CustomerRebateDetailsIn."Customer Rebate Amount" := Round((CustomerRebateDetailsIn."Rebate %" / 100) * CustomerRebateDetailsIn.Amount, 0.01);
                    CustomerRebateDetailsIn."Rebate Per Quantity" := 0;
                end;
            else
                CustomerRebateDetailsIn."Customer Rebate Amount" := Round(CustomerRebateDetailsIn."Rebate Per Quantity" * CustomerRebateDetailsIn.Quantity, 0.01);
        end;
    end;

    local procedure CalculateProfitPercentage(var CustomerRebateDetailsVar: Record "AQD Customer Rebate Details"): Decimal
    var
        ProfitPer: Decimal;
    begin
        ProfitPer := 0;
        CustomerRebateDetailsVar."Profit Amount" := Round(CustomerRebateDetailsVar.Quantity * (CustomerRebateDetailsVar."Unit Price" - CustomerRebateDetailsVar."Unit Cost"), 0.01);
        if CustomerRebateDetailsVar."Unit Price" <> 0 then
            ProfitPer := Round((CustomerRebateDetailsVar."Unit Price" - CustomerRebateDetailsVar."Unit Cost") / CustomerRebateDetailsVar."Unit Price" * 100, 0.01);
        if CustomerRebateDetailsVar."Document Type" = CustomerRebateDetailsVar."Document Type"::"Credit Memo" then begin
            CustomerRebateDetailsVar."Profit Amount" := -1 * CustomerRebateDetailsVar."Profit Amount";
            ProfitPer := ProfitPer * -1;
        end;
        exit(ProfitPer);
    end;

    local procedure IsPayRebateOnlyOnPaidInvoices(): Boolean
    begin
        if RebateSetup."Pay Customer Rebate On" = RebateSetup."Pay Customer Rebate On"::"All Invoices" then
            exit(false)
        else
            if RebateSetup."Pay Customer Rebate On" = RebateSetup."Pay Customer Rebate On"::"Fully Paid Invoices" then
                exit(true);
    end;

    local procedure "===Edit Rebate==="()
    begin
    end;

    procedure ProcessLine(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        ExportNewLines: Boolean;
    begin
        ExportNewLines := false;
        if GenJournalLine."Amount (LCY)" <> 0 then
            if ((GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment") or
                (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Electronic Payment-IAT")) and
               (GenJournalLine."Check Exported" = false)
            then
                ExportNewLines := true;

        exit(ExportNewLines);
    end;

    local procedure "=====Events====="()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyInvoiceLineFilter(SalesInvHeader: Record "Sales Invoice Header"; var SalesInvLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyCreditMemoLineFilter(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateRebateAmount(var CustomerRebateDetails: Record "AQD Customer Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRebateAmount(var CustomerRebateDetails: Record "AQD Customer Rebate Details")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalculatingInvoiceRebate(SalesInvHeader: Record "Sales Invoice Header"; Customer: Record Customer; Vendor: Record Vendor; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalculatingCrMemoRebate(SalesCrMHeader: Record "Sales Cr.Memo Header"; Customer: Record Customer; Vendor: Record Vendor; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; var IsRebateEnabled: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitCustomerRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; SalesInvHeader: Record "Sales Invoice Header"; SalesInvLine: Record "Sales Invoice Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindRebateRate(SourceDocType: Option "Posted Invoice","Posted Credit Memo"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesRebateDetail(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesRebateDetail(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    begin
    end;
}