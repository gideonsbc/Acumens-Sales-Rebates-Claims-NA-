codeunit 14301911 "AQD Cust Rebate Calc Mgt"
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
        RebateDocEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
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
        RebatePeriodText: Label 'Rebate: %1..%2';
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

    [EventSubscriber(ObjectType::Page, Page::"AQD Cust Rebate Doc Entries", 'OnAfterActionEvent', 'DoNotPayRebate', true, false)]
    local procedure Pag1477013_AQDCustRebateDocEntries_OnValidate_DoNotPayRebate(var Rec: Record "AQD Cust Rebate Document Entry")
    var
        CustomerRebateEntry: Record "AQD Customer Rebate Entry";
    begin
        if Rec.IsTemporary then
            exit;

        Rec.TestField(Open, true);
        Rec.TestField(Payable, false);
        Rec.TestField("Rebate Approved", false);
        Rec.TestField("Payment Status", Rec."Payment Status"::" ");

        CustomerRebateEntry.Reset;
        CustomerRebateEntry.SetRange("Rebate Code", Rec."Rebate Code");
        CustomerRebateEntry.SetRange("Document Type", Rec."Document Type");
        CustomerRebateEntry.SetRange("Document No.", Rec."Document No.");
        if CustomerRebateEntry.FindFirst then
            CustomerRebateEntry.ModifyAll("Do Not Pay Rebate", Rec."Do Not Pay Rebate");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Invoice", 'OnAfterActionEvent', 'AQD DoNotPayRebate', true, false)]
    local procedure Page132_PostedSalesInvoice_Onpush_Action_DoNotPayRebate(var Rec: Record "Sales Invoice Header")
    var
        PermissionError: Label 'You do not have the permission to update Do Not Pay Rebate';
        VendorPayableError: Label 'Vendor Payable is already generated for %1 %2. So, "Do Not Pay Rebate" cannot be updated.';
        RebateAlreadyPaidError: Label 'Rebate has already been paid for %1 %2.';
        PermissionConfirmMsg: Label 'Do you want to mark %1 %2 as non-Rebatable?';
    begin
        if Rec.IsTemporary then
            exit;

        if DoNotPayRebateFunc(
          Rec."AQD Do Not Pay Rebate",
          Rec."AQD Rebate Vendor No",
          CalledFromDocumentType::Invoice,
          Rec."No.")
        then
            Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Invoices", 'OnAfterActionEvent', 'AQD DoNotPayRebate', true, false)]
    local procedure Page143_PostedSalesInvoices_Onpush_Action_DoNotPayRebate(var Rec: Record "Sales Invoice Header")
    begin
        if Rec.IsTemporary then
            exit;

        if Rec.FindFirst then begin
            repeat
                if DoNotPayRebateFunc(
                  Rec."AQD Do Not Pay Rebate",
                  Rec."AQD Rebate Vendor No",
                  CalledFromDocumentType::Invoice,
                  Rec."No.")
                then
                    Rec.Modify;
            until Rec.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Credit Memo", 'OnAfterActionEvent', 'AQD DoNotPayRebate', true, false)]
    local procedure Page134_PostedSalesCreditMemo_Onpush_Action_DoNotPayRebate(var Rec: Record "Sales Cr.Memo Header")
    begin
        if Rec.IsTemporary then
            exit;

        if DoNotPayRebateFunc(
          Rec."AQD Do Not Pay Rebate",
          Rec."AQD Rebate Vendor No",
          CalledFromDocumentType::"Credit Memo",
          Rec."No.")
        then
            Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Credit Memos", 'OnAfterActionEvent', 'AQD DoNotPayRebate', true, false)]
    local procedure Page144_PostedSalesCreditMemos_Onpush_Action_DoNotPayRebate(var Rec: Record "Sales Cr.Memo Header")
    begin
        if Rec.IsTemporary then
            exit;

        if Rec.FindFirst then begin
            repeat
                if DoNotPayRebateFunc(
                  Rec."AQD Do Not Pay Rebate",
                  Rec."AQD Rebate Vendor No",
                  CalledFromDocumentType::"Credit Memo",
                  Rec."No.")
                then
                    Rec.Modify;
            until Rec.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"AQD Cust Rebate Doc Entries", 'OnAfterActionEvent', 'DoNotPayRebate', true, false)]
    local procedure Page_70904_RebateDocumentEntries_OnPush_Action_DoNotPayRebate(var Rec: Record "AQD Cust Rebate Document Entry")
    var
        PermissionConfirmMsg: Label 'You really do not want to pay rebate on %1 %2';
        GenJnlLine: Record "Gen. Journal Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        VendorPayableError: Label 'Vendor Payable is already generated for Invoice %1. So, "Do Not Pay Rebate" cannot be updated.';
        PermissionError: Label 'You do not have the permission to update Do Not Pay Rebate.';
        RebateAlreadyPaidError: Label 'Rebate has already been paid for %1 %2.';
        DocumentType: Option Invoice,"Credit Memo";
        DocumentTypeError: Label '"Do Not Pay Rebate" can be only updated for either Invoice or Credit Memo.';
        DocumentFound: Boolean;
    begin
        if Rec.IsTemporary then
            exit;

        if not (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo"]) then
            Error(DocumentTypeError);

        RebateUserSetup.Get(UserId);
        if not (RebateUserSetup."Rebate Role" in
          [RebateUserSetup."Rebate Role"::"Sales Manager",
           RebateUserSetup."Rebate Role"::Admin])
        then
            Error(PermissionError);

        if not Confirm(StrSubstNo(PermissionConfirmMsg, Format(DocumentType), Rec."Document No."), false) then
            exit;

        Rec.TestField(Open, true);
        Rec.TestField(Payable, false);

        if Rec."Document Type" = Rec."Document Type"::Invoice then
            DocumentType := DocumentType::Invoice
        else
            if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
                DocumentType := DocumentType::"Credit Memo";

        DocumentFound := false;
        if Rec."Document Type" = Rec."Document Type"::Invoice then begin
            if SalesInvHeader.Get(Rec."Document No.") then
                DocumentFound := true;
        end else
            if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then begin
                if SalesCrMemoHeader.Get(Rec."Document No.") then
                    DocumentFound := true;
            end;

        if DocumentFound then begin
            Rec.Validate("Do Not Pay Rebate", true);
            Rec.Modify;

            if Rec."Document Type" = Rec."Document Type"::Invoice then begin
                SalesInvHeader."AQD Do Not Pay Rebate" := true;
                SalesInvHeader.Modify;
            end else
                if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then begin
                    SalesCrMemoHeader."AQD Do Not Pay Rebate" := true;
                    SalesCrMemoHeader.Modify;
                end;
        end;
    end;

    procedure DoNotPayRebateFunc(var DocumentDonotPayRebateIn: Boolean; RebateCodeIn: Code[20]; DocumentTypeIn: Option Invoice,"Credit Memo"; DocumentNoIn: Code[20]): Boolean
    var
        RebateUserSetup: Record "AQD Customer Rebate User Setup";
        PermissionError: Label 'You do not have the permission to update Do Not Pay Rebate';
        VendorPayableError: Label 'Vendor Payable is already generated for %1 %2. So, "Do Not Pay Rebate" cannot be updated.';
        RebateAlreadyPaidError: Label 'Rebate has already been paid for %1 %2.';
        PermissionConfirmMsg: Label 'Do you want to mark %1 %2 as non-rebatable?';
        RebateDocEntryFound: Boolean;
    begin
        ModifyRecord := false;
        RebateUserSetup.Get(UserId);
        if not (RebateUserSetup."Rebate Role" in
          [RebateUserSetup."Rebate Role"::"Sales Manager",
           RebateUserSetup."Rebate Role"::Admin])
        then
            Error(PermissionError);

        if not FirstTime then begin
            if not Confirm(StrSubstNo(PermissionConfirmMsg, Format(DocumentTypeIn), DocumentNoIn), false) then
                exit(false);
            FirstTime := true;
        end;

        RebateDocEntry.Reset;
        RebateDocEntry.SetRange("Rebate Code", RebateCodeIn);
        if DocumentTypeIn = DocumentTypeIn::Invoice then
            RebateDocEntry.SetRange("Document Type", RebateDocEntry."Document Type"::Invoice)
        else
            if DocumentTypeIn = DocumentTypeIn::"Credit Memo" then
                RebateDocEntry.SetRange("Document Type", RebateDocEntry."Document Type"::"Credit Memo");
        RebateDocEntry.SetRange("Document No.", DocumentNoIn);
        if RebateDocEntry.FindFirst then begin
            repeat
                if not RebateDocEntry.Open then
                    Error(StrSubstNo(RebateAlreadyPaidError, Format(RebateDocEntry."Document Type"), RebateDocEntry."Document No."));
                if RebateDocEntry."Vendor Ledger Entry No." <> 0 then
                    Error(VendorPayableError, Format(RebateDocEntry."Document Type"), RebateDocEntry."Document No.");

                DocumentDonotPayRebateIn := true;
                RebateDocEntry.Validate("Do Not Pay Rebate", DocumentDonotPayRebateIn);
                RebateDocEntry.Modify;
            until RebateDocEntry.Next = 0;
        end;

        exit(DocumentDonotPayRebateIn);
    end;


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
        SalesInvoiceHeader.ModifyAll("AQD Do Not Pay Rebate", true);

        SalesCrMemoHeader.Reset;
        SalesCrMemoHeader.SetFilter("Posting Date", '<%1', RebateSetup."Start Date");
        SalesCrMemoHeader.ModifyAll("AQD Do Not Pay Rebate", true);

        RebateSetup."Old Documents Updated" := true;
        RebateSetup.Modify;
        Message(OldDocAlreadyUpdatedSuccessfully);
    end;

    local procedure "===Calculation==="()
    begin
    end;

    procedure CalculateRebate(var CustomerIn: Record Customer; RegenerateEntries: Boolean)
    var
        LocalCustomer: Record Customer;
    //UpdateRebateCustomerType: Report "AQD Udt Rebate Customer Type";
    begin
        RebateSetup.Get;

        LastRebateLdgrEntryNo := 0;
        Clear(RebateEntry);
        if RebateEntry.FindLast then
            LastRebateLdgrEntryNo := RebateEntry."Entry No.";

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

        SourceCodeSetup.Get;

        if RegenerateEntries then begin
            RebateDocEntry.Reset;
            RebateDocEntry.SetFilter("Document Type", '%1|%2',
              RebateDocEntry."Document Type"::Invoice,
              RebateDocEntry."Document Type"::"Credit Memo");
            RebateDocEntry.SetRange("Sell-to Customer No.", CustomerIn."No.");
            RebateDocEntry.SetRange(Open, true);
            RebateDocEntry.SetRange(Payable, false);
            RebateDocEntry.SetRange("Rebate Approved", false);
            RebateDocEntry.SetRange("Payment Status", RebateDocEntry."Payment Status"::" ");
            if RebateDocEntry.FindFirst then begin
                repeat
                    RebateDocEntry.Delete(true);
                until RebateDocEntry.Next = 0;
            end;
        end;

        // Calculate Rebate for Posted Sales Invoices
        BuildInvoiceRebate(CustomerIn);

        // Calculate Rebate for Posted Sales Credit Memos
        if not RebateSetup."Prevent Negative Cust Rebate" then // To Include Credit Memo, it must be Yes
            BuildCrMemoRebate(CustomerIn);
    end;

    local procedure BuildInvoiceRebate(var CustomerIn: Record Customer)
    var
        SkipRecord: Boolean;
        LocalSalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetCurrentKey("Sell-to Customer No.", "AQD Rebate Vendor No", "Posting Date");
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", CustomerIn."No.");
        SalesInvoiceHeader.SetRange("AQD Do Not Pay Rebate", false);
        SalesInvoiceHeader.SetRange("AQD Cust Rebate Entry Created", false);
        SalesInvoiceHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        if RebateSetup."Start Date" <> 0D then
            SalesInvoiceHeader.SetFilter("Posting Date", '>=%1', RebateSetup."Start Date");
        if SalesInvoiceHeader.FindFirst then
            repeat
                SkipRecord := false;

                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then
                    if not Vendor.Get(SalesInvoiceHeader."AQD Rebate Vendor No") then
                        SkipRecord := true;

                if IsPayRebateOnlyOnPaidInvoices() then begin
                    SalesInvoiceHeader.CalcFields(Closed);
                    if not SalesInvoiceHeader.Closed then
                        SkipRecord := true;
                end;

                //if SalesInvoiceHeader."AQD Rebate %" = 0 then
                IF NOT IsRebataEnabledLineExist(SourceDocumentType::Invoice, SalesInvoiceHeader, LocalSalesCrMemoHeader) THEN
                    SkipRecord := true;

                RebateDocEntry.Reset;
                RebateDocEntry.SetRange("Document Type", RebateDocEntry."Document Type"::Invoice);
                RebateDocEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
                if RebateDocEntry.FindFirst then
                    SkipRecord := true;

                SalesInvLine.Reset;
                SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                SalesInvLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
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
                    BuildInvoiceRebateDetail(SalesInvoiceHeader, CustomerIn);
            until SalesInvoiceHeader.Next = 0;
    end;

    local procedure BuildInvoiceRebateDetail(var SalesInvHeaderIn: Record "Sales Invoice Header"; CustomerIn: Record Customer)
    var
        Vendor: Record Vendor;
        SalesInvLine: Record "Sales Invoice Line";
        CustLdgrEntry: Record "Cust. Ledger Entry";
        VendorTypeError: Label 'Vendor Type must be either %1 or %2.';
        Counter: Integer;
        IsHandled: Boolean;
    begin
        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            Clear(Vendor);
            Vendor.Get(SalesInvoiceHeader."AQD Rebate Vendor No");
            if Vendor."AQD Cust Rbt Vendor Type" <> Vendor."AQD Cust Rbt Vendor Type"::"Rebate Vendor" then
                Error(VendorTypeError, Vendor."AQD Cust Rbt Vendor Type");
        end;

        IsHandled := false;
        OnBeforeStartCalculatingInvoiceRebate(SalesInvHeaderIn, CustomerIn, Vendor, IsHandled);
        if IsHandled then
            exit;

        if IsRebataEnabledLineExist(SourceDocumentType::Invoice, SalesInvHeaderIn, SalesCrMemoHeader) then begin
            InsertRebateDocumentEntry(DocumentType::Invoice, SalesInvHeaderIn, SalesCrMemoHeader, CustomerIn, Vendor);

            SalesInvLine.Reset;
            SalesInvLine.SetRange("Document No.", SalesInvHeaderIn."No.");
            SalesInvLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
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
                      SalesInvLine.Type,
                      SalesInvLine."No.")
                    then
                        InsertRebateEntry(DocumentType::Invoice, SalesInvHeaderIn, SalesInvLine, SalesCrMemoHeader, SalesCrMemoLine, CustomerIn, Vendor);
                until SalesInvLine.Next = 0;

                IF CustLdgrEntry.GET(SalesInvHeaderIn."Cust. Ledger Entry No.") then begin
                    RebateDocEntry.CalcFields("Remaining Rebate Amount");
                    CustLdgrEntry."AQD Customer Rebate Amount" := RebateDocEntry."Remaining Rebate Amount";
                    CustLdgrEntry.Modify();
                END
            end;
        end;
    end;

    local procedure BuildCrMemoRebate(var CustomerIn: Record Customer)
    var
        SkipRecord: Boolean;
        LocalSalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesCrMemoHeader.Reset;
        SalesCrMemoHeader.SetCurrentKey("Sell-to Customer No.", "AQD Rebate Vendor No", "Posting Date");
        SalesCrMemoHeader.SetRange("Sell-to Customer No.", CustomerIn."No.");
        SalesCrMemoHeader.SetRange("AQD Do Not Pay Rebate", false);
        SalesCrMemoHeader.SetRange("AQD Rebate Entry Created", false);
        SalesCrMemoHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        if RebateSetup."Start Date" <> 0D then
            SalesCrMemoHeader.SetFilter("Posting Date", '>=%1', RebateSetup."Start Date");
        if SalesCrMemoHeader.FindFirst then begin
            repeat
                SkipRecord := false;

                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then
                    if not Vendor.Get(SalesCrMemoHeader."AQD Rebate Vendor No") then
                        SkipRecord := true;

                if IsPayRebateOnlyOnPaidInvoices() then begin
                    SalesCrMemoHeader.CalcFields(Paid);
                    if not SalesCrMemoHeader.Paid then
                        SkipRecord := true;
                end;

                //if SalesCrMemoHeader."AQD Rebate %" = 0 then
                IF NOT IsRebataEnabledLineExist(SourceDocumentType::"Credit Memo", LocalSalesInvoiceHeader, SalesCrMemoHeader) THEN
                    SkipRecord := true;

                //Rebate Code,Document Type,Document No.,Rebate Type
                RebateDocEntry.Reset;
                RebateDocEntry.SetRange("Document Type", RebateDocEntry."Document Type"::"Credit Memo");
                RebateDocEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
                if RebateDocEntry.FindFirst then
                    SkipRecord := true;

                SalesCrMemoLine.Reset;
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
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
                    BuildCreditMemoRebateDetail(SalesCrMemoHeader, CustomerIn);
            until SalesCrMemoHeader.Next = 0;
        end;
    end;

    local procedure BuildCreditMemoRebateDetail(SalesCrMHeaderIn: Record "Sales Cr.Memo Header"; CustomerIn: Record Customer)
    var
        Vendor: Record Vendor;
        IsHandled: Boolean;
    begin
        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            Clear(Vendor);
            Vendor.Get(SalesCrMHeaderIn."AQD Rebate Vendor No");
            Vendor.TestField("AQD Cust Rbt Vendor Type", Vendor."AQD Cust Rbt Vendor Type"::"Rebate Vendor");
        end;

        IsHandled := false;
        OnBeforeStartCalculatingCrMemoRebate(SalesCrMHeaderIn, CustomerIn, Vendor, IsHandled);
        if IsHandled then
            exit;

        if IsRebataEnabledLineExist(SourceDocumentType::"Credit Memo", SalesInvoiceHeader, SalesCrMHeaderIn) then begin
            InsertRebateDocumentEntry(DocumentType::"Credit Memo", SalesInvoiceHeader, SalesCrMHeaderIn, CustomerIn, Vendor);

            SalesCrMemoLine.Reset;
            SalesCrMemoLine.SetRange("Document No.", SalesCrMHeaderIn."No.");
            SalesCrMemoLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
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
                      SalesCrMemoLine.Type,
                      SalesCrMemoLine."No.")
                    then
                        InsertRebateEntry(DocumentType::"Credit Memo", SalesInvoiceHeader, SalesInvLine, SalesCrMHeaderIn, SalesCrMemoLine, CustomerIn, Vendor);
                until SalesCrMemoLine.Next = 0;

            IF CustLdgrEntry.GET(SalesCrMHeaderIn."Cust. Ledger Entry No.") then begin
                RebateDocEntry.CalcFields("Remaining Rebate Amount");
                CustLdgrEntry."AQD Customer Rebate Amount" := RebateDocEntry."Remaining Rebate Amount";
                CustLdgrEntry.Modify();
            END;
        end;
    end;

    local procedure IsRebataEnabledLineExist(SourceDocType: Option "Posted Invoice","Posted Credit Memo"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        IsHandled: Boolean;
    begin
        if SourceDocType = SourceDocType::"Posted Invoice" then begin
            SalesInvoiceLine.Reset;
            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
            SalesInvoiceLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
              SalesInvoiceLine.Type::Item,
              SalesInvoiceLine.Type::Resource,
              SalesInvoiceLine.Type::"G/L Account",
              SalesInvoiceLine.Type::"Fixed Asset",
              SalesInvoiceLine.Type::"Charge (Item)");
            SalesInvoiceLine.SetFilter("No.", '<>%1', '');
            SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
            OnAfterApplyInvoiceLineFilter(SalesInvoiceHeader, SalesInvoiceLine);
            if SalesInvoiceLine.FindFirst then begin
                repeat
                    IsHandled := false;
                    OnBeforeFindRebateRate(SourceDocType, SalesInvoiceHeader, SalesInvoiceLine, SalesCrMemoHeader, SalesCrMemoLine, IsHandled);
                    if not IsHandled then
                        if IsLineRebateEnabled(
                          SalesInvoiceLine.Type,
                          SalesInvoiceLine."No.")
                        then
                            exit(true);
                until SalesInvoiceLine.Next = 0;
            end;
        end else
            if SourceDocType = SourceDocType::"Posted Credit Memo" then begin
                SalesCrMemoLine.Reset;
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
                  SalesCrMemoLine.Type::Item,
                  SalesCrMemoLine.Type::Resource,
                  SalesCrMemoLine.Type::"Fixed Asset",
                  SalesCrMemoLine.Type::"G/L Account",
                  SalesCrMemoLine.Type::"Charge (Item)");
                SalesCrMemoLine.SetFilter("No.", '<>%1', '');
                SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                OnAfterApplyCreditMemoLineFilter(SalesCrMemoHeader, SalesCrMemoLine);
                if SalesCrMemoLine.FindFirst then begin
                    repeat
                        IsHandled := false;
                        OnBeforeFindRebateRate(SourceDocType, SalesInvoiceHeader, SalesInvoiceLine, SalesCrMemoHeader, SalesCrMemoLine, IsHandled);
                        if not IsHandled then
                            if IsLineRebateEnabled(
                              SalesCrMemoLine.Type,
                              SalesCrMemoLine."No.")
                            then
                                exit(true);
                    until SalesCrMemoLine.Next = 0;
                end;
            end;

        exit(false);
    end;

    local procedure IsLineRebateEnabled(DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        ItemRebateCategory: Record "AQD Cust Rebate Item Category";
        IsHandled: Boolean;
        IsRebateEnabled: Boolean;
    begin
        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    Item.Get(DocumentLine_No);
                    IF Item."AQD Customer Rebate Enabled" then
                        EXIT(Item."AQD Customer Rebate Enabled");
                    EXIT(FALSE);
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GLAccount.Get(DocumentLine_No);
                    exit(GLAccount."AQD Customer Rebate Enabled");
                end;
            DocumentLine_Type::Resource:
                begin
                    Resource.Get(DocumentLine_No);
                    exit(Resource."AQD Customer Rebate Enabled");
                end;
            DocumentLine_Type::"Charge (Item)":
                begin
                    ItemCharge.Get(DocumentLine_No);
                    exit(ItemCharge."AQD Customer Rebate Enabled");
                end;
            DocumentLine_Type::"Fixed Asset":
                begin
                    FixedAsset.Get(DocumentLine_No);
                    exit(FixedAsset."AQD Customer Rebate Enabled");
                end;
            else begin
                IsHandled := false;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebateEnabled, IsHandled);
                if IsHandled then
                    exit(IsRebateEnabled);
            end;
        end;
        exit(false);
    end;

    local procedure InsertRebateDocumentEntry(DocumentType: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesCrMHeaderIn: Record "Sales Cr.Memo Header"; CustomerIn: Record Customer; VendorIn: Record Vendor)
    var
        DocumentNo: Code[20];
    begin
        Clear(RebateDocEntry);

        RebateDocEntry.Init;
        if DocumentType = DocumentType::Invoice then begin
            SalesInvHeaderIn.CalcFields(Amount);
            if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
                RebateDocEntry."Rebate Type" := RebateDocEntry."Rebate Type"::Vendor;
                RebateDocEntry."Rebate Code" := VendorIn."No.";
            end else
                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::"Credit Memo" then begin
                    RebateDocEntry."Rebate Type" := RebateDocEntry."Rebate Type"::Customer;
                    RebateDocEntry."Rebate Code" := CustomerIn."No.";
                end;
            RebateDocEntry."Document Type" := RebateDocEntry."Document Type"::Invoice;
            RebateDocEntry."Document No." := SalesInvHeaderIn."No.";
            RebateDocEntry."Sell-to Customer No." := SalesInvHeaderIn."Sell-to Customer No.";
            RebateDocEntry."Sell-to Customer Name" := SalesInvHeaderIn."Sell-to Customer Name";
            RebateDocEntry."Bill-to Customer No." := SalesInvHeaderIn."Bill-to Customer No.";
            RebateDocEntry."Sell-to Customer Name" := SalesInvHeaderIn."Sell-to Customer Name";
            RebateDocEntry."Salesperson Code" := SalesInvHeaderIn."Salesperson Code";
            RebateDocEntry."Document Posting Date" := SalesInvHeaderIn."Posting Date";
            RebateDocEntry.Open := true;
            RebateDocEntry.Description := OrderText + SalesInvHeaderIn."Order No.";
            RebateDocEntry."Cust. Ledger Entry No." := SalesInvHeaderIn."Cust. Ledger Entry No.";
            RebateDocEntry.State := SalesInvHeaderIn."Ship-to County";
            RebateDocEntry."Order Date" := SalesInvHeaderIn."Order Date";
            RebateDocEntry."External Document No." := SalesInvHeaderIn."External Document No.";
            RebateDocEntry."Order No." := SalesInvHeaderIn."Order No.";
            RebateDocEntry."Location Code" := SalesInvHeaderIn."Location Code";
            RebateDocEntry."Shortcut Dimension 1 Code" := SalesInvHeaderIn."Shortcut Dimension 1 Code";
            RebateDocEntry."Shortcut Dimension 2 Code" := SalesInvHeaderIn."Shortcut Dimension 2 Code";
            RebateDocEntry."Document Amount" := SalesInvHeaderIn.Amount;
            DocumentNo := SalesInvHeaderIn."No.";
        end else
            if DocumentType = DocumentType::"Credit Memo" then begin
                SalesCrMHeaderIn.CalcFields(Amount);
                if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
                    RebateDocEntry."Rebate Type" := RebateDocEntry."Rebate Type"::Vendor;
                    RebateDocEntry."Rebate Code" := VendorIn."No.";
                end else
                    if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::"Credit Memo" then begin
                        RebateDocEntry."Rebate Type" := RebateDocEntry."Rebate Type"::Customer;
                        RebateDocEntry."Rebate Code" := CustomerIn."No.";
                    end;
                RebateDocEntry."Document Type" := RebateDocEntry."Document Type"::"Credit Memo";
                RebateDocEntry."Document No." := SalesCrMHeaderIn."No.";
                RebateDocEntry."Sell-to Customer No." := SalesCrMHeaderIn."Sell-to Customer No.";
                RebateDocEntry."Sell-to Customer Name" := SalesCrMHeaderIn."Sell-to Customer Name";
                RebateDocEntry."Bill-to Customer No." := SalesCrMHeaderIn."Bill-to Customer No.";
                RebateDocEntry."Sell-to Customer Name" := SalesCrMHeaderIn."Sell-to Customer Name";
                RebateDocEntry."Salesperson Code" := SalesCrMHeaderIn."Salesperson Code";
                RebateDocEntry."Document Posting Date" := SalesCrMHeaderIn."Posting Date";
                RebateDocEntry.Open := true;
                RebateDocEntry.Description := ReturnOrderText + SalesCrMHeaderIn."Return Order No.";
                RebateDocEntry."Cust. Ledger Entry No." := SalesCrMHeaderIn."Cust. Ledger Entry No.";
                RebateDocEntry.State := SalesCrMHeaderIn."Ship-to County";
                RebateDocEntry."Order Date" := 0D;
                RebateDocEntry."External Document No." := SalesCrMHeaderIn."External Document No.";
                RebateDocEntry."Order No." := SalesCrMHeaderIn."Return Order No.";
                RebateDocEntry."Location Code" := SalesCrMHeaderIn."Location Code";
                RebateDocEntry."Shortcut Dimension 1 Code" := SalesCrMHeaderIn."Shortcut Dimension 1 Code";
                RebateDocEntry."Shortcut Dimension 2 Code" := SalesCrMHeaderIn."Shortcut Dimension 2 Code";
                RebateDocEntry."Document Amount" := -1 * SalesCrMHeaderIn.Amount;
                DocumentNo := SalesCrMHeaderIn."No.";
            end;
        RebateDocEntry."Created Date Time" := CurrentDateTime;
        OnBeforeInsertRebateDocEntry(DocumentType, DocumentNo, RebateDocEntry);
        RebateDocEntry.Insert;
        OnAfterInsertRebateDocEntry(DocumentType, DocumentNo, RebateDocEntry);
    end;

    local procedure InsertRebateEntry(DocumentTypeIn: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesInvLineIn: Record "Sales Invoice Line"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; SalesCrMemoLineIn: Record "Sales Cr.Memo Line"; CustomerIn: Record Customer; VendorIn: Record Vendor)
    var
        Resource: Record Resource;
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemLedgEntry: Record "Item Ledger Entry";
        DocumentNo: Code[20];
        DocumentLineNo: Integer;
        IsHandled: Boolean;
    begin
        LastRebateLdgrEntryNo := LastRebateLdgrEntryNo + 1;
        Clear(RebateEntry);

        IsHandled := false;
        OnBeforeInitCustomerRebateEntry(DocumentTypeIn, SalesInvHeaderIn, SalesInvLineIn, SalesCrMemoHeaderIn, SalesCrMemoLineIn, IsHandled);
        if IsHandled then
            exit;

        RebateEntry.Init;
        RebateEntry."Entry No." := LastRebateLdgrEntryNo;
        CASE DocumentTypeIn OF
            DocumentTypeIn::Invoice:
                BEGIN
                    RebateEntry."State" := SalesInvHeaderIn."Ship-to County";
                    CASE CustomerIn."AQD Rebate Payment Method" OF
                        CustomerIn."AQD Rebate Payment Method"::Check:
                            BEGIN
                                RebateEntry."AQD Rebate Type" := RebateEntry."AQD Rebate Type"::Vendor;
                                RebateEntry."Rebate Code" := VendorIn."No.";
                            END;
                        CustomerIn."AQD Rebate Payment Method"::"Credit Memo":
                            BEGIN
                                RebateEntry."AQD Rebate Type" := RebateEntry."AQD Rebate Type"::Customer;
                                RebateEntry."Rebate Code" := CustomerIn."No.";
                            END;
                    END;
                    RebateEntry."Document Type" := RebateEntry."Document Type"::Invoice;
                    RebateEntry."Document No." := SalesInvLineIn."Document No.";
                    RebateEntry."Document Line No." := SalesInvLineIn."Line No.";
                    RebateEntry."Document Posting Date" := SalesInvLineIn."Posting Date";
                    CASE SalesInvLineIn.Type of
                        SalesInvLineIn.Type::Item:
                            RebateEntry."Type" := RebateEntry."Type"::Item;
                        SalesInvLineIn.Type::Resource:
                            RebateEntry."Type" := RebateEntry."Type"::Resource;
                        SalesInvLineIn.Type::"G/L Account":
                            RebateEntry."Type" := RebateEntry."Type"::"G/L Account";
                        SalesInvLineIn.Type::"Charge (Item)":
                            RebateEntry."Type" := RebateEntry."Type"::"Charge (Item)";
                        SalesInvLineIn.Type::"Fixed Asset":
                            RebateEntry."Type" := RebateEntry."Type"::"Fixed Asset";
                    END;
                    RebateEntry."No." := SalesInvLineIn."No.";
                    RebateEntry."Description" := SalesInvLineIn.Description;
                    RebateEntry."Sell-to Customer No." := SalesInvHeaderIn."Sell-to Customer No.";
                    RebateEntry."Sell-to Customer Name" := SalesInvHeaderIn."Sell-to Customer Name";
                    RebateEntry."Bill-to Customer No." := SalesInvHeaderIn."Bill-to Customer No.";
                    RebateEntry."Billl-to Customer Name" := SalesInvHeaderIn."Bill-to Name";
                    RebateEntry."Salesperson Code" := SalesInvHeaderIn."Salesperson Code";
                    RebateEntry."Unit Price" := SalesInvLineIn."Unit Price";
                    RebateEntry."Unit Cost" := SalesInvLineIn."Unit Cost";
                    RebateEntry."Item Category Code" := SalesInvLineIn."Item Category Code";
                    RebateEntry."Payable" := false;
                    RebateEntry."Open" := true;
                    RebateEntry."Location Code" := SalesInvLineIn."Location Code";
                    RebateEntry."Shortcut Dimension 1 Code" := SalesInvLineIn."Shortcut Dimension 1 Code";
                    RebateEntry."Shortcut Dimension 2 Code" := SalesInvLineIn."Shortcut Dimension 2 Code";
                    RebateEntry."Do Not Pay Rebate" := SalesInvHeaderIn."AQD Do Not Pay Rebate";
                    RebateEntry."Quantity" := SalesInvLineIn.Quantity;
                    RebateEntry."Line Amount" := SalesInvLineIn.Amount;

                    //RebateEntry."AQDRebate %" := SalesInvHeaderIn."Rebate %";
                    GetSalesRebateDetails(RebateEntry, DocumentTypeIn, SalesInvHeaderIn, SalesInvLineIn, SalesCrMemoHeaderIn, SalesCrMemoLineIn);

                    RebateEntry."Profit %" := CalculateProfitPercentage(RebateEntry);
                    DocumentNo := SalesInvLineIn."Document No.";
                    DocumentLineNo := SalesInvLineIn."Line No.";

                    SalesInvLineIn.GetItemLedgEntries(TempItemLedgEntry, false);
                    OnAfterInitInvoiceRebateEntries(RebateEntry, SalesInvLineIn);
                END;
            DocumentTypeIn::"Credit Memo":
                BEGIN
                    RebateEntry."State" := SalesCrMemoHeaderIn."Ship-to County";
                    if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
                        RebateEntry."AQD Rebate Type" := RebateEntry."AQD Rebate Type"::Vendor;
                        RebateEntry."Rebate Code" := VendorIn."No.";
                    end else
                        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::"Credit Memo" then begin
                            RebateEntry."AQD Rebate Type" := RebateEntry."AQD Rebate Type"::Customer;
                            RebateEntry."Rebate Code" := CustomerIn."No.";
                        end;
                    RebateEntry."Document Type" := RebateEntry."Document Type"::"Credit Memo";
                    RebateEntry."Document No." := SalesCrMemoLineIn."Document No.";
                    RebateEntry."Document Line No." := SalesCrMemoLineIn."Line No.";
                    RebateEntry."Document Posting Date" := SalesCrMemoLineIn."Posting Date";
                    case SalesCrMemoLineIn.Type of
                        SalesCrMemoLineIn.Type::Item:
                            RebateEntry."Type" := RebateEntry."Type"::Item;
                        SalesCrMemoLineIn.Type::Resource:
                            RebateEntry."Type" := RebateEntry."Type"::Resource;
                        SalesCrMemoLineIn.Type::"G/L Account":
                            RebateEntry."Type" := RebateEntry."Type"::"G/L Account";
                        SalesCrMemoLineIn.Type::"Charge (Item)":
                            RebateEntry."Type" := RebateEntry."Type"::"Charge (Item)";
                        SalesCrMemoLineIn.Type::"Fixed Asset":
                            RebateEntry."Type" := RebateEntry."Type"::"Fixed Asset";
                    end;
                    RebateEntry."No." := SalesCrMemoLineIn."No.";
                    RebateEntry."Description" := SalesCrMemoLineIn.Description;
                    RebateEntry."Sell-to Customer No." := SalesCrMemoHeaderIn."Sell-to Customer No.";
                    RebateEntry."Sell-to Customer Name" := SalesInvHeaderIn."Sell-to Customer Name";
                    RebateEntry."Bill-to Customer No." := SalesCrMemoHeaderIn."Bill-to Customer No.";
                    RebateEntry."Billl-to Customer Name" := SalesCrMemoHeaderIn."Bill-to Name";
                    RebateEntry."Salesperson Code" := SalesCrMemoHeaderIn."Salesperson Code";
                    RebateEntry."Unit Price" := SalesCrMemoLineIn."Unit Price";
                    RebateEntry."Unit Cost" := SalesCrMemoLineIn."Unit Cost";
                    RebateEntry."Item Category Code" := SalesCrMemoLineIn."Item Category Code";
                    RebateEntry."Payable" := false;
                    RebateEntry."Open" := true;
                    RebateEntry."Location Code" := SalesCrMemoLineIn."Location Code";
                    RebateEntry."Shortcut Dimension 1 Code" := SalesCrMemoLineIn."Shortcut Dimension 1 Code";
                    RebateEntry."Shortcut Dimension 2 Code" := SalesCrMemoLineIn."Shortcut Dimension 2 Code";
                    RebateEntry."Do Not Pay Rebate" := SalesCrMemoHeaderIn."AQD Do Not Pay Rebate";
                    RebateEntry."Quantity" := SalesCrMemoLineIn.Quantity;
                    RebateEntry."Line Amount" := -1 * SalesCrMemoLineIn.Amount;

                    //RebateEntry."AQDRebate %" := SalesCrMemoHeaderIn."AQD Rebate %";
                    GetSalesRebateDetails(RebateEntry, DocumentTypeIn, SalesInvHeaderIn, SalesInvLineIn, SalesCrMemoHeaderIn, SalesCrMemoLineIn);

                    RebateEntry."Profit %" := CalculateProfitPercentage(RebateEntry);
                    DocumentNo := SalesCrMemoLineIn."Document No.";
                    DocumentLineNo := SalesCrMemoLineIn."Line No.";

                    SalesCrMemoLineIn.GetItemLedgEntries(TempItemLedgEntry, FALSE);

                    OnAfterInitCreditMemoRebateEntries(RebateEntry, SalesCrMemoLineIn);
                END;
        END;

        // Calculate and Assign Amount
        CalculateRebateAmount(RebateEntry);
        if (RebateEntry."Document Type" = RebateEntry."Document Type"::Invoice) and
          (RebateEntry."Profit %" < 0)
        then begin
            RebateEntry."Rebate %" := 0;
            RebateEntry."Rebate Per Quantity" := 0;
            RebateEntry."Rebate Amount" := 0;
            RebateEntry."Remaining Rebate Amount" := 0;
        end;

        // IF TempItemLedgEntry.FindFirst() THEN begin
        //     REPEAT
        //         IF ItemLedgEntry.GET(TempItemLedgEntry."Entry No.") THEN begin
        //             case RebateEntry."Rebate Type" of
        //                 RebateEntry."Rebate Type"::Percentage:
        //                     ItemLedgEntry."AQD Rebate Type" := ItemLedgEntry."AQD Rebate Type"::Percentage;
        //                 RebateEntry."Rebate Type"::"Per Quantity":
        //                     ItemLedgEntry."AQD Rebate Type" := ItemLedgEntry."AQD Rebate Type"::"Per Quantity";
        //             end;
        //             ItemLedgEntry."AQD Rebate Per Quantity" := RebateEntry."Rebate Per Quantity";
        //             ItemLedgEntry."AQD Rebate %" := RebateEntry."Rebate %";
        //             IF RebateEntry."Quantity" <> 0 THEN
        //                 ItemLedgEntry."AQD Customer Rebate Amount" := ROUND(RebateEntry."Rebate Amount" * ItemLedgEntry.Quantity / RebateEntry.Quantity, 0.01);
        //             ItemLedgEntry.Modify();
        //         END;
        //     UNTIL TempItemLedgEntry.Next() = 0;
        // END;

        RebateEntry."Created Date Time" := CurrentDateTime;
        OnBeforeInsertRebateEntry(DocumentTypeIn, DocumentNo, DocumentLineNo, RebateEntry);
        RebateEntry.Insert;
        OnAfterInsertRebateEntry(DocumentTypeIn, DocumentNo, DocumentLineNo, RebateEntry);
    END;

    local procedure GetSalesRebateDetails(var RebateEntryIn: Record "AQD Customer Rebate Entry"; DocumentTypeIn: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesInvLineIn: Record "Sales Invoice Line"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; SalesCrMemoLineIn: Record "Sales Cr.Memo Line")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalFixedAsset: Record "Fixed Asset";
        LocalGLAccount: Record "G/L Account";
        LocalItemCharge: Record "Item Charge";
        CustomerIn: Record Customer;
        IsHandled: Boolean;
        InputType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        InputNo: Code[20];
        CustomerNo: Code[20];
        SalesRebateCalcMgt: Codeunit "AQD Sales Rebate Calc. Mgt.";
    begin
        OnBeforeGetSalesRebateDetail(RebateEntryIn, DocumentTypeIn, SalesInvHeaderIn, SalesInvLineIn, SalesCrMemoHeaderIn, SalesCrMemoLineIn, IsHandled);
        IF IsHandled THEN
            EXIT;

        IF DocumentTypeIn = DocumentTypeIn::Invoice THEN BEGIN
            InputType := SalesInvLineIn.Type;
            InputNo := SalesInvLineIn."No.";
            CustomerNo := SalesInvHeaderIn."Bill-to Customer No.";
        END ELSE
            IF DocumentTypeIn = DocumentTypeIn::"Credit Memo" THEN BEGIN
                InputType := SalesCrMemoLineIn.Type;
                InputNo := SalesCrMemoLineIn."No.";
                CustomerNo := SalesCrMemoHeaderIn."Bill-to Customer No.";
            END;

        SalesRebateCalcMgt.FindSalesLineRebate(RebateEntryIn);
        OnAfterGetSalesRebateDetail(RebateEntryIn, DocumentTypeIn, SalesInvHeaderIn, SalesInvLineIn, SalesCrMemoHeaderIn, SalesCrMemoLineIn);
    end;

    local procedure CalculateProfitPercentage(var RebateEntryVar: Record "AQD Customer Rebate Entry"): Decimal
    var
        ProfitPer: Decimal;
    begin
        ProfitPer := 0;
        RebateEntryVar."Profit Amount" := Round(RebateEntryVar.Quantity * (RebateEntryVar."Unit Price" - RebateEntryVar."Unit Cost"), 0.01);
        if RebateEntryVar."Unit Price" <> 0 then
            ProfitPer := Round((RebateEntryVar."Unit Price" - RebateEntryVar."Unit Cost") / RebateEntryVar."Unit Price" * 100, 0.01);
        if RebateEntryVar."Document Type" = RebateEntryVar."Document Type"::"Credit Memo" then begin
            RebateEntryVar."Profit Amount" := -1 * RebateEntryVar."Profit Amount";
            ProfitPer := ProfitPer * -1;
        end;
        exit(ProfitPer);
    end;

    local procedure CalculateRebateAmount(var RebateEntryIn: Record "AQD Customer Rebate Entry")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateRebateAmount(RebateEntryIn, IsHandled);
        if IsHandled then
            exit;

        if (RebateSetup."Min GP% for Customer Rebate" <> 0) and
          (RebateSetup."Min GP% for Customer Rebate" > Abs(RebateEntryIn."Profit %"))
        then begin
            RebateEntryIn."Rebate %" := 0;
            RebateEntryIn."Base Amount" := 0;
            RebateEntryIn."Rebate Amount" := 0;
            RebateEntryIn."Remaining Rebate Amount" := 0;
            exit;
        end;

        RebateEntryIn."Base Amount" := ROUND(RebateEntryIn."Line Amount", 0.01);
        IF RebateEntryIn."Rebate Type" = RebateEntryIn."Rebate Type"::Percentage THEN BEGIN
            RebateEntryIn."Rebate Amount" := ROUND(RebateEntryIn."Base Amount" * (RebateEntry."Rebate %" / 100), 0.01);
            RebateEntryIn."Remaining Rebate Amount" := RebateEntryIn."Rebate Amount";
            RebateEntryIn."Rebate Type" := RebateEntryIn."Rebate Type"::Percentage;
            RebateEntryIn."Rebate Per Quantity" := 0;
        END ELSE
            IF RebateEntryIn."Rebate Type" = RebateEntryIn."Rebate Type"::"Per Quantity" THEN BEGIN
                RebateEntryIn."Rebate Amount" := ROUND(RebateEntryIn.Quantity * RebateEntryIn."Rebate Per Quantity", 0.01);
                RebateEntryIn."Remaining Rebate Amount" := RebateEntryIn."Rebate Amount";
                RebateEntryIn."Rebate Type" := RebateEntryIn."Rebate Type"::"Per Quantity";
                RebateEntryIn."Rebate %" := 0;
            END;

        OnAfterCalculateRebateAmount(RebateEntryIn);
    end;

    local procedure IsPayRebateOnlyOnPaidInvoices(): Boolean
    begin
        if RebateSetup."Pay Customer Rebate On" = RebateSetup."Pay Customer Rebate On"::"All Invoices" then
            exit(false)
        else
            if RebateSetup."Pay Customer Rebate On" = RebateSetup."Pay Customer Rebate On"::"Fully Paid Invoices" then
                exit(true);
    end;

    local procedure "===Journal==="()
    begin
    end;


    procedure CalVendorRebateJournal(var CustomerIn: Record Customer; StartPostingDateIn: Date; EndPostingDateIn: Date; RunForIn: Option Review,Process)
    var
        RebateJnlLine: Record "AQD Cust Rebate Journal Line";
        NextLineNo: Integer;
    begin
        if not CustomerIn."AQD Enroll for Cust Rebate" then
            exit;

        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            if CustomerIn."AQD Cust Rebate Vendor No" = '' then
                exit;

            Vendor.Get(CustomerIn."AQD Cust Rebate Vendor No");
            if Vendor."AQD Cust Rbt Vendor Type" = Vendor."AQD Cust Rbt Vendor Type"::" " then
                exit;
        end;

        CalculateRebate(CustomerIn, true);

        if not FirstRecord then begin
            FirstRecord := true;

            RebateJnlLine.Reset;
            RebateJnlLine.SetRange("AQD User ID", UserId);
            if RebateJnlLine.FindFirst then
                RebateJnlLine.DeleteAll(true); // Call with RunTrigger to call additional code
        end;

        StartDate := StartPostingDateIn;
        EndDate := EndPostingDateIn;
        RunFor := RunForIn;

        Customer.Copy(CustomerIn);

        if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::Check then begin
            RebateType := RebateType::Vendor;
            RebateCodeName := Vendor.Name;
            CalculateRebateJournal(Vendor."No.",
                                   StartDate,
                                   EndDate,
                                   RunFor);
        end else
            if CustomerIn."AQD Rebate Payment Method" = CustomerIn."AQD Rebate Payment Method"::"Credit Memo" then begin
                RebateType := RebateType::Customer;
                RebateCodeName := CustomerIn.Name;
                CalculateRebateJournal(CustomerIn."No.",
                                       StartDate,
                                       EndDate,
                                       RunFor);
            end;
    end;

    procedure CalculateRebateJournal(RebateCodeIn: Code[20]; StartPostingDateIn: Date; EndPostingDateIn: Date; RunForIn: Option Review,Process)
    var
        RebateJnlLine: Record "AQD Cust Rebate Journal Line";
        NextLineNo: Integer;
        PayRebateOnDoc: Boolean;
        IsHandled: Boolean;
    begin
        RebateSetup.Get;

        LocationFilter := Customer.GetFilter("Location Code");
        ShortcutDim1CodeFilter := Customer.GetFilter("Global Dimension 1 Code");
        ShortcutDim2CodeFilter := Customer.GetFilter("Global Dimension 2 Code");
        CountyFilter := Customer.GetFilter(County);

        RebateDocEntry.Reset;
        if RebateType = RebateType::Vendor then
            RebateDocEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type"::Vendor)
        else
            if RebateType = RebateType::Customer then
                RebateDocEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type"::Customer);
        RebateDocEntry.SetRange("Rebate Code", RebateCodeIn);
        if CountyFilter <> '' then
            RebateDocEntry.SetFilter(State, CountyFilter);
        if LocationFilter <> '' then
            RebateDocEntry.SetFilter("Location Code", LocationFilter);
        if ShortcutDim1CodeFilter <> '' then
            RebateDocEntry.SetFilter("Shortcut Dimension 1 Code", ShortcutDim1CodeFilter);
        if ShortcutDim2CodeFilter <> '' then
            RebateDocEntry.SetFilter("Shortcut Dimension 2 Code", ShortcutDim2CodeFilter);
        RebateDocEntry.SetRange("Document Posting Date", StartDate, EndDate);
        RebateDocEntry.SetRange("Do Not Pay Rebate", false);

        if RunFor = RunFor::Process then begin
            RebateDocEntry.SetFilter("Document Posting Date", '<=%1', EndDate); // Process for all Invoices which are not yetPaid Rebate
            RebateDocEntry.SetRange(Open, true);
            RebateDocEntry.SetRange(Payable, false);
            RebateDocEntry.SetRange("Journal Batch Name", '');
            RebateDocEntry.SetRange("Rebate Approved", false);
        end;

        if RebateDocEntry.FindFirst then begin
            repeat
                RebateDocEntry.CalcFields("Cust. Ledger Entry Open");

                PayRebateOnDoc := true;
                if IsPayRebateOnlyOnPaidInvoices() then begin
                    if RebateDocEntry."Cust. Ledger Entry Open" then
                        PayRebateOnDoc := false;
                end;

                if PayRebateOnDoc then begin
                    RebateJnlLine.Reset;
                    RebateJnlLine.SetRange("AQD User ID", UserId);
                    if RebateJnlLine.FindLast then
                        NextLineNo := RebateJnlLine."AQD Line No." + 10000
                    else
                        NextLineNo := 10000;

                    RebateDocEntry.CalcFields("Base Amount", "Rebate Amount", "Profit Amount");

                    RebateJnlLine.Reset;
                    RebateJnlLine.SetRange("AQD Rebate Code", RebateCodeIn);
                    RebateJnlLine.SetRange("AQD Document Type", RebateDocEntry."Document Type");
                    RebateJnlLine.SetRange("AQD Document No.", RebateDocEntry."Document No.");
                    if not RebateJnlLine.FindFirst then begin
                        Clear(RebateJnlLine);
                        RebateJnlLine.Init;
                        RebateJnlLine."AQD User ID" := UserId;
                        RebateJnlLine."AQD Line No." := NextLineNo;
                        if RebateType = RebateType::Vendor then begin
                            RebateJnlLine."AQD Pay-To Rebate Type" := RebateJnlLine."AQD Pay-To Rebate Type"::Vendor;
                            RebateJnlLine."AQD Rebate Code" := Vendor."No.";
                            RebateJnlLine."AQD Payee Type" := Vendor."AQD Payee Type";
                        end else
                            if RebateType = RebateType::Customer then begin
                                RebateJnlLine."AQD Pay-To Rebate Type" := RebateJnlLine."AQD Pay-To Rebate Type"::Customer;
                                RebateJnlLine."AQD Rebate Code" := RebateCodeIn;
                                RebateJnlLine."AQD Payee Type" := RebateJnlLine."AQD Payee Type"::" ";
                            end;
                        RebateJnlLine."AQD Name" := RebateCodeName;
                        RebateJnlLine."AQD Document Type" := RebateDocEntry."Document Type";
                        RebateJnlLine."AQD Document No." := RebateDocEntry."Document No.";
                        RebateJnlLine."AQD Customer No." := RebateDocEntry."Sell-to Customer No.";
                        RebateJnlLine."AQD Customer Name" := RebateDocEntry."Sell-to Customer Name";
                        RebateJnlLine."AQD Bill-to Customer No." := RebateDocEntry."Bill-to Customer No.";
                        RebateJnlLine."AQD Bill-to Customer Name" := RebateDocEntry."Bill-to Customer Name";
                        RebateJnlLine."AQD Name" := RebateCodeName;
                        RebateJnlLine."AQD Location Code" := RebateDocEntry."Location Code";
                        RebateJnlLine."AQD Shortcut Dimension 1 Code" := RebateDocEntry."Shortcut Dimension 1 Code";
                        RebateJnlLine."AQD Shortcut Dimension 2 Code" := RebateDocEntry."Shortcut Dimension 2 Code";
                        RebateJnlLine."AQD State" := RebateDocEntry.State;
                        RebateJnlLine."AQD Run For" := RunFor;
                        RebateJnlLine."AQD Base Amount" := RebateJnlLine."AQD Base Amount" + RebateDocEntry."Base Amount";
                        RebateJnlLine."AQD Rebate Amount" := RebateJnlLine."AQD Rebate Amount" + RebateDocEntry."Rebate Amount";
                        RebateJnlLine."AQD Profit Amount" := RebateJnlLine."AQD Profit Amount" + RebateDocEntry."Profit Amount";
                        RebateJnlLine."AQD Start Date" := StartDate;
                        RebateJnlLine."AQD End Date" := EndDate;
                        IsHandled := false;
                        OnBeforeInsertRebateJournalLine(RebateJnlLine, RebateDocEntry, IsHandled);
                        RebateJnlLine.Insert;
                        OnAfterInsertRebateJournalLine(RebateJnlLine, RebateDocEntry, IsHandled);
                    end else begin
                        RebateJnlLine."AQD Base Amount" := RebateJnlLine."AQD Base Amount" + RebateDocEntry."Base Amount";
                        RebateJnlLine."AQD Rebate Amount" := RebateJnlLine."AQD Rebate Amount" + RebateDocEntry."Rebate Amount";
                        RebateJnlLine."AQD Profit Amount" := RebateJnlLine."AQD Profit Amount" + RebateDocEntry."Profit Amount";
                        RebateJnlLine.Modify;
                    end;
                    if RebateJnlLine."AQD Run For" = RebateJnlLine."AQD Run For"::Process then begin
                        RebateDocEntry."Journal Template Name" := '';
                        RebateDocEntry."Journal Batch Name" := RebateJnlLine."AQD User ID";
                        RebateDocEntry."Journal Line No." := RebateJnlLine."AQD Line No.";
                        RebateDocEntry.Modify;

                        RebateEntry.Reset;
                        RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                        if RebateEntry."AQD Rebate Type" = RebateEntry."AQD Rebate Type"::Vendor then begin
                            RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type"::Vendor);
                            RebateEntry.SetRange("Rebate Code", Vendor."No.");
                        end else
                            if RebateEntry."AQD Rebate Type" = RebateEntry."AQD Rebate Type"::Customer then begin
                                RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type"::Customer);
                                RebateEntry.SetRange("Rebate Code", RebateCodeIn);
                            end;
                        RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                        RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                        if RebateEntry.FindFirst then begin
                            repeat
                                RebateEntry."Journal Template Name" := '';
                                RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                                RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                                RebateEntry.Modify;
                            until RebateEntry.Next = 0;
                        end;
                    end;
                end;
            until RebateDocEntry.Next = 0;
        end;
    end;

    local procedure "===Edit Rebate==="()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterValidateEvent', 'AQD Do Not Pay Rebate', true, false)]
    local procedure Table112_SalesInvoiceHeader_DoNotPayRebate_OnValidate(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header"; CurrFieldNo: Integer)
    begin
        CheckInvoiceRebateValidation(Rec, xRec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterValidateEvent', 'AQD Rebate Vendor No', true, false)]
    local procedure Table112_SalesInvoiceHeader_RebateVendorNo_OnValidate(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header"; CurrFieldNo: Integer)
    begin
        CheckInvoiceRebateValidation(Rec, xRec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterValidateEvent', 'AQD Do Not Pay Rebate', true, false)]
    local procedure Table114_SalesCrMemoHeader_DoNotPayRebate_OnValidate(var Rec: Record "Sales Cr.Memo Header"; var xRec: Record "Sales Cr.Memo Header"; CurrFieldNo: Integer)
    begin
        CheckCrMemoRebateValidation(Rec, xRec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Header", 'OnAfterValidateEvent', 'AQD Rebate Vendor No', true, false)]
    local procedure Table114_SalesCrMemoHeader_RebateVendorNo_OnValidate(var Rec: Record "Sales Cr.Memo Header"; var xRec: Record "Sales Cr.Memo Header"; CurrFieldNo: Integer)
    begin
        CheckCrMemoRebateValidation(Rec, xRec, CurrFieldNo);
    end;

    local procedure CheckInvoiceRebateValidation(var Rec: Record "Sales Invoice Header"; var xRec: Record "Sales Invoice Header"; CurrFieldNo: Integer)
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateIsAlreadyPaidError: Label 'Rebate is already paid for Invoice %1.';
        RebateIsAlreadyPayableError: Label 'Rebate is already posted for Invoice %1.';
        RebateIsAlreadyApprovedError: Label 'Rebate is already approved for Invoice %1.';
        RebateIsAlreadyPaymentStatusError: Label 'Rebate Payment Status is %1 for Invoice %2.';
        LocalCustomer: Record Customer;
    begin
        RebateSetup.Get;

        if not LocalCustomer.Get(Rec."Sell-to Customer No.") then
            LocalCustomer.Init;

        RebateDocumentEntry.Reset;
        if LocalCustomer."AQD Rebate Payment Method" = LocalCustomer."AQD Rebate Payment Method"::Check then
            RebateDocumentEntry.SetRange("Rebate Code", xRec."AQD Rebate Vendor No")
        else
            if LocalCustomer."AQD Rebate Payment Method" = LocalCustomer."AQD Rebate Payment Method"::"Credit Memo" then
                RebateDocumentEntry.SetRange("Rebate Code", Rec."Sell-to Customer No.");
        RebateDocumentEntry.SetRange("Document Type", RebateDocumentEntry."Document Type"::Invoice);
        RebateDocumentEntry.SetRange("Document No.", Rec."No.");
        if RebateDocumentEntry.FindFirst then begin
            if not RebateDocumentEntry.Open then
                Error(RebateIsAlreadyPaidError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry.Payable then
                Error(RebateIsAlreadyPayableError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry."Rebate Approved" then
                Error(RebateIsAlreadyApprovedError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry."Payment Status" <> RebateDocumentEntry."Payment Status"::" " then
                Error(RebateIsAlreadyPaymentStatusError, Format(RebateDocumentEntry."Payment Status"), RebateDocumentEntry."Document No.");
        end;
        Rec."AQD Cust Rebate LastChangedBy" := UserId;
        Rec."AQD CustRbt LastChangdDateTime" := CurrentDateTime;
    end;

    local procedure CheckCrMemoRebateValidation(var Rec: Record "Sales Cr.Memo Header"; var xRec: Record "Sales Cr.Memo Header"; CurrFieldNo: Integer)
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateIsAlreadyPaidError: Label 'Rebate is already paid for Credit Memo %1.';
        RebateIsAlreadyPayableError: Label 'Rebate is already posted for Credit Memo %1.';
        RebateIsAlreadyApprovedError: Label 'Rebate is already approved for Invoice %1.';
        RebateIsAlreadyPaymentStatusError: Label 'Rebate Payment Status is %1 for Credit Memo %2.';
        LocalCustomer: Record Customer;
    begin
        RebateSetup.Get;

        if not LocalCustomer.Get(Rec."Sell-to Customer No.") then
            LocalCustomer.Init;

        RebateDocumentEntry.Reset;
        if LocalCustomer."AQD Rebate Payment Method" = LocalCustomer."AQD Rebate Payment Method"::Check then
            RebateDocumentEntry.SetRange("Rebate Code", xRec."AQD Rebate Vendor No")
        else
            if LocalCustomer."AQD Rebate Payment Method" = LocalCustomer."AQD Rebate Payment Method"::"Credit Memo" then
                RebateDocumentEntry.SetRange("Rebate Code", Rec."Sell-to Customer No.");
        RebateDocumentEntry.SetRange("Document Type", RebateDocumentEntry."Document Type"::"Credit Memo");
        RebateDocumentEntry.SetRange("Document No.", Rec."No.");
        if RebateDocumentEntry.FindFirst then begin
            if not RebateDocumentEntry.Open then
                Error(RebateIsAlreadyPaidError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry.Payable then
                Error(RebateIsAlreadyPayableError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry."Rebate Approved" then
                Error(RebateIsAlreadyApprovedError, RebateDocumentEntry."Document No.");
            if RebateDocumentEntry."Payment Status" <> RebateDocumentEntry."Payment Status"::" " then
                Error(RebateIsAlreadyPaymentStatusError, Format(RebateDocumentEntry."Payment Status"), RebateDocumentEntry."Document No.");
        end;
        Rec."AQD Rebate Last Changed By" := UserId;
        Rec."AQD Rebate LastChangd DateTime" := CurrentDateTime;
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
    local procedure OnBeforeCalculateRebateAmount(var RebateEntry: Record "AQD Customer Rebate Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRebateAmount(var RebateEntry: Record "AQD Customer Rebate Entry")
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
    local procedure OnBeforeInsertRebateDocEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; var CustRebateDocEntry: Record "AQD Cust Rebate Document Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateDocEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; var CustRebateDocEntry: Record "AQD Cust Rebate Document Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; DocumentLineNo: Integer; var CustomerRebateEntry: Record "AQD Customer Rebate Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; DocumentLineNo: Integer; var CustomerRebateEntry: Record "AQD Customer Rebate Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; var IsRebateEnabled: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateJournalLine(var RebateJnlLine: Record "AQD Cust Rebate Journal Line"; CustRebateDocEntry: Record "AQD Cust Rebate Document Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateJournalLine(var RebateJnlLine: Record "AQD Cust Rebate Journal Line"; CustRebateDocEntry: Record "AQD Cust Rebate Document Entry"; var IsHandled: Boolean)
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
    local procedure OnAfterInitInvoiceRebateEntries(var CustomerRebateEntry: Record "AQD Customer Rebate Entry"; SalesInvoiceLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitCreditMemoRebateEntries(var CustomerRebateEntry: Record "AQD Customer Rebate Entry"; SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesRebateDetail(var CustomerRebateEntry: Record "AQD Customer Rebate Entry"; DocumentTypeIn: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesInvLineIn: Record "Sales Invoice Line"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; SalesCrMemoLineIn: Record "Sales Cr.Memo Line"; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesRebateDetail(var CustomerRebateEntry: Record "AQD Customer Rebate Entry"; DocumentTypeIn: Option " ",Invoice,"Credit Memo"; SalesInvHeaderIn: Record "Sales Invoice Header"; SalesInvLineIn: Record "Sales Invoice Line"; SalesCrMemoHeaderIn: Record "Sales Cr.Memo Header"; SalesCrMemoLineIn: Record "Sales Cr.Memo Line")
    begin
    end;
}

