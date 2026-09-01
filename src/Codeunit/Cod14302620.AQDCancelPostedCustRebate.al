codeunit 14302620 "AQD Cancel Posted Cust Rebate"
{
    Permissions = tabledata "AQD Posted Cust Rebate Header" = rm,
                  tabledata "AQD Posted Cust Rebate Line" = rm,
                  tabledata "AQD Posted Cust Reb Details" = rm,
                  tabledata "AQD CR Reb Item Ledger Entry" = rm,
                  tabledata "AQD Sales Rebate Approvals" = d,
                  tabledata "Sales Header" = d,
                  tabledata "Gen. Journal Line" = d,
                  tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm,
                  tabledata "Sales Shipment Header" = rm,
                  tabledata "Return Receipt Header" = rm,
                  tabledata "G/L Entry" = rm;

    procedure CancelPostedCustomerRebate(var PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialog: Boolean)
    var
        TransactionNos: List of [Integer];
        ConfirmCancelLbl: Label 'Do you want to cancel posted sales rebate %1?';
        CancellationCompletedLbl: Label 'Posted sales rebate %1 was canceled.';
        MissingPostedTxnErr: Label 'Posted sales rebate %1 cannot be canceled because no posted rebate transactions were identified for reversal.';
        CFBaseEvents: Codeunit "AQD Acumens Base Events";
    begin
        EnsureCancelPermission();

        RebateSetup.Get();
        PostedCustRebateHeader.Get(PostedCustRebateHeader."No.");

        if ShowDialog then
            if not Confirm(StrSubstNo(ConfirmCancelLbl, PostedCustRebateHeader."No.")) then
                exit;

        PostingDate := PostedCustRebateHeader."Posting Date";
        PostingDate := CFBaseEvents.ConfirmReversalPostingDate(PostingDate);

        DeleteOpenRebateSalesDocuments(PostedCustRebateHeader);
        DeleteOpenRebateJournalLines(PostedCustRebateHeader);

        ReversePostedRebateSalesDocuments(PostedCustRebateHeader);
        ReversePostedVendorCommissions(PostedCustRebateHeader);

        DeleteSalesRebateApprovals(PostedCustRebateHeader);
        ResetSourceSalesDocumentStatus(PostedCustRebateHeader);
        ResetRebateItemLedgerEntries(PostedCustRebateHeader);
        ZeroPostedRebateAmounts(PostedCustRebateHeader);

        Message(CancellationCompletedLbl, PostedCustRebateHeader."No.");
    end;

    // local procedure EnsureCancelPermission()
    // var
    //     UserSetup: Record "User Setup";
    //     NoPermissionErr: Label 'Only Admin users can cancel posted sales rebates.';
    // begin
    //     if not UserSetup.Get(UserId) then
    //         Error(NoPermissionErr);

    //     if not (UserSetup."AQD Cust Rebate Rebate Role" in [UserSetup."AQD Cust Rebate Rebate Role"::Admin])
    //     then
    //         Error(NoPermissionErr);
    // end;

    local procedure EnsureCancelPermission()
    var
        AccessControl: Record "Access Control";
        User: Record User;
        NoPermissionErr: Label 'You do not have permission to perform this action.';
    begin
        if not User.Get(UserSecurityId()) then
            Error(NoPermissionErr);

        AccessControl.Reset();
        AccessControl.SetRange("User Name", User."User Name");
        AccessControl.SetRange("Role ID", 'AQD SREBATE ADMIN');
        if not AccessControl.FindFirst() then
            Error(NoPermissionErr);
    end;

    local procedure DeleteOpenRebateSalesDocuments(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("AQD Customer Rebate", true);
        SalesHeader.SetRange("AQD Customer Rebate No", PostedCustRebateHeader."No.");
        if SalesHeader.FindSet(true) then
            repeat
                SalesHeader.Delete(true);
            until SalesHeader.Next() = 0;
    end;

    local procedure DeleteOpenRebateJournalLines(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    begin
        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateDetail.SetRange("Customer Rebate Status", PostedCustRebateDetail."Customer Rebate Status"::Created);
        PostedCustRebateDetail.SetFilter("Sales Jnl Template Name", '<>%1', '');
        PostedCustRebateDetail.SetFilter("Sales Jnl Batch Name", '<>%1', '');
        PostedCustRebateDetail.SetFilter("Sales Jnl Line No.", '<>%1', 0);
        if PostedCustRebateDetail.FindSet() then
            repeat
                DeleteJournalLine(
                  PostedCustRebateDetail."Sales Jnl Template Name",
                  PostedCustRebateDetail."Sales Jnl Batch Name",
                  PostedCustRebateDetail."Sales Jnl Line No.");
            until PostedCustRebateDetail.Next() = 0;

        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateLine.SetRange("Customer Rebate Status", PostedCustRebateLine."Customer Rebate Status"::Created);
        PostedCustRebateLine.SetFilter("Sales Jnl Template Name", '<>%1', '');
        PostedCustRebateLine.SetFilter("Sales Jnl Batch Name", '<>%1', '');
        PostedCustRebateLine.SetFilter("Sales Jnl Line No.", '<>%1', 0);
        if PostedCustRebateLine.FindSet() then
            repeat
                DeleteJournalLine(
                  PostedCustRebateLine."Sales Jnl Template Name",
                  PostedCustRebateLine."Sales Jnl Batch Name",
                  PostedCustRebateLine."Sales Jnl Line No.");
            until PostedCustRebateLine.Next() = 0;
    end;

    local procedure DeleteJournalLine(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer)
    begin
        if (TemplateName = '') or (BatchName = '') or (LineNo = 0) then
            exit;

        if GenJournalLine.Get(TemplateName, BatchName, LineNo) then
            GenJournalLine.Delete(true);
    end;

    [Obsolete('Not in Use', 'Deprecated in v25.1023.1.35')]
    local procedure CollectPostedTransactionNos(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header"; var TransactionNos: List of [Integer])
    begin
        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        if PostedCustRebateDetail.FindSet() then
            repeat
                AddTransactionNosByNonSalesDocumentNo(PostedCustRebateDetail."Rebate Sales Document No.", TransactionNos);
                AddTransactionNosByNonSalesDocumentNo(PostedCustRebateDetail."Vendor Document No.", TransactionNos);
            until PostedCustRebateDetail.Next() = 0;
    end;

    local procedure ReversePostedRebateSalesDocuments(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        LocalSalesHeader: Record "Sales Header";
        LocalSalesInvoiceHeader: Record "Sales Invoice Header";
        LocalSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        CancelPostedSalesCrMemo: Codeunit "Cancel Posted Sales Cr. Memo";
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        SalesPost: Codeunit "Sales-Post";
    begin
        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateLine.SetFilter("Credit Document No.", '<>%1', '');
        if PostedCustRebateLine.FindSet() then
            repeat
                case PostedCustRebateLine."Document Type" of
                    PostedCustRebateLine."Document Type"::Invoice, PostedCustRebateLine."Document Type"::Shipment:
                        begin
                            if not CanceledSalesDocumentNos.Contains(PostedCustRebateLine."Credit Document No.") then begin
                                if LocalSalesCrMemoHeader.Get(PostedCustRebateLine."Credit Document No.") then
                                    if (LocalSalesCrMemoHeader."AQD Customer Rebate") and
                                       (LocalSalesCrMemoHeader."AQD Customer Rebate No" = PostedCustRebateHeader."No.")
                                    then begin
                                        Clear(LocalSalesHeader);
                                        LocalSalesHeader.Init();
                                        LocalSalesHeader.SetHideValidationDialog(TRUE);
                                        LocalSalesHeader."Document Type" := LocalSalesHeader."Document Type"::Invoice;
                                        LocalSalesHeader."External Document No." := LocalSalesCrMemoHeader."No.";
                                        LocalSalesHeader."No." := '';
                                        LocalSalesHeader.Insert(true);

                                        CopyDocumentMgt.SetPropertiesForCreditMemoCorrection();
                                        CopyDocumentMgt.CopySalesDocForCrMemoCancelling(LocalSalesCrMemoHeader."No.", LocalSalesHeader);

                                        LocalSalesHeader.Validate("Posting Date", PostingDate);
                                        LocalSalesHeader.Validate("AQD Customer Rebate", true);
                                        LocalSalesHeader.Validate("AQD Customer Rebate No", PostedCustRebateHeader."No.");
                                        LocalSalesHeader.Modify(true);

                                        LocalSalesHeader.Ship := true;
                                        LocalSalesHeader.Invoice := true;
                                        SalesPost.Run(LocalSalesHeader);

                                        AddCanceledSalesDocumentNo(PostedCustRebateLine."Credit Document No.");
                                    end;
                            end;
                        end;
                    PostedCustRebateLine."Document Type"::"Credit Memo", PostedCustRebateLine."Document Type"::"Return Receipt":
                        begin
                            if not CanceledSalesDocumentNos.Contains(PostedCustRebateLine."Credit Document No.") then begin
                                if LocalSalesInvoiceHeader.Get(PostedCustRebateLine."Credit Document No.") then
                                    if (LocalSalesInvoiceHeader."AQD Customer Rebate") and
                                       (LocalSalesInvoiceHeader."AQD Customer Rebate No" = PostedCustRebateHeader."No.")
                                    then begin
                                        Clear(LocalSalesHeader);
                                        LocalSalesHeader.Init();
                                        LocalSalesHeader.SetHideValidationDialog(true);
                                        LocalSalesHeader."Document Type" := LocalSalesHeader."Document Type"::"Credit Memo";
                                        LocalSalesHeader."External Document No." := LocalSalesInvoiceHeader."No.";
                                        LocalSalesHeader."No." := '';
                                        LocalSalesHeader.Insert(true);

                                        CopyDocumentMgt.SetPropertiesForInvoiceCorrection(false);
                                        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(LocalSalesInvoiceHeader."No.", LocalSalesHeader);

                                        LocalSalesHeader.Validate("Posting Date", PostingDate);
                                        LocalSalesHeader.Validate("AQD Customer Rebate", true);
                                        LocalSalesHeader.Validate("AQD Customer Rebate No", PostedCustRebateHeader."No.");
                                        LocalSalesHeader.Modify(true);

                                        LocalSalesHeader.Receive := true;
                                        LocalSalesHeader.Invoice := true;
                                        SalesPost.Run(LocalSalesHeader);

                                        AddCanceledSalesDocumentNo(PostedCustRebateLine."Credit Document No.");
                                    end;
                            end;
                        end;
                end;
            until PostedCustRebateLine.Next() = 0;
    end;

    local procedure AddCanceledSalesDocumentNo(DocumentNo: Code[20])
    begin
        if (DocumentNo <> '') and (not CanceledSalesDocumentNos.Contains(DocumentNo)) then
            CanceledSalesDocumentNos.Add(DocumentNo);
    end;

    local procedure ReversePostedVendorCommissions(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        LineNo: Integer;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        LocalRebateAmount: Decimal;
        VendLedgEntry: Record "Vendor Ledger Entry";
        DocumentNo: Code[20];
    begin
        if not RebateSetup.Get() then
            exit;

        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateDetail.SetFilter("Vendor Document No.", '<>%1', '');
        PostedCustRebateDetail.SetRange("Entity Type", PostedCustRebateDetail."Entity Type"::Vendor);
        PostedCustRebateDetail.SetFilter("Customer Rebate Status", '<>%1', PostedCustRebateDetail."Customer Rebate Status"::Cancelled);
        if PostedCustRebateDetail.FindSet() then begin
            repeat
                UnapplyVendorLedgerEntry(PostedCustRebateDetail."Vendor Document Type", PostedCustRebateDetail."Vendor Document No.", PostedCustRebateDetail."Entity No.", PostedCustRebateDetail."Rebate Program Code", VendLedgEntry);

                PostedCustRebateLine.Reset();
                PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateDetail."Rebate No.");
                PostedCustRebateLine.SetRange("Line No.", PostedCustRebateDetail."Rebate Line No.");
                if PostedCustRebateLine.FindFirst() then;

                GenJnlLine.Reset;
                GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                if GenJnlLine.FINDLAST() then
                    LineNo := GenJnlLine."Line No." + 10000
                ELSE
                    LineNo := 10000;

                Clear(DocumentNo);
                Clear(GenJnlLine);
                GenJnlLine.Init;
                GeneralJournalInit(DocumentNo);
                GenJnlTemplate.Get(JnlBatch."Journal Template Name");
                GenJnlLine."Document No." := DocumentNo;
                GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                GenJnlLine."Line No." := LineNo;
                GenJnlLine.Insert(true);
                LineNo += 10000;

                if GenJnlLine."Document No." = '' then
                    GenJnlLine."Document No." := PostedCustRebateDetail."Vendor Document No." + 'R';

                GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                GenJnlLine.UpdateJournalBatchID();
                GenJnlLine.SetHideValidation(true);
                GenJnlLine."Posting Date" := PostingDate;
                GenJnlLine.Description := PostedCustRebateHeader."Posting Description";

                LocalRebateAmount := PostedCustRebateDetail."Calculated Line Rebate Amount";
                if LocalRebateAmount > 0 then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                else
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);

                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                GenJnlLine.Validate("Account No.", PostedCustRebateDetail."Entity No.");
                GenJnlLine.Validate("Currency Code", PostedCustRebateLine."Currency Code");
                GenJnlLine.Validate(Amount, LocalRebateAmount);
                GenJnlLine."External Document No." := PostedCustRebateLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                GenJnlLine.Validate("Payment Method Code", VendLedgEntry."Payment Method Code");

                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", VendLedgEntry."Bal. Account No.");

                GenJnlLine."Shortcut Dimension 1 Code" := PostedCustRebateLine."Shortcut Dimension 1 Code";
                GenJnlLine.Validate("Shortcut Dimension 1 Code");
                GenJnlLine."Shortcut Dimension 2 Code" := PostedCustRebateLine."Shortcut Dimension 2 Code";
                GenJnlLine.Validate("Shortcut Dimension 2 Code");

                case PostedCustRebateDetail."Vendor Document Type" of
                    PostedCustRebateDetail."Vendor Document Type"::Invoice:
                        GenJnlLine."AQD Cust Rebate Document Type" := GenJnlLine."AQD Cust Rebate Document Type"::"Credit Memo";
                    PostedCustRebateDetail."Vendor Document Type"::"Credit Memo":
                        GenJnlLine."AQD Cust Rebate Document Type" := GenJnlLine."AQD Cust Rebate Document Type"::Invoice;
                end;

                GenJnlLine."AQD Cust Rebate Document No." := PostedCustRebateLine."Rebate No.";
                GenJnlLine."AQD CR Rebate Program Code" := PostedCustRebateDetail."Rebate Program Code";
                GenJnlLine."AQD CR Pay-to Vendor No." := VendLedgEntry."AQD CR Pay-to Vendor No.";
                GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                GenJnlLine."Source Code" := VendLedgEntry."Source Code";
                GenJnlLine."AQD Cust Rebate Journal" := TRUE;

                GenJnlLine."Applies-to Doc. Type" := VendLedgEntry."Document Type";
                GenJnlLine."Applies-to Doc. No." := VendLedgEntry."Document No.";

                //To Flow Source Type and Source No.
                GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                GenJnlLine."Source No." := PostedCustRebateLine."Rebate Pay-To Customer No.";
                GenJnlLine."AQD CR Bill-To Customer No." := PostedCustRebateLine."Bill-To Customer No.";
                GenJnlLine.Modify(TRUE);
                if GenJnlLine.Amount = 0 then
                    GenJnlLine.Delete();

            until PostedCustRebateDetail.Next() = 0;
        end;

        GenJnlLine.RESET;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
        GenJnlLine.SetRange("AQD Cust Rebate Journal", TRUE);
        IF GenJnlLine.FindFirst() THEN
            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
    end;

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

    procedure UnapplyVendorLedgerEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; PayeeNo: Code[20]; ProgramCode: Code[20]; var VendLedgEntry: Record "Vendor Ledger Entry")
    var
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
    begin
        VendLedgEntry.SetRange("Document Type", DocumentType);
        VendLedgEntry.SetRange("Document No.", DocumentNo);
        VendLedgEntry.SetRange("Vendor No.", PayeeNo);
        VendLedgEntry.SetRange("AQD CR Rebate Program Code", ProgramCode);
        if VendLedgEntry.FindFirst() then begin
            if not VendLedgEntry.Open then begin
                //Commit();
                VendEntryApplyPostedEntries.CheckVendorLedgerEntryToUnapply(VendLedgEntry."Entry No.", DtldVendLedgEntry);

                if (DtldVendLedgEntry."Entry Type" = DtldVendLedgEntry."Entry Type"::Application) and (not DtldVendLedgEntry.Unapplied) then begin
                    ApplyUnapplyParameters."Posting Date" := DtldVendLedgEntry."Posting Date";
                    ApplyUnapplyParameters."Document No." := DtldVendLedgEntry."Document No.";
                    VendEntryApplyPostedEntries.PostUnApplyVendor(DtldVendLedgEntry, ApplyUnapplyParameters);
                end;
            end;
        end;
    end;

    [Obsolete('Not in Use', 'Deprecated in v25.1023.1.35')]
    local procedure AddTransactionNosByNonSalesDocumentNo(DocumentNo: Code[20]; var TransactionNos: List of [Integer])
    begin
        if (DocumentNo = '') or CanceledSalesDocumentNos.Contains(DocumentNo) then
            exit;

        AddTransactionNosByDocumentNo(DocumentNo, TransactionNos);
    end;

    [Obsolete('Not in Use', 'Deprecated in v25.1023.1.35')]
    local procedure AddTransactionNosByDocumentNo(DocumentNo: Code[20]; var TransactionNos: List of [Integer])
    var
        FromEntryNo: Integer;
        ToEntryNo: Integer;
    begin
        if DocumentNo = '' then
            exit;

        GLEntry.Reset();
        GLEntry.SetCurrentKey("Entry No.");
        GLEntry.SetRange("AQD Customer Rebate", true);
        GLEntry.SetFilter("Document No.", DocumentNo);
        GLEntry.SetRange(Reversed, false);
        GLEntry.SetRange("Source Code", RebateSetup."Customer Rebate Source Code");
        if not GLEntry.FindFirst() then
            exit;

        FromEntryNo := GLEntry."Entry No.";

        if GLEntry.FindLast() then
            ToEntryNo := GLEntry."Entry No.";

        GLRegister.Reset();
        GLRegister.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
        GLRegister.SetFilter("From Entry No.", '<=%1', FromEntryNo);
        GLRegister.SetFilter("To Entry No.", '>=%1', ToEntryNo);
        GLRegister.SetRange(Reversed, false);
        if GLRegister.FindSet() then
            repeat
                if not TransactionNos.Contains(GLRegister."No.") then
                    TransactionNos.Add(GLRegister."No.");
            until GLRegister.Next() = 0;
    end;

    local procedure DeleteSalesRebateApprovals(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        ApprovalKeys: List of [Text];
        ApprovalKey: Text;
    begin
        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        if PostedCustRebateDetail.FindSet() then
            repeat
                ApprovalKey :=
                  Format(PostedCustRebateDetail."Document Type".AsInteger()) + '|' +
                  PostedCustRebateDetail."Document No." + '|' +
                  PostedCustRebateDetail."Rebate Program Code" + '|' +
                  PostedCustRebateDetail."Entity No.";

                if not ApprovalKeys.Contains(ApprovalKey) then begin
                    ApprovalKeys.Add(ApprovalKey);
                    DeleteSalesRebateApproval(PostedCustRebateDetail);
                end;
            until PostedCustRebateDetail.Next() = 0;
    end;

    local procedure DeleteSalesRebateApproval(PostedCustRebateDetail: Record "AQD Posted Cust Reb Details")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        SalesRebateApprovals.Reset();
        SetSalesRebateApprovalDocumentTypeFilter(SalesRebateApprovals, PostedCustRebateDetail."Document Type");
        SalesRebateApprovals.SetRange("Sales Document No.", PostedCustRebateDetail."Document No.");
        SalesRebateApprovals.SetRange("Rebate Program Code", PostedCustRebateDetail."Rebate Program Code");
        SalesRebateApprovals.SetRange("Entity No.", PostedCustRebateDetail."Entity No.");
        SalesRebateApprovals.SetSkipStatusCheck(true);
        if SalesRebateApprovals.FindSet(true) then
            repeat
                ApprovalsMgmt.DeleteApprovalEntries(SalesRebateApprovals.RecordId);
                SalesRebateApprovals.Delete(true);
            until SalesRebateApprovals.Next() = 0;
        SalesRebateApprovals.SetSkipStatusCheck(false);
    end;

    local procedure SetSalesRebateApprovalDocumentTypeFilter(var SalesRebateApprovals: Record "AQD Sales Rebate Approvals"; RebateDocumentType: Enum "AQD Cust Rebate Document Type")
    begin
        case RebateDocumentType of
            RebateDocumentType::"Credit Memo":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Credit Memo");
            RebateDocumentType::Invoice:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Invoice);
            RebateDocumentType::"Return Receipt":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Return Receipt");
            RebateDocumentType::Shipment:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Shipment);
            else
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::" ");
        end;
    end;

    local procedure ResetSourceSalesDocumentStatus(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        LocalPostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
    begin
        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        if PostedCustRebateLine.FindSet() then
            repeat

                LocalPostedCustRebateLine.Reset();
                LocalPostedCustRebateLine.SetRange("Document No.", PostedCustRebateLine."Document No.");
                LocalPostedCustRebateLine.SetRange("Document Type", PostedCustRebateLine."Document Type");
                LocalPostedCustRebateLine.SetFilter("Customer Rebate Status", '<>%1', PostedCustRebateLine."Customer Rebate Status"::Cancelled);
                LocalPostedCustRebateLine.SetFilter("Rebate No.", '<>%1', PostedCustRebateLine."Rebate No.");
                if not LocalPostedCustRebateLine.FindFirst() then begin
                    case PostedCustRebateLine."Document Type" of
                        PostedCustRebateLine."Document Type"::Invoice:
                            if SalesInvoiceHeader.Get(PostedCustRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD Customer Rebate Status" := SalesInvoiceHeader."AQD Customer Rebate Status"::Cancelled;
                                SalesInvoiceHeader."AQD Customer Rebate No" := '';
                                SalesInvoiceHeader."AQD Cust Rebate Program Code" := '';
                                SalesInvoiceHeader."AQD Marketplace Code" := '';
                                SalesInvoiceHeader."AQD Cust Rebate Entry Created" := false;
                                SalesInvoiceHeader.Modify(true);
                            end;
                        PostedCustRebateLine."Document Type"::"Credit Memo":
                            if SalesCrMemoHeader.Get(PostedCustRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD Customer Rebate Status" := SalesCrMemoHeader."AQD Customer Rebate Status"::Cancelled;
                                SalesCrMemoHeader."AQD Customer Rebate No" := '';
                                SalesCrMemoHeader."AQD Cust Rebate Program Code" := '';
                                SalesCrMemoHeader."AQD Marketplace Code" := '';
                                SalesCrMemoHeader."AQD Rebate Entry Created" := false;
                                SalesCrMemoHeader.Modify(true);
                            end;
                        PostedCustRebateLine."Document Type"::Shipment:
                            if SalesShipmentHeader.Get(PostedCustRebateLine."Document No.") then begin
                                SalesShipmentHeader."AQD Customer Rebate Status" := SalesShipmentHeader."AQD Customer Rebate Status"::Cancelled;
                                SalesShipmentHeader."AQD Customer Rebate No" := '';
                                SalesShipmentHeader."AQD Cust Rebate Program Code" := '';
                                SalesShipmentHeader."AQD Marketplace Code" := '';
                                SalesShipmentHeader."AQD Rebate Entry Created" := false;
                                SalesShipmentHeader.Modify(true);
                            end;
                        PostedCustRebateLine."Document Type"::"Return Receipt":
                            if ReturnReceiptHeader.Get(PostedCustRebateLine."Document No.") then begin
                                ReturnReceiptHeader."AQD Customer Rebate Status" := ReturnReceiptHeader."AQD Customer Rebate Status"::Cancelled;
                                ReturnReceiptHeader."AQD Customer Rebate No" := '';
                                ReturnReceiptHeader."AQD Cust Rebate Program Code" := '';
                                ReturnReceiptHeader."AQD Marketplace Code" := '';
                                ReturnReceiptHeader."AQD Rebate Entry Created" := false;
                                ReturnReceiptHeader.Modify(true);
                            end;
                    end;
                end;

            until PostedCustRebateLine.Next() = 0;
    end;

    local procedure ResetRebateItemLedgerEntries(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    begin
        RebateItemLedgerEntry.Reset();
        RebateItemLedgerEntry.SetRange("AQD Rebate No", PostedCustRebateHeader."No.");
        if RebateItemLedgerEntry.FindSet(true) then
            repeat
                RebateItemLedgerEntry."AQD Rebate Entry Created" := false;
                RebateItemLedgerEntry."AQD Rebate Last Changed By" := '';
                RebateItemLedgerEntry."AQD Rebate LastChangd DateTime" := 0DT;
                RebateItemLedgerEntry."AQD Rebate No" := '';
                RebateItemLedgerEntry."AQD Rebate Line No" := 0;
                RebateItemLedgerEntry."AQD Rebate Detail Line No." := 0;
                RebateItemLedgerEntry."AQD Rebate Status" := RebateItemLedgerEntry."AQD Rebate Status"::" ";
                RebateItemLedgerEntry."Rebate Amount" := 0;
                RebateItemLedgerEntry.Modify(true);
            until RebateItemLedgerEntry.Next() = 0;
    end;

    local procedure ZeroPostedRebateAmounts(var PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    begin
        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        if PostedCustRebateLine.FindSet(true) then
            repeat
                PostedCustRebateLine.Amount := 0;
                PostedCustRebateLine."Amount Including VAT" := 0;
                PostedCustRebateLine."Credit Document No." := '';
                PostedCustRebateLine."Rebate Payable A/C" := PostedCustRebateLine."Rebate Payable A/C"::" ";
                PostedCustRebateLine."Sales Jnl Template Name" := '';
                PostedCustRebateLine."Sales Jnl Batch Name" := '';
                PostedCustRebateLine."Sales Jnl Line No." := 0;
                PostedCustRebateLine.Posted := false;
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Cancelled;
                PostedCustRebateLine.Modify(true);
            until PostedCustRebateLine.Next() = 0;

        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        if PostedCustRebateDetail.FindSet(true) then
            repeat
                PostedCustRebateDetail.Amount := 0;
                PostedCustRebateDetail."Amount Including VAT" := 0;
                PostedCustRebateDetail."Calculated Line Rebate Amount" := 0;
                PostedCustRebateDetail."Customer Rebate Amount" := 0;
                PostedCustRebateDetail."Rebate %" := 0;
                PostedCustRebateDetail."Rebate Per Unit" := 0;
                PostedCustRebateDetail."Profit %" := 0;
                PostedCustRebateDetail."Profit Amount" := 0;
                PostedCustRebateDetail."Rebate Sales Document No." := '';
                PostedCustRebateDetail."Rebate Sales Document Line No." := 0;
                PostedCustRebateDetail."Rebate Sales Line No." := 0;
                PostedCustRebateDetail."Vendor Document Type" := PostedCustRebateDetail."Vendor Document Type"::" ";
                PostedCustRebateDetail."Vendor Document No." := '';
                PostedCustRebateDetail."Rebate Payable A/C" := PostedCustRebateDetail."Rebate Payable A/C"::" ";
                PostedCustRebateDetail."Sales Jnl Template Name" := '';
                PostedCustRebateDetail."Sales Jnl Batch Name" := '';
                PostedCustRebateDetail."Sales Jnl Line No." := 0;
                PostedCustRebateDetail."Customer Rebate Status" := PostedCustRebateDetail."Customer Rebate Status"::Cancelled;
                PostedCustRebateDetail.Modify(true);
            until PostedCustRebateDetail.Next() = 0;

        PostedCustRebateHeader."Rebate Payable AC" := PostedCustRebateHeader."Rebate Payable AC"::" ";
        PostedCustRebateHeader."Sales Jnl Template Name" := '';
        PostedCustRebateHeader."Sales Jnl Batch Name" := '';
        PostedCustRebateHeader."Sales Jnl Line No." := 0;
        PostedCustRebateHeader.Approved := false;
        PostedCustRebateHeader."Approved By" := '';
        PostedCustRebateHeader."Approved Date Time" := 0DT;
        PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Cancelled;
        PostedCustRebateHeader.Modify(true);
    end;

    local procedure HasPostedRebateAmounts(PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header"): Boolean
    begin
        PostedCustRebateDetail.Reset();
        PostedCustRebateDetail.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateDetail.SetRange("Customer Rebate Status", PostedCustRebateDetail."Customer Rebate Status"::Posted);
        PostedCustRebateDetail.SetFilter("Calculated Line Rebate Amount", '<>%1', 0);
        exit(PostedCustRebateDetail.FindFirst());
    end;

    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetail: Record "AQD Posted Cust Reb Details";
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        ReversalEntry: Record "Reversal Entry";
        RebateItemLedgerEntry: Record "AQD CR Reb Item Ledger Entry";
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
        CanceledSalesDocumentNos: List of [Code[20]];
        PostingDate: Date;
        GenJnlLine: Record "Gen. Journal Line";
        JnlBatch: Record "Gen. Journal Batch";
        NoSeriesMgt: Codeunit "No. Series";
}