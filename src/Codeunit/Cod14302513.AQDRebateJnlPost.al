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

        RebateJournalLine.SetRange("Batch Name", BatchName);
        if not RebateJournalLine.FindSet() then
            Error(NoLinesErr, BatchName);
        repeat
            CheckLine(RebateJournalLine);
        until RebateJournalLine.Next() = 0;
        CheckDocuments(BatchName);

        PostedRebateNos := '';
        RebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
        while RebateJournalLine.FindFirst() do begin
            DocumentRebateJournalLine.Reset();
            DocumentRebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
            DocumentRebateJournalLine.SetRange("Batch Name", BatchName);
            DocumentRebateJournalLine.SetRange("Document No.", RebateJournalLine."Document No.");
            PostDocument(RebateJournalBatch, DocumentRebateJournalLine);
        end;
    end;

    procedure GetPostedRebateNos(): Text
    begin
        exit(PostedRebateNos);
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
        DocumentTotal: Decimal;
        SameValueErr: Label 'All lines with Document No. %1 must have the same %2.', Comment = '%1 = Document No., %2 = Field Caption';
        ZeroTotalErr: Label 'The total rebate amount for Document No. %1 must not be zero.', Comment = '%1 = Document No.';
    begin
        RebateJournalLine.SetCurrentKey("Batch Name", "Document No.", "Posting Date");
        RebateJournalLine.SetRange("Batch Name", BatchName);
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
            DocumentTotal += RebateJournalLine."Rebate Amount";
        until RebateJournalLine.Next() = 0;
        if DocumentTotal = 0 then
            Error(ZeroTotalErr, FirstRebateJournalLine."Document No.");
    end;

    local procedure PostDocument(RebateJournalBatch: Record "AQD Rebate Journal Batch"; var DocumentRebateJournalLine: Record "AQD Rebate Journal Line")
    var
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        RebateLineNo: Integer;
        NotPostedErr: Label 'Sales Rebate %1 created from journal Document No. %2 could not be posted.', Comment = '%1 = Rebate No., %2 = Journal Document No.';
    begin
        DocumentRebateJournalLine.FindFirst();
        InsertRebateHeader(CustomerRebateHeader, DocumentRebateJournalLine);

        RebateLineNo := 0;
        DocumentRebateJournalLine.FindSet();
        repeat
            RebateLineNo += 10000;
            InsertRebateLine(CustomerRebateHeader, DocumentRebateJournalLine, RebateLineNo);
            InsertRebateDetail(CustomerRebateHeader, DocumentRebateJournalLine, RebateLineNo);
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

    local procedure InsertRebateDetail(CustomerRebateHeader: Record "AQD Customer Rebate Header"; RebateJournalLine: Record "AQD Rebate Journal Line"; RebateLineNo: Integer)
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
    begin
        CustomerRebateDetails.Init();
        CustomerRebateDetails."Rebate No." := CustomerRebateHeader."No.";
        CustomerRebateDetails."Rebate Line No." := RebateLineNo;
        CustomerRebateDetails."Line No." := 10000;
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
