codeunit 14302611 "AQD Cust Claim Event And Func"
{
    trigger OnRun()
    begin

    end;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        BillToCustomer: Record Customer;
        SalesLine: Record "Sales Line";
        CustomerClaimVendor: Record "AQD Customer Claim Vendors";
        PaymentMethod: Record "Payment Method";
        ClaimLine: Record "AQD Customer Claim Line";
        SupplementaryInvoice: Record "Sales Header";
        SupplementaryInvoiceLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ClaimManagement: Codeunit "AQD Customer Claim Management";
        ClaimSingleInstance: Codeunit "AQD CustRbtClaim SngleInstance";
        CalledFromSalesOrderPosting: Boolean;
        NextLineNo: Integer;
        TotalClaimAmount: Decimal;
        ClaimIsNotApprovedError: Label 'Order cannot be posted as Claim is not approved yet.';
        BlankClaimVendorNoError: Label '%1 must not be blank.';

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", OnBeforeInsertEvent, '', FALSE, FALSE)]
    local procedure Tab15_GLAccount_OnBeforeInsertEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    BEGIN
        IF Rec.IsTemporary THEN
            EXIT;

        IF ClaimSetup.GET THEN
            Rec."AQM Customer Claim Enabled" := ClaimSetup."Item Claim Enabled";
    END;

    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeInsertEvent, '', FALSE, FALSE)]
    local procedure Tab27_Item_OnBeforeInsertEvent(var Rec: Record Item; RunTrigger: Boolean)
    BEGIN
        IF Rec.IsTemporary THEN
            EXIT;

        IF ClaimSetup.GET THEN
            Rec."AQM Customer Claim Enabled" := ClaimSetup."Item Claim Enabled";
    END;

    [EventSubscriber(ObjectType::Table, Database::Resource, OnBeforeInsertEvent, '', FALSE, FALSE)]
    local procedure Tab156_Resource_OnBeforeInsertEvent(var Rec: Record Resource; RunTrigger: Boolean)
    BEGIN
        IF Rec.IsTemporary THEN
            EXIT;

        IF ClaimSetup.GET THEN
            Rec."AQM Customer Claim Enabled" := ClaimSetup."Item Claim Enabled";
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, 'Bill-To Customer No.', FALSE, FALSE)]
    local procedure Tab36_SalesHeader_BillToCustomerNo_OnAfterValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    BEGIN
        IF Rec.ISTEMPORARY THEN
            EXIT;

        ClaimSetup.GET;

        IF Rec."Bill-to Customer No." <> xRec."Bill-to Customer No." THEN BEGIN
            IF BillToCustomer.GET(Rec."Bill-to Customer No.") THEN BEGIN
                Rec."AQD CustClaim Claim Type" := BillToCustomer."AQD Default Claim Type";

                IF Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Full Price" THEN BEGIN
                    CustomerClaimVendor.RESET;
                    CustomerClaimVendor.SetRange("Bill-to Customer No.", Rec."Bill-to Customer No.");
                    CustomerClaimVendor.SETRANGE("Claim Type", Rec."AQD CustClaim Claim Type");
                    IF CustomerClaimVendor.FINDFIRST THEN
                        Rec.VALIDATE("AQD Claim Vendor No.", CustomerClaimVendor."Vendor No.");

                    ClaimSetup.TestField("Full Price Default Pyt Method");
                    PaymentMethod.GET(ClaimSetup."Full Price Default Pyt Method");
                    PaymentMethod.TestField("Bal. Account No.");
                    Rec.VALIDATE("Payment Method Code", ClaimSetup."Full Price Default Pyt Method");
                END;
            END;
        END;
    END;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, 'AQD Claim Type', FALSE, FALSE)]
    // local procedure Tab36_SalesHeader_AQDClaimType_OnAfterValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    // BEGIN
    //     IF Rec.ISTEMPORARY THEN
    //         EXIT;

    //     ClaimSetup.GET;

    //     IF (Rec."AQD Claim Type" <> xRec."AQD Claim Type") THEN BEGIN
    //         IF CurrFieldNo = Rec.FIELDNO("AQD Claim Type") THEN BEGIN
    //             CASE Rec."AQD Claim Type" OF
    //                 Rec."AQD Claim Type"::"Full Price":
    //                     BEGIN
    //                         ClaimSetup.TestField("Full Price Default Pyt Method");
    //                         PaymentMethod.GET(ClaimSetup."Full Price Default Pyt Method");
    //                         PaymentMethod.TestField("Bal. Account No.");
    //                         IF Rec."Payment Method Code" <> ClaimSetup."Full Price Default Pyt Method" THEN
    //                             Rec.VALIDATE("Payment Method Code", ClaimSetup."Full Price Default Pyt Method");

    //                         CustomerClaimVendor.RESET;
    //                         CustomerClaimVendor.SetRange("Bill-to Customer No.", Rec."Bill-to Customer No.");
    //                         CustomerClaimVendor.SETRANGE("Claim Type", Rec."AQD Claim Type");
    //                         IF CustomerClaimVendor.FINDFIRST THEN
    //                             Rec.VALIDATE("AQD Claim Vendor No.", CustomerClaimVendor."Vendor No.");
    //                     END;
    //                 Rec."AQD Claim Type"::"Price Match":
    //                     BEGIN

    //                     END;
    //             END;
    //         END;
    //     END;
    // END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeModifySalesDoc, '', FALSE, FALSE)]
    local procedure Cod414_ReleaseSalesDOcument_OnBeforeModifySalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    BEGIN
        IF PreviewMode THEN
            EXIT;

        IF SalesHeader.ISTEMPORARY THEN
            EXIT;

        IF SalesHeader."AQD CustClaim Claim Type" = SalesHeader."AQD CustClaim Claim Type"::" " THEN
            EXIT;

        ClaimSetup.GET;

        Case SalesHeader."AQD CustClaim Claim Type" OF
            SalesHeader."AQD CustClaim Claim Type"::"Full Price":
                BEGIN
                    IF ClaimSetup."Create Claim On" = ClaimSetup."Create Claim On"::"Order Release" THEN
                        CreateClaimFromSalesOrder(SalesHeader, FALSE, FALSE, TRUE);
                END;
            SalesHeader."AQD CustClaim Claim Type"::"Price Match":
                BEGIN
                END;
        END;
    END;

    procedure CreateClaimFromSalesOrder(var SalesHeader: Record "Sales Header"; AskUserConfirmation: Boolean; ShowResult: Boolean; RecreateClaimIn: Boolean)
    var
        UserConfirmMsg: Label 'Do you want to create Claim?';
    BEGIN
        SalesHeader.TESTFIELD("AQD CustClaim Claim Type", SalesHeader."AQD CustClaim Claim Type"::"Full Price");

        IF AskUserConfirmation THEN
            IF NOT CONFIRM(UserConfirmMsg) THEN
                EXIT;

        ClaimSetup.GET;
        Case SalesHeader."AQD CustClaim Claim Type" OF
            SalesHeader."AQD CustClaim Claim Type"::"Full Price":
                BEGIN
                    IF SalesHeader."AQD Claim Vendor No." = '' THEN
                        ERROR(BlankClaimVendorNoError, SalesHeader.FieldCaption("AQD Claim Vendor No."));

                    CLEAR(ClaimManagement);
                    ClaimManagement.SetCreateFullPriceClaimsParameters(SalesHeader, TRUE, RecreateClaimIn, ShowResult);
                    ClaimManagement.RUN;
                END;
            SalesHeader."AQD CustClaim Claim Type"::"Price Match":
                BEGIN
                END;
        End;
    END;

    procedure CreateClaimFromPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; AskUserConfirmation: Boolean; ShowResult: Boolean; RecreateClaimIn: Boolean)
    var
        UserConfirmMsg: Label 'Do you want to create Claim?';
    BEGIN
        SalesInvoiceHeader.TESTFIELD("AQD CustClaim Claim Type", SalesInvoiceHeader."AQD CustClaim Claim Type"::"Price Match");

        IF AskUserConfirmation THEN
            IF NOT CONFIRM(UserConfirmMsg) THEN
                EXIT;

        ClaimSetup.GET;
        Case SalesInvoiceHeader."AQD CustClaim Claim Type" OF
            SalesInvoiceHeader."AQD CustClaim Claim Type"::"Price Match":
                BEGIN
                    CLEAR(ClaimManagement);
                    ClaimManagement.SetCreatePriceMatchClaimsParameters(SalesInvoiceHeader, TRUE, RecreateClaimIn, ShowResult);
                    ClaimManagement.RUN;
                END;
        End;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', FALSE, FALSE)]
    local procedure Cod80_SalesPost_OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        ClaimHeader: Record "AQD Customer Claim Header";
        ClaimMandatoryFieldsLbl: Label 'Please define %1 for Sales %2 %3 Line No. %4.';
    BEGIN
        IF PreviewMode THEN
            EXIT;

        IF SalesHeader.ISTEMPORARY THEN
            EXIT;

        IF NOT ClaimSetup.GET THEN
            EXIT;

        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) THEN BEGIN
            Case SalesHeader."AQD CustClaim Claim Type" OF
                SalesHeader."AQD CustClaim Claim Type"::"Full Price":
                    BEGIN
                        SalesHeader.TESTFIELD("Payment Method Code");
                        PaymentMethod.GET(SalesHeader."Payment Method Code");
                        PaymentMethod.TESTFIELD("Bal. Account No.");

                        IF ClaimSetup.AllowToPostOrdAfterClaimApprov THEN BEGIN
                            ClaimHeader.RESET;
                            ClaimHeader.SetRange("Order No.", SalesHeader."No.");
                            ClaimHeader.SetRange("Claim Approved", FALSE);
                            IF ClaimHeader.FindFirst() THEN
                                ERROR(ClaimIsNotApprovedError);
                        END;
                    END;
                SalesHeader."AQD CustClaim Claim Type"::"Price Match":
                    BEGIN
                        IF (ClaimSetup."Price Match ClaimProgCode Mand") OR
                           (ClaimSetup."Price Match ClaimServCode Mand")
                        THEN BEGIN
                            SalesLine.RESET;
                            SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                            SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                            SalesLine.SETFILTER(Type, '%1|%2|%3',
                                SalesLine.Type::Item,
                                SalesLine.Type::Resource,
                                SalesLine.Type::"G/L Account");
                            SalesLine.SetFilter("No.", '<>%1', '');
                            SalesLine.SetFilter(Quantity, '<>%1', 0);
                            IF SalesLine.FindFirst() THEN BEGIN
                                REPEAT
                                    IF (ClaimSetup."Price Match ClaimProgCode Mand") AND
                                       (SalesLine."AQD CustClaim Program Code" = '')
                                    THEN
                                        Error(ClaimMandatoryFieldsLbl,
                                            SalesLine.FieldCaption("AQD CustClaim Program Code"),
                                            SalesLine."Document Type",
                                            SalesLine."Document No.",
                                            SalesLine."Line No.");

                                    IF (ClaimSetup."Price Match ClaimServCode Mand") AND
                                       (SalesLine."AQD CustClaim Service Code" = '')
                                    THEN
                                        Error(ClaimMandatoryFieldsLbl,
                                            SalesLine.FieldCaption("AQD CustClaim Service Code"),
                                            SalesLine."Document Type",
                                            SalesLine."Document No.",
                                            SalesLine."Line No.")
                                UNTIL SalesLine.Next() = 0;
                            END;
                        END;
                    End;
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterFinalizePostingOnBeforeCommit, '', FALSE, FALSE)]
    local procedure Cod80_SalesPost_OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var CommitIsSuppressed: Boolean; var PreviewMode: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var EverythingInvoiced: Boolean)
    var
        ClaimHeader: Record "AQD Customer Claim Header";
    BEGIN
        IF PreviewMode THEN
            EXIT;

        IF SalesHeader.ISTEMPORARY THEN
            EXIT;

        IF NOT ClaimSetup.GET then
            EXIT;

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
            CASE SalesHeader."AQD CustClaim Claim Type" OF
                SalesHeader."AQD CustClaim Claim Type"::"Full Price":
                    BEGIN
                        IF EverythingInvoiced THEN BEGIN
                            ClaimHeader.RESET;
                            ClaimHeader.SETRANGE("Order No.", SalesHeader."No.");
                            IF ClaimHeader.FindFirst() THEN BEGIN
                                REPEAT
                                    ClaimHeader.Status := ClaimHeader.Status::"Order Posted";
                                    ClaimHeader."Posted Invoice No." := SalesInvoiceHeader."No.";
                                    ClaimHeader.Modify();
                                UNTIL ClaimHeader.Next() = 0;
                            END;
                        END;
                    END;
                SalesHeader."AQD CustClaim Claim Type"::"Price Match":
                    BEGIN
                        // IF (SalesInvoiceHeader."No." <> '') AND
                        //    (ClaimSetup."Price Match Create Claim On" = ClaimSetup."Price Match Create Claim On"::"Order Invoicing")
                        // THEN BEGIN
                        //     CLEAR(ClaimManagement);
                        //     ClaimManagement.SetCreatePriceMatchClaimsParameters(SalesInvoiceHeader, TRUE, FALSE, FALSE);
                        //     ClaimManagement.RUN;
                        // END;
                    END;

            END;
        END ELSE IF SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice THEN BEGIN
            IF (SalesHeader."AQD CustClaim Claim Type" = SalesHeader."AQD CustClaim Claim Type"::"Price Match") AND
               (SalesHeader."AQD Customer Claim No." <> '') AND
               (SalesHeader."AQD CustClaim Sales Order No." <> '')
            THEN BEGIN // This check is for Supplementary Invoice
                ClaimHeader.RESET;
                ClaimHeader.SETRANGE("Supplementary Invoice No.", SalesHeader."No.");
                IF ClaimHeader.FindFirst() THEN BEGIN
                    REPEAT
                        ClaimHeader."Posted Supplementary Inv No." := SalesInvoiceHeader."No.";
                        ClaimHeader.Modify();
                    UNTIL ClaimHeader.Next() = 0;
                END;
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnFinalizePostingOnBeforeCreateOutboxSalesTrans, '', FALSE, FALSE)]
    local procedure Cod80_SalesPost_OnFinalizePostingOnBeforeCreateOutboxSalesTrans(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; EverythingInvoiced: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        ClaimHeader: Record "AQD Customer Claim Header";
        PurchaseHeader: Record "Purchase Header";
        PurchasePost: Codeunit "Purch.-Post";
    BEGIN
        IF NOT ClaimSetup.GET THEN
            EXIT;

        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) AND
           (SalesHeader."AQD CustClaim Claim Type" = SalesHeader."AQD CustClaim Claim Type"::"Full Price")
        THEN BEGIN
            IF EverythingInvoiced THEN BEGIN
                IF ClaimSetup.GET AND
                   ClaimSetup.PostCreditMemoOnOrderInvoicing
                THEN BEGIN
                    PurchaseHeader.RESET;
                    PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
                    PurchaseHeader.SETRANGE("AQD CustClaim Sales Order No.", SalesHeader."No.");
                    IF PurchaseHeader.FINDFIRST THEN BEGIN
                        ClaimSingleInstance.SetCalledFromSalesOrderPosting(TRUE);
                        REPEAT
                            PurchaseHeader.Receive := TRUE;
                            PurchaseHeader.Invoice := TRUE;
                            PurchasePost.RUN(PurchaseHeader);
                        UNTIL PurchaseHeader.Next() = 0;
                        ClaimSingleInstance.SetCalledFromSalesOrderPosting(FALSE);
                    END;
                END;
            END;
        END;
        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) AND
           (SalesHeader."AQD CustClaim Claim Type" = SalesHeader."AQD CustClaim Claim Type"::"Price Match")
        THEN BEGIN
            IF (SalesInvoiceHeader."No." <> '') AND
               (ClaimSetup."Price Match Create Claim On" = ClaimSetup."Price Match Create Claim On"::"Order Invoicing")
            THEN BEGIN
                CLEAR(ClaimManagement);
                ClaimManagement.SetCreatePriceMatchClaimsParameters(SalesInvoiceHeader, TRUE, FALSE, FALSE);
                ClaimManagement.RUN;
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', FALSE, FALSE)]
    local procedure Cod90_PurchPost_OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    var
        CalledFromSalesOrderPosting: Boolean;
    BEGIN
        ClaimSingleInstance.GetCalledFromSalesOrderPosting(CalledFromSalesOrderPosting);
        IF CalledFromSalesOrderPosting THEN
            HideProgressWindow := TRUE;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterFinalizePostingOnBeforeCommit, '', FALSE, FALSE)]
    local procedure Cod90_PurchPost_OnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean; EverythingInvoiced: Boolean)
    var
        ClaimHeader: Record "AQD Customer Claim Header";
        SupplementaryInvoice: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    BEGIN
        IF PurchHeader."Document Type" = PurchHeader."Document Type"::"Credit Memo" THEN BEGIN
            IF EverythingInvoiced THEN BEGIN
                IF PurchHeader."AQD CustClaim Claim Type" = PurchHeader."AQD CustClaim Claim Type"::"Price Match" THEN BEGIN
                    SupplementaryInvoice.RESET;
                    SupplementaryInvoice.SETRANGE("Document Type", SupplementaryInvoice."Document Type"::Invoice);
                    SupplementaryInvoice.SetRange("AQD CustClaim Claim Type", PurchHeader."AQD CustClaim Claim Type");
                    SupplementaryInvoice.SetRange("AQD Customer Claim No.", PurchHeader."AQD Customer Claim No.");
                    SupplementaryInvoice.SetRange("AQD CustClaim Sales Order No.", PurchHeader."AQD CustClaim Sales Order No.");
                    IF SupplementaryInvoice.FindFirst() THEN BEGIN
                        SupplementaryInvoice.Ship := TRUE;
                        SupplementaryInvoice.Invoice := TRUE;
                        SalesPost.RUN(SupplementaryInvoice);
                    END;
                END;

                ClaimHeader.RESET;
                ClaimHeader.SETRANGE("Purchase Credit Memo No.", PurchHeader."No.");
                IF ClaimHeader.FindFirst() THEN BEGIN
                    REPEAT
                        ClaimHeader.Status := ClaimHeader.Status::"Credit Posted";
                        ClaimHeader."Posted Purch Credit Memo No." := PurchCrMemoHdr."No.";
                        ClaimHeader.Modify();
                    UNTIL ClaimHeader.Next() = 0;
                END;
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnCopySalesDocOnBeforeUpdateSalesInvoiceDiscountValue, '', FALSE, FALSE)]
    local procedure Cod6620_CopyDocumentMgt_OnCopySalesDocOnBeforeUpdateSalesInvoiceDiscountValue(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20]; FromDocOccurrenceNo: Integer; FromDocVersionNo: Integer; RecalculateLines: Boolean)
    BEGIN
        ToSalesHeader."AQD Vendor Cr. Memo No." := '';
        ToSalesHeader."AQD Claim Approved Amount" := 0;
        ToSalesHeader."AQD Claim Delivery Commission" := 0;
        ToSalesHeader."AQD Claim Purchase Discount" := 0;
        ToSalesHeader.Modify();
    END;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeInitInsert, '', FALSE, FALSE)]
    local procedure Tab38_PurchaseHeader_OnBeforeInitInsert(var PurchaseHeader: Record "Purchase Header"; var xPurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        PurchaseHeader2: Record "Purchase Header";
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        ClaimSetup.GET;
        IF PurchaseHeader."AQD CustClaim Claim Type" = PurchaseHeader."AQD CustClaim Claim Type"::" " THEN
            EXIT;

        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Credit Memo" THEN
            EXIT;

        IF PurchaseHeader."No." = '' THEN BEGIN
            ClaimSetup.TESTFIELD("Claim Purchase Cr Memo Nos.");
            NoSeriesCode := ClaimSetup."Claim Purchase Cr Memo Nos.";
            PurchaseHeader."No. Series" := NoSeriesCode;
            IF NoSeries.AreRelated(PurchaseHeader."No. Series", xPurchaseHeader."No. Series") THEN
                PurchaseHeader."No. Series" := xPurchaseHeader."No. Series";
            PurchaseHeader."No." := NoSeries.GetNextNo(PurchaseHeader."No. Series", PurchaseHeader."Posting Date");
            PurchaseHeader2.ReadIsolation(IsolationLevel::ReadUncommitted);
            PurchaseHeader2.SetLoadFields("No.");
            while PurchaseHeader2.Get(PurchaseHeader."Document Type", PurchaseHeader."No.") do
                PurchaseHeader."No." := NoSeries.GetNextNo(PurchaseHeader."No. Series", PurchaseHeader."Posting Date");
            IsHandled := PurchaseHeader."No." <> '';
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeInitInsert, '', FALSE, FALSE)]
    local procedure Tab36_SalesHeader_OnBeforeInitInsert(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        SalesHeader2: Record "Sales Header";
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        IF NOT ClaimSetup.GET THEN
            EXIT;

        IF SalesHeader."AQD CustClaim Claim Type" <> SalesHeader."AQD CustClaim Claim Type"::"Price Match" THEN
            EXIT;

        IF SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice THEN
            EXIT;

        IF SalesHeader."No." = '' THEN BEGIN
            ClaimSetup.TESTFIELD("Supplementary Invoice Nos.");
            NoSeriesCode := ClaimSetup."Supplementary Invoice Nos.";
            SalesHeader."No. Series" := NoSeriesCode;
            IF NoSeries.AreRelated(SalesHeader."No. Series", xSalesHeader."No. Series") THEN
                SalesHeader."No. Series" := xSalesHeader."No. Series";
            SalesHeader."No." := NoSeries.GetNextNo(SalesHeader."No. Series", SalesHeader."Posting Date");
            SalesHeader2.ReadIsolation(IsolationLevel::ReadUncommitted);
            SalesHeader2.SetLoadFields("No.");
            while SalesHeader2.Get(SalesHeader."Document Type", SalesHeader."No.") do
                SalesHeader."No." := NoSeries.GetNextNo(SalesHeader."No. Series", SalesHeader."Posting Date");
            IsHandled := SalesHeader."No." <> '';
        END;
    END;

    procedure CreatePurchCrMemoForFullPriceClaim(var SalesHeader: Record "Sales Header"; var ClaimHeader: Record "AQD Customer Claim Header"; ShowMessage: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        LocalSalesLine: Record "Sales Line";
        ClaimLine: Record "AQD Customer Claim Line";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        SalesOrderIsRelease: Boolean;
        VarianceAmount: Decimal;
        CrTotal: Decimal;
        LineNo: Integer;
        ClaimCreditMemoMsg: Label 'Purchase Credit Memo %1 has created for $%2.';
        GLAccountSetupError: Label '%1 is not setup in Claim Setup. Please setup %1 in Claim Setup. ';
    BEGIN
        ClaimSetup.GET;

        IF SalesHeader."No." <> '' THEN BEGIN // This means it is not deleted.
            IF SalesHeader.ISTEMPORARY THEN
                EXIT;

            IF (SalesHeader."AQD CustClaim Claim Type" = SalesHeader."AQD CustClaim Claim Type"::"Full Price") AND
               (SalesHeader."AQD Claim Approved Amount" <> 0)
            THEN BEGIN
                IF SalesHeader."AQD Claim Vendor No." = '' THEN
                    ERROR(BlankClaimVendorNoError, SalesHeader.FIELDCAPTION("AQD Claim Vendor No."));

                IF SalesHeader.Status <> SalesHeader.Status::Open THEN BEGIN
                    ReleaseSalesDocument.Reopen(SalesHeader);
                    SalesOrderIsRelease := TRUE;
                END;

                LocalSalesLine.RESET;
                LocalSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                LocalSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                LocalSalesLine.SETRANGE("AQD Customer Claim Line", TRUE);
                LocalSalesLine.DELETEALL;

                SalesHeader.CALCFIELDS("Amount Including VAT");

                LocalSalesLine.RESET;
                LocalSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                LocalSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                IF LocalSalesLine.FINDLAST THEN
                    LineNo := LocalSalesLine."Line No." + 10000
                ELSE
                    LineNo := 10000;

                // Create Commission Amount Line
                IF SalesHeader."AQD Claim Delivery Commission" <> 0 THEN BEGIN
                    IF ClaimSetup."Claim Delivery Commission Acct" = '' THEN
                        Error(GLAccountSetupError, ClaimSetup.FieldCaption("Claim Delivery Commission Acct"));

                    LocalSalesLine.INIT;
                    LocalSalesLine.SetHideValidationDialog(TRUE);
                    LocalSalesLine."Document Type" := SalesHeader."Document Type";
                    LocalSalesLine."Document No." := SalesHeader."No.";
                    LineNo := LineNo + 10000;
                    LocalSalesLine."Line No." := LineNo;
                    LocalSalesLine.Type := LocalSalesLine.Type::"G/L Account";
                    LocalSalesLine.VALIDATE("No.", ClaimSetup."Claim Delivery Commission Acct");
                    LocalSalesLine.VALIDATE("Unit Price", SalesHeader."AQD Claim Delivery Commission");
                    LocalSalesLine.VALIDATE(Quantity, 1);
                    LocalSalesLine.VALIDATE("Qty. to Ship", 1);
                    LocalSalesLine."AQD Customer Claim Line" := TRUE;
                    LocalSalesLine."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                    LocalSalesLine."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                    LocalSalesLine."Dimension Set ID" := SalesHeader."Dimension Set ID";
                    LocalSalesLine."AQD Customer Claim Line" := TRUE;
                    LocalSalesLine.INSERT;
                END;

                ClaimLine.RESET;
                ClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
                ClaimLine.SetRange("Manual Line", FALSE);
                IF ClaimLine.FindFirst() THEN BEGIN
                    REPEAT
                        IF LocalSalesLine.GET(LocalSalesLine."Document Type"::Order,
                            ClaimLine."Order No.",
                            ClaimLine."Order Line No.")
                        THEN BEGIN
                            IF (ClaimLine."Approved Unit Price" <> 0) AND
                               (ClaimLine."Unit Price" <> ClaimLine."Approved Unit Price")
                            THEN BEGIN
                                LocalSalesLine.SetHideValidationDialog(true);
                                LocalSalesLine.Validate("Unit Price", ClaimLine."Approved Unit Price");
                                LocalSalesLine.Modify(TRUE);
                            END;
                        END;
                    UNTIL ClaimLine.Next() = 0;
                END;

                ClaimLine.RESET;
                ClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
                ClaimLine.SetRange("Manual Line", TRUE);
                IF ClaimLine.FindFirst() THEN BEGIN
                    REPEAT
                        LocalSalesLine.INIT;
                        LocalSalesLine.SetHideValidationDialog(TRUE);
                        LocalSalesLine."Document Type" := SalesHeader."Document Type";
                        LocalSalesLine."Document No." := SalesHeader."No.";
                        LineNo := LineNo + 10000;
                        LocalSalesLine."Line No." := LineNo;
                        LocalSalesLine.VALIDATE(Type, ClaimLine.Type);
                        LocalSalesLine.VALIDATE("No.", ClaimLine."No.");
                        LocalSalesLine.VALIDATE("Unit Price", ClaimLine."Unit Price");
                        LocalSalesLine.VALIDATE(Quantity, ClaimLine.Quantity);
                        LocalSalesLine.VALIDATE("Qty. to Ship", ClaimLine.Quantity);
                        LocalSalesLine."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                        LocalSalesLine."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                        LocalSalesLine."Dimension Set ID" := SalesHeader."Dimension Set ID";
                        LocalSalesLine."AQD Customer Claim Line" := TRUE;
                        LocalSalesLine."AQD CustClaim Manual Line" := TRUE;
                        LocalSalesLine.INSERT;
                    UNTIL ClaimLine.NEXT = 0;
                END;

                SalesHeader.CALCFIELDS(Amount);
                VarianceAmount := 0;
                VarianceAmount := SalesHeader."AQD Claim Approved Amount" - SalesHeader.Amount;

                IF VarianceAmount <> 0 THEN BEGIN
                    IF ClaimSetup."Claim Variance G/L Account" = '' THEN
                        Error(GLAccountSetupError, ClaimSetup.FieldCaption("Claim Variance G/L Account"));

                    LocalSalesLine.INIT;
                    LocalSalesLine.SetHideValidationDialog(TRUE);
                    LocalSalesLine."Document Type" := SalesHeader."Document Type";
                    LocalSalesLine."Document No." := SalesHeader."No.";
                    LineNo := LineNo + 10000;
                    LocalSalesLine."Line No." := LineNo;
                    LocalSalesLine.Type := LocalSalesLine.Type::"G/L Account";
                    LocalSalesLine.VALIDATE("No.", ClaimSetup."Claim Variance G/L Account");
                    LocalSalesLine.VALIDATE("Unit Price", VarianceAmount);
                    LocalSalesLine.VALIDATE(Quantity, 1);
                    LocalSalesLine.VALIDATE("Qty. to Ship", 1);
                    LocalSalesLine."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                    LocalSalesLine."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                    LocalSalesLine."Dimension Set ID" := SalesHeader."Dimension Set ID";
                    LocalSalesLine."AQD Customer Claim Line" := TRUE;
                    LocalSalesLine.INSERT;
                END;

                IF SalesOrderIsRelease THEN
                    ReleaseSalesDocument.PerformManualRelease(SalesHeader);
            END;

            // To Create Purchase Cr. Memo
            PurchHeader.RESET;
            PurchHeader.SETCURRENTKEY("Document Type", "No.");
            PurchHeader.SETRANGE("Document Type", PurchHeader."Document Type"::"Credit Memo");
            PurchHeader.SETRANGE("AQD CustClaim Sales Order No.", ClaimHeader."Order No.");
            IF PurchHeader.FINDFIRST THEN BEGIN
                CLEAR(ReleasePurchaseDocument);
                IF PurchHeader.Status <> PurchHeader.Status::Open THEN
                    ReleasePurchaseDocument.Reopen(PurchHeader);

                PurchLine.RESET;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine.DELETEALL;

                PurchHeader.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
                PurchHeader.VALIDATE("Document Date", ClaimHeader."Document Date");
                PurchHeader."Vendor Cr. Memo No." := ClaimHeader."Vendor Cr. Memo No.";
                PurchHeader.MODIFY;
            END ELSE BEGIN
                PurchHeader.INIT;
                PurchHeader."Document Type" := PurchHeader."Document Type"::"Credit Memo";
                PurchHeader."AQD CustClaim Claim Type" := PurchHeader."AQD CustClaim Claim Type"::"Full Price";
                PurchHeader."No." := '';
                PurchHeader.INSERT(TRUE);
                PurchHeader.VALIDATE("Buy-from Vendor No.", ClaimHeader."Vendor No.");
                PurchHeader.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
                PurchHeader.VALIDATE("Document Date", ClaimHeader."Document Date");
                PurchHeader."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
                PurchHeader."Posting Description" := ClaimHeader."Order No.";
                PurchHeader."Vendor Cr. Memo No." := ClaimHeader."Vendor Cr. Memo No.";
                PurchHeader."AQD Claim Sell-to Cust No." := ClaimHeader."Sell-to Customer No.";
                PurchHeader."AQD Claim Bill-to Cust No." := ClaimHeader."Bill-to Customer No.";
                PurchHeader."AQD CustClaim Claim Type" := PurchHeader."AQD CustClaim Claim Type"::"Full Price";
                PurchHeader.MODIFY;
            END;
            PurchHeader.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
            PurchHeader.VALIDATE("Location Code", ClaimHeader."Location Code");
            PurchHeader.VALIDATE("Shortcut Dimension 1 Code", ClaimHeader."Shortcut Dimension 1 Code");
            PurchHeader.VALIDATE("Shortcut Dimension 2 Code", ClaimHeader."Shortcut Dimension 2 Code");
            PurchHeader."Dimension Set ID" := ClaimHeader."Dimension Set ID";
            PurchHeader."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
            PurchHeader."AQD Customer Claim No." := ClaimHeader."No.";
            PurchHeader.MODIFY;

            ClaimHeader."Purchase Credit Memo No." := PurchHeader."No.";
            ClaimHeader.Modify();

            // Create Purch. Cr. Memo Lines
            CrTotal := ClaimHeader."Amount Approved" - ABS(ClaimHeader."Purchase Discount");

            IF CrTotal <> 0 THEN BEGIN
                IF ClaimSetup."Full Price Claims G/L Account" = '' THEN
                    Error(GLAccountSetupError, ClaimSetup.FieldCaption("Full Price Claims G/L Account"));

                LineNo := LineNo + 10000;
                PurchLine.INIT;
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;
                PurchLine.INSERT(TRUE);
                PurchLine.Type := PurchLine.Type::"G/L Account";
                PurchLine.VALIDATE("No.", ClaimSetup."Full Price Claims G/L Account");
                PurchLine.VALIDATE("Direct Unit Cost", ClaimHeader."Amount Approved");
                PurchLine.VALIDATE(Quantity, 1);
                PurchLine.VALIDATE("Shortcut Dimension 1 Code", PurchHeader."Shortcut Dimension 1 Code");
                PurchLine.VALIDATE("Shortcut Dimension 2 Code", PurchHeader."Shortcut Dimension 2 Code");
                PurchLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
                PurchLine."AQD Claim Sell-to Cust No." := ClaimHeader."Sell-to Customer No.";
                PurchLine."AQD Claim Bill-to Cust No." := ClaimHeader."Bill-to Customer No.";
                PurchLine."AQD Customer Claim Code" := ClaimHeader."Order No.";
                PurchLine.MODIFY(TRUE);
            END;

            IF ClaimHeader."Purchase Discount" <> 0 THEN BEGIN
                IF ClaimSetup."Claim Discount G/L Account" = '' THEN
                    Error(GLAccountSetupError, ClaimSetup.FieldCaption("Claim Discount G/L Account"));

                LineNo := LineNo + 10000;
                PurchLine.INIT;
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;
                PurchLine.INSERT(TRUE);
                PurchLine.Type := PurchLine.Type::"G/L Account";
                PurchLine.VALIDATE("No.", ClaimSetup."Claim Discount G/L Account");
                PurchLine.VALIDATE("Direct Unit Cost", ClaimHeader."Purchase Discount");
                PurchLine.VALIDATE(Quantity, 1);
                PurchLine.VALIDATE("Shortcut Dimension 1 Code", PurchHeader."Shortcut Dimension 1 Code");
                PurchLine.VALIDATE("Shortcut Dimension 2 Code", PurchHeader."Shortcut Dimension 2 Code");
                PurchLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
                PurchLine."AQD Claim Sell-to Cust No." := ClaimHeader."Sell-to Customer No.";
                PurchLine."AQD Claim Bill-to Cust No." := ClaimHeader."Bill-to Customer No.";
                PurchLine."AQD Customer Claim Code" := ClaimHeader."Order No.";
                PurchLine.MODIFY(TRUE);
            END;

            PurchHeader.CALCFIELDS(Amount);
            IF PurchHeader.Amount <> 0 THEN
                IF GUIALLOWED AND ShowMessage THEN
                    MESSAGE(ClaimCreditMemoMsg, PurchHeader."No.", PurchHeader.Amount);
        END;
    END;

    procedure CreatePurchCrMemoForPriceMatchClaim(var ClaimHeader: Record "AQD Customer Claim Header"; ShowMessage: Boolean)
    var
        ClaimApprovalError: Label '%1 must not be zero to approve Claim.';
        ClaimApprovalBlankError: Label '%1 must not be blank to approve Claim.';
        ClaimCreditMemoMsg: Label 'Purchase Credit Memo %1 has created for $%2.';
        NextLineNo: Integer;
        ClaimAmountExclDelComm: Decimal;
        ApprovedAmountExclDelComm: Decimal;
    BEGIN
        IF ClaimHeader."Claim Type" <> ClaimHeader."Claim Type"::"Price Match" THEN
            EXIT;

        IF NOT ClaimHeader."Claim Approved" THEN
            EXIT;

        ClaimSetup.GET;
        ClaimSetup.TESTFIELD("Price Match Claims G/L Account");
        ClaimSetup.TESTFIELD("PriceMatch ClmCostDiff G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Claim Disc G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Claim DelComm Acct");
        ClaimSetup.TESTFIELD("Price Match Claim Vari G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Default Pyt Method");

        ClaimHeader.TESTFIELD("Claim Rejected", FALSE);
        IF ClaimHeader."Vendor Cr. Memo No." = '' THEN
            ERROR(ClaimApprovalBlankError, ClaimHeader.FieldCaption("Vendor Cr. Memo No."));
        IF ClaimHeader."Vendor Cr. Memo Date" = 0D THEN
            ERROR(ClaimApprovalBlankError, ClaimHeader.FieldCaption("Vendor Cr. Memo Date"));
        IF ClaimHeader."Amount Approved" = 0 THEN
            ERROR(ClaimApprovalError, ClaimHeader.FieldCaption("Amount Approved"));

        ClaimAmountExclDelComm := 0;
        ApprovedAmountExclDelComm := 0;

        ClaimLine.RESET;
        ClaimLine.SETRANGE("Claim Type", ClaimHeader."Claim Type");
        ClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
        IF ClaimLine.FINDFIRST THEN BEGIN
            CreateSupplementaryInvoiceHeader(ClaimHeader);
            CreatePurchaseCreditMemoHeader(ClaimHeader);
            REPEAT
                CreateSupplementaryInvoiceLine(ClaimLine);
                CreatePurchaseCreditMemoLine(ClaimLine);
                IF (ClaimLine."Claim Line Type" = ClaimLine."Claim Line Type"::"Cost of Good Sold") AND
                   (ClaimLine."Claim Line")
                THEN BEGIN
                    ClaimAmountExclDelComm += ClaimLine.Amount;
                    ApprovedAmountExclDelComm += ClaimLine."Approved Amount";
                END;
            UNTIL ClaimLine.Next() = 0;

            IF ClaimHeader."Purchase Discount" <> 0 THEN
                CreateDiscountPurchaseCreditMemoLine(ClaimHeader, ClaimLine);

            SupplementaryInvoice.CalcFields(Amount);
            IF ClaimAmountExclDelComm <> ApprovedAmountExclDelComm THEN
                CreateVarianceSupplementaryInvoiceLine(ClaimLine, ClaimAmountExclDelComm - ApprovedAmountExclDelComm);

            PurchHeader.CALCFIELDS(Amount);
            IF PurchHeader.Amount <> 0 THEN
                IF GUIALLOWED AND ShowMessage THEN
                    MESSAGE(ClaimCreditMemoMsg, PurchHeader."No.", PurchHeader.Amount);

            // PurchHeader.CalcFields(Amount);
            // PurchaseLine.RESET;
            // PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
            // PurchaseLine.SetRange("Document No.", PurchHeader."No.");
            // IF PurchaseLine.FindFirst() THEN BEGIN
            //     REPEAT
            //         IF PurchaseLine."AQD Claim Line Type" <> PurchaseLine."AQD Claim Line Type"::Discount THEN
            //             PurchaseAmount += PurchaseLine.Amount;
            //     UNTIL PurchaseLine.NEXT = 0;
            // END;
            //IF PurchaseAmount <> ClaimHeader."Claim Amount" THEN
            //    CreateVariancePurchaseCreditMemoLine(ClaimLine, ClaimHeader."Claim Amount" - PurchaseAmount);
        END;
    END;

    local procedure CreatePurchaseCreditMemoHeader(var ClaimHeader: Record "AQD Customer Claim Header")
    begin
        PurchHeader.RESET;
        PurchHeader.SETRANGE("Document Type", PurchHeader."Document Type"::"Credit Memo");
        PurchHeader.SETRANGE("AQD CustClaim Sales Order No.", ClaimHeader."Order No.");
        PurchHeader.SETRANGE("Buy-from Vendor No.", ClaimHeader."Vendor No.");
        PurchHeader.SetRange("AQD Customer Claim No.", ClaimHeader."No.");
        IF PurchHeader.FINDFIRST THEN BEGIN
            PurchaseLine.RESET;
            PurchaseLine.SETRANGE("Document Type", PurchHeader."Document Type");
            PurchaseLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchaseLine.DELETEALL;

            PurchHeader.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
            PurchHeader.VALIDATE("Document Date", ClaimHeader."Posting Date");
            PurchHeader."Vendor Authorization No." := ClaimHeader."Order No.";
            PurchHeader."Vendor Cr. Memo No." := ClaimHeader."Vendor Cr. Memo No.";
            PurchHeader."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
            PurchHeader."AQD Claim Bill-to Cust No." := ClaimHeader."Bill-to Customer No.";
            PurchHeader."AQD Claim Sell-to Cust No." := ClaimHeader."Sell-to Customer No.";
            PurchHeader."AQD Customer Claim No." := ClaimHeader."No.";
            PurchHeader."AQD CustRbt LinkToSupplInvoice" := TRUE;
            PurchHeader."Posting Description" := ClaimHeader."Order No.";
            PurchHeader.VALIDATE("Location Code", ClaimHeader."Location Code");
            PurchHeader.VALIDATE("Shortcut Dimension 1 Code", ClaimHeader."Shortcut Dimension 1 Code");
            PurchHeader.VALIDATE("Shortcut Dimension 2 Code", ClaimHeader."Shortcut Dimension 2 Code");
            PurchHeader."Dimension Set ID" := ClaimHeader."Dimension Set ID";
            PurchHeader."AQD CustClaim Claim Type" := PurchHeader."AQD CustClaim Claim Type"::"Price Match";
            PurchHeader.MODIFY;

            ClaimHeader."Purchase Credit Memo No." := PurchHeader."No.";
            ClaimHeader.Modify;
        END ELSE BEGIN
            // Create Purch. Cr. Memo Header
            CLEAR(PurchHeader);
            PurchHeader.INIT;
            PurchHeader."Document Type" := PurchHeader."Document Type"::"Credit Memo";
            PurchHeader."AQD CustClaim Claim Type" := PurchHeader."AQD CustClaim Claim Type"::"Price Match";
            PurchHeader."No." := '';
            PurchHeader.INSERT(TRUE);
            PurchHeader.VALIDATE("Buy-from Vendor No.", ClaimHeader."Vendor No.");
            PurchHeader.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
            PurchHeader.VALIDATE("Document Date", ClaimHeader."Posting Date");
            PurchHeader."Vendor Authorization No." := ClaimHeader."Order No.";
            PurchHeader."Vendor Cr. Memo No." := ClaimHeader."Vendor Cr. Memo No.";
            PurchHeader.VALIDATE("Location Code", ClaimHeader."Location Code");
            PurchHeader.VALIDATE("Shortcut Dimension 1 Code", ClaimHeader."Shortcut Dimension 1 Code");
            PurchHeader.VALIDATE("Shortcut Dimension 2 Code", ClaimHeader."Shortcut Dimension 2 Code");
            PurchHeader."Dimension Set ID" := ClaimHeader."Dimension Set ID";
            PurchHeader."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
            PurchHeader."AQD Customer Claim No." := ClaimHeader."No.";
            PurchHeader."AQD Claim Sell-to Cust No." := ClaimHeader."Sell-to Customer No.";
            PurchHeader."AQD Claim Bill-to Cust No." := ClaimHeader."Bill-to Customer No.";
            PurchHeader."AQD CustRbt LinkToSupplInvoice" := TRUE;
            PurchHeader."Posting Description" := ClaimHeader."Order No.";
            PurchHeader."AQD CustClaim Claim Type" := PurchHeader."AQD CustClaim Claim Type"::"Price Match";
            PurchHeader.MODIFY;

            ClaimHeader."Purchase Credit Memo No." := PurchHeader."No.";
            ClaimHeader.Modify;
        END;
    END;

    local procedure CreatePurchaseCreditMemoLine(ClaimLine: Record "AQD Customer Claim Line")
    var
        DeliveryCommissionLbl: Label 'Delivery Commission';
        PurchaseDiscountLbl: Label 'Purchase Discount';
    BEGIN
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchHeader."No.");
        IF PurchaseLine.FINDLAST THEN
            NextLineNo := PurchaseLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        PurchaseLine.INIT;
        PurchaseLine."Document Type" := PurchHeader."Document Type";
        PurchaseLine."Document No." := PurchHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.VALIDATE("No.", ClaimSetup."Price Match Claims G/L Account");
        PurchaseLine.Description := ClaimLine.Description;
        PurchaseLine.VALIDATE("Direct Unit Cost", ClaimLine."Approved Unit Price");
        PurchaseLine.VALIDATE(Quantity, ClaimLine.Quantity);
        PurchaseLine."Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
        PurchaseLine."Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
        PurchaseLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
        PurchaseLine."AQD Claim Sell-to Cust No." := ClaimLine."Sell-to Customer No.";
        PurchaseLine."AQD Claim Bill-to Cust No." := ClaimLine."Bill-to Customer No.";
        PurchaseLine."AQD Customer Claim Code" := ClaimLine."Document No.";
        PurchaseLine."AQD CustClaim Orig Order No." := ClaimLine."Order No.";
        PurchaseLine."AQD CustClaim Orig OdrLine No." := ClaimLine."Order Line No.";
        PurchaseLine."AQD CustClaim Claim No." := ClaimLine."Document No.";
        PurchaseLine."AQD CustClaim Claim Line No." := ClaimLine."Line No.";
        PurchaseLine."AQD Claim Line Type" := ClaimLine."Claim Line Type";
        PurchaseLine.INSERT(TRUE);
    END;

    local procedure CreateDiscountPurchaseCreditMemoLine(ClaimHeader: Record "AQD Customer Claim Header"; ClaimLine: Record "AQD Customer Claim Line")
    var
        PurchaseDiscountLbl: Label 'Purchase Discount';
    BEGIN
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchHeader."No.");
        IF PurchaseLine.FINDLAST THEN
            NextLineNo := PurchaseLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        PurchaseLine.INIT;
        PurchaseLine."Document Type" := PurchHeader."Document Type";
        PurchaseLine."Document No." := PurchHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.VALIDATE("No.", ClaimSetup."Price Match Claim Disc G/LAcct");
        PurchaseLine.Description := PurchaseDiscountLbl;
        PurchaseLine.VALIDATE("Direct Unit Cost", ClaimHeader."Purchase Discount"); // It should -ve input.
        PurchaseLine.VALIDATE(Quantity, 1);
        PurchaseLine."Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
        PurchaseLine."Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
        PurchaseLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
        PurchaseLine."AQD Claim Sell-to Cust No." := ClaimLine."Sell-to Customer No.";
        PurchaseLine."AQD Claim Bill-to Cust No." := ClaimLine."Bill-to Customer No.";
        PurchaseLine."AQD Customer Claim Code" := ClaimLine."Document No.";
        PurchaseLine."AQD CustClaim Orig Order No." := ClaimLine."Order No.";
        PurchaseLine."AQD CustClaim Orig OdrLine No." := 0;
        PurchaseLine."AQD CustClaim Claim No." := ClaimLine."Document No.";
        PurchaseLine."AQD CustClaim Claim Line No." := 0;
        PurchaseLine."AQD Claim Line Type" := PurchaseLine."AQD Claim Line Type"::Discount;
        PurchaseLine.INSERT(TRUE);
    END;

    // local procedure CreateVariancePurchaseCreditMemoLine(ClaimLine: Record "AQD Customer Claim Line"; VarianceAmount: Decimal)
    // var
    //     ClaimVarianceLbl: Label 'Claim Variance';
    // BEGIN
    //     PurchaseLine.RESET;
    //     PurchaseLine.SETRANGE("Document Type", PurchHeader."Document Type");
    //     PurchaseLine.SETRANGE("Document No.", PurchHeader."No.");
    //     IF PurchaseLine.FINDLAST THEN
    //         NextLineNo := PurchaseLine."Line No." + 10000
    //     ELSE
    //         NextLineNo := 10000;

    //     PurchaseLine.INIT;
    //     PurchaseLine."Document Type" := PurchHeader."Document Type";
    //     PurchaseLine."Document No." := PurchHeader."No.";
    //     PurchaseLine."Line No." := NextLineNo;
    //     PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
    //     PurchaseLine.VALIDATE("No.", ClaimSetup."Price Match Claim Vari G/LAcct");
    //     PurchaseLine.VALIDATE("Direct Unit Cost", VarianceAmount);
    //     PurchaseLine.VALIDATE(Quantity, 1);
    //     PurchaseLine.Description := ClaimVarianceLbl;
    //     PurchaseLine."Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
    //     PurchaseLine."Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
    //     PurchaseLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
    //     PurchaseLine."AQD Claim Sell-to Cust No." := ClaimLine."Sell-to Customer No.";
    //     PurchaseLine."AQD Claim Bill-to Cust No." := ClaimLine."Bill-to Customer No.";
    //     PurchaseLine."AQD Customer Claim Code" := ClaimLine."Document No.";
    //     PurchaseLine."AQD CustClaim Orig Order No." := '';
    //     PurchaseLine."AQD CustClaim Orig OdrLine No." := 0;
    //     PurchaseLine."AQD CustClaim Claim No." := ClaimLine."Document No.";
    //     PurchaseLine."AQD CustClaim Claim Line No." := 0;
    //     PurchaseLine."AQD Claim Line Type" := PurchaseLine."AQD Claim Line Type"::Variance;
    //     PurchaseLine.INSERT(TRUE);
    // END;

    local procedure CreateSupplementaryInvoiceHeader(var ClaimHeader: Record "AQD Customer Claim Header")
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        SupplementaryInvoice.RESET;
        SupplementaryInvoice.SETRANGE("Document Type", SupplementaryInvoice."Document Type"::Invoice);
        SupplementaryInvoice.SetRange("AQD CustClaim Sales Order No.", ClaimHeader."order No.");
        SupplementaryInvoice.SetRange("AQD Customer Claim No.", ClaimHeader."No.");
        SupplementaryInvoice.SetRange("AQD Claim Vendor No.", ClaimHeader."Vendor No.");
        IF SupplementaryInvoice.FINDFIRST THEN BEGIN
            SupplementaryInvoiceLine.RESET;
            SupplementaryInvoiceLine.SETRANGE("Document Type", SupplementaryInvoice."Document Type");
            SupplementaryInvoiceLine.SETRANGE("Document No.", SupplementaryInvoice."No.");
            SupplementaryInvoiceLine.DELETEALL;

            SupplementaryInvoice.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
            SupplementaryInvoice.VALIDATE("Document Date", ClaimHeader."Posting Date");
            SupplementaryInvoice.VALIDATE("Tax Liable", FALSE);
            SupplementaryInvoice."Posting Description" := ClaimHeader."Order No.";
            IF (ClaimSetup."Price Match Default Pyt Method" <> '') AND
               (SupplementaryInvoice."Payment Method Code" <> ClaimSetup."Price Match Default Pyt Method")
            THEN
                SupplementaryInvoice.VALIDATE("Payment Method Code", ClaimSetup."Price Match Default Pyt Method");

            SupplementaryInvoice."AQD Claim Vendor No." := ClaimHeader."Vendor No.";
            SupplementaryInvoice."AQD Customer Claim No." := ClaimHeader."No.";
            SupplementaryInvoice."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
            SupplementaryInvoice."AQD CustClaim Purch CrMemo No." := PurchHeader."No.";
            SupplementaryInvoice."AQD CustClaim Claim Type" := SupplementaryInvoice."AQD CustClaim Claim Type"::"Price Match";
            SupplementaryInvoice.MODIFY;

            ClaimHeader."Supplementary Invoice No." := SupplementaryInvoice."No.";
            ClaimHeader.Modify();
        END ELSE BEGIN
            // Create Sales Invoice Header
            Vendor.GET(ClaimHeader."Vendor No.");
            Customer.GET(Vendor."AQD Claim From Customer No.");

            SupplementaryInvoice.INIT;
            SupplementaryInvoice.SetHideValidationDialog(TRUE);
            SupplementaryInvoice."Document Type" := SupplementaryInvoice."Document Type"::Invoice;
            SupplementaryInvoice."AQD CustClaim Claim Type" := SupplementaryInvoice."AQD CustClaim Claim Type"::"Price Match";
            SupplementaryInvoice."No." := '';
            SupplementaryInvoice.INSERT(TRUE);
            SupplementaryInvoice.VALIDATE("Sell-to Customer No.", ClaimHeader."Sell-to Customer No.");
            SupplementaryInvoice.VALIDATE("Bill-to Customer No.", Customer."No.");
            SupplementaryInvoice.VALIDATE("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
            SupplementaryInvoice.VALIDATE("Document Date", ClaimHeader."Posting Date");
            SupplementaryInvoice.VALIDATE("Location Code", ClaimHeader."Location Code");
            SupplementaryInvoice.VALIDATE("Shortcut Dimension 1 Code", ClaimHeader."Shortcut Dimension 1 Code");
            SupplementaryInvoice.VALIDATE("Shortcut Dimension 2 Code", ClaimHeader."Shortcut Dimension 2 Code");
            SupplementaryInvoice."Dimension Set ID" := ClaimHeader."Dimension Set ID";
            SupplementaryInvoice.VALIDATE("Tax Liable", FALSE);
            SupplementaryInvoice."Posting Description" := ClaimHeader."Order No.";
            IF SupplementaryInvoice."Payment Method Code" <> ClaimSetup."Price Match Default Pyt Method" THEN
                SupplementaryInvoice.VALIDATE("Payment Method Code", ClaimSetup."Price Match Default Pyt Method");
            SupplementaryInvoice."Ship-to Code" := ClaimHeader."Ship-to Code";
            SupplementaryInvoice."Ship-to Name" := ClaimHeader."Ship-to Name";
            SupplementaryInvoice."Ship-to Name 2" := ClaimHeader."Ship-to Name 2";
            SupplementaryInvoice."Ship-to Address" := ClaimHeader."Ship-to Address";
            SupplementaryInvoice."Ship-to Address 2" := ClaimHeader."Ship-to Address 2";
            SupplementaryInvoice."Ship-to City" := ClaimHeader."Ship-to City";
            SupplementaryInvoice."Ship-to Post Code" := ClaimHeader."Ship-to Post Code";
            SupplementaryInvoice."Ship-to Contact" := ClaimHeader."Ship-to Contact";
            SupplementaryInvoice."Ship-to County" := ClaimHeader."Ship-to County";
            SupplementaryInvoice."Ship-to Country/Region Code" := ClaimHeader."Ship-to Country/Region Code";
            SupplementaryInvoice."External Document No." := ClaimHeader."No.";

            SupplementaryInvoice."AQD Customer Claim No." := ClaimHeader."No.";
            SupplementaryInvoice."AQD Claim Vendor No." := ClaimHeader."Vendor No.";
            SupplementaryInvoice."AQD CustClaim Sales Order No." := ClaimHeader."Order No.";
            SupplementaryInvoice."AQD CustClaim Purch CrMemo No." := PurchHeader."No.";
            SupplementaryInvoice."AQD CustClaim Claim Type" := SupplementaryInvoice."AQD CustClaim Claim Type"::"Price Match";
            SupplementaryInvoice.MODIFY;

            ClaimHeader."Supplementary Invoice No." := SupplementaryInvoice."No.";
            ClaimHeader.Modify();
        END;
    END;

    local procedure CreateSupplementaryInvoiceLine(ClaimLine: Record "AQD Customer Claim Line")
    BEGIN
        SupplementaryInvoiceLine.RESET;
        SupplementaryInvoiceLine.SetRange("Document Type", SupplementaryInvoice."Document Type");
        SupplementaryInvoiceLine.SetRange("Document No.", SupplementaryInvoice."No.");
        IF SupplementaryInvoiceLine.FINDLAST THEN
            NextLineNo := SupplementaryInvoiceLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        SupplementaryInvoiceLine.INIT;
        SupplementaryInvoiceLine."Document Type" := SupplementaryInvoice."Document Type";
        SupplementaryInvoiceLine."Document No." := SupplementaryInvoice."No.";
        SupplementaryInvoiceLine."Line No." := NextLineNo;
        SupplementaryInvoiceLine.Type := SupplementaryInvoiceLine.Type::"G/L Account";
        SupplementaryInvoiceLine."Shortcut Dimension 1 Code" := SupplementaryInvoice."Shortcut Dimension 1 Code";
        SupplementaryInvoiceLine."Shortcut Dimension 2 Code" := SupplementaryInvoice."Shortcut Dimension 2 Code";
        SupplementaryInvoiceLine."Dimension Set ID" := SupplementaryInvoice."Dimension Set ID";
        Case ClaimLine."Claim Line Type" OF
            ClaimLine."Claim Line Type"::"Cost of Good Sold":
                SupplementaryInvoiceLine.VALIDATE("No.", ClaimSetup."PriceMatch ClmCostDiff G/LAcct");
            ClaimLine."Claim Line Type"::"Delivery Commission":
                SupplementaryInvoiceLine.VALIDATE("No.", ClaimSetup."Price Match Claim DelComm Acct");
            ClaimLine."Claim Line Type"::Discount:
                SupplementaryInvoiceLine.VALIDATE("No.", ClaimSetup."Price Match Claim Disc G/LAcct");
        End;
        SupplementaryInvoiceLine.VALIDATE("Unit Price", ClaimLine."Approved Unit Price");
        SupplementaryInvoiceLine.VALIDATE(Quantity, ClaimLine.Quantity);
        SupplementaryInvoiceLine.Description := ClaimLine.Description;
        SupplementaryInvoiceLine."Sell-to Customer No." := ClaimLine."Sell-to Customer No.";
        SupplementaryInvoiceLine."Bill-to Customer No." := ClaimLine."Bill-to Customer No.";
        SupplementaryInvoiceLine."AQM CustClaim Mfg Product Code" := ClaimLine."Cust Claim Mfg Product Code";
        SupplementaryInvoiceLine."AQD CustClaim Program Code" := ClaimLine."Cust Claim Program Code";
        SupplementaryInvoiceLine."AQD CustClaim Service Code" := ClaimLine."Cust Claim Service Code";

        SupplementaryInvoiceLine."AQD Customer Claim Code" := ClaimLine."Document No.";
        SupplementaryInvoiceLine."AQD CustClaim Vendor No." := SupplementaryInvoice."AQD Claim Vendor No.";
        SupplementaryInvoiceLine."AQD CustClaim Orig Order No." := ClaimLine."Order No.";
        SupplementaryInvoiceLine."AQD CustClaim Orig OdrLine No." := ClaimLine."Order Line No.";
        SupplementaryInvoiceLine."AQD CustClaim Claim No." := ClaimLine."Document No.";
        SupplementaryInvoiceLine."AQD CustClaim Claim Line No." := ClaimLine."Line No.";
        SupplementaryInvoiceLine."AQD Claim Line Type" := ClaimLine."Claim Line Type";
        SupplementaryInvoiceLine.INSERT(TRUE);
        TotalClaimAmount := TotalClaimAmount + SupplementaryInvoiceLine.Amount;
    END;

    local procedure CreateVarianceSupplementaryInvoiceLine(ClaimLine: Record "AQD Customer Claim Line"; VarianceAmount: Decimal)
    var
        ClaimVarianceLbl: Label 'Claim Variance';
    BEGIN
        SupplementaryInvoiceLine.RESET;
        SupplementaryInvoiceLine.SetRange("Document Type", SupplementaryInvoice."Document Type");
        SupplementaryInvoiceLine.SetRange("Document No.", SupplementaryInvoice."No.");
        IF SupplementaryInvoiceLine.FINDLAST THEN
            NextLineNo := SupplementaryInvoiceLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        SupplementaryInvoiceLine.INIT;
        SupplementaryInvoiceLine."Document Type" := SupplementaryInvoice."Document Type";
        SupplementaryInvoiceLine."Document No." := SupplementaryInvoice."No.";
        SupplementaryInvoiceLine."Line No." := NextLineNo;
        SupplementaryInvoiceLine.Type := SupplementaryInvoiceLine.Type::"G/L Account";
        SupplementaryInvoiceLine."Shortcut Dimension 1 Code" := SupplementaryInvoice."Shortcut Dimension 1 Code";
        SupplementaryInvoiceLine."Shortcut Dimension 2 Code" := SupplementaryInvoice."Shortcut Dimension 2 Code";
        SupplementaryInvoiceLine."Dimension Set ID" := SupplementaryInvoice."Dimension Set ID";
        SupplementaryInvoiceLine.VALIDATE("No.", ClaimSetup."Price Match Claim Vari G/LAcct");
        SupplementaryInvoiceLine.VALIDATE("Unit Price", VarianceAmount);
        SupplementaryInvoiceLine.VALIDATE(Quantity, 1);
        SupplementaryInvoiceLine.Description := ClaimVarianceLbl;
        SupplementaryInvoiceLine."Sell-to Customer No." := ClaimLine."Sell-to Customer No.";
        SupplementaryInvoiceLine."Bill-to Customer No." := ClaimLine."Bill-to Customer No.";
        SupplementaryInvoiceLine."AQM CustClaim Mfg Product Code" := ClaimLine."Cust Claim Mfg Product Code";
        SupplementaryInvoiceLine."AQD CustClaim Program Code" := ClaimLine."Cust Claim Program Code";
        SupplementaryInvoiceLine."AQD CustClaim Service Code" := ClaimLine."Cust Claim Service Code";

        SupplementaryInvoiceLine."AQD Customer Claim Code" := ClaimLine."Document No.";
        SupplementaryInvoiceLine."AQD CustClaim Vendor No." := SupplementaryInvoice."AQD Claim Vendor No.";
        SupplementaryInvoiceLine."AQD CustClaim Orig Order No." := '';
        SupplementaryInvoiceLine."AQD CustClaim Orig OdrLine No." := 0;
        SupplementaryInvoiceLine."AQD CustClaim Claim No." := ClaimLine."Document No.";
        SupplementaryInvoiceLine."AQD CustClaim Claim Line No." := 0;
        SupplementaryInvoiceLine."AQD Claim Line Type" := ClaimLine."Claim Line Type"::Variance;
        SupplementaryInvoiceLine.INSERT(TRUE);
        TotalClaimAmount := TotalClaimAmount + SupplementaryInvoiceLine.Amount;
    END;

    procedure PostOrderFromClaim(var ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SourceSetup: Record "Source Code Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
        PurchPost: Codeunit "Purch.-Post";
        SalesOrderPostConfirm: Label 'Do you want to post Sales %1 %2?';
        OrderIsPostedError: Label 'Sales Order %1 is already posted.';
        OrderIsDeletedError: Label 'Sales Order %1 is deleted.';
    begin
        ClaimHeader.TestField("Claim Approved", TRUE);
        IF NOT CONFIRM(StrSubstNo(SalesOrderPostConfirm, FORMAT(SalesHeader."Document Type"::Order), ClaimHeader."Order No.")) THEN
            EXIT;

        ClaimSetup.GET;
        SourceSetup.GET;
        IF NOT SalesHeader.GET(SalesHeader."Document Type"::Order, ClaimHeader."Order No.") THEN BEGIN
            SalesInvoiceHeader.RESET;
            SalesInvoiceHeader.SETRANGE("Order No.", ClaimHeader."Order No.");
            IF SalesInvoiceHeader.FindFirst() THEN BEGIN
                IF SalesInvoiceHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Order No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Order No.");
            END;

            SalesInvoiceHeader.RESET;
            SalesInvoiceHeader.SETRANGE("Pre-Assigned No.", ClaimHeader."Order No.");
            IF SalesInvoiceHeader.FindFirst() THEN BEGIN
                IF SalesInvoiceHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Order No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Order No.");
            END;
        END;

        clear(SalesPost);
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        SalesPost.Run(SalesHeader);

        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::"Credit Memo",
            ClaimHeader."Purchase Credit Memo No.")
        THEN BEGIN
            IF ClaimSetup.PostCreditMemoOnOrderInvoicing THEN
                PurchPost.RUN(PurchaseHeader);
        END;
    end;

    procedure PostPurchaseCreditMemoFromClaim(var ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        SourceSetup: Record "Source Code Setup";
        SalesPost: Codeunit "Sales-Post";
        PurchPost: Codeunit "Purch.-Post";
        OrderIsPostedError: Label 'Purchase Credit Memo %1 is already posted.';
        OrderIsDeletedError: Label 'Purchase Credit Memo  %1 is deleted.';
        PurchaseCreditMemoPostConfirm: Label 'Do you want to post Purchase %1 %2?';
    begin
        ClaimHeader.TestField("Claim Approved", TRUE);
        ClaimHeader.TestField("Purchase Credit Memo No.");

        IF NOT CONFIRM(StrSubstNo(PurchaseCreditMemoPostConfirm,
                            FORMAT(PurchaseHeader."Document Type"::"Credit Memo"),
                            ClaimHeader."Purchase Credit Memo No."))
        THEN
            EXIT;

        SourceSetup.GET;

        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::"Credit Memo",
            ClaimHeader."Purchase Credit Memo No.")
        THEN BEGIN
            IF PurchaseHeader."Posting Date" <> ClaimHeader."Vendor Cr. Memo Date" THEN BEGIN
                PurchaseHeader.SetHideValidationDialog(TRUE);
                PurchaseHeader.SuspendStatusCheck(TRUE);
                PurchaseHeader.Validate("Posting Date", ClaimHeader."Vendor Cr. Memo Date");
                PurchaseHeader.Modify();
                PurchaseHeader.GET(PurchaseHeader."Document Type"::"Credit Memo", ClaimHeader."Purchase Credit Memo No.");
            END;
            PurchPost.RUN(PurchaseHeader)
        END ELSE BEGIN
            PurchCrMemoHeader.RESET;
            PurchCrMemoHeader.SETRANGE("Pre-Assigned No.", ClaimHeader."Purchase Credit Memo No.");
            IF PurchCrMemoHeader.FindFirst() THEN BEGIN
                IF PurchCrMemoHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Purchase Credit Memo No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Purchase Credit Memo No.");
            END;
        END;
    END;

    procedure ShowSalesOrder(ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SourceSetup: Record "Source Code Setup";
        OrderIsPostedError: Label 'Sales Order %1 is already posted.';
        OrderIsDeletedError: Label 'Sales Order %1 is deleted.';
    begin
        ClaimHeader.TestField("Order No.");
        SourceSetup.GET;

        IF SalesHeader.GET(SalesHeader."Document Type"::Order, ClaimHeader."Order No.") THEN
            Page.RunModal(Page::"Sales Order", SalesHeader)
        ELSE BEGIN
            SalesInvoiceHeader.RESET;
            SalesInvoiceHeader.SETRANGE("Order No.", ClaimHeader."Order No.");
            IF SalesInvoiceHeader.FindFirst() THEN BEGIN
                IF SalesInvoiceHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Order No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Order No.");
            END;

            SalesInvoiceHeader.RESET;
            SalesInvoiceHeader.SETRANGE("Pre-Assigned No.", ClaimHeader."Order No.");
            IF SalesInvoiceHeader.FindFirst() THEN BEGIN
                IF SalesInvoiceHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Order No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Order No.");
            END;
        END;
    END;

    procedure ShowSupplementaryInvoice(ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SourceSetup: Record "Source Code Setup";
        OrderIsPostedError: Label 'Sales Invoice %1 is already posted.';
        OrderIsDeletedError: Label 'Sales Invoice %1 is deleted.';
    begin
        ClaimHeader.TestField("Supplementary Invoice No.");
        SourceSetup.GET;

        IF SalesHeader.GET(SalesHeader."Document Type"::Invoice, ClaimHeader."Supplementary Invoice No.") THEN
            Page.RunModal(Page::"Sales Invoice", SalesHeader)
        ELSE BEGIN
            SalesInvoiceHeader.RESET;
            SalesInvoiceHeader.SETRANGE("Pre-Assigned No.", ClaimHeader."Supplementary Invoice No.");
            IF SalesInvoiceHeader.FindFirst() THEN BEGIN
                IF SalesInvoiceHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Supplementary Invoice No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Supplementary Invoice No.");
            END;
        END;
    END;

    procedure ShowPostedSupplementaryInvoice(ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        ClaimHeader.TestField("Posted Supplementary Inv No.");

        SalesInvoiceHeader.GET(ClaimHeader."Posted Supplementary Inv No.");

        Page.RunModal(Page::"Posted Sales Invoice", SalesInvoiceHeader);
    end;

    procedure ShowPurchaseCreditMemo(ClaimHeader: Record "AQD Customer Claim Header")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        SourceSetup: Record "Source Code Setup";
        OrderIsPostedError: Label 'Purchase Credit Memo %1 is already posted.';
        OrderIsDeletedError: Label 'Purchase Credit Memo  %1 is deleted.';
    BEGIN
        ClaimHeader.TestField("Purchase Credit Memo No.");
        SourceSetup.GET;

        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::"Credit Memo",
            ClaimHeader."Purchase Credit Memo No.")
        THEN
            Page.RunModal(Page::"Purchase Credit Memo", PurchaseHeader)
        ELSE BEGIN
            PurchCrMemoHeader.RESET;
            PurchCrMemoHeader.SETRANGE("Pre-Assigned No.", ClaimHeader."Purchase Credit Memo No.");
            IF PurchCrMemoHeader.FindFirst() THEN BEGIN
                IF PurchCrMemoHeader."Source Code" <> SourceSetup."Deleted Document" THEN
                    ERROR(OrderIsPostedError, ClaimHeader."Purchase Credit Memo No.")
                ELSE
                    ERROR(OrderIsDeletedError, ClaimHeader."Purchase Credit Memo No.");
            END;
        END;
    END;

    procedure ShowPostedSalesInvoice(ClaimHeader: Record "AQD Customer Claim Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        ClaimHeader.TestField("Posted Invoice No.");

        SalesInvoiceHeader.GET(ClaimHeader."Posted Invoice No.");

        Page.RunModal(Page::"Posted Sales Invoice", SalesInvoiceHeader);
    end;

    procedure ShowPostedPurchaseCreditMemo(ClaimHeader: Record "AQD Customer Claim Header")
    var
        PostedPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        ClaimHeader.TestField("Posted Purch Credit Memo No.");

        PostedPurchCrMemoHeader.GET(ClaimHeader."Posted Purch Credit Memo No.");

        Page.RunModal(Page::"Posted Purchase Credit Memo", PostedPurchCrMemoHeader);
    end;
}