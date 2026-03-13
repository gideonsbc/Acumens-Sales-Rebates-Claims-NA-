codeunit 14302512 "AQD CustRbtMgt EventsFunctions"
{

    trigger OnRun()
    begin
    end;

    var
        RebateSingleInstance: Codeunit "AQD CustRbtClaim SngleInstance";
        CalledFromRebate: Boolean;
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure Tab15_GLAccount_OnBeforeInsert(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebate Enabled" := RebateSetup."G/L Account Rebate Enabled";
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table27_Item_OnBeforeInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebate Enabled" := RebateSetup."Item Rebate Enabled";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInitRecord, '', FALSE, FALSE)]
    local procedure Tab36_SalesHeader_OnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
        //SalesHeader."AQD Customer Rebate Order Date" := SalesHeader."Order Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Bill-to Customer No.", FALSE, FALSE)]
    local procedure Tab36_SalesHeader_BillToCustomerNo_OnAfterValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        IF Customer.GET(Rec."Bill-to Customer No.") THEN BEGIN
            CASE Customer."AQD CustRbt Calculation Date" OF
                Customer."AQD CustRbt Calculation Date"::"Rebate Order Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Order Date";
                Customer."AQD CustRbt Calculation Date"::"Shipment Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Posting Date";
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Order Date", FALSE, FALSE)]
    local procedure Tab36_SalesHeader_OrderDate_OnAfterValidateEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    BEGIN
        IF Customer.GET(Rec."Bill-to Customer No.") THEN BEGIN
            CASE Customer."AQD CustRbt Calculation Date" OF
                Customer."AQD CustRbt Calculation Date"::"Rebate Order Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Order Date";
                Customer."AQD CustRbt Calculation Date"::"Shipment Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Posting Date";
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Posting Date", FALSE, FALSE)]
    local procedure Tab36_SalesHeader_PostingDate_OnAfterValidateEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    BEGIN
        IF Customer.GET(Rec."Bill-to Customer No.") THEN BEGIN
            CASE Customer."AQD CustRbt Calculation Date" OF
                Customer."AQD CustRbt Calculation Date"::"Rebate Order Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Order Date";
                Customer."AQD CustRbt Calculation Date"::"Shipment Date":
                    Rec."AQD Customer Rebate Order Date" := Rec."Posting Date";
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table156_Resource_OnBeforeInsert(var Rec: Record Resource; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebate Enabled" := RebateSetup."Resource Rebate Enabled";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeLookupName', '', true, false)]
    local procedure Cod230_GenJnlManagement_OnBeforeLookupName(var GenJnlBatch: Record "Gen. Journal Batch")
    begin
        // To Show Rebate Batch From Rebate Purchase / Payment Journal
        RebateSingleInstance.GetCalledFromRebate(CalledFromRebate);
        GenJnlBatch.FilterGroup(2);
        GenJnlBatch.SetRange(GenJnlBatch."AQD Customer Rebate", CalledFromRebate);
        GenJnlBatch.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure Cod80_SalesPost_OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        BillToCustomer: Record Customer;
        Item: Record Item;
        GLAccount: Record "G/L Account";
        Resource: Record Resource;
        SalesLine: Record "Sales Line";
        RebateEnabled: Boolean;
        CustomerRebateSetupDoesNotExist: Label 'Customer Rebate Setup does not exist. Please set up and try again.';
        CustomerRebateDefaultValuesMissing: Label 'Customer Rebate Setup default values are missing. Please update the setup and try again.';
        CustomerRebateCardDefaultValuesMissing: Label 'Customer Card %1 - %2 is missing. Please update the setup and try again.';
    BEGIN
        IF SalesHeader.IsTemporary THEN
            EXIT;

        IF BillToCustomer.GET(SalesHeader."Bill-To Customer No.") THEN
            IF NOT BillToCustomer."AQD Enroll for Cust Rebate" THEN
                EXIT;

        SalesLine.RESET;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETFILTER(Type, '%1|%2|%3',
            SalesLine.Type::Item,
            SalesLine.Type::"G/L Account",
            SalesLine.Type::Resource);
        SalesLine.SETFILTER("No.", '<>%1', '');
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        IF NOT SalesLine.FINDFIRST THEN
            EXIT;

        REPEAT
            CASE SalesLine.Type OF
                SalesLine.Type::Item:
                    BEGIN
                        IF Item.GET(SalesLine."No.") THEN
                            RebateEnabled := Item."AQD Customer Rebate Enabled";
                    END;
                SalesLine.Type::Resource:
                    BEGIN
                        IF Resource.GET(SalesLine."No.") THEN
                            RebateEnabled := Resource."AQD Customer Rebate Enabled";
                    END;
                SalesLine.Type::"G/L Account":
                    BEGIN
                        IF GLAccount.GET(SalesLine."No.") THEN
                            RebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                    END;
            END;
        UNTIL (SalesLine.NEXT = 0) OR RebateEnabled;

        IF NOT RebateEnabled THEN
            EXIT;

        IF NOT CustomerRebateSetup.GET THEN
            Error(CustomerRebateSetupDoesNotExist);

        //IF CustomerRebateSetup."Customer Rebate Document Nos" = '' THEN
        //    Error(CustomerRebateDefaultValuesMissing);

        //IF BillToCustomer."AQD Cust Rebate Customer No." = '' THEN
        //    Error(CustomerRebateCardDefaultValuesMissing, BillToCustomer."No.", BillToCustomer."AQD Cust Rebate Customer No.");

        CustomerRebateSetup.TestField("Customer Rebate Document Nos");
        CustomerRebateSetup.TESTFIELD("Sales Journal Template Name");
        CustomerRebateSetup.TESTFIELD("Sales Journal Batch Name");
        CustomerRebateSetup.TESTFIELD("Customer Rebate Start Date");
        BillToCustomer.TestField("AQD Cust Rebate Customer No.");
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesShptHeaderInsert, '', false, false)]
    local procedure Cod80_SalesPost_OnBeforeSalesShptHeaderInsert(var SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; WhseShip: Boolean; InvtPickPutaway: Boolean)
    var
        BillToCustomer: Record Customer;
    BEGIN
        IF BillToCustomer.GET(SalesShptHeader."Bill-to Customer No.") THEN
            SalesShptHeader."AQD Comm Territory Code" := BillToCustomer."Territory Code";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesInvHeaderInsert, '', false, false)]
    local procedure Cod80_SalesPost_CommOnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; WhseShip: Boolean; WhseShptHeader: Record "Warehouse Shipment Header"; InvtPickPutaway: Boolean)
    var
        BillToCustomer: Record Customer;
    BEGIN
        IF BillToCustomer.GET(SalesInvHeader."Bill-to Customer No.") THEN
            SalesInvHeader."AQD CR Territory Code" := BillToCustomer."Territory Code";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesCrMemoHeaderInsert, '', false, false)]
    local procedure Cod80_SalesPost_OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesInvHeader: Record "Sales Invoice Header")
    var
        BillToCustomer: Record Customer;
    BEGIN
        IF BillToCustomer.GET(SalesInvHeader."Bill-to Customer No.") THEN
            SalesCrMemoHeader."AQD CR Territory Code" := BillToCustomer."Territory Code";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeReturnRcptHeaderInsert, '', false, false)]
    local procedure Cod80_SalesPost_OnBeforeReturnRcptHeaderInsert(var ReturnRcptHeader: Record "Return Receipt Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; WhseShip: Boolean)
    var
        BillToCustomer: Record Customer;
    BEGIN
        IF BillToCustomer.GET(ReturnRcptHeader."Bill-to Customer No.") THEN
            ReturnRcptHeader."AQD Comm Territory Code" := BillToCustomer."Territory Code";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure Cod80_SalesPost_OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        CustRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        SourceCodeSetup: Record "Source Code Setup";
        SalesShptHdr: Record "Sales Shipment Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesReturnRcpt: Record "Return Receipt Header";
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
        GenerateCustomerRebate: Report "AQD Generate Customer Rebates";
        ShptRcptNo: Code[20];
        InvCrMemoNo: Code[20];
        SourceCode: Code[20];
        BillToCustomerNo: Code[20];
        IsHandled: Boolean;
        ExitFunction: Boolean;
    begin
        IF PreviewMode THEN
            EXIT;

        SourceCodeSetup.GET;
        IF SalesHeader."AQD Customer Rebate" THEN
            EXIT;

        IF NOT CustRebateSetup.GET THEN
            EXIT;

        IF NOT CustRebateSetup."Auto Process Customer Rebates" THEN
            EXIT;

        ExitFunction := FALSE;

        IF (SalesInvHdrNo = '') AND (SalesCrMemoHdrNo = '') THEN
            ExitFunction := TRUE;

        IF ExitFunction THEN
            EXIT;

        IF SalesShptHdrNo <> '' THEN BEGIN
            ShptRcptNo := SalesShptHdrNo;
            IF SalesShptHdr.GET(SalesShptHdrNo) THEN BEGIN
                IF SalesShptHdr."Source Code" = SourceCodeSetup."Deleted Document" THEN
                    EXIT;
                BillToCustomerNo := SalesShptHdr."Bill-to Customer No.";
            END;
        END;

        IF RetRcpHdrNo <> '' then BEGIN
            ShptRcptNo := RetRcpHdrNo;
            IF SalesReturnRcpt.GET(RetRcpHdrNo) THEN BEGIN
                IF SalesReturnRcpt."Source Code" = SourceCodeSetup."Deleted Document" THEN
                    EXIT;
                BillToCustomerNo := SalesReturnRcpt."Bill-to Customer No.";
            END;
        END;

        IF SalesInvHdrNo <> '' then BEGIN
            InvCrMemoNo := SalesInvHdrNo;
            IF SalesInvHdr.GET(SalesInvHdrNo) THEN BEGIN
                IF SalesInvHdr."Source Code" = SourceCodeSetup."Deleted Document" THEN
                    EXIT;
                BillToCustomerNo := SalesInvHdr."Bill-to Customer No.";
            END;
        END;

        if SalesCrMemoHdrNo <> '' then BEGIN
            InvCrMemoNo := SalesCrMemoHdrNo;
            IF SalesCrMemoHdr.GET(SalesCrMemoHdrNo) THEN BEGIN
                IF SalesCrMemoHdr."Source Code" = SourceCodeSetup."Deleted Document" THEN
                    EXIT;
                BillToCustomerNo := SalesCrMemoHdr."Bill-to Customer No.";
            END;
        END;

        IsHandled := false;
        OnBeforeGenerateRealTimeCustomerRebate(SalesHeader, SalesShptHdrNo, RetRcpHdrNo, SalesInvHdrNo, SalesCrMemoHdrNo, PreviewMode, IsHandled);
        IF IsHandled then
            exit;

        CLEAR(GenerateCustomerRebate);
        GenerateCustomerRebate.SetShptRcptNoAndInvCrMemoNo(BillToCustomerNo, ShptRcptNo, InvCrMemoNo, TRUE);
        GenerateCustomerRebate.UseRequestPage(false);
        GenerateCustomerRebate.Run();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterInitValueEntry, '', FALSE, FALSE)]
    local procedure Cod22_ItemJnlPostLine_OnAfterInitValueEntry(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line"; var ValueEntryNo: Integer; var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        ValueEntry."AQD Customer Rebate" := ItemJournalLine."AQD Customer Rebate Journal";
        IF NOT ItemJournalLine."AQD Customer Rebate Journal" THEN
            EXIT;

        IF ItemLedgEntry."Entry Type" <> ItemLedgEntry."Entry Type"::Purchase THEN
            EXIT;

        IF ValueEntry."Item Charge No." = '' THEN
            EXIT;

        IF ItemLedgEntry.Quantity >= 0 THEN
            EXIT;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Cost Element Buffer", OnAfterExcludeEntryFromAvgCostCalc, '', false, false)]
    local procedure Tab5820_CostElementBuffer_OnAfterExcludeEntryFromAvgCostCalc(var CostElementBuffer: Record "Cost Element Buffer"; ValueEntry: Record "Value Entry")
    begin
        IF ValueEntry."Item Charge No." = '' THEN
            EXIT;

        IF NOT ValueEntry."AQD Customer Rebate" THEN
            EXIT;

        IF ValueEntry."Valued Quantity" >= 0 THEN
            EXIT;

        CostElementBuffer."Remaining Quantity" := CostElementBuffer."Remaining Quantity" +
                                                  ValueEntry."Item Ledger Entry Quantity";
        CostElementBuffer."Actual Cost" := CostElementBuffer."Actual Cost" +
                                           ValueEntry."Cost Amount (Actual)" +
                                           ValueEntry."Cost Amount (Expected)";
        CostElementBuffer."Actual Cost (ACY)" := CostElementBuffer."Actual Cost (ACY)" +
                                                 ValueEntry."Cost Amount (Actual) (ACY)" +
                                                 ValueEntry."Cost Amount (Expected) (ACY)";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cost Element Buffer", OnAfterExcludeBufFromAvgCostCalc, '', false, false)]
    local procedure Tab5820_CostElementBuffer_OnAfterExcludeBufFromAvgCostCalc(var CostElementBuffer: Record "Cost Element Buffer"; InvtAdjmtBuffer: Record "Inventory Adjustment Buffer")
    var
        ExcludedValueEntry: Record "Value Entry";
    begin
        IF NOT ExcludedValueEntry.GET(InvtAdjmtBuffer."Entry No.") THEN
            EXIT;

        IF ExcludedValueEntry."Item Charge No." = '' THEN
            EXIT;

        IF NOT ExcludedValueEntry."AQD Customer Rebate" THEN
            EXIT;

        IF ExcludedValueEntry."Valued Quantity" >= 0 THEN // To allow only Sales Return Entries
            EXIT;

        CostElementBuffer."Remaining Quantity" := CostElementBuffer."Remaining Quantity" +
                                                  InvtAdjmtBuffer."Item Ledger Entry Quantity";
        CostElementBuffer."Actual Cost" := CostElementBuffer."Actual Cost" +
                                           InvtAdjmtBuffer."Cost Amount (Actual)" +
                                           InvtAdjmtBuffer."Cost Amount (Expected)";
        CostElementBuffer."Actual Cost (ACY)" := CostElementBuffer."Actual Cost (ACY)" +
                                                 InvtAdjmtBuffer."Cost Amount (Actual) (ACY)" +
                                                 InvtAdjmtBuffer."Cost Amount (Expected) (ACY)";
    end;

    procedure ShowPostedDocument(DocumentType: Enum "AQD Cust Rebate Document Type"; DocumentNo: COde[20])
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedSalesCrMemo: Record "Sales Cr.Memo Header";
        PostedSalesShptHeader: Record "Sales Shipment Header";
        PostedReturnRcptHeader: Record "Return Receipt Header";
        PostedSalesInvoicePage: Page "Posted Sales Invoice";
        PostedSalesCrMemoPage: Page "Posted Sales Credit Memo";
        PostedSalesShptPage: Page "Posted Sales Shipment";
        PostedReturnRcptPage: Page "Posted Return Receipt";
    begin
        CASE DocumentType of
            DocumentType::Invoice:
                begin
                    PostedSalesInvoice.GET(DocumentNo);

                    clear(PostedSalesInvoicePage);
                    PostedSalesInvoicePage.SetRecord(PostedSalesInvoice);
                    PostedSalesInvoicePage.Run();
                end;
            DocumentType::"Credit Memo":
                begin
                    PostedSalesCrMemo.GET(DocumentNo);

                    clear(PostedSalesCrMemoPage);
                    PostedSalesCrMemoPage.SetRecord(PostedSalesCrMemo);
                    PostedSalesCrMemoPage.Run();
                end;
            DocumentType::Shipment:
                begin
                    PostedSalesShptHeader.GET(DocumentNo);

                    clear(PostedSalesShptPage);
                    PostedSalesShptPage.SetRecord(PostedSalesShptHeader);
                    PostedSalesShptPage.Run();
                end;
            DocumentType::"Return Receipt":
                begin
                    PostedReturnRcptHeader.GET(DocumentNo);

                    clear(PostedReturnRcptPage);
                    PostedReturnRcptPage.SetRecord(PostedReturnRcptHeader);
                    PostedReturnRcptPage.Run();
                end;
        END;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGenerateRealTimeCustomerRebate(var SalesHeader: Record "Sales Header"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; PreviewMode: Boolean; var IsHandled: Boolean)
    BEGIN
    END;
}