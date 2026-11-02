codeunit 14302513 "AQD Rebate Jnl.-Post"
{
    TableNo = "AQD Rebate Journal Line";

    trigger OnRun()
    begin
        PostBatch(Rec."Batch Name");
    end;

    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        PostedRebateNos: Text;
        ManualRebateDescTxt: Label 'Manual Rebate %1', Comment = '%1 = Journal Document No.';

    procedure PostBatch(BatchName: Code[10])
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
        RebateJournalLine: Record "AQD Rebate Journal Line";
        DocumentRebateJournalLine: Record "AQD Rebate Journal Line";
        NoLinesErr: Label 'There is nothing to post in rebate journal batch %1.', Comment = '%1 = Batch Name';
    begin
        RebateSetup.Get();
        RebateSetup.TestField("Customer Rebate Document Nos");
        RebateJournalBatch.Get(BatchName);

        // Only manual entries are posted here; lines sent from a Sales Rebate Document are
        // posted by SendToJournalAndPost and are hidden from the Rebate Journal page.
        RebateJournalLine.SetRange("Batch Name", BatchName);
        RebateJournalLine.SetRange("Rebate No.", '');
        if not RebateJournalLine.FindSet() then
            Error(NoLinesErr, BatchName);
        repeat
            CheckLine(RebateJournalLine);
        until RebateJournalLine.Next() = 0;
        CheckDocuments(BatchName);

        PostedRebateNos := '';

        // Each Document No. becomes a new Sales Rebate Document.
        RebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
        while RebateJournalLine.FindFirst() do begin
            DocumentRebateJournalLine.Reset();
            DocumentRebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
            DocumentRebateJournalLine.SetRange("Batch Name", BatchName);
            DocumentRebateJournalLine.SetRange("Rebate No.", '');
            DocumentRebateJournalLine.SetRange("Document No.", RebateJournalLine."Document No.");
            PostDocument(RebateJournalBatch, DocumentRebateJournalLine);
        end;
    end;

    procedure GetPostedRebateNos(): Text
    begin
        exit(PostedRebateNos);
    end;

    // Posting entry point for calculated Sales Rebate Documents (document page, auto process, batch posting):
    // the document is sent to the Rebate Journal and its journal lines are posted straight away.
    // Manual journal lines in the same batch are not touched; they are posted from the Rebate Journal page.
    procedure SendToJournalAndPost(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
        RebateJournalLine: Record "AQD Rebate Journal Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        ApplyJournalAmounts: Boolean;
    begin
        RebateJournalLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if RebateJournalLine.IsEmpty() then begin
            CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateHeader."No.");
            if CustomerRebateDetails.IsEmpty() then begin
                // Nothing to journalize (no calculated rebate lines); post the document as before.
                CustomerRebatePost.PostCustomerRebate(CustomerRebateHeader, false);
                exit;
            end;
            RebateJournalBatch.CreateDefaultBatch();
            SendToRebateJournal(CustomerRebateHeader, RebateJournalBatch.Name);
            // Freshly sent lines are copies of the details, so there is nothing to validate or write back.
            ApplyJournalAmounts := false;
        end else
            // Lines already in a journal (e.g. sent earlier and adjusted) are posted with their journal amounts.
            ApplyJournalAmounts := true;

        PostSalesRebate(CustomerRebateHeader, RebateJournalLine, ApplyJournalAmounts);
    end;

    procedure SendToRebateJournal(CustomerRebateHeader: Record "AQD Customer Rebate Header"; BatchName: Code[10]): Integer
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
        RebateJournalLine: Record "AQD Rebate Journal Line";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        NextLineNo: Integer;
        LineCount: Integer;
    begin
        CustomerRebateHeader.TestField(Preview, false);
        CustomerRebateHeader.TestField("Posting Date");
        RebateJournalBatch.Get(BatchName);

        // Already sent to a journal: keep the existing (possibly adjusted) lines and send nothing.
        RebateJournalLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if not RebateJournalLine.IsEmpty() then
            exit(0);

        // No calculated rebate lines: nothing to send.
        CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if not CustomerRebateDetails.FindSet() then
            exit(0);

        // Lock so concurrent postings into the same batch cannot pick the same Line No.
        RebateJournalLine.Reset();
        RebateJournalLine.LockTable();
        RebateJournalLine.SetRange("Batch Name", BatchName);
        if RebateJournalLine.FindLast() then
            NextLineNo := RebateJournalLine."Line No.";

        repeat
            if (CustomerRebateLine."Rebate No." <> CustomerRebateDetails."Rebate No.") or
               (CustomerRebateLine."Line No." <> CustomerRebateDetails."Rebate Line No.")
            then
                if not CustomerRebateLine.Get(CustomerRebateDetails."Rebate No.", CustomerRebateDetails."Rebate Line No.") then
                    Clear(CustomerRebateLine);
            NextLineNo += 10000;
            InsertJournalLineFromDetail(CustomerRebateHeader, CustomerRebateLine, CustomerRebateDetails, BatchName, NextLineNo);
            LineCount += 1;
        until CustomerRebateDetails.Next() = 0;
        exit(LineCount);
    end;

    local procedure InsertJournalLineFromDetail(CustomerRebateHeader: Record "AQD Customer Rebate Header"; CustomerRebateLine: Record "AQD Customer Rebate Line"; CustomerRebateDetails: Record "AQD Customer Rebate Details"; BatchName: Code[10]; LineNo: Integer)
    var
        RebateJournalLine: Record "AQD Rebate Journal Line";
    begin
        RebateJournalLine.Init();
        RebateJournalLine."Batch Name" := BatchName;
        RebateJournalLine."Line No." := LineNo;
        RebateJournalLine."Rebate No." := CustomerRebateDetails."Rebate No.";
        RebateJournalLine."Rebate Line No." := CustomerRebateDetails."Rebate Line No.";
        RebateJournalLine."Rebate Detail Line No." := CustomerRebateDetails."Line No.";
        RebateJournalLine."Posting Date" := CustomerRebateHeader."Posting Date";
        RebateJournalLine."Document Date" := CustomerRebateHeader."Document Date";
        RebateJournalLine."Document Type" := CustomerRebateDetails."Document Type";
        RebateJournalLine."Document No." := CustomerRebateDetails."Document No.";
        RebateJournalLine."Document Line No." := CustomerRebateDetails."Document Line No.";
        RebateJournalLine."External Document No." := CustomerRebateLine."External Document No.";
        RebateJournalLine."Entity Type" := CustomerRebateDetails."Entity Type";
        RebateJournalLine."Entity No." := CustomerRebateDetails."Entity No.";
        RebateJournalLine.Type := CustomerRebateDetails.Type;
        RebateJournalLine."No." := CustomerRebateDetails."No.";
        RebateJournalLine."Rebate Item Category Code" := CustomerRebateDetails."Rebate Item Category Code";
        RebateJournalLine."Rebate Program Code" := CustomerRebateDetails."Rebate Program Code";
        RebateJournalLine."CustRbt Rate Type" := CustomerRebateDetails."CustRbt Rate Type";
        RebateJournalLine.Description := CustomerRebateDetails.Description;
        RebateJournalLine.Quantity := CustomerRebateDetails.Quantity;
        RebateJournalLine."Unit Cost" := CustomerRebateDetails."Unit Cost";
        RebateJournalLine."Unit Price" := CustomerRebateDetails."Unit Price";
        RebateJournalLine."Rebate Type" := CustomerRebateDetails."Rebate Type";
        RebateJournalLine."Rebate %" := CustomerRebateDetails."Rebate %";
        RebateJournalLine."Rebate Per Unit" := CustomerRebateDetails."Rebate Per Unit";
        RebateJournalLine."Rebate Order Date" := CustomerRebateDetails."Rebate Order Date";
        RebateJournalLine.Amount := CustomerRebateDetails.Amount;
        RebateJournalLine."Amount Including VAT" := CustomerRebateDetails."Amount Including VAT";
        RebateJournalLine."Rebate Amount" := CustomerRebateDetails."Customer Rebate Amount";
        RebateJournalLine."Salesperson Code" := CustomerRebateDetails."Salesperson Code";
        RebateJournalLine."Responsibility Center" := CustomerRebateDetails."Responsibility Center";
        RebateJournalLine."Location Code" := CustomerRebateDetails."Location Code";
        RebateJournalLine."Territory Code" := CustomerRebateDetails."Territory Code";
        RebateJournalLine."Shortcut Dimension 1 Code" := CustomerRebateDetails."Shortcut Dimension 1 Code";
        RebateJournalLine."Shortcut Dimension 2 Code" := CustomerRebateDetails."Shortcut Dimension 2 Code";
        RebateJournalLine."Currency Code" := CustomerRebateLine."Currency Code";
        RebateJournalLine."Order No." := CustomerRebateDetails."Order No.";
        RebateJournalLine."Order Line No." := CustomerRebateDetails."Order Line No.";
        RebateJournalLine.State := CustomerRebateDetails.State;
        RebateJournalLine."Sell-To Customer No." := CustomerRebateDetails."Sell-To Customer No.";
        RebateJournalLine."Sell-To Customer Name" := CustomerRebateLine."Sell-To Customer Name";
        RebateJournalLine."Bill-To Customer No." := CustomerRebateDetails."Bill-To Customer No.";
        RebateJournalLine."Bill-To Customer Name" := CustomerRebateLine."Bill-To Customer Name";
        RebateJournalLine."Rebate Pay-To Customer No." := CustomerRebateDetails."Rebate Pay-To Customer No.";
        RebateJournalLine."Applies-to Doc. Type" := CustomerRebateDetails."Applies-to Doc. Type";
        RebateJournalLine."Applies-to Doc. No." := CustomerRebateDetails."Applies-to Doc. No.";
        RebateJournalLine."Applies-to Doc. Line No." := CustomerRebateDetails."Applies-to Doc. Line No.";
        RebateJournalLine."Cust Rebate Posting Type" := CustomerRebateDetails."AQD Cust Rebate Posting Type";
        RebateJournalLine."Marketplace Code" := CustomerRebateDetails."Marketplace Code";
        RebateJournalLine."Customer Rebate Category" := CustomerRebateDetails."Customer Rebate Category";
        RebateJournalLine."Payment Terms Code" := CustomerRebateDetails."Payment Terms Code";
        RebateJournalLine."Line Type" := CustomerRebateDetails."Line Type";
        RebateJournalLine."Rebate Payment Method Code" := CustomerRebateDetails."Rebate Payment Method Code";
        RebateJournalLine."Commission Type" := CustomerRebateHeader."Commission Type";
        OnBeforeInsertJournalLineFromDetail(RebateJournalLine, CustomerRebateDetails);
        RebateJournalLine.Insert();
    end;

    local procedure PostSalesRebate(var CustomerRebateHeader: Record "AQD Customer Rebate Header"; var DocumentRebateJournalLine: Record "AQD Rebate Journal Line"; ApplyJournalAmounts: Boolean)
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        PostingDate: Date;
        SamePostingDateErr: Label 'All journal lines for Sales Rebate %1 must have the same %2.', Comment = '%1 = Rebate No., %2 = Field Caption';
        NotPostedErr: Label 'Sales Rebate %1 could not be posted.', Comment = '%1 = Rebate No.';
    begin
        if ApplyJournalAmounts then begin
            CustomerRebateHeader.Get(CustomerRebateHeader."No.");
            CustomerRebateHeader.TestField(Preview, false);
            DocumentRebateJournalLine.FindSet();
            DocumentRebateJournalLine.TestField("Posting Date");
            PostingDate := DocumentRebateJournalLine."Posting Date";
            repeat
                if DocumentRebateJournalLine."Posting Date" <> PostingDate then
                    Error(SamePostingDateErr, CustomerRebateHeader."No.", DocumentRebateJournalLine.FieldCaption("Posting Date"));
                // The journal amount is the approved amount; adjustments made in the journal flow back to the rebate document.
                CustomerRebateDetails.Get(DocumentRebateJournalLine."Rebate No.", DocumentRebateJournalLine."Rebate Line No.", DocumentRebateJournalLine."Rebate Detail Line No.");
                if CustomerRebateDetails."Customer Rebate Amount" <> DocumentRebateJournalLine."Rebate Amount" then begin
                    CustomerRebateDetails.Validate("Customer Rebate Amount", DocumentRebateJournalLine."Rebate Amount");
                    CustomerRebateDetails.Modify(true);
                end;
            until DocumentRebateJournalLine.Next() = 0;

            if CustomerRebateHeader."Posting Date" <> PostingDate then begin
                CustomerRebateHeader.Validate("Posting Date", PostingDate);
                CustomerRebateHeader.Modify(true);
            end;
        end;

        // Journal lines are removed in the same transaction that posts the rebate document,
        // so they cannot be posted twice if the standard posting commits midway.
        DocumentRebateJournalLine.DeleteAll();

        CustomerRebatePost.PostCustomerRebate(CustomerRebateHeader, false);

        if not PostedCustRebateHeader.Get(CustomerRebateHeader."No.") then
            Error(NotPostedErr, CustomerRebateHeader."No.");

        if PostedRebateNos <> '' then
            PostedRebateNos += ', ';
        PostedRebateNos += PostedCustRebateHeader."No.";
    end;

    local procedure CheckLine(var RebateJournalLine: Record "AQD Rebate Journal Line")
    var
        RebateProgramCode: Record "AQD Cust Rebate Program Code";
        Customer: Record Customer;
    begin
        RebateJournalLine.TestField("Posting Date");
        RebateJournalLine.TestField("Document Type");
        RebateJournalLine.TestField("Document No.");
        RebateJournalLine.TestField("Bill-To Customer No.");
        RebateJournalLine.TestField("Rebate Pay-To Customer No.");
        RebateJournalLine.TestField("Rebate Program Code");
        RebateJournalLine.TestField("Entity No.");
        RebateJournalLine.TestField("Rebate Amount");

        Customer.Get(RebateJournalLine."Bill-To Customer No.");
        Customer.Get(RebateJournalLine."Rebate Pay-To Customer No.");

        RebateProgramCode.Get(RebateJournalLine."Rebate Program Code");
        RebateProgramCode.TestField(Blocked, false);
        RebateProgramCode.TestField("Rebate Expense AC");

        if RebateJournalLine."Cust Rebate Posting Type" = RebateJournalLine."Cust Rebate Posting Type"::" " then
            RebateJournalLine.FieldError("Cust Rebate Posting Type");

        if RebateJournalLine."Cust Rebate Posting Type" = RebateJournalLine."Cust Rebate Posting Type"::Inventory then begin
            // Inventory rebates are credited as an item charge assigned to the applies-to document line.
            RebateJournalLine.TestField("Entity Type", RebateJournalLine."Entity Type"::Customer);
            RebateJournalLine.TestField(Type, RebateJournalLine.Type::Item);
            RebateJournalLine.TestField("No.");
            RebateJournalLine.TestField("Applies-to Doc. No.");
            RebateJournalLine.TestField("Applies-to Doc. Line No.");
            RebateSetup.TestField("Sales Item Charge No.");
        end;
    end;

    local procedure CheckDocuments(BatchName: Code[10])
    var
        RebateJournalLine: Record "AQD Rebate Journal Line";
        FirstRebateJournalLine: Record "AQD Rebate Journal Line";
        SameDocumentLine: Record "AQD Rebate Journal Line";
        DocumentTotal: Decimal;
        SameValueErr: Label 'All lines with Document No. %1 must have the same %2.', Comment = '%1 = Document No., %2 = Field Caption';
        SameSalesAmountErr: Label 'All lines for %1 %2 must have the same %3, because it is the sales amount of the document. Line %4 has %5, but the first line has %6.', Comment = '%1 = Document Type, %2 = Document No., %3 = Field Caption, %4 = Line No., %5 = Line value, %6 = First line value';
        ZeroTotalErr: Label 'The total rebate amount for Document No. %1 must not be zero.', Comment = '%1 = Document No.';
    begin
        RebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
        RebateJournalLine.SetRange("Batch Name", BatchName);
        RebateJournalLine.SetRange("Rebate No.", '');
        if not RebateJournalLine.FindSet() then
            exit;
        FirstRebateJournalLine := RebateJournalLine;
        repeat
            if RebateJournalLine."Document No." <> FirstRebateJournalLine."Document No." then begin
                if DocumentTotal = 0 then
                    Error(ZeroTotalErr, FirstRebateJournalLine."Document No.");
                FirstRebateJournalLine := RebateJournalLine;
                DocumentTotal := 0;
            end;
            if RebateJournalLine."Posting Date" <> FirstRebateJournalLine."Posting Date" then
                Error(SameValueErr, RebateJournalLine."Document No.", RebateJournalLine.FieldCaption("Posting Date"));
            if RebateJournalLine."Rebate Pay-To Customer No." <> FirstRebateJournalLine."Rebate Pay-To Customer No." then
                Error(SameValueErr, RebateJournalLine."Document No.", RebateJournalLine.FieldCaption("Rebate Pay-To Customer No."));
            // Commission Type is held on the rebate header, so it must be the same for the whole document.
            if RebateJournalLine."Commission Type" <> FirstRebateJournalLine."Commission Type" then
                Error(SameValueErr, RebateJournalLine."Document No.", RebateJournalLine.FieldCaption("Commission Type"));

            // The sales amount is per sales document, so every line of the same document must carry the same value.
            SameDocumentLine.SetRange("Batch Name", BatchName);
            SameDocumentLine.SetRange("Rebate No.", '');
            SameDocumentLine.SetRange("Document Type", RebateJournalLine."Document Type");
            SameDocumentLine.SetRange("Document No.", RebateJournalLine."Document No.");
            SameDocumentLine.FindFirst();
            if RebateJournalLine.Amount <> SameDocumentLine.Amount then
                Error(SameSalesAmountErr, RebateJournalLine."Document Type", RebateJournalLine."Document No.",
                    RebateJournalLine.FieldCaption(Amount), RebateJournalLine."Line No.", RebateJournalLine.Amount, SameDocumentLine.Amount);
            if RebateJournalLine."Amount Including VAT" <> SameDocumentLine."Amount Including VAT" then
                Error(SameSalesAmountErr, RebateJournalLine."Document Type", RebateJournalLine."Document No.",
                    RebateJournalLine.FieldCaption("Amount Including VAT"), RebateJournalLine."Line No.", RebateJournalLine."Amount Including VAT", SameDocumentLine."Amount Including VAT");

            DocumentTotal += RebateJournalLine."Rebate Amount";
        until RebateJournalLine.Next() = 0;
        if DocumentTotal = 0 then
            Error(ZeroTotalErr, FirstRebateJournalLine."Document No.");
    end;

    local procedure PostDocument(RebateJournalBatch: Record "AQD Rebate Journal Batch"; var DocumentRebateJournalLine: Record "AQD Rebate Journal Line")
    var
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        RebateLineNo: Integer;
        DetailLineNo: Integer;
        NotPostedErr: Label 'Sales Rebate %1 created from journal Document No. %2 could not be posted.', Comment = '%1 = Rebate No., %2 = Journal Document No.';
    begin
        DocumentRebateJournalLine.FindFirst();
        InsertRebateHeader(CustomerRebateHeader, DocumentRebateJournalLine);

        // As in the rebate calculation: one rebate line per sales document, with each journal line as a detail under it.
        DocumentRebateJournalLine.FindSet();
        repeat
            CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
            CustomerRebateLine.SetRange("Document Type", DocumentRebateJournalLine."Document Type");
            CustomerRebateLine.SetRange("Document No.", DocumentRebateJournalLine."Document No.");
            // The sales amount belongs to the document and is the same on every line (checked in CheckDocuments),
            // so it is taken once, when the rebate line is created.
            if CustomerRebateLine.FindFirst() then
                RebateLineNo := CustomerRebateLine."Line No."
            else begin
                CustomerRebateLine.Reset();
                CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
                if CustomerRebateLine.FindLast() then
                    RebateLineNo := CustomerRebateLine."Line No." + 10000
                else
                    RebateLineNo := 10000;
                InsertRebateLine(CustomerRebateHeader, DocumentRebateJournalLine, RebateLineNo);
            end;
            CustomerRebateLine.Reset();

            CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateHeader."No.");
            CustomerRebateDetails.SetRange("Rebate Line No.", RebateLineNo);
            if CustomerRebateDetails.FindLast() then
                DetailLineNo := CustomerRebateDetails."Line No." + 10000
            else
                DetailLineNo := 10000;
            InsertRebateDetail(CustomerRebateHeader, DocumentRebateJournalLine, RebateLineNo, DetailLineNo);
        until DocumentRebateJournalLine.Next() = 0;

        DocumentRebateJournalLine.FindFirst();
        ConsumeDocumentNo(RebateJournalBatch, DocumentRebateJournalLine);

        // Journal lines are removed in the same transaction that posts the rebate document,
        // so they cannot be posted twice if the standard posting commits midway.
        DocumentRebateJournalLine.DeleteAll();

        CustomerRebatePost.PostCustomerRebate(CustomerRebateHeader, false);

        if not PostedCustRebateHeader.Get(CustomerRebateHeader."No.") then
            Error(NotPostedErr, CustomerRebateHeader."No.", DocumentRebateJournalLine."Document No.");

        if PostedRebateNos <> '' then
            PostedRebateNos += ', ';
        PostedRebateNos += PostedCustRebateHeader."No.";
    end;

    local procedure InsertRebateHeader(var CustomerRebateHeader: Record "AQD Customer Rebate Header"; RebateJournalLine: Record "AQD Rebate Journal Line")
    var
        RebateCustomer: Record Customer;
    begin
        RebateCustomer.Get(RebateJournalLine."Rebate Pay-To Customer No.");

        CustomerRebateHeader.Init();
        CustomerRebateHeader."No." := '';
        CustomerRebateHeader.Insert(true);

        CustomerRebateHeader."Rebate Pay-To Customer No." := RebateCustomer."No.";
        CustomerRebateHeader."Rebate-to Name" := RebateCustomer.Name;
        CustomerRebateHeader."Rebate-To Name 2" := RebateCustomer."Name 2";
        CustomerRebateHeader."Rebate-To Address" := RebateCustomer.Address;
        CustomerRebateHeader."Rebate-To Address 2" := RebateCustomer."Address 2";
        CustomerRebateHeader."Rebate-To City" := RebateCustomer.City;
        CustomerRebateHeader."Rebate-To Contact" := RebateCustomer.Contact;
        CustomerRebateHeader."Rebate-To Post Code" := RebateCustomer."Post Code";
        CustomerRebateHeader."Rebate-To County" := RebateCustomer.County;
        CustomerRebateHeader."Rebate-To Country/Region Code" := RebateCustomer."Country/Region Code";
        CustomerRebateHeader."Salesperson Code" := RebateJournalLine."Salesperson Code";
        CustomerRebateHeader."Responsibility Center" := RebateJournalLine."Responsibility Center";
        CustomerRebateHeader."Location Code" := RebateJournalLine."Location Code";
        CustomerRebateHeader."Territory Code" := RebateJournalLine."Territory Code";
        CustomerRebateHeader."Shortcut Dimension 1 Code" := RebateJournalLine."Shortcut Dimension 1 Code";
        CustomerRebateHeader."Shortcut Dimension 2 Code" := RebateJournalLine."Shortcut Dimension 2 Code";
        CustomerRebateHeader.State := RebateJournalLine.State;
        CustomerRebateHeader."External Document No." := RebateJournalLine."Document No.";
        CustomerRebateHeader."Posting Description" := StrSubstNo(ManualRebateDescTxt, RebateJournalLine."Document No.");
        CustomerRebateHeader."Posting Date" := RebateJournalLine."Posting Date";
        if RebateJournalLine."Document Date" <> 0D then
            CustomerRebateHeader."Document Date" := RebateJournalLine."Document Date"
        else
            CustomerRebateHeader."Document Date" := RebateJournalLine."Posting Date";
        CustomerRebateHeader."Created By" := CopyStr(UserId(), 1, MaxStrLen(CustomerRebateHeader."Created By"));
        CustomerRebateHeader."Created Date" := Today();
        CustomerRebateHeader."Manual Entry" := true;
        CustomerRebateHeader."Commission Type" := RebateJournalLine."Commission Type";
        OnBeforeModifyRebateHeader(CustomerRebateHeader, RebateJournalLine);
        CustomerRebateHeader.Modify();
    end;

    local procedure InsertRebateLine(CustomerRebateHeader: Record "AQD Customer Rebate Header"; RebateJournalLine: Record "AQD Rebate Journal Line"; RebateLineNo: Integer)
    var
        CustomerRebateLine: Record "AQD Customer Rebate Line";
    begin
        CustomerRebateLine.Init();
        CustomerRebateLine."Rebate No." := CustomerRebateHeader."No.";
        CustomerRebateLine."Line No." := RebateLineNo;
        CustomerRebateLine."Document Type" := RebateJournalLine."Document Type";
        CustomerRebateLine."Document No." := RebateJournalLine."Document No.";
        CustomerRebateLine."Order No." := RebateJournalLine."Order No.";
        CustomerRebateLine.Description := RebateJournalLine.Description;
        CustomerRebateLine."Rebate Order Date" := RebateJournalLine."Rebate Order Date";
        CustomerRebateLine."Posting Date" := RebateJournalLine."Posting Date";
        CustomerRebateLine."External Document No." := RebateJournalLine."External Document No.";
        CustomerRebateLine.Amount := RebateJournalLine.Amount;
        CustomerRebateLine."Amount Including VAT" := RebateJournalLine."Amount Including VAT";
        CustomerRebateLine."Salesperson Code" := RebateJournalLine."Salesperson Code";
        CustomerRebateLine."Responsibility Center" := RebateJournalLine."Responsibility Center";
        CustomerRebateLine."Location Code" := RebateJournalLine."Location Code";
        CustomerRebateLine."Territory Code" := RebateJournalLine."Territory Code";
        CustomerRebateLine."Shortcut Dimension 1 Code" := RebateJournalLine."Shortcut Dimension 1 Code";
        CustomerRebateLine."Shortcut Dimension 2 Code" := RebateJournalLine."Shortcut Dimension 2 Code";
        CustomerRebateLine."Currency Code" := RebateJournalLine."Currency Code";
        CustomerRebateLine."Sell-To Customer No." := RebateJournalLine."Sell-To Customer No.";
        CustomerRebateLine."Sell-To Customer Name" := RebateJournalLine."Sell-To Customer Name";
        CustomerRebateLine."Bill-To Customer No." := RebateJournalLine."Bill-To Customer No.";
        CustomerRebateLine."Bill-To Customer Name" := RebateJournalLine."Bill-To Customer Name";
        CustomerRebateLine."Rebate Pay-To Customer No." := RebateJournalLine."Rebate Pay-To Customer No.";
        CustomerRebateLine."Cust Rebate Program Code" := RebateJournalLine."Rebate Program Code";
        CustomerRebateLine."Marketplace Code" := RebateJournalLine."Marketplace Code";
        OnBeforeInsertRebateLine(CustomerRebateLine, RebateJournalLine);
        CustomerRebateLine.Insert();
    end;

    local procedure InsertRebateDetail(CustomerRebateHeader: Record "AQD Customer Rebate Header"; RebateJournalLine: Record "AQD Rebate Journal Line"; RebateLineNo: Integer; DetailLineNo: Integer)
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
    begin
        CustomerRebateDetails.Init();
        CustomerRebateDetails."Rebate No." := CustomerRebateHeader."No.";
        CustomerRebateDetails."Rebate Line No." := RebateLineNo;
        CustomerRebateDetails."Line No." := DetailLineNo;
        CustomerRebateDetails."Document Type" := RebateJournalLine."Document Type";
        CustomerRebateDetails."Document No." := RebateJournalLine."Document No.";
        CustomerRebateDetails."Document Line No." := RebateJournalLine."Document Line No.";
        CustomerRebateDetails."Entity Type" := RebateJournalLine."Entity Type";
        CustomerRebateDetails."Entity No." := RebateJournalLine."Entity No.";
        CustomerRebateDetails.Type := RebateJournalLine.Type;
        CustomerRebateDetails."No." := RebateJournalLine."No.";
        CustomerRebateDetails."Rebate Item Category Code" := RebateJournalLine."Rebate Item Category Code";
        CustomerRebateDetails."Rebate Program Code" := RebateJournalLine."Rebate Program Code";
        CustomerRebateDetails."Header Rebate Program Code" := RebateJournalLine."Rebate Program Code";
        CustomerRebateDetails."CustRbt Rate Type" := RebateJournalLine."CustRbt Rate Type";
        CustomerRebateDetails.Description := RebateJournalLine.Description;
        CustomerRebateDetails.Quantity := RebateJournalLine.Quantity;
        CustomerRebateDetails."Unit Cost" := RebateJournalLine."Unit Cost";
        CustomerRebateDetails."Unit Price" := RebateJournalLine."Unit Price";
        CustomerRebateDetails."Rebate Type" := RebateJournalLine."Rebate Type";
        CustomerRebateDetails."Rebate %" := RebateJournalLine."Rebate %";
        CustomerRebateDetails."Rebate Per Unit" := RebateJournalLine."Rebate Per Unit";
        CustomerRebateDetails."Rebate Order Date" := RebateJournalLine."Rebate Order Date";
        CustomerRebateDetails."Posting Date" := RebateJournalLine."Posting Date";
        CustomerRebateDetails.Amount := RebateJournalLine.Amount;
        CustomerRebateDetails."Amount Including VAT" := RebateJournalLine."Amount Including VAT";
        // Manual entry: the entered amount is both the calculated and the credited rebate amount.
        CustomerRebateDetails."Calculated Line Rebate Amount" := RebateJournalLine."Rebate Amount";
        CustomerRebateDetails."Customer Rebate Amount" := RebateJournalLine."Rebate Amount";
        CustomerRebateDetails."Rebate Amount Changed By" := CopyStr(UserId(), 1, MaxStrLen(CustomerRebateDetails."Rebate Amount Changed By"));
        CustomerRebateDetails."Rebate Amount Changed DateTime" := CurrentDateTime();
        CustomerRebateDetails."Salesperson Code" := RebateJournalLine."Salesperson Code";
        CustomerRebateDetails."Responsibility Center" := RebateJournalLine."Responsibility Center";
        CustomerRebateDetails."Location Code" := RebateJournalLine."Location Code";
        CustomerRebateDetails."Territory Code" := RebateJournalLine."Territory Code";
        CustomerRebateDetails."Shortcut Dimension 1 Code" := RebateJournalLine."Shortcut Dimension 1 Code";
        CustomerRebateDetails."Shortcut Dimension 2 Code" := RebateJournalLine."Shortcut Dimension 2 Code";
        CustomerRebateDetails."Order No." := RebateJournalLine."Order No.";
        CustomerRebateDetails."Order Line No." := RebateJournalLine."Order Line No.";
        CustomerRebateDetails.State := RebateJournalLine.State;
        CustomerRebateDetails."Sell-To Customer No." := RebateJournalLine."Sell-To Customer No.";
        CustomerRebateDetails."Bill-To Customer No." := RebateJournalLine."Bill-To Customer No.";
        CustomerRebateDetails."Rebate Pay-To Customer No." := RebateJournalLine."Rebate Pay-To Customer No.";
        CustomerRebateDetails."Applies-to Doc. Type" := RebateJournalLine."Applies-to Doc. Type";
        CustomerRebateDetails."Applies-to Doc. No." := RebateJournalLine."Applies-to Doc. No.";
        CustomerRebateDetails."Applies-to Doc. Line No." := RebateJournalLine."Applies-to Doc. Line No.";
        CustomerRebateDetails."AQD Cust Rebate Posting Type" := RebateJournalLine."Cust Rebate Posting Type";
        CustomerRebateDetails."Marketplace Code" := CopyStr(RebateJournalLine."Marketplace Code", 1, MaxStrLen(CustomerRebateDetails."Marketplace Code"));
        CustomerRebateDetails."Header Marketplace Code" := CustomerRebateDetails."Marketplace Code";
        CustomerRebateDetails."Customer Rebate Category" := RebateJournalLine."Customer Rebate Category";
        CustomerRebateDetails."Payment Terms Code" := RebateJournalLine."Payment Terms Code";
        CustomerRebateDetails."Line Type" := RebateJournalLine."Line Type";
        CustomerRebateDetails."Rebate Payment Method Code" := RebateJournalLine."Rebate Payment Method Code";
        OnBeforeInsertRebateDetail(CustomerRebateDetails, RebateJournalLine);
        CustomerRebateDetails.Insert();
    end;

    local procedure ConsumeDocumentNo(RebateJournalBatch: Record "AQD Rebate Journal Batch"; RebateJournalLine: Record "AQD Rebate Journal Line")
    var
        NoSeries: Codeunit "No. Series";
    begin
        if RebateJournalBatch."No. Series" = '' then
            exit;
        if RebateJournalLine."Document No." = NoSeries.PeekNextNo(RebateJournalBatch."No. Series", RebateJournalLine."Posting Date") then
            NoSeries.GetNextNo(RebateJournalBatch."No. Series", RebateJournalLine."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertJournalLineFromDetail(var RebateJournalLine: Record "AQD Rebate Journal Line"; CustomerRebateDetails: Record "AQD Customer Rebate Details")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyRebateHeader(var CustomerRebateHeader: Record "AQD Customer Rebate Header"; RebateJournalLine: Record "AQD Rebate Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateLine(var CustomerRebateLine: Record "AQD Customer Rebate Line"; RebateJournalLine: Record "AQD Rebate Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateDetail(var CustomerRebateDetails: Record "AQD Customer Rebate Details"; RebateJournalLine: Record "AQD Rebate Journal Line")
    begin
    end;
}
