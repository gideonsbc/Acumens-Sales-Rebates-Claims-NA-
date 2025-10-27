codeunit 14277043 "AQD Vendor Rebate Calc. Mgt"
{
    Permissions = TableData "Cust. Ledger Entry" = rm,
                  TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm;

    trigger OnRun()
    begin
    end;

    var
        RebateUserSetup: Record "AQD Rebate User Setup";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        VendorRebateHeader: Record "AQD Vendor Rebate Header";
        TempVendorRebateHeader: Record "AQD Vendor Rebate Header";
        VendorRebateLine: Record "AQD Vendor Rebate Line";
        VendorRebateDetails: Record "AQD Vendor Rebate Details";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        CustLdgrEntry: Record "Cust. Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
        SalesPerson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        CreatedVendorRebate: Record "AQD Created Vendor Rebate";
        NoSeriesMgt: Codeunit "No. Series";
        SourceDocumentType: Option Invoice,"Credit Memo";
        DocumentType: Option " ",Invoice,"Credit Memo";
        RebatePeriodText: Label 'Rebate Period: %1..%2';
        PostingDescrptionText: Text;
        GlobalBatchID: Code[50];
        GlobalBatchEntryNo: Integer;
        GlobalBatchStartDate: Date;
        GlobalBatchEndDate: Date;
        GlobalRebateBatchFrequency: Enum "AQD Rebate Batch Frequency";

    procedure CalculateRebate(var VendorIn: Record Vendor; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        UpdateVendorRebateTypeRpt: Report "AQD Udt Rebate Vendor Type";
        LocalVendor: Record Vendor;
    begin
        RebateSetup.Get;
        RebateSetup.TestField("Vendor Rebate Nos");

        if not VendorIn."AQD Enroll for Rebate" then
            exit;

        IF RebateSetup."Auto Update Rebate Vendor Type" THEN BEGIN
            Commit();  // There is nothing to Commit
            LocalVendor.GET(VendorIn."No.");
            LocalVendor.SetRecFilter();

            CLEAR(UpdateVendorRebateTypeRpt);
            UpdateVendorRebateTypeRpt.SetTableView(LocalVendor);
            UpdateVendorRebateTypeRpt.SetDoNotShowDialog(TRUE);
            UpdateVendorRebateTypeRpt.UseRequestPage(FALSE);
            UpdateVendorRebateTypeRpt.Run();
            COMMIT;
        END;

        CreatedVendorRebate.RESET;
        CreatedVendorRebate.DeleteAll();

        SourceCodeSetup.Get();

        Clear(PostingDescrptionText);
        PostingDescrptionText := StrSubstNo(RebatePeriodText, DateArray[1], DateArray[2]);

        Case RebateSetup."Calculate Vendor Rebate using" of
            RebateSetup."Calculate Vendor Rebate using"::"Posted Invoice and Cr Memo":
                BEGIN
                    // Calculate Rebate for Posted Purchase Invoices
                    BuildInvoiceRebate(VendorIn, DateArray, SummaryArray);

                    // Calculate Rebate for Posted Purchase Credit memos
                    if not RebateSetup."Prevent Negative Vendor Rebate" then
                        BuildCrMemoRebate(VendorIn, DateArray, SummaryArray);
                END;
            RebateSetup."Calculate Vendor Rebate using"::"Posted Receipt and Return Shipment":
                BEGIN
                    // Calculate Rebate for Posted Purchase Receipt,Invoice,Cr Memo, Return Shipment from ILE
                    BuildReceiptReturnShipmentRebate(VendorIn, DateArray, SummaryArray);
                END;
        End;
    end;

    local procedure BuildInvoiceRebate(var VendorIn: Record Vendor; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        SkipRecord: Boolean;
        StartDate: Date;
        DummyPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        Clear(StartDate);
        if DateArray[1] <> 0D then
            StartDate := DateArray[1];
        IF (StartDate = 0D) or (StartDate < RebateSetup."Vendor Rebate Start Date") then
            StartDate := RebateSetup."Vendor Rebate Start Date";

        PurchaseInvHeader.Reset;
        //PurchaseInvHeader.SetCurrentKey("Pay-to Vendor No.", "AQD Rebate Customer No", "Posting Date");
        PurchaseInvHeader.SetCurrentKey("Pay-to Vendor No.", "Posting Date");
        PurchaseInvHeader.SetRange("Pay-to Vendor No.", VendorIn."No.");
        PurchaseInvHeader.SetRange("AQD Do Not Pay Rebate", false);
        PurchaseInvHeader.SetRange("AQD Rebate Status", PurchaseInvHeader."AQD Rebate Status"::" ");
        PurchaseInvHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then begin
            CASE VendorIn."AQD Calculation Date" OF
                VendorIn."AQD Calculation Date"::" ",
                VendorIn."AQD Calculation Date"::"Receipt Date":
                    PurchaseInvHeader.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
                VendorIn."AQD Calculation Date"::"Rebate Order Date":
                    PurchaseInvHeader.SetFilter("AQD Rebate Order Date", '%1..%2', StartDate, DateArray[2])
            END;
        end;
        if PurchaseInvHeader.FindSet() then
            repeat
                SkipRecord := false;
                if IsPayRebateOnlyOnPaidInvoices() then begin
                    PurchaseInvHeader.CalcFields(Closed);
                    if not PurchaseInvHeader.Closed then
                        SkipRecord := true;
                end;

                PurchaseInvHeader.CalcFields(Cancelled);
                IF PurchaseInvHeader.Cancelled then
                    SkipRecord := true;

                if not IsRebatableLineExist(SourceDocumentType::Invoice, PurchaseInvHeader, DummyPurchCrMemoHeader, VendorIn) then
                    SkipRecord := true;

                VendorRebateLine.Reset;
                VendorRebateLine.SetRange("Document Type", VendorRebateLine."Document Type"::Invoice);
                VendorRebateLine.SetRange("Document No.", PurchaseInvHeader."No.");
                VendorRebateLine.SetFilter("Rebate No.", '<>%1', '');
                if VendorRebateLine.FindFirst then
                    SkipRecord := true;

                PurchaseInvLine.Reset;
                PurchaseInvLine.SetRange("Document No.", PurchaseInvHeader."No.");
                PurchaseInvLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
                  PurchaseInvLine.Type::Item,
                  PurchaseInvLine.Type::Resource,
                  PurchaseInvLine.Type::"G/L Account",
                  PurchaseInvLine.Type::"Fixed Asset",
                  PurchaseInvLine.Type::"Charge (Item)");
                PurchaseInvLine.SetFilter("No.", '<>%1', '');
                PurchaseInvLine.SetFilter(Quantity, '<>0');
                OnAfterApplyInvoiceLineFilter(PurchaseInvHeader, PurchaseInvLine);
                if PurchaseInvLine.IsEmpty then
                    SkipRecord := true;

                if not SkipRecord then
                    BuildInvoiceRebateDetail(PurchaseInvHeader, VendorIn, SummaryArray);
            until PurchaseInvHeader.Next = 0;
    end;

    local procedure BuildInvoiceRebateDetail(var PurchInvHeaderIn: Record "Purch. Inv. Header"; VendorIn: Record Vendor; SummaryArray: array[5] of Boolean)
    var
        CustomerTypeError: Label 'Customer Type must be either %1 or %2.';
        Counte: Integer;
        IsHandled: Boolean;
        RebateNo: Code[20];
        RebateLineNo: Integer;
    begin
        Clear(RebateNo);
        RebateLineNo := 10000;

        IsHandled := false;
        OnBeforeStartCalculatingInvoiceRebate(PurchInvHeaderIn, VendorIn, Customer, IsHandled);
        if IsHandled then
            exit;

        if IsRebatableLineExist(SourceDocumentType::Invoice, PurchInvHeaderIn, PurchCrMemoHeader, VendorIn) then begin
            //Document
            InsertRebateHeader(DocumentType::Invoice, PurchInvHeaderIn, PurchCrMemoHeader, VendorIn, Customer, RebateNo, SummaryArray);
            //Line
            InsertRebateLine(DocumentType::Invoice, PurchInvHeaderIn, PurchCrMemoHeader, RebateNo, RebateLineNo);

            PurchaseInvLine.Reset;
            PurchaseInvLine.SetRange("Document No.", PurchInvHeaderIn."No.");
            PurchaseInvLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
              PurchaseInvLine.Type::Item,
              PurchaseInvLine.Type::"Resource",
              PurchaseInvLine.Type::"G/L Account",
              PurchaseInvLine.Type::"Fixed Asset",
              PurchaseInvLine.Type::"Charge (Item)");
            PurchaseInvLine.SetFilter("No.", '<>%1', '');
            PurchaseInvLine.SetFilter(Quantity, '<>0');
            OnAfterApplyInvoiceLineFilter(PurchInvHeaderIn, PurchaseInvLine);
            if PurchaseInvLine.FindFirst then begin
                repeat
                    if IsLineRebatable(
                      VendorIn."No.",
                      PurchaseInvLine.Type,
                      PurchaseInvLine."No.",
                      PurchInvHeaderIn."Posting Date")
                    then
                        InsertRebateDetail(DocumentType::Invoice, PurchInvHeaderIn, PurchaseInvLine, PurchCrMemoHeader, PurchCrMemoLine, VendorIn, Customer, RebateNo, RebateLineNo);
                until PurchaseInvLine.Next = 0;
            end;
        end;
    end;

    local procedure BuildReceiptReturnShipmentRebate(var VendorIn: Record Vendor; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        SkipRecord: Boolean;
        StartDate: Date;
        DummyReturnShptHeader: Record "Return Shipment Header";
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        Clear(StartDate);
        if DateArray[1] <> 0D then
            StartDate := DateArray[1];
        IF (StartDate = 0D) or (StartDate < RebateSetup."Vendor Rebate Start Date") then
            StartDate := RebateSetup."Vendor Rebate Start Date";

        RebateItemLdgrEntry.Reset;
        RebateItemLdgrEntry.SetCurrentKey("AQD Pay-to Vendor No.", "Posting Date", "Document Type", "Document No.", "Document Line No.", "Location Code");
        RebateItemLdgrEntry.SetRange("AQD Pay-to Vendor No.", VendorIn."No.");
        // IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then
        //     RebateItemLdgrEntry.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);

        IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then begin
            CASE VendorIn."AQD Calculation Date" OF
                VendorIn."AQD Calculation Date"::" ",
                VendorIn."AQD Calculation Date"::"Receipt Date":
                    RebateItemLdgrEntry.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
                VendorIn."AQD Calculation Date"::"Rebate Order Date":
                    RebateItemLdgrEntry.SetFilter("AQD Rebate Order Date", '%1..%2', StartDate, DateArray[2])
            END;
        end;

        RebateItemLdgrEntry.SetRange("AQD Do Not Pay Rebate", false);
        RebateItemLdgrEntry.SetRange("AQD Rebate Status", RebateItemLdgrEntry."AQD Rebate Status"::" ");
        IF NOT RebateSetup."Prevent Negative Vendor Rebate" THEN
            RebateItemLdgrEntry.SetFilter("Document Type", '%1|%2|%3|%4',
               RebateItemLdgrEntry."Document Type"::"Purchase Receipt",
               RebateItemLdgrEntry."Document Type"::"Purchase Invoice",
               RebateItemLdgrEntry."Document Type"::"Purchase Return Shipment",
               RebateItemLdgrEntry."Document Type"::"Purchase Credit Memo")
        else
            RebateItemLdgrEntry.SetFilter("Document Type", '%1|%2',
               RebateItemLdgrEntry."Document Type"::"Purchase Receipt",
               RebateItemLdgrEntry."Document Type"::"Purchase Invoice");
        if RebateItemLdgrEntry.FindFirst() then
            repeat
                if IsLineRebatable(VendorIn."No.",
                                   PurchaseInvLine.Type::Item,
                                   RebateItemLdgrEntry."Item No.",
                                   RebateItemLdgrEntry."Posting Date")
                then
                    BuildReceiptReturnShipmentRebateDetail(RebateItemLdgrEntry, VendorIn, SummaryArray);
            until RebateItemLdgrEntry.Next = 0;
    end;

    local procedure BuildReceiptReturnShipmentRebateDetail(var RebateItemLdgrEntryIn: Record "AQD Rebate Item Ledger Entry"; VendorIn: Record Vendor; SummaryArray: array[5] of Boolean)
    var
        CustomerTypeError: Label 'Customer Type must be either %1 or %2.';
        Counte: Integer;
        IsHandled: Boolean;
        RebateAmount: Decimal;
        RebateType: Option " ","Per Quantity",Percentage;
        RebateNo: Code[20];
        RebateLineNo: Integer;
        RebatePercent: Decimal;
        RebatePerQuantity: Decimal;
    begin
        Clear(RebateNo);
        RebateLineNo := 0;
        RebateAmount := 0;
        RebateType := RebateType::" ";
        RebatePercent := 0;
        RebatePerQuantity := 0;

        IsHandled := false;
        OnBeforeStartCalcReceiptReturnShipmentRebate(RebateItemLdgrEntryIn, VendorIn, IsHandled);
        if IsHandled then
            exit;

        //Document
        InsertRebateReceiptReturnShipmentDocumentEntry(RebateItemLdgrEntryIn, VendorIn, SummaryArray);
        //Line
        InsertRebateReceiptShipmentLineEntry(RebateItemLdgrEntryIn, RebateLineNo);
        //Detail
        InsertRebateReceiptShipmentEntry(RebateItemLdgrEntryIn, RebateLineNo);
    end;

    local procedure InsertRebateReceiptReturnShipmentDocumentEntry(var RebateItemLdgrEntryIn: Record "AQD Rebate Item Ledger Entry"; VendorIn: Record Vendor; SummaryArray: array[5] of Boolean)
    var
        BuyFromVendorRec: Record Vendor;
        PayToVendorRec: Record Vendor;
        RebateVendorRec: Record Vendor;
        VendorRebateBatch: Record "AQD Vendor Rebate Batch";
        PayToVendorCode: Code[20];
    begin
        Clear(VendorRebateHeader);

        BuyFromVendorRec.GET(RebateItemLdgrEntryIn."AQD Buy-from Vendor No.");
        PayToVendorRec.GET(RebateItemLdgrEntryIn."AQD Pay-To Vendor No.");
        IF PayToVendorRec."AQD Rebate Vendor No" <> '' THEN
            RebateVendorRec.GET(PayToVendorRec."AQD Rebate Vendor No")
        ELSE
            RebateVendorRec.GET(RebateItemLdgrEntryIn."AQD Pay-To Vendor No.");

        IF RebateSetup."AQD Rebate Batch Frequency" <> RebateSetup."AQD Rebate Batch Frequency"::" " then begin
            CASE VendorIn."AQD Calculation Date" OF
                VendorIn."AQD Calculation Date"::" ",
                VendorIn."AQD Calculation Date"::"Receipt Date":
                    GlobalBatchID := GetBatchID(RebateItemLdgrEntryIn."Posting Date");
                VendorIn."AQD Calculation Date"::"Rebate Order Date":
                    GlobalBatchID := GetBatchID(RebateItemLdgrEntryIn."AQD Rebate Order Date");
            END;
        END;

        CreatedVendorRebate.Reset();
        CreatedVendorRebate.SetRange("Pay-to Vendor No.", RebateVendorRec."No.");
        if SummaryArray[1] then
            CreatedVendorRebate.SetRange("Buy-from Vendor No.", BuyFromVendorRec."No.")
        ELSE
            CreatedVendorRebate.SetRange("Buy-from Vendor No.", PayToVendorRec."No.");
        if SummaryArray[2] then
            CreatedVendorRebate.SetRange("Responsibility Center", RebateItemLdgrEntryIn."Responsibility Center");
        if SummaryArray[3] then
            CreatedVendorRebate.SetRange("Location Code", RebateItemLdgrEntryIn."Location Code");
        if SummaryArray[4] then
            CreatedVendorRebate.SetRange("Shortcut Dimension 1 Code", RebateItemLdgrEntryIn."Global Dimension 1 Code");
        if SummaryArray[5] then
            CreatedVendorRebate.SetRange("Shortcut Dimension 2 Code", RebateItemLdgrEntryIn."Global Dimension 2 Code");
        IF GlobalBatchID <> '' then
            CreatedVendorRebate.SetRange(GlobalBatchID, GlobalBatchID);
        if not CreatedVendorRebate.FindFirst() then begin
            IF GlobalBatchID <> '' THEN BEGIN
                VendorRebateBatch.RESET;
                VendorRebateBatch.SetRange(BatchID, GlobalBatchID);
                IF NOT VendorRebateBatch.FindFirst() THEN BEGIN
                    VendorRebateBatch.INIT;
                    VendorRebateBatch.BatchID := GlobalBatchID;
                    VendorRebateBatch."Posting Date" := TODAY;
                    VendorRebateBatch."Created By" := UserId;
                    VendorRebateBatch."Created Date" := Today;
                    VendorRebateBatch."Start Date" := GlobalBatchStartDate;
                    VendorRebateBatch."End Date" := GlobalBatchEndDate;
                    VendorRebateBatch."AQD Rebate Batch Frequency" := GlobalRebateBatchFrequency;
                    VendorRebateBatch.INSERT();
                    GlobalBatchEntryNo := VendorRebateBatch."Entry No.";
                END ELSE
                    GlobalBatchEntryNo := VendorRebateBatch."Entry No.";
            END;

            VendorRebateHeader.Init;
            VendorRebateHeader."No." := NoSeriesMgt.GetNextNo(RebateSetup."Vendor Rebate Nos", Today, true);
            IF SummaryArray[1] then BEGIN
                VendorRebateHeader."Buy-from Vendor No." := BuyFromVendorRec."No.";
                VendorRebateHeader."Buy-from Vendor Name" := BuyFromVendorRec.Name;
                VendorRebateHeader."Buy-from Vendor Name 2" := BuyFromVendorRec."Name 2";
                VendorRebateHeader."Buy-from Address" := BuyFromVendorRec.Address;
                VendorRebateHeader."Buy-from Address 2" := BuyFromVendorRec."Address 2";
                VendorRebateHeader."Buy-from City" := BuyFromVendorRec.City;
                VendorRebateHeader."Buy-from Contact" := BuyFromVendorRec.Contact;
                VendorRebateHeader."Buy-from Post Code" := BuyFromVendorRec."Post Code";
                VendorRebateHeader."Buy-from County" := BuyFromVendorRec.County;
                VendorRebateHeader."Buy-from Country/Region Code" := BuyFromVendorRec."Country/Region Code";
            END ELSE begin
                VendorRebateHeader."Buy-from Vendor No." := PayToVendorRec."No.";
                VendorRebateHeader."Buy-from Vendor Name" := PayToVendorRec.Name;
                VendorRebateHeader."Buy-from Vendor Name 2" := PayToVendorRec."Name 2";
                VendorRebateHeader."Buy-from Address" := PayToVendorRec.Address;
                VendorRebateHeader."Buy-from Address 2" := PayToVendorRec."Address 2";
                VendorRebateHeader."Buy-from City" := PayToVendorRec.City;
                VendorRebateHeader."Buy-from Contact" := PayToVendorRec.Contact;
                VendorRebateHeader."Buy-from Post Code" := PayToVendorRec."Post Code";
                VendorRebateHeader."Buy-from County" := PayToVendorRec.County;
                VendorRebateHeader."Buy-from Country/Region Code" := PayToVendorRec."Country/Region Code";
            end;
            VendorRebateHeader."Pay-to Vendor No." := RebateVendorRec."No.";
            VendorRebateHeader."Pay-to Name" := RebateVendorRec.Name;
            VendorRebateHeader."Pay-to Name 2" := RebateVendorRec."Name 2";
            VendorRebateHeader."Pay-to Address" := RebateVendorRec.Address;
            VendorRebateHeader."Pay-to Address 2" := RebateVendorRec."Address 2";
            VendorRebateHeader."Pay-to City" := RebateVendorRec.City;
            VendorRebateHeader."Pay-to Contact" := RebateVendorRec.Contact;
            VendorRebateHeader."Pay-to Post Code" := RebateVendorRec."Post Code";
            VendorRebateHeader."Pay-to County" := RebateVendorRec.County;
            VendorRebateHeader."Pay-to Country/Region Code" := RebateVendorRec."Country/Region Code";
            VendorRebateHeader."External Document No." := RebateItemLdgrEntryIn."External Document No.";
            if SummaryArray[2] then
                VendorRebateHeader."Responsibility Center" := RebateItemLdgrEntryIn."Responsibility Center";
            if SummaryArray[3] then
                VendorRebateHeader."Location Code" := RebateItemLdgrEntryIn."Location Code";
            if SummaryArray[4] then
                VendorRebateHeader."Shortcut Dimension 1 Code" := RebateItemLdgrEntryIn."Global Dimension 1 Code";
            if SummaryArray[5] then
                VendorRebateHeader."Shortcut Dimension 2 Code" := RebateItemLdgrEntryIn."Global Dimension 2 Code";
            VendorRebateHeader."Purchaser Code" := RebateItemLdgrEntryIn."AQD Purchaser Code";
            VendorRebateHeader.State := RebateItemLdgrEntryIn."AQD Ship-to County";
            VendorRebateHeader."Posting Description" := PostingDescrptionText;
            VendorRebateHeader."Posting Date" := Today;
            VendorRebateHeader."Document Date" := Today;
            VendorRebateHeader."Created By" := UserId;
            VendorRebateHeader."Created Date" := Today;
            VendorRebateHeader.BatchID := GlobalBatchID;
            VendorRebateHeader."Batch Entry No." := GlobalBatchEntryNo;
            VendorRebateHeader."AQD Calculation Date" := VendorIn."AQD Calculation Date";
            VendorRebateHeader.Insert;

            CreatedVendorRebate.Init();
            CreatedVendorRebate."Rebate No." := VendorRebateHeader."No.";
            CreatedVendorRebate."Pay-to Vendor No." := VendorRebateHeader."Pay-to Vendor No.";
            CreatedVendorRebate."Buy-from Vendor No." := VendorRebateHeader."Buy-from Vendor No.";
            CreatedVendorRebate."Responsibility Center" := VendorRebateHeader."Responsibility Center";
            CreatedVendorRebate."Location Code" := VendorRebateHeader."Location Code";
            CreatedVendorRebate."Shortcut Dimension 1 Code" := VendorRebateHeader."Shortcut Dimension 1 Code";
            CreatedVendorRebate."Shortcut Dimension 2 Code" := VendorRebateHeader."Shortcut Dimension 2 Code";
            CreatedVendorRebate.GlobalBatchID := GlobalBatchID;
            CreatedVendorRebate.Insert();
        end;
    end;

    local procedure InsertRebateReceiptShipmentLineEntry(var RebateItemLdgrEntryIn: Record "AQD Rebate Item Ledger Entry"; var RebateLineNoIn: Integer)
    var
        VendorRebateLineLoc: Record "AQD Vendor Rebate Line";
        RebateLineNo: Integer;
    begin
        Clear(VendorRebateLineLoc);

        VendorRebateLineLoc.Reset();
        VendorRebateLineLoc.SetRange("Rebate No.", CreatedVendorRebate."Rebate No.");
        VendorRebateLineLoc.SetRange("Original Document Type", RebateItemLdgrEntryIn."Document Type");
        VendorRebateLineLoc.SetRange("Document No.", RebateItemLdgrEntryIn."Document No.");
        if VendorRebateLineLoc.FindLast() THEN BEGIN
            RebateItemLdgrEntryIn.CalcFields("Cost Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
            CASE RebateItemLdgrEntryIn."Document Type" OF
                RebateItemLdgrEntryIn."Document Type"::"Purchase Receipt",
                RebateItemLdgrEntryIn."Document Type"::"Purchase Invoice":
                    BEGIN
                        VendorRebateLineLoc.Amount += RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                                      RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                                      RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
                        VendorRebateLineLoc."Amount Including VAT" += RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                                                      RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                                                      RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
                    END;
                RebateItemLdgrEntryIn."Document Type"::"Purchase Return Shipment",
                RebateItemLdgrEntryIn."Document Type"::"Purchase Credit Memo":
                    BEGIN
                        VendorRebateLineLoc.Amount += RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                                      RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                                      RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
                        VendorRebateLineLoc."Amount Including VAT" += RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                                                      RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                                                      RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
                    END;
            END;
            RebateLineNoIn := VendorRebateLineLoc."Line No.";
            EXIT;
        END;

        VendorRebateLineLoc.SetRange("Original Document Type");
        VendorRebateLineLoc.SetRange("Document No.");
        if VendorRebateLineLoc.FindLast() then
            RebateLineNo := VendorRebateLineLoc."Line No." + 10000
        else
            RebateLineNo := 10000;

        RebateItemLdgrEntryIn.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl.)");

        VendorRebateLine.Init;
        VendorRebateLine."Rebate No." := CreatedVendorRebate."Rebate No.";
        VendorRebateLine."Line No." := RebateLineNo;
        CASE RebateItemLdgrEntryIn."Document Type" OF
            RebateItemLdgrEntryIn."Document Type"::"Purchase Receipt":
                VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::Receipt;
            RebateItemLdgrEntryIn."Document Type"::"Purchase Invoice":
                VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::Invoice;
            RebateItemLdgrEntryIn."Document Type"::"Purchase Return Shipment":
                VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::"Return Shipment";
            RebateItemLdgrEntryIn."Document Type"::"Purchase Credit Memo":
                VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::"Credit Memo";
        END;

        VendorRebateLine."Document No." := RebateItemLdgrEntryIn."Document No.";
        VendorRebateLine."Order No." := RebateItemLdgrEntryIn."Order No.";
        IF VendorRebateLine."Order No." = '' THEN
            VendorRebateLine."Order No." := GetOrderNoFromRebateItemLedgerEntry(RebateItemLdgrEntryIn);
        VendorRebateLine.Description := RebateItemLdgrEntryIn."Document Posting Description";
        VendorRebateLine."Order Date" := RebateItemLdgrEntryIn."Order Date";
        VendorRebateLine."Rebate Order Date" := RebateItemLdgrEntryIn."AQD Rebate Order Date";
        VendorRebateLine."Posting Date" := RebateItemLdgrEntryIn."Posting Date";
        VendorRebateLine."Vendor Order No." := RebateItemLdgrEntryIn."Vendor Order No.";
        VendorRebateLine."Vendor Cr. Memo No." := RebateItemLdgrEntryIn."Vendor Cr. Memo No.";
        VendorRebateLine."Vendor Invoice No." := RebateItemLdgrEntryIn."Vendor Invoice No.";
        VendorRebateLine.Amount := RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                   RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                   RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
        VendorRebateLine."Amount Including VAT" := RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                                                   RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                                                   RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";
        VendorRebateLine."Purchaser Code" := RebateItemLdgrEntryIn."AQD Purchaser Code";
        VendorRebateLine."Responsibility Center" := RebateItemLdgrEntryIn."Responsibility Center";
        VendorRebateLine."Location Code" := RebateItemLdgrEntryIn."Location Code";
        VendorRebateLine."Shortcut Dimension 1 Code" := RebateItemLdgrEntryIn."Global Dimension 1 Code";
        VendorRebateLine."Shortcut Dimension 2 Code" := RebateItemLdgrEntryIn."Global Dimension 2 Code";
        VendorRebateLine."Buy-from Vendor No." := RebateItemLdgrEntryIn."AQD Buy-from Vendor No.";
        VendorRebateLine."Pay-to Vendor No." := RebateItemLdgrEntryIn."AQD Pay-to Vendor No.";
        VendorRebateLine."Original Document Type" := RebateItemLdgrEntryIn."Document Type";
        VendorRebateLine.Exclude := false;
        VendorRebateLine.BatchID := GlobalBatchID;
        VendorRebateLine."Batch Entry No." := GlobalBatchEntryNo;
        VendorRebateLine.Insert;
        RebateLineNoIn := VendorRebateLine."Line No.";
    end;

    local procedure InsertRebateReceiptShipmentEntry(var RebateItemLdgrEntryIn: Record "AQD Rebate Item Ledger Entry"; var RebateLineNoIn: Integer)
    var
        Resource: Record Resource;
        ItemCard: Record Item;
        PayToVendorRec: Record Vendor;
        DocumentNo: Code[20];
        LineNo: Integer;
        IsHandled: Boolean;
        VendorRebateDetailsLoc: Record "AQD Vendor Rebate Details";
        TempRebateCategoryLines: Record "AQD Rebate Category Lines" temporary;
        RebateCategoryLines: Record "AQD Rebate Category Lines";
        RebateProgramCodeRec: Record "AQD Rebate Program Code";
        RebateILECostAmount: Decimal;
    begin
        Clear(VendorRebateDetails);
        LineNo := 1;

        IsHandled := false;
        OnBeforeInitRebateEntryFromRebateItemLdgrEntry(RebateItemLdgrEntryIn, IsHandled);
        if IsHandled then
            exit;

        PayToVendorRec.GET(RebateItemLdgrEntryIn."AQD Pay-To Vendor No.");

        RebateItemLdgrEntryIn.CalcFields("Cost Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
        RebateILECostAmount := RebateItemLdgrEntryIn."Cost Amount (Actual)" +
                               RebateItemLdgrEntryIn."Cost Amount (Expected)" +
                               RebateItemLdgrEntryIn."Cost Amount (Non-Invtbl.)";

        //Get Item Rebate Category Lines.
        ItemCard.get(RebateItemLdgrEntryIn."Item No.");

        TempRebateCategoryLines.Init();
        TempRebateCategoryLines."Rebate Category Code" := ItemCard."AQD Rebate Category Code";

        RebateCategoryLines.RESET;
        RebateCategoryLines.SetRange("Rebate Category Code", ItemCard."AQD Rebate Category Code");
        IF RebateCategoryLines.FindFirst() THEN begin
            repeat
                TempRebateCategoryLines."Line No." := RebateCategoryLines."Line No.";
                TempRebateCategoryLines."Rebate Program Code" := RebateCategoryLines."Rebate Program Code";

                TempRebateCategoryLines."AQD Use Rebate Setup From" := ItemCard."AQD Use Rebate Setup From";
                TempRebateCategoryLines."AQD Rebate Posting Type" := ItemCard."AQD Rebate Posting Type";
                IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN begin
                    IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                        TempRebateCategoryLines."AQD Rebate Posting Type" := RebateProgramCodeRec."Rebate Posting Type";
                    end;
                end;
                IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN
                    TempRebateCategoryLines."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type"::"G/L Account";

                TempRebateCategoryLines.Insert();
            until RebateCategoryLines.Next() = 0;
        end ELSE BEGIN
            TempRebateCategoryLines."Line No." := 10000;
            TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";

            TempRebateCategoryLines."AQD Use Rebate Setup From" := ItemCard."AQD Use Rebate Setup From";
            TempRebateCategoryLines."AQD Rebate Posting Type" := ItemCard."AQD Rebate Posting Type";
            IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN begin
                IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                    TempRebateCategoryLines."AQD Rebate Posting Type" := RebateProgramCodeRec."Rebate Posting Type";
                end;
            end;
            IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN
                TempRebateCategoryLines."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type"::"G/L Account";

            TempRebateCategoryLines.INSERT;
        END;

        TempRebateCategoryLines.RESET;
        IF TempRebateCategoryLines.FindFirst() THEN BEGIN
            Repeat
                VendorRebateDetailsLoc.Reset();
                VendorRebateDetailsLoc.SetRange("Rebate No.", CreatedVendorRebate."Rebate No.");
                VendorRebateDetailsLoc.SetRange("Rebate Line No.", RebateLineNoIn);
                VendorRebateDetailsLoc.SetRange("Original Document Type", RebateItemLdgrEntryIn."Document Type");
                VendorRebateDetailsLoc.SetRange("Document No.", RebateItemLdgrEntryIn."Document No.");
                VendorRebateDetailsLoc.SetRange("Document Line No.", RebateItemLdgrEntryIn."Document Line No.");
                VendorRebateDetailsLoc.SetRange("Rebate Item Category Code", TempRebateCategoryLines."Rebate Category Code");
                VendorRebateDetailsLoc.SetRange("Rebate Program Code", TempRebateCategoryLines."Rebate Program Code");
                if VendorRebateDetailsLoc.FindLast() then begin
                    CASE RebateItemLdgrEntryIn."Document Type" OF
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Receipt",
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Invoice":
                            BEGIN
                                VendorRebateDetailsLoc.Quantity += RebateItemLdgrEntryIn.Quantity;
                                VendorRebateDetailsLoc.Amount += RebateILECostAmount;
                                VendorRebateDetailsLoc."Amount Including VAT" += RebateILECostAmount;
                            END;
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Return Shipment",
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Credit Memo":
                            BEGIN
                                VendorRebateDetailsLoc.Quantity += RebateItemLdgrEntryIn.Quantity;
                                VendorRebateDetailsLoc.Amount += RebateILECostAmount;
                                VendorRebateDetailsLoc."Amount Including VAT" += RebateILECostAmount;
                            END;
                    END;
                end else begin
                    VendorRebateDetailsLoc.SetRange("Original Document Type");
                    VendorRebateDetailsLoc.SetRange("Document No.");
                    VendorRebateDetailsLoc.SetRange("Document Line No.");
                    VendorRebateDetailsLoc.SetRange("Rebate Item Category Code");
                    VendorRebateDetailsLoc.SetRange("Rebate Program Code");
                    if VendorRebateDetailsLoc.FindLast() then
                        LineNo := VendorRebateDetailsLoc."Line No." + 10000
                    else
                        LineNo := 10000;

                    VendorRebateDetails.Init;
                    VendorRebateDetails."Rebate No." := CreatedVendorRebate."Rebate No.";
                    VendorRebateDetails."Rebate Line No." := RebateLineNoIn;
                    VendorRebateDetails."Line No." := LineNo;
                    CASE RebateItemLdgrEntryIn."Document Type" OF
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Receipt":
                            VendorRebateDetails."Document Type" := VendorRebateLine."Document Type"::Receipt;
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Invoice":
                            VendorRebateDetails."Document Type" := VendorRebateLine."Document Type"::Invoice;
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Return Shipment":
                            VendorRebateDetails."Document Type" := VendorRebateLine."Document Type"::"Return Shipment";
                        RebateItemLdgrEntryIn."Document Type"::"Purchase Credit Memo":
                            VendorRebateDetails."Document Type" := VendorRebateLine."Document Type"::"Credit Memo";
                    END;
                    VendorRebateDetails."Document No." := RebateItemLdgrEntryIn."Document No.";
                    VendorRebateDetails."Document Line No." := RebateItemLdgrEntryIn."Document Line No.";
                    VendorRebateDetails.Type := VendorRebateDetails.Type::Item;
                    VendorRebateDetails."No." := RebateItemLdgrEntryIn."Item No.";
                    VendorRebateDetails.Description := RebateItemLdgrEntryIn.Description;
                    IF VendorRebateDetails.Description = '' then
                        VendorRebateDetails.Description := ItemCard.Description;
                    VendorRebateDetails.Quantity := RebateItemLdgrEntryIn.Quantity;
                    VendorRebateDetails.Amount := RebateILECostAmount;
                    VendorRebateDetails."Amount Including VAT" := RebateILECostAmount;
                    IF VendorRebateDetails.Quantity <> 0 THEN BEGIN
                        VendorRebateDetails."Direct Unit Cost" := ROUND(VendorRebateDetails.Amount / VendorRebateDetails.Quantity, 0.01);
                        VendorRebateDetails."Unit Cost" := ROUND(VendorRebateDetails.Amount / VendorRebateDetails.Quantity, 0.01);
                    END;
                    VendorRebateDetails."Purchaser Code" := RebateItemLdgrEntryIn."AQD Purchaser Code";
                    VendorRebateDetails."Responsibility Center" := RebateItemLdgrEntryIn."Responsibility Center";
                    VendorRebateDetails."Location Code" := RebateItemLdgrEntryIn."Location Code";
                    VendorRebateDetails."Shortcut Dimension 1 Code" := RebateItemLdgrEntryIn."Global Dimension 1 Code";
                    VendorRebateDetails."Shortcut Dimension 2 Code" := RebateItemLdgrEntryIn."Global Dimension 2 Code";
                    VendorRebateDetails.State := RebateItemLdgrEntryIn."AQD Ship-to County";
                    VendorRebateDetails."Buy-from Vendor No." := RebateItemLdgrEntryIn."AQD Buy-from Vendor No.";
                    VendorRebateDetails."Pay-to Vendor No." := RebateItemLdgrEntryIn."AQD Pay-to Vendor No.";
                    VendorRebateDetails.Exclude := false;
                    VendorRebateDetails."Rebate Item Category Code" := TempRebateCategoryLines."Rebate Category Code";
                    VendorRebateDetails."Rebate Program Code" := TempRebateCategoryLines."Rebate Program Code";
                    CASE VendorRebateDetails."Document Type" OF
                        VendorRebateLine."Document Type"::Receipt:
                            VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::Receipt;
                        VendorRebateLine."Document Type"::Invoice:
                            VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::Invoice;
                        VendorRebateLine."Document Type"::"Return Shipment":
                            VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::"Return Shipment";
                        VendorRebateLine."Document Type"::"Credit Memo":
                            VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    VendorRebateDetails."Applies-to Doc. No." := VendorRebateDetails."Document No.";
                    VendorRebateDetails."Applies-to Doc. Line No." := VendorRebateDetails."Document Line No.";
                    VendorRebateDetails.BatchID := GlobalBatchID;
                    VendorRebateDetails."Batch Entry No." := GlobalBatchEntryNo;

                    VendorRebateDetails."AQD Use Rebate Setup From" := TempRebateCategoryLines."AQD Use Rebate Setup From";
                    VendorRebateDetails."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type";

                    VendorRebateDetails.Insert();
                end;
                // Calculate and Vendor Rebate Amount
                GetPurchaseRebateDetails(VendorRebateDetails);
                CalculateRebateAmount(VendorRebateDetails);
                VendorRebateDetails."Calculated Line Rebate Amount" := VendorRebateDetails."Vendor Rebate Amount";
                VendorRebateDetails.Modify();

                RebateItemLdgrEntryIn."AQD Rebate Type" := VendorRebateDetails."Rebate Type";
                RebateItemLdgrEntryIn."AQD Rebate %" := VendorRebateDetails."Rebate %";
                RebateItemLdgrEntryIn."Rebate Per Quantity" := VendorRebateDetails."Rebate Per Quantity";
                case RebateItemLdgrEntryIn."AQD Rebate Type" of
                    RebateItemLdgrEntryIn."AQD Rebate Type"::"Per Quantity":
                        begin
                            RebateItemLdgrEntryIn."Rebate Amount" := Round(RebateItemLdgrEntryIn."Rebate Per Quantity" * RebateItemLdgrEntryIn.Quantity, 0.01);
                            RebateItemLdgrEntryIn."AQD Rebate %" := 0;
                        end;
                    RebateItemLdgrEntryIn."AQD Rebate Type"::Percentage:
                        begin
                            RebateItemLdgrEntryIn."Rebate Amount" := Round((RebateItemLdgrEntryIn."AQD Rebate %" / 100) * RebateILECostAmount, 0.01);
                            RebateItemLdgrEntryIn."Rebate Per Quantity" := 0;
                        end;
                    else
                        RebateItemLdgrEntryIn."Rebate Amount" := Round(RebateItemLdgrEntryIn."Rebate Per Quantity" * RebateILECostAmount, 0.01);
                end;
                RebateItemLdgrEntryIn."AQD Rebate Vendor No" := VendorRebateDetails."Pay-to Vendor No.";
                RebateItemLdgrEntryIn."AQD Rebate Entry Created" := TRUE;
                RebateItemLdgrEntryIn."AQD Rebate Last Changed By" := UserId;
                RebateItemLdgrEntryIn."AQD Rebate LastChangd DateTime" := CurrentDateTime;
                RebateItemLdgrEntryIn."AQD Rebate No" := VendorRebateDetails."Rebate No.";
                RebateItemLdgrEntryIn."AQD Rebate Line No" := VendorRebateDetails."Rebate Line No.";
                RebateItemLdgrEntryIn."AQD Rebate Detail Line No." := VendorRebateDetails."Line No.";
                RebateItemLdgrEntryIn."AQD Rebate Status" := RebateItemLdgrEntryIn."AQD Rebate Status"::Created;
                RebateItemLdgrEntryIn.Modify();
            Until TempRebateCategoryLines.Next() = 0;
        END;
    end;

    procedure GetOrderNoFromRebateItemLedgerEntry(RebateItemLedgerEntry: Record "AQD Rebate Item Ledger Entry"): Code[20];
    var
        PostedPurchInvoice: Record "Purch. Inv. Header";
        PostedPurchCrMemo: Record "Purch. Cr. Memo Hdr.";
        PostedPurchReceiptHeader: Record "Purch. Rcpt. Header";
        PostedReturnShptHeader: Record "Return Shipment Header";
    begin
        CASE RebateItemLedgerEntry."Document Type" of
            RebateItemLedgerEntry."Document Type"::"Purchase Invoice":
                begin
                    IF PostedPurchInvoice.GET(RebateItemLedgerEntry."Document No.") then
                        EXIT(PostedPurchInvoice."Pre-Assigned No.");
                end;
            RebateItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                begin
                    IF PostedPurchCrMemo.GET(RebateItemLedgerEntry."Document No.") then
                        EXIT(PostedPurchCrMemo."Pre-Assigned No.");
                end;
            RebateItemLedgerEntry."Document Type"::"Purchase Receipt":
                begin
                    IF PostedPurchReceiptHeader.GET(RebateItemLedgerEntry."Document No.") then
                        EXIT(PostedPurchReceiptHeader."Order No.");
                end;
            RebateItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                begin
                    IF PostedReturnShptHeader.GET(RebateItemLedgerEntry."Document No.") then
                        EXIT(PostedReturnShptHeader."Return Order No.");
                end;
        END;
    end;

    local procedure BuildCrMemoRebate(var VendorIn: Record Vendor; DateArray: array[2] of Date; SummaryArray: array[5] of Boolean)
    var
        SkipRecord: Boolean;
        StartDate: Date;
        DummyPurchInvoiceHeader: Record "Purch. Inv. Header";
    begin
        Clear(StartDate);
        if DateArray[1] <> 0D then
            StartDate := DateArray[1];
        IF (StartDate = 0D) or (StartDate < RebateSetup."Vendor Rebate Start Date") then
            StartDate := RebateSetup."Vendor Rebate Start Date";

        PurchCrMemoHeader.Reset;
        //PurchCrMemoHeader.SetCurrentKey("Pay-to Vendor No.", "AQD Rebate Customer No", "Posting Date");
        PurchCrMemoHeader.SetCurrentKey("Pay-to Vendor No.", "Posting Date");
        PurchCrMemoHeader.SetRange("Pay-to Vendor No.", VendorIn."No.");
        PurchCrMemoHeader.SetRange("AQD Do Not Pay Rebate", false);
        PurchCrMemoHeader.SetRange("AQD Rebate Status", PurchCrMemoHeader."AQD Rebate Status"::" ");
        PurchCrMemoHeader.SetFilter("Source Code", '<>%1', SourceCodeSetup."Deleted Document");
        // IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then
        //     PurchCrMemoHeader.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
        IF (StartDate <> 0D) OR (DateArray[2] <> 0D) then begin
            CASE VendorIn."AQD Calculation Date" OF
                VendorIn."AQD Calculation Date"::" ",
                VendorIn."AQD Calculation Date"::"Receipt Date":
                    PurchCrMemoHeader.SetFilter("Posting Date", '%1..%2', StartDate, DateArray[2]);
                VendorIn."AQD Calculation Date"::"Rebate Order Date":
                    PurchCrMemoHeader.SetFilter("AQD Rebate Order Date", '%1..%2', StartDate, DateArray[2])
            END;
        end;

        if PurchCrMemoHeader.FindFirst then begin
            repeat
                SkipRecord := false;

                // if VendorIn."AQD Rebate Payment Method" = VendorIn."AQD Rebate Payment Method"::Check then
                //     if not Customer.Get(PurchCrMemoHeader."AQD Rebate Customer No") then
                //         SkipRecord := true;

                //if PurchCrMemoHeader."AQD Rebate %" = 0 then
                if not IsRebatableLineExist(SourceDocumentType::"Credit Memo", DummyPurchInvoiceHeader, PurchCrMemoHeader, VendorIn) then
                    SkipRecord := true;

                PurchCrMemoHeader.CalcFields(Cancelled);
                IF PurchCrMemoHeader.Cancelled then
                    SkipRecord := true;

                VendorRebateLine.Reset;
                VendorRebateLine.SetRange("Document Type", VendorRebateLine."Document Type"::"Credit Memo");
                VendorRebateLine.SetRange("Document No.", PurchCrMemoHeader."No.");
                if VendorRebateLine.FindFirst then
                    SkipRecord := true;

                PurchCrMemoLine.Reset;
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
                PurchCrMemoLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
                  PurchCrMemoLine.Type::Item,
                  PurchCrMemoLine.Type::Resource,
                  PurchCrMemoLine.Type::"G/L Account",
                  PurchCrMemoLine.Type::"Fixed Asset",
                  PurchCrMemoLine.Type::"Charge (Item)");
                PurchCrMemoLine.SetFilter("No.", '<>%1', '');
                PurchCrMemoLine.SetFilter(Quantity, '<>0');
                OnAfterApplyCreditMemoLineFilter(PurchCrMemoHeader, PurchCrMemoLine);
                if PurchCrMemoLine.IsEmpty then
                    SkipRecord := true;

                if not SkipRecord then
                    BuildCreditMemoRebateDetail(PurchCrMemoHeader, VendorIn, SummaryArray);
            until PurchCrMemoHeader.Next = 0;
        end;
    end;

    local procedure BuildCreditMemoRebateDetail(PurchCrMemoHeaderIn: Record "Purch. Cr. Memo Hdr."; VendorIn: Record Vendor; SummaryArray: array[5] of Boolean)
    var
        IsHandled: Boolean;
        RebateNo: Code[20];
        RebateLineNo: Integer;
    begin
        Clear(RebateNo);
        RebateLineNo := 1;

        // if VendorIn."AQD Rebate Payment Method" = VendorIn."AQD Rebate Payment Method"::Check then begin
        //     Clear(Customer);
        //     Customer.Get(PurchCrMemoHeaderIn."AQD Rebate Customer No");
        //     Customer.TestField("AQD Customer Type", Customer."AQD Customer Type"::"Rebate Customer");
        // end;

        IsHandled := false;
        OnBeforeStartCalculatingCrMemoRebate(PurchCrMemoHeaderIn, VendorIn, Customer, IsHandled);
        if IsHandled then
            exit;

        if IsRebatableLineExist(SourceDocumentType::"Credit Memo", PurchaseInvHeader, PurchCrMemoHeaderIn, VendorIn) then begin
            //Document
            InsertRebateHeader(DocumentType::"Credit Memo", PurchaseInvHeader, PurchCrMemoHeaderIn, VendorIn, Customer, RebateNo, SummaryArray);
            //Line
            InsertRebateLine(DocumentType::"Credit Memo", PurchaseInvHeader, PurchCrMemoHeaderIn, RebateNo, RebateLineNo);

            PurchCrMemoLine.Reset;
            PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeaderIn."No.");
            PurchCrMemoLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
              PurchCrMemoLine.Type::Item,
              PurchCrMemoLine.Type::Resource,
              PurchCrMemoLine.Type::"G/L Account",
              PurchCrMemoLine.Type::"Fixed Asset",
              PurchCrMemoLine.Type::"Charge (Item)");
            PurchCrMemoLine.SetFilter("No.", '<>%1', '');
            PurchCrMemoLine.SetFilter(Quantity, '<>0');
            OnAfterApplyCreditMemoLineFilter(PurchCrMemoHeaderIn, PurchCrMemoLine);
            if PurchCrMemoLine.FindFirst then begin
                repeat
                    //RebateAmount := PurchCrMemoHeaderIn."AQD Rebate %";
                    if IsLineRebatable(
                      VendorIn."No.",
                      PurchCrMemoLine.Type,
                      PurchCrMemoLine."No.",
                      PurchCrMemoHeaderIn."Posting Date")
                    then
                        InsertRebateDetail(DocumentType::"Credit Memo", PurchaseInvHeader, PurchaseInvLine, PurchCrMemoHeaderIn, PurchCrMemoLine, VendorIn, Customer, RebateNo, RebateLineNo);
                until PurchCrMemoLine.Next = 0;
            end;
        end;
    end;

    local procedure IsRebatableLineExist(SourceDocType: Option "Posted Invoice","Posted Credit Memo"; PurchaseInvHeaderIn: Record "Purch. Inv. Header"; PurchCrMemoHeaderIn: Record "Purch. Cr. Memo Hdr."; VendorIn: Record Vendor): Boolean
    var
        PurchaseInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        IsHandled: Boolean;
        LineRebatable: Boolean;
    begin
        LineRebatable := false;
        if SourceDocType = SourceDocType::"Posted Invoice" then begin
            PurchaseInvLine.Reset;
            PurchaseInvLine.SetRange("Document No.", PurchaseInvHeaderIn."No.");
            PurchaseInvLine.SetFilter(Type,
              '%1|%2|%3|%4|%5',
              PurchaseInvLine.Type::Item,
              PurchaseInvLine.Type::Resource,
              PurchaseInvLine.Type::"G/L Account",
              PurchaseInvLine.Type::"Fixed Asset",
              PurchaseInvLine.Type::"Charge (Item)");
            PurchaseInvLine.SetFilter("No.", '<>%1', '');
            PurchaseInvLine.SetFilter(Quantity, '<>%1', 0);
            OnAfterApplyInvoiceLineFilter(PurchaseInvHeaderIn, PurchaseInvLine);
            if PurchaseInvLine.FindFirst then begin
                repeat
                    IsHandled := false;
                    //RebateAmount := PurchaseInvHeaderIn."AQD Rebate %";
                    OnBeforeFindRebateRate(SourceDocType, PurchaseInvHeaderIn, PurchaseInvLine, PurchCrMemoHeaderIn, PurchCrMemoLine, IsHandled);
                    if not IsHandled then
                        LineRebatable := IsLineRebatable(VendorIn."No.",
                                                         PurchaseInvLine.Type,
                                                         PurchaseInvLine."No.",
                                                         PurchaseInvHeaderIn."Posting Date");
                until (PurchaseInvLine.Next = 0) OR LineRebatable;
                EXIT(LineRebatable);
            end;
        end else
            if SourceDocType = SourceDocType::"Posted Credit Memo" then begin
                PurchCrMemoLine.Reset;
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeaderIn."No.");
                PurchCrMemoLine.SetFilter(Type,
                  '%1|%2|%3|%4|%5',
                  PurchCrMemoLine.Type::Item,
                  PurchCrMemoLine.Type::Resource,
                  PurchCrMemoLine.Type::"Fixed Asset",
                  PurchCrMemoLine.Type::"G/L Account",
                  PurchCrMemoLine.Type::"Charge (Item)");
                PurchCrMemoLine.SetFilter("No.", '<>%1', '');
                PurchCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                OnAfterApplyCreditMemoLineFilter(PurchCrMemoHeaderIn, PurchCrMemoLine);
                if PurchCrMemoLine.FindFirst then begin
                    repeat
                        IsHandled := false;
                        OnBeforeFindRebateRate(SourceDocType, PurchaseInvHeaderIn, PurchaseInvLine, PurchCrMemoHeaderIn, PurchCrMemoLine, IsHandled);
                        LineRebatable := IsLineRebatable(VendorIn."No.",
                                                         PurchCrMemoLine.Type,
                                                         PurchCrMemoLine."No.",
                                                         PurchCrMemoHeaderIn."Posting Date");
                    until (PurchCrMemoLine.Next = 0) OR LineRebatable;
                    EXIT(LineRebatable);
                end;
            end;
        exit(false);
    end;

    local procedure IsLineRebatable(VendorNo: Code[20]; DocumentLine_Type: Enum "Purchase Line Type"; DocumentLine_No: Code[20]; PostingDate: Date): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        RebateCategoryLines: Record "AQD Rebate Category Lines";
        VendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib";
        TempRebateCategoryLines: Record "AQD Rebate Category Lines" temporary;
        ChkVendItemRebateElig: Codeunit "AQD ChkVendItemRebateElig Mgt";
        LocalRebateCategoryCode: Code[20];
        IsHandled: Boolean;
        IsRebatable: Boolean;
    begin
        IsRebatable := FALSE;
        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                BEGIN
                    Item.GET(DocumentLine_No);
                    LocalRebateCategoryCode := Item."AQD Rebate Category Code";
                    IsRebatable := Item."AQD Vendor Rebatable";
                END;
            DocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(DocumentLine_No);
                    LocalRebateCategoryCode := GLAccount."AQD Rebate Category Code";
                    IsRebatable := GLAccount."AQD Vendor Rebatable";
                END;
            DocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(DocumentLine_No);
                    LocalRebateCategoryCode := Resource."AQD Rebate Category Code";
                    IsRebatable := Resource."AQD Vendor Rebatable";
                END;
            DocumentLine_Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(DocumentLine_No);
                    LocalRebateCategoryCode := ItemCharge."AQD Rebate Category Code";
                    IsRebatable := ItemCharge."AQD Vendor Rebatable";
                END;
            DocumentLine_Type::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(DocumentLine_No);
                    LocalRebateCategoryCode := FixedAsset."AQD Rebate Category Code";
                    IsRebatable := FixedAsset."AQD Vendor Rebatable";
                END;
            ELSE BEGIN
                IsHandled := FALSE;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebatable, IsHandled);
                IF IsHandled THEN
                    EXIT(IsRebatable);
            END;
        END;

        IF IsRebatable then begin
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
                        IsRebatable := ChkVendItemRebateElig.IsPayToVendorEligibleForRebate(VendorItemRebateEligibility,
                                                                    VendorNo,
                                                                    DocumentLine_Type,
                                                                    DocumentLine_No,
                                                                    PostingDate,
                                                                    TempRebateCategoryLines."Rebate Program Code");
                    Until (TempRebateCategoryLines.Next() = 0) OR IsRebatable;
                END;
            END;
        end;
        EXIT(IsRebatable);
    end;

    local procedure InsertRebateHeader(DocumentType: Option " ",Invoice,"Credit Memo"; PurchInvHeaderIn: Record "Purch. Inv. Header"; PurchCrMemoHeaderIn: Record "Purch. Cr. Memo Hdr."; VendorIn: Record Vendor; CustomerIn: Record Customer; var RebateNo: code[20]; SummaryArray: array[5] of Boolean)
    var
        VendorRebateBatch: Record "AQD Vendor Rebate Batch";
        BuyFromVendorRec: Record Vendor;
        PayToVendorRec: Record Vendor;
        RebateVendorRec: Record Vendor;
        PayToVendorCode: Code[20];
        DocumentPostingDate: Date;
    begin
        Clear(VendorRebateHeader);

        CreatedVendorRebate.Reset();
        case DocumentType of
            DocumentType::Invoice:
                begin
                    IF RebateSetup."AQD Rebate Batch Frequency" <> RebateSetup."AQD Rebate Batch Frequency"::" " then BEGIN
                        CASE VendorIn."AQD Calculation Date" OF
                            VendorIn."AQD Calculation Date"::" ",
                            VendorIn."AQD Calculation Date"::"Receipt Date":
                                GlobalBatchID := GetBatchID(PurchInvHeaderIn."Posting Date");
                            VendorIn."AQD Calculation Date"::"Rebate Order Date":
                                GlobalBatchID := GetBatchID(PurchInvHeaderIn."AQD Rebate Order Date");
                        END;
                    END;

                    BuyFromVendorRec.GET(PurchInvHeaderIn."Buy-from Vendor No.");
                    PayToVendorRec.GET(PurchInvHeaderIn."Pay-To Vendor No.");
                    IF PayToVendorRec."AQD Rebate Vendor No" <> '' THEN
                        RebateVendorRec.GET(PayToVendorRec."AQD Rebate Vendor No");
                    DocumentPostingDate := PurchInvHeaderIn."Posting Date";

                    CreatedVendorRebate.SetRange("Pay-to Vendor No.", PayToVendorRec."No.");
                    if SummaryArray[1] then
                        CreatedVendorRebate.SetRange("Buy-from Vendor No.", PurchInvHeaderIn."Buy-from Vendor No.")
                    ELSE
                        CreatedVendorRebate.SetRange("Buy-from Vendor No.", PayToVendorRec."No.");
                    if SummaryArray[2] then
                        CreatedVendorRebate.SetRange("Responsibility Center", PurchInvHeaderIn."Responsibility Center");
                    if SummaryArray[3] then
                        CreatedVendorRebate.SetRange("Location Code", PurchInvHeaderIn."Location Code");
                    if SummaryArray[4] then
                        CreatedVendorRebate.SetRange("Shortcut Dimension 1 Code", PurchInvHeaderIn."Shortcut Dimension 1 Code");
                    if SummaryArray[5] then
                        CreatedVendorRebate.SetRange("Shortcut Dimension 2 Code", PurchInvHeaderIn."Shortcut Dimension 2 Code");
                    IF GlobalBatchID <> '' then
                        CreatedVendorRebate.SetRange(GlobalBatchID, GlobalBatchID);
                end;
            DocumentType::"Credit Memo":
                begin
                    IF RebateSetup."AQD Rebate Batch Frequency" <> RebateSetup."AQD Rebate Batch Frequency"::" " then BEGIN
                        //GlobalBatchID := GetBatchID(PurchCrMemoHeaderIn."Posting Date");
                        CASE VendorIn."AQD Calculation Date" OF
                            VendorIn."AQD Calculation Date"::" ",
                            VendorIn."AQD Calculation Date"::"Receipt Date":
                                GlobalBatchID := GetBatchID(PurchCrMemoHeaderIn."Posting Date");
                            VendorIn."AQD Calculation Date"::"Rebate Order Date":
                                GlobalBatchID := GetBatchID(PurchCrMemoHeaderIn."AQD Rebate Order Date");
                        END;
                    END;

                    BuyFromVendorRec.GET(PurchCrMemoHeaderIn."Buy-from Vendor No.");
                    PayToVendorRec.GET(PurchCrMemoHeaderIn."Pay-To Vendor No.");
                    IF PayToVendorRec."AQD Rebate Vendor No" <> '' THEN
                        RebateVendorRec.GET(PayToVendorRec."AQD Rebate Vendor No");
                    DocumentPostingDate := PurchCrMemoHeaderIn."Posting Date";

                    CreatedVendorRebate.SetRange("Pay-to Vendor No.", PayToVendorRec."No.");
                    if SummaryArray[1] then
                        CreatedVendorRebate.SetRange("Buy-from Vendor No.", PurchCrMemoHeaderIn."Buy-from Vendor No.")
                    ELSE
                        CreatedVendorRebate.SetRange("Buy-from Vendor No.", PayToVendorRec."No.");
                    if SummaryArray[2] then
                        CreatedVendorRebate.SetRange("Responsibility Center", PurchCrMemoHeaderIn."Responsibility Center");
                    if SummaryArray[3] then
                        CreatedVendorRebate.SetRange("Location Code", PurchCrMemoHeaderIn."Location Code");
                    if SummaryArray[4] then
                        CreatedVendorRebate.SetRange("Shortcut Dimension 1 Code", PurchCrMemoHeaderIn."Shortcut Dimension 1 Code");
                    if SummaryArray[5] then
                        CreatedVendorRebate.SetRange("Shortcut Dimension 2 Code", PurchCrMemoHeaderIn."Shortcut Dimension 2 Code");
                    IF GlobalBatchID <> '' then
                        CreatedVendorRebate.SetRange(GlobalBatchID, GlobalBatchID);
                end;
        end;

        IF NOT CreatedVendorRebate.FindFirst() then begin
            IF GlobalBatchID <> '' THEN BEGIN
                VendorRebateBatch.RESET;
                VendorRebateBatch.SetRange(BatchID, GlobalBatchID);
                IF NOT VendorRebateBatch.FindFirst() THEN BEGIN
                    VendorRebateBatch.INIT;
                    VendorRebateBatch.BatchID := GlobalBatchID;
                    VendorRebateBatch."Posting Date" := TODAY;
                    VendorRebateBatch."Created By" := UserId;
                    VendorRebateBatch."Created Date" := Today;
                    VendorRebateBatch."Start Date" := GlobalBatchStartDate;
                    VendorRebateBatch."End Date" := GlobalBatchEndDate;
                    VendorRebateBatch."AQD Rebate Batch Frequency" := GlobalRebateBatchFrequency;
                    VendorRebateBatch.INSERT();
                    GlobalBatchEntryNo := VendorRebateBatch."Entry No.";
                END ELSE
                    GlobalBatchEntryNo := VendorRebateBatch."Entry No.";
            end;

            VendorRebateHeader.Init;
            VendorRebateHeader."No." := NoSeriesMgt.GetNextNo(RebateSetup."Vendor Rebate Nos", Today, true);
            if SummaryArray[1] then begin
                VendorRebateHeader."Buy-from Vendor No." := BuyFromVendorRec."No.";
                VendorRebateHeader."Buy-from Vendor Name" := BuyFromVendorRec.Name;
                VendorRebateHeader."Buy-from Vendor Name 2" := BuyFromVendorRec."Name 2";
                VendorRebateHeader."Buy-from Address" := BuyFromVendorRec.Address;
                VendorRebateHeader."Buy-from Address 2" := BuyFromVendorRec."Address 2";
                VendorRebateHeader."Buy-from City" := BuyFromVendorRec.City;
                VendorRebateHeader."Buy-from Contact" := BuyFromVendorRec.Contact;
                VendorRebateHeader."Buy-from Post Code" := BuyFromVendorRec."Post Code";
                VendorRebateHeader."Buy-from County" := BuyFromVendorRec.County;
                VendorRebateHeader."Buy-from Country/Region Code" := BuyFromVendorRec."Country/Region Code";
            END ELSE begin
                CreatedVendorRebate.SetRange("Buy-from Vendor No.", PayToVendorRec."No.");
                VendorRebateHeader."Buy-from Vendor No." := PayToVendorRec."No.";
                VendorRebateHeader."Buy-from Vendor Name" := PayToVendorRec.Name;
                VendorRebateHeader."Buy-from Vendor Name 2" := PayToVendorRec."Name 2";
                VendorRebateHeader."Buy-from Address" := PayToVendorRec.Address;
                VendorRebateHeader."Buy-from Address 2" := PayToVendorRec."Address 2";
                VendorRebateHeader."Buy-from City" := PayToVendorRec.City;
                VendorRebateHeader."Buy-from Contact" := PayToVendorRec.Contact;
                VendorRebateHeader."Buy-from Post Code" := PayToVendorRec."Post Code";
                VendorRebateHeader."Buy-from County" := PayToVendorRec."County";
                VendorRebateHeader."Buy-from Country/Region Code" := PayToVendorRec."Country/Region Code";

                VendorRebateHeader."Pay-to Vendor No." := PayToVendorRec."No.";
                VendorRebateHeader."Pay-to Name" := PayToVendorRec.Name;
                VendorRebateHeader."Pay-to Name 2" := PayToVendorRec."Name 2";
                VendorRebateHeader."Pay-to Address" := PayToVendorRec.Address;
                VendorRebateHeader."Pay-to Address 2" := PayToVendorRec."Address 2";
                VendorRebateHeader."Pay-to City" := PayToVendorRec.City;
                VendorRebateHeader."Pay-to Contact" := PayToVendorRec.Contact;
                VendorRebateHeader."Pay-to Post Code" := PayToVendorRec."Post Code";
                VendorRebateHeader."Pay-to County" := PayToVendorRec."County";
                VendorRebateHeader."Pay-to Country/Region Code" := PayToVendorRec."Country/Region Code";
            end;

            case DocumentType of
                DocumentType::Invoice:
                    begin
                        VendorRebateHeader."Purchaser Code" := PurchInvHeaderIn."Purchaser Code";
                        VendorRebateHeader."External Document No." := PurchInvHeaderIn."Vendor Invoice No.";
                        VendorRebateHeader.State := PurchInvHeaderIn."Ship-to County";
                        if SummaryArray[2] then
                            VendorRebateHeader."Responsibility Center" := PurchInvHeaderIn."Responsibility Center";
                        if SummaryArray[3] then
                            VendorRebateHeader."Location Code" := PurchInvHeaderIn."Location Code";
                        if SummaryArray[4] then
                            VendorRebateHeader."Shortcut Dimension 1 Code" := PurchInvHeaderIn."Shortcut Dimension 1 Code";
                        if SummaryArray[5] then
                            VendorRebateHeader."Shortcut Dimension 2 Code" := PurchInvHeaderIn."Shortcut Dimension 2 Code";
                    end;
                DocumentType::"Credit Memo":
                    begin
                        VendorRebateHeader."Purchaser Code" := PurchCrMemoHeaderIn."Purchaser Code";
                        VendorRebateHeader.State := PurchCrMemoHeaderIn."Ship-to County";
                        if SummaryArray[2] then
                            VendorRebateHeader."Responsibility Center" := PurchCrMemoHeaderIn."Responsibility Center";
                        if SummaryArray[3] then
                            VendorRebateHeader."Location Code" := PurchCrMemoHeaderIn."Location Code";
                        VendorRebateHeader."External Document No." := PurchCrMemoHeaderIn."Vendor Cr. Memo No.";
                        if SummaryArray[4] then
                            VendorRebateHeader."Shortcut Dimension 1 Code" := PurchCrMemoHeaderIn."Shortcut Dimension 1 Code";
                        if SummaryArray[5] then
                            VendorRebateHeader."Shortcut Dimension 2 Code" := PurchCrMemoHeaderIn."Shortcut Dimension 2 Code";
                    end;
            end;
            VendorRebateHeader."Posting Description" := PostingDescrptionText;
            VendorRebateHeader."Posting Date" := Today;
            VendorRebateHeader."Document Date" := Today;
            VendorRebateHeader."Created By" := UserId;
            VendorRebateHeader."Created Date" := Today;
            VendorRebateHeader.BatchID := GlobalBatchID;
            VendorRebateHeader."Batch Entry No." := VendorRebateBatch."Entry No.";
            VendorRebateHeader."AQD Calculation Date" := VendorIn."AQD Calculation Date";
            VendorRebateHeader.Insert;
            RebateNo := VendorRebateHeader."No.";

            CreatedVendorRebate.Init();
            CreatedVendorRebate."Rebate No." := VendorRebateHeader."No.";
            CreatedVendorRebate."Pay-to Vendor No." := VendorRebateHeader."Pay-to Vendor No.";
            CreatedVendorRebate."Buy-from Vendor No." := VendorRebateHeader."Buy-from Vendor No.";
            CreatedVendorRebate."Location Code" := VendorRebateHeader."Location Code";
            CreatedVendorRebate."Responsibility Center" := VendorRebateHeader."Responsibility Center";
            CreatedVendorRebate."Shortcut Dimension 1 Code" := VendorRebateHeader."Shortcut Dimension 1 Code";
            CreatedVendorRebate."Shortcut Dimension 2 Code" := VendorRebateHeader."Shortcut Dimension 2 Code";
            CreatedVendorRebate.GlobalBatchID := GlobalBatchID;
            CreatedVendorRebate.INSERT;
        end else
            RebateNo := CreatedVendorRebate."Rebate No.";
    end;

    local procedure InsertRebateLine(DocumentType: Option " ",Invoice,"Credit Memo"; PurchInvHeaderIn: Record "Purch. Inv. Header"; PurchCrMemoHeaderIn: Record "Purch. Cr. Memo Hdr."; RebateNo: Code[20]; var RebateLineNo: Integer)
    var
        VendorRebateLineLoc: Record "AQD Vendor Rebate Line";
    begin
        Clear(VendorRebateLine);

        VendorRebateLineLoc.Reset();
        VendorRebateLineLoc.SetRange("Rebate No.", RebateNo);
        if VendorRebateLineLoc.FindLast() then
            RebateLineNo := VendorRebateLineLoc."Line No." + 10000
        else
            RebateLineNo := 10000;

        VendorRebateLine.Init;
        case DocumentType of
            DocumentType::Invoice:
                begin
                    PurchInvHeaderIn.CalcFields(Amount, "Amount Including VAT");
                    VendorRebateLine."Rebate No." := RebateNo;
                    VendorRebateLine."Line No." := RebateLineNo;
                    VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::Invoice;
                    VendorRebateLine."Document No." := PurchInvHeaderIn."No.";
                    VendorRebateLine."Order No." := PurchInvHeaderIn."Order No.";
                    VendorRebateLine.Description := PurchInvHeaderIn."Posting Description";
                    VendorRebateLine."Order Date" := PurchInvHeaderIn."Order Date";
                    VendorRebateLine."Rebate Order Date" := PurchInvHeaderIn."Order Date";
                    VendorRebateLine."Posting Date" := PurchInvHeaderIn."Posting Date";
                    VendorRebateLine."Vendor Order No." := PurchInvHeaderIn."Vendor Order No.";
                    VendorRebateLine."Vendor Invoice No." := PurchInvHeaderIn."Vendor Invoice No.";
                    VendorRebateLine.Amount := PurchInvHeaderIn.Amount;
                    VendorRebateLine."Amount Including VAT" := PurchInvHeaderIn."Amount Including VAT";
                    VendorRebateLine."Purchaser Code" := PurchInvHeaderIn."Purchaser Code";
                    VendorRebateLine."Responsibility Center" := PurchInvHeaderIn."Responsibility Center";
                    VendorRebateLine."Location Code" := PurchInvHeaderIn."Location Code";
                    VendorRebateLine."Currency Code" := PurchInvHeaderIn."Currency Code";
                    VendorRebateLine."Shortcut Dimension 1 Code" := PurchInvHeaderIn."Shortcut Dimension 1 Code";
                    VendorRebateLine."Shortcut Dimension 2 Code" := PurchInvHeaderIn."Shortcut Dimension 2 Code";
                    VendorRebateLine."Buy-from Vendor No." := PurchInvHeaderIn."Buy-from Vendor No.";
                    VendorRebateLine."Pay-to Vendor No." := PurchInvHeaderIn."Pay-to Vendor No.";
                end;
            DocumentType::"Credit Memo":
                begin
                    PurchCrMemoHeaderIn.CalcFields(Amount, "Amount Including VAT");
                    VendorRebateLine."Rebate No." := RebateNo;
                    VendorRebateLine."Line No." := RebateLineNo;
                    VendorRebateLine."Document Type" := VendorRebateLine."Document Type"::"Credit Memo";
                    VendorRebateLine."Document No." := PurchCrMemoHeaderIn."No.";
                    VendorRebateLine."Order No." := PurchCrMemoHeaderIn."Return Order No.";
                    VendorRebateLine.Description := PurchCrMemoHeaderIn."Posting Description";
                    VendorRebateLine."Posting Date" := PurchCrMemoHeaderIn."Posting Date";
                    VendorRebateLine."Vendor Cr. Memo No." := PurchCrMemoHeaderIn."Vendor Cr. Memo No.";
                    VendorRebateLine.Amount := -1 * PurchCrMemoHeaderIn.Amount;
                    VendorRebateLine."Amount Including VAT" := -1 * PurchCrMemoHeaderIn."Amount Including VAT";
                    VendorRebateLine."Purchaser Code" := PurchCrMemoHeaderIn."Purchaser Code";
                    VendorRebateLine."Responsibility Center" := PurchCrMemoHeaderIn."Responsibility Center";
                    VendorRebateLine."Location Code" := PurchCrMemoHeaderIn."Location Code";
                    VendorRebateLine."Currency Code" := PurchCrMemoHeaderIn."Currency Code";
                    VendorRebateLine."Shortcut Dimension 1 Code" := PurchCrMemoHeaderIn."Shortcut Dimension 1 Code";
                    VendorRebateLine."Shortcut Dimension 2 Code" := PurchCrMemoHeaderIn."Shortcut Dimension 2 Code";
                    VendorRebateLine."Buy-from Vendor No." := PurchCrMemoHeaderIn."Buy-from Vendor No.";
                    VendorRebateLine."Pay-to Vendor No." := PurchCrMemoHeaderIn."Pay-to Vendor No.";
                end;
        end;
        //VendorRebateLine.Exclude := false;
        VendorRebateLine.BatchID := GlobalBatchID;
        VendorRebateLine."Batch Entry No." := GlobalBatchEntryNo;
        VendorRebateLine.Insert;
    end;

    local procedure InsertRebateDetail(DocumentTypeIn: Option " ",Invoice,"Credit Memo"; PurchInvHeaderIn: Record "Purch. Inv. Header"; PurchInvLineIn: Record "Purch. Inv. Line"; PurchCrMemoHeaderIn: Record "Purch. Cr. Memo Hdr."; PurchCrMemoLineIn: Record "Purch. Cr. Memo Line"; VendorIn: Record Vendor; Customer: Record Customer; RebateNo: Code[20]; RebateLineNo: Integer)
    var
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        Location: Record Location;
        RebateCategoryLines: Record "AQD Rebate Category Lines";
        TempRebateCategoryLines: Record "AQD Rebate Category Lines" temporary;
        LocalDocumentLine_Type: Enum "Purchase Line Type";
        LocalDocumentLine_No: Code[20];
        LineNo: Integer;
        IsHandled: Boolean;
        PostingDate: Date;
        VendorRebateDetailsLoc: Record "AQD Vendor Rebate Details";
        VendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib";
        TempPurchRcptLine: Record "Purch. Rcpt. Line" temporary;
        TempReturnShipmentLine: Record "Return Shipment Line" temporary;
        RebateProgramCodeRec: Record "AQD Rebate Program Code";
        ChkVendItemRebateElig: Codeunit "AQD ChkVendItemRebateElig Mgt";
        LocalRebateCategoryCode: Code[20];
        IsRebatable: Boolean;
        UseRebateCostSetupFrom: Enum "AQD Use Rebate Setup From";
        RebateCostPostingType: Enum "AQD Rebate Posting Type";
    begin
        Clear(VendorRebateDetails);
        LineNo := 1;

        IsHandled := false;
        OnBeforeInitRebateEntry(DocumentTypeIn, PurchInvHeaderIn, PurchInvLineIn, PurchCrMemoHeaderIn, PurchCrMemoLineIn, IsHandled);
        if IsHandled then
            exit;

        CASE DocumentTypeIn OF
            DocumentTypeIn::Invoice:
                begin
                    PostingDate := PurchInvHeaderIn."Posting Date";
                    LocalDocumentLine_Type := PurchInvLineIn.Type;
                    LocalDocumentLine_No := PurchInvLineIn."No.";
                end;
            DocumentTypeIn::"Credit Memo":
                begin
                    PostingDate := PurchCrMemoHeaderIn."Posting Date";
                    LocalDocumentLine_Type := PurchCrMemoLineIn.Type;
                    LocalDocumentLine_No := PurchCrMemoLineIn."No.";
                end;
        END;

        CASE LocalDocumentLine_Type OF
            LocalDocumentLine_Type::Item:
                BEGIN
                    Item.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := Item."AQD Rebate Category Code";
                    UseRebateCostSetupFrom := Item."AQD Use Rebate Setup From";
                    RebateCostPostingType := Item."AQD Rebate Posting Type";
                END;
            LocalDocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := GLAccount."AQD Rebate Category Code";
                    UseRebateCostSetupFrom := GLAccount."AQD Use Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := Resource."AQD Rebate Category Code";
                    UseRebateCostSetupFrom := Resource."AQD Use Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := ItemCharge."AQD Rebate Category Code";
                    UseRebateCostSetupFrom := ItemCharge."AQD Use Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
            LocalDocumentLine_Type::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(LocalDocumentLine_No);
                    LocalRebateCategoryCode := FixedAsset."AQD Rebate Category Code";
                    UseRebateCostSetupFrom := FixedAsset."AQD Use Rebate Setup From";
                    RebateCostPostingType := RebateCostPostingType::"G/L Account";
                END;
        END;

        VendorRebateDetailsLoc.Reset();
        VendorRebateDetailsLoc.SetRange("Rebate No.", RebateNo);
        VendorRebateDetailsLoc.SetRange("Rebate Line No.", RebateLineNo);
        if VendorRebateDetailsLoc.FindLast() then
            LineNo := VendorRebateDetailsLoc."Line No." + 10000
        else
            LineNo := 10000;

        TempRebateCategoryLines.RESET;
        IF TempRebateCategoryLines.IsTemporary then
            TempRebateCategoryLines.DeleteAll();

        IF LocalRebateCategoryCode <> '' THEN BEGIN
            TempRebateCategoryLines.Init();
            TempRebateCategoryLines."Rebate Category Code" := LocalRebateCategoryCode;

            TempRebateCategoryLines."AQD Use Rebate Setup From" := UseRebateCostSetupFrom;
            TempRebateCategoryLines."AQD Rebate Posting Type" := RebateCostPostingType;

            RebateCategoryLines.RESET;
            RebateCategoryLines.SetRange("Rebate Category Code", LocalRebateCategoryCode);
            IF RebateCategoryLines.FindFirst() THEN begin
                repeat
                    TempRebateCategoryLines."Line No." := RebateCategoryLines."Line No.";
                    TempRebateCategoryLines."Rebate Program Code" := RebateCategoryLines."Rebate Program Code";

                    IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN begin
                        IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                            TempRebateCategoryLines."AQD Rebate Posting Type" := RebateProgramCodeRec."Rebate Posting Type";
                        end;
                    end;

                    IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN
                        TempRebateCategoryLines."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type"::"G/L Account";

                    TempRebateCategoryLines.Insert();
                until RebateCategoryLines.Next() = 0;
            end ELSE BEGIN
                TempRebateCategoryLines."Line No." := 10000;
                TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";

                IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN begin
                    IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN begin
                        TempRebateCategoryLines."AQD Rebate Posting Type" := RebateProgramCodeRec."Rebate Posting Type";
                    end;
                end;

                IF TempRebateCategoryLines."AQD Rebate Posting Type" = TempRebateCategoryLines."AQD Rebate Posting Type"::" " THEN
                    TempRebateCategoryLines."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type"::"G/L Account";

                TempRebateCategoryLines.INSERT;
            END;

            TempRebateCategoryLines.RESET;
            IF TempRebateCategoryLines.FindFirst() THEN BEGIN
                Repeat
                    IsRebatable := FALSE;
                    IsRebatable := ChkVendItemRebateElig.IsPayToVendorEligibleForRebate(VendorItemRebateEligibility,
                                                                VendorIn."No.",
                                                                LocalDocumentLine_Type,
                                                                LocalDocumentLine_No,
                                                                PostingDate,
                                                                TempRebateCategoryLines."Rebate Program Code");
                    IF IsRebatable THEN BEGIN
                        VendorRebateDetails.Init;
                        case DocumentTypeIn of
                            DocumentTypeIn::Invoice:
                                begin
                                    VendorRebateDetails.INIT;
                                    VendorRebateDetails."Rebate No." := RebateNo;
                                    VendorRebateDetails."Rebate Line No." := RebateLineNo;
                                    VendorRebateDetails."Line No." := LineNo;
                                    VendorRebateDetails."Document Type" := VendorRebateDetails."Document Type"::Invoice;
                                    VendorRebateDetails."Document No." := PurchInvLineIn."Document No.";
                                    VendorRebateDetails."Document Line No." := PurchInvLineIn."Line No.";
                                    case PurchInvLineIn.Type of
                                        PurchInvLineIn.Type::"Charge (Item)":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"Charge (Item)";
                                        PurchInvLineIn.Type::"Fixed Asset":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"Fixed Asset";
                                        PurchInvLineIn.Type::"G/L Account":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"G/L Account";
                                        PurchInvLineIn.Type::Item:
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::Item;
                                        PurchInvLineIn.Type::Resource:
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::Resource;
                                    end;
                                    VendorRebateDetails."No." := PurchInvLineIn."No.";
                                    VendorRebateDetails.Description := PurchInvLineIn.Description;
                                    VendorRebateDetails.Quantity := PurchInvLineIn.Quantity;
                                    VendorRebateDetails."Direct Unit Cost" := PurchInvLineIn."Direct Unit Cost";
                                    VendorRebateDetails."Unit Cost" := PurchInvLineIn."Unit Cost";
                                    VendorRebateDetails.Amount := PurchInvLineIn.Amount;
                                    VendorRebateDetails."Amount Including VAT" := PurchInvLineIn."Amount Including VAT";
                                    VendorRebateDetails."Rebate Type" := VendorRebateDetails."Rebate Type"::" ";
                                    VendorRebateDetails."Rebate %" := 0;
                                    VendorRebateDetails."Rebate Per Quantity" := 0;
                                    VendorRebateDetails."Purchaser Code" := PurchInvHeaderIn."Purchaser Code";
                                    VendorRebateDetails."Responsibility Center" := PurchInvLineIn."Responsibility Center";
                                    VendorRebateDetails."Location Code" := PurchInvLineIn."Location Code";
                                    VendorRebateDetails."Shortcut Dimension 1 Code" := PurchInvLineIn."Shortcut Dimension 1 Code";
                                    VendorRebateDetails."Shortcut Dimension 2 Code" := PurchInvLineIn."Shortcut Dimension 2 Code";
                                    VendorRebateDetails.State := PurchInvHeaderIn."Ship-to County";
                                    VendorRebateDetails."Buy-from Vendor No." := PurchInvHeaderIn."Buy-from Vendor No.";
                                    VendorRebateDetails."Pay-to Vendor No." := PurchInvHeaderIn."Pay-to Vendor No.";
                                    PurchInvLineIn.GetPurchRcptLines(TempPurchRcptLine);
                                    IF TempPurchRcptLine.FindFirst() THEN BEGIN
                                        VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::Receipt;
                                        VendorRebateDetails."Applies-to Doc. No." := TempPurchRcptLine."Document No.";
                                        VendorRebateDetails."Applies-to Doc. Line No." := TempPurchRcptLine."Line No.";
                                    END ELSE BEGIN
                                        VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::Invoice;
                                        VendorRebateDetails."Applies-to Doc. No." := PurchInvLineIn."Document No.";
                                        VendorRebateDetails."Applies-to Doc. Line No." := PurchInvLineIn."Line No.";
                                    END;
                                end;
                            DocumentTypeIn::"Credit Memo":
                                begin
                                    VendorRebateDetails.INIT;
                                    VendorRebateDetails."Rebate No." := RebateNo;
                                    VendorRebateDetails."Rebate Line No." := RebateLineNo;
                                    VendorRebateDetails."Line No." := LineNo;
                                    VendorRebateDetails."Document Type" := VendorRebateDetails."Document Type"::"Credit Memo";
                                    VendorRebateDetails."Document No." := PurchCrMemoLineIn."Document No.";
                                    VendorRebateDetails."Document Line No." := PurchCrMemoLineIn."Line No.";
                                    case PurchCrMemoLineIn.Type of
                                        PurchCrMemoLineIn.Type::"Charge (Item)":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"Charge (Item)";
                                        PurchCrMemoLineIn.Type::"Fixed Asset":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"Fixed Asset";
                                        PurchCrMemoLineIn.Type::"G/L Account":
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::"G/L Account";
                                        PurchCrMemoLineIn.Type::Item:
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::Item;
                                        PurchCrMemoLineIn.Type::Resource:
                                            VendorRebateDetails.Type := VendorRebateDetails.Type::Resource;
                                    end;
                                    VendorRebateDetails."No." := PurchCrMemoLineIn."No.";
                                    VendorRebateDetails.Description := PurchCrMemoLineIn.Description;
                                    VendorRebateDetails.Quantity := -1 * PurchCrMemoLineIn.Quantity;
                                    VendorRebateDetails."Direct Unit Cost" := PurchCrMemoLineIn."Direct Unit Cost";
                                    VendorRebateDetails."Unit Cost" := PurchCrMemoLineIn."Unit Cost";
                                    VendorRebateDetails."Rebate Type" := VendorRebateDetails."Rebate Type"::" ";
                                    VendorRebateDetails."Rebate %" := 0;
                                    VendorRebateDetails."Rebate Per Quantity" := 0;
                                    VendorRebateDetails.Amount := -1 * PurchCrMemoLineIn.Amount;
                                    VendorRebateDetails."Amount Including VAT" := -1 * PurchCrMemoLineIn."Amount Including VAT";
                                    VendorRebateDetails."Purchaser Code" := PurchCrMemoHeaderIn."Purchaser Code";
                                    VendorRebateDetails."Responsibility Center" := PurchCrMemoLineIn."Responsibility Center";
                                    VendorRebateDetails."Location Code" := PurchCrMemoLineIn."Location Code";
                                    VendorRebateDetails."Shortcut Dimension 1 Code" := PurchCrMemoLineIn."Shortcut Dimension 1 Code";
                                    VendorRebateDetails."Shortcut Dimension 2 Code" := PurchCrMemoLineIn."Shortcut Dimension 2 Code";
                                    VendorRebateDetails.State := PurchCrMemoHeaderIn."Ship-to County";
                                    VendorRebateDetails."Buy-from Vendor No." := PurchCrMemoHeaderIn."Buy-from Vendor No.";
                                    VendorRebateDetails."Pay-to Vendor No." := PurchCrMemoHeaderIn."Pay-to Vendor No.";
                                    PurchCrMemoLineIn.GetReturnShptLines(TempReturnShipmentLine);
                                    IF TempReturnShipmentLine.FindFirst() THEN BEGIN
                                        VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::"Return Shipment";
                                        VendorRebateDetails."Applies-to Doc. No." := TempReturnShipmentLine."Document No.";
                                        VendorRebateDetails."Applies-to Doc. Line No." := TempReturnShipmentLine."Line No.";
                                    END ELSE BEGIN
                                        VendorRebateDetails."Applies-to Doc. Type" := VendorRebateDetails."Applies-to Doc. Type"::"Credit Memo";
                                        VendorRebateDetails."Applies-to Doc. No." := PurchCrMemoLineIn."Document No.";
                                        VendorRebateDetails."Applies-to Doc. Line No." := PurchCrMemoLineIn."Line No.";
                                    END;
                                end;
                        end;
                        // Calculate and Vendor Rebate Amount
                        VendorRebateDetails."Rebate Item Category Code" := TempRebateCategoryLines."Rebate Category Code";
                        VendorRebateDetails."Rebate Program Code" := TempRebateCategoryLines."Rebate Program Code";
                        GetRebateCategoryCode(VendorRebateDetails);
                        GetPurchaseRebateDetails(VendorRebateDetails);
                        CalculateRebateAmount(VendorRebateDetails);
                        VendorRebateDetails."Calculated Line Rebate Amount" := VendorRebateDetails."Vendor Rebate Amount";
                        VendorRebateDetails.Exclude := false;
                        VendorRebateDetails.BatchID := GlobalBatchID;
                        VendorRebateDetails."Batch Entry No." := GlobalBatchEntryNo;
                        VendorRebateDetails."AQD Use Rebate Setup From" := TempRebateCategoryLines."AQD Use Rebate Setup From";
                        VendorRebateDetails."AQD Rebate Posting Type" := TempRebateCategoryLines."AQD Rebate Posting Type";
                        VendorRebateDetails.Insert();
                    END;
                Until (TempRebateCategoryLines.Next() = 0);
            END;
        END;
    END;

    local procedure GetBatchID(DocumentPostingDate: Date): Code[50];
    var
        LocalVendorRebateBatch: Record "AQD Vendor Rebate Batch";
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

        LocalVendorRebateBatch.RESET;
        LocalVendorRebateBatch.SetRange(BatchID, LocalBatchID);
        IF LocalVendorRebateBatch.FindFirst() THEN
            GlobalBatchEntryNo := LocalVendorRebateBatch."Entry No.";
        exit(LocalBatchID);
    end;

    local procedure GetRebateCategoryCode(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalGLAccount: Record "G/L Account";
        LocalFixesAsset: Record "Fixed Asset";
        LocalItemCharge: Record "Item Charge";
    begin
        case VendorRebateDetails.Type OF
            VendorRebateDetails.Type::Item:
                begin
                    IF LocalItem.GET(VendorRebateDetailsLocIn."No.") then
                        VendorRebateDetailsLocIn."Rebate Item Category Code" := LocalItem."AQD Rebate Category Code";
                end;
            VendorRebateDetails.Type::Resource:
                begin
                    IF LocalResource.GET(VendorRebateDetailsLocIn."No.") then
                        VendorRebateDetailsLocIn."Rebate Item Category Code" := LocalResource."AQD Rebate Category Code";
                end;
            VendorRebateDetails.Type::"G/L Account":
                begin
                    IF LocalGLAccount.GET(VendorRebateDetailsLocIn."No.") then
                        VendorRebateDetailsLocIn."Rebate Item Category Code" := LocalGLAccount."AQD Rebate Category Code";
                end;
            VendorRebateDetails.Type::"Fixed Asset":
                begin
                    IF LocalFixesAsset.GET(VendorRebateDetailsLocIn."No.") then
                        VendorRebateDetailsLocIn."Rebate Item Category Code" := LocalFixesAsset."AQD Rebate Category Code";
                end;
            VendorRebateDetails.Type::"Charge (Item)":
                begin
                    IF LocalItemCharge.GET(VendorRebateDetailsLocIn."No.") then
                        VendorRebateDetailsLocIn."Rebate Item Category Code" := LocalItemCharge."AQD Rebate Category Code";
                end;
        end;
    end;

    local procedure GetPurchaseRebateDetails(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalFixedAsset: Record "Fixed Asset";
        LocalGLAccount: Record "G/L Account";
        LocalItemCharge: Record "Item Charge";
        LocalVendor: Record Vendor;
        PurchRebateCalcMgt: Codeunit "AQD Purch Rebate Calc. Mgt.";
        VendRebateCategoryCode: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeGetSalesRebateDetail(VendorRebateDetailsLocIn, IsHandled);
        IF IsHandled THEN
            EXIT;

        PurchRebateCalcMgt.FindPurchLineRebate(VendorRebateDetailsLocIn);

        OnAfterGetSalesRebateDetail(VendorRebateDetailsLocIn);
    end;

    local procedure CalculateRebateAmount(var VendorRebateDetailsIn: Record "AQD Vendor Rebate Details")
    begin
        case VendorRebateDetailsIn."Rebate Type" of
            VendorRebateDetailsIn."Rebate Type"::"Per Quantity":
                begin
                    VendorRebateDetailsIn."Vendor Rebate Amount" := Round(VendorRebateDetailsIn."Rebate Per Quantity" * VendorRebateDetailsIn.Quantity, 0.01);
                    VendorRebateDetailsIn."Rebate %" := 0;
                end;
            VendorRebateDetailsIn."Rebate Type"::Percentage:
                begin
                    VendorRebateDetailsIn."Vendor Rebate Amount" := Round((VendorRebateDetailsIn."Rebate %" / 100) * VendorRebateDetailsIn.Amount, 0.01);
                    VendorRebateDetailsIn."Rebate Per Quantity" := 0;
                end;
            else
                VendorRebateDetailsIn."Vendor Rebate Amount" := Round(VendorRebateDetailsIn."Rebate Per Quantity" * VendorRebateDetailsIn.Quantity, 0.01);
        end;
    end;

    local procedure IsPayRebateOnlyOnPaidInvoices(): Boolean
    begin
        Case RebateSetup."Pay Vendor Rebate On" of
            RebateSetup."Pay Vendor Rebate On"::"All Invoices":
                exit(false);
            RebateSetup."Pay Vendor Rebate On"::"Fully Paid Invoices":
                exit(true);
        End;
    END;

    local procedure "=====Events====="()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyInvoiceLineFilter(PurchaseInvHeader: Record "Purch. Inv. Header"; var PurchaseInvLine: Record "Purch. Inv. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalcReceiptReturnShipmentRebate(var RebateItemLdgrEntryIn: Record "AQD Rebate Item Ledger Entry"; VendorIn: Record Vendor; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyCreditMemoLineFilter(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateRebateAmount(var RebateEntry: Record "AQD Rebate Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRebateAmount(var RebateEntry: Record "AQD Rebate Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalculatingInvoiceRebate(PurchaseInvHeader: Record "Purch. Inv. Header"; Vendor: Record Vendor; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalculatingCrMemoRebate(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; Vendor: Record Vendor; Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateDocEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; var RebateDocEntry: Record "AQD Rebate Document Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateDocEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; var RebateDocEntry: Record "AQD Rebate Document Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; DocumentLineNo: Integer; var RebateEntry: Record "AQD Rebate Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; DocumentNo: Code[20]; DocumentLineNo: Integer; var RebateEntry: Record "AQD Rebate Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type: Enum "Purchase Line Type";
                                                                              DocumentLine_No:
                Code[20]; var IsRebatable: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateJournalLine(var RebateJnlLine: Record "AQD Rebate Journal Line"; RebateDocEntry: Record "AQD Rebate Document Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateJournalLine(var RebateJnlLine: Record "AQD Rebate Journal Line"; RebateDocEntry: Record "AQD Rebate Document Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; PurchInvHeader: Record "Purch. Inv. Header"; PurchInvLine: Record "Purch. Inv. Line"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var IsHandled: Boolean)
    begin
    end;

    local procedure OnBeforeInitRebateEntryFromRebateItemLdgrEntry(var RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindRebateRate(SourceDocType: Option "Posted Invoice","Posted Credit Memo"; PurchaseInvHeader: Record "Purch. Inv. Header"; PurchaseInvLine: Record "Purch. Inv. Line"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitInvoiceRebateEntries(var RebateEntry: Record "AQD Rebate Entry"; SalesInvoiceLine: Record "Sales Invoice Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitCreditMemoRebateEntries(var RebateEntry: Record "AQD Rebate Entry"; SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesRebateDetail(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesRebateDetail(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details")
    begin
    end;
}

