codeunit 14302613 "AQD Customer Claim Process"
{
    trigger OnRun()
    BEGIN
        CASE TRUE OF
            RunForFullPriceClaims:
                BEGIN
                    CreateFullPriceClaim();
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
        ClaimLine: Record "AQD Customer Claim Line";
        ClaimError: Record "AQD Customer Claim Errors";
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        Customer: Record Customer;
        TmpInvPostingBuffer: Record "Invoice Posting Buffer" temporary;
        RecreateClaim: Boolean;
        RecreateClaimMemo: Boolean;
        ShowResult: Boolean;
        RunForFullPriceClaims: Boolean;
        RunForPriceMatchClaims: Boolean;
        ClaimHasDataError: Boolean;
        TotalClaimAmount: Decimal;
        EstimateDeliveryCommission: Decimal;
        NextLineNo: Integer;
        ClaimLineType: Enum "AQD CustClmPrcMthClaimLineType";
        EstimateDeliveryCommissionLbl: Label 'Estimated Delivery Commission';
        CheckMandtoryFieldError: Label '%1 must have a value in Sales %2 %3 - Line No. = %4. It cannot be zero or empty.';
        InvoiceMandtoryFieldError: Label '%1 must have a value in Posted Sales Invoice %2 - Line No. = %3. It cannot be zero or empty.';

    procedure SetCreateFullPriceClaimsParameters(VAR SalesHeaderIn: Record "Sales Header"; RecreateClaimIn: Boolean; ShowResultIn: Boolean)
    begin
        SalesHeader := SalesHeaderIn;
        RecreateClaim := RecreateClaimIn;
        ShowResult := ShowResultIn;
        RunForFullPriceClaims := TRUE;
    end;

    procedure SetCreatePriceMatchClaimsParameters(VAR SalesInvoiceHeaderIn: Record "Sales Invoice Header"; CurrentRecordIn: Boolean; RecreateClaimIn: Boolean; ShowResultIn: Boolean)
    BEGIN
        SalesInvoiceHeader := SalesInvoiceHeaderIn;
        RecreateClaim := RecreateClaimIn;
        ShowResult := ShowResultIn;
        RunForPriceMatchClaims := TRUE;
    END;

    procedure IsSalesLineClaimable(SalesLine: Record "Sales Line"; IgnoreCommentsCheck: Boolean) ReturnValue: Boolean
    BEGIN
        IF NOT IgnoreCommentsCheck THEN
            IF (SalesLine.Type = SalesLine.Type::" ") AND
               (NOT ClaimSetup."Insert Comment Lines on Claim")
            THEN
                EXIT(FALSE);

        CASE SalesLine.Type OF
            SalesLine.Type::Item:
                BEGIN
                    IF Item.GET(SalesLine."No.") THEN
                        EXIT(Item."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
            SalesLine.Type::Resource:
                BEGIN
                    IF Resource.GET(SalesLine."No.") THEN
                        EXIT(Resource."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
            SalesLine.Type::"G/L Account":
                BEGIN
                    IF GLAccount.GET(SalesLine."No.") THEN
                        EXIT(GLAccount."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
        END;
        EXIT(TRUE);
    END;

    procedure IsSalesInvoiceLineClaimable(SalesInvoiceLine: Record "Sales Invoice Line"; IgnoreCommentsCheck: Boolean) ReturnValue: Boolean
    BEGIN
        IF NOT IgnoreCommentsCheck THEN
            IF (SalesInvoiceLine.Type = SalesInvoiceLine.Type::" ") AND
               (NOT ClaimSetup."Insert Comment Lines on Claim")
            THEN
                EXIT(FALSE);

        CASE SalesInvoiceLine.Type OF
            SalesInvoiceLine.Type::Item:
                BEGIN
                    IF Item.GET(SalesInvoiceLine."No.") THEN
                        EXIT(Item."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
            SalesInvoiceLine.Type::Resource:
                BEGIN
                    IF Resource.GET(SalesInvoiceLine."No.") THEN
                        EXIT(Resource."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
            SalesInvoiceLine.Type::"G/L Account":
                BEGIN
                    IF GLAccount.GET(SalesInvoiceLine."No.") THEN
                        EXIT(GLAccount."AQM Customer Claim Enabled")
                    ELSE
                        EXIT(FALSE);
                END;
        END;
        EXIT(TRUE);
    END;

    procedure InsertClaimError(OrderNo: Code[20]; ClaimNo: Code[20]; ClaimLineNo: Integer; FieldName: Text[30]; ErrorDesc: Text[80]; FieldMandatory: Boolean; SourceType: Enum "AQD CustClaim Error SourceType"; ShowError: Boolean)
    BEGIN
        NextLineNo := 10;

        ClaimError.RESET;
        ClaimError.SETRANGE("Order No.", OrderNo);
        ClaimError.SETRANGE("Claim No.", ClaimNo);
        ClaimError.SETRANGE("Claim Line No.", ClaimLineNo);
        IF ClaimError.FINDLAST THEN
            NextLineNo := ClaimError."Line No." + 10;

        ClaimError.RESET;
        ClaimError.INIT;
        ClaimError."Order No." := OrderNo;
        ClaimError."Claim No." := ClaimNo;
        ClaimError."Claim Line No." := ClaimLineNo;
        ClaimError."Line No." := NextLineNo;
        ClaimError."Field Name" := FieldName;
        ClaimError.Description := ErrorDesc;
        ClaimError.Mandatory := FieldMandatory;
        ClaimError."Source Type" := SourceType;
        ClaimError."Error Date Time" := CURRENTDATETIME;
        ClaimError.INSERT;

        ClaimHasDataError := TRUE;
    END;

    LOCAL procedure CreateFullPriceClaim()
    var
        LocalSalesLine: Record "Sales Line";
    BEGIN
        ClaimError.RESET;
        ClaimError.SETRANGE("Order No.", SalesHeader."No.");
        IF ClaimError.FINDFIRST THEN
            ClaimError.DELETEALL;

        ClaimHeader.RESET;
        ClaimHeader.SetRange("Claim Type", ClaimHeader."Claim Type"::"Full Price");
        ClaimHeader.SETRANGE("Order No.", SalesHeader."No.");
        ClaimHeader.SetRange("Claim Submitted", false);
        ClaimHeader.SetRange("Claim Approved", false);
        IF RecreateClaim THEN BEGIN
            IF ClaimHeader.FINDFIRST THEN BEGIN
                ClaimLine.RESET;
                ClaimLine.SetRange("Document No.", ClaimHeader."No.");
                ClaimLine.DeleteAll();

                ClaimHeader.DELETE;
            END;
        END;

        SalesHeader.TESTFIELD("AQD Claim Vendor No.");
        Vendor.GET(SalesHeader."AQD Claim Vendor No.");

        ClaimHeader.RESET;
        ClaimHeader.SetRange("Claim Type", ClaimHeader."Claim Type"::"Full Price");
        ClaimHeader.SETRANGE("Order No.", SalesHeader."No.");
        IF NOT ClaimHeader.FINDFIRST THEN BEGIN

            ClaimHeader.INIT;
            ClaimHeader."Claim Type" := ClaimHeader."Claim Type"::"Full Price";
            ClaimHeader."Order No." := SalesHeader."No.";
            IF ClaimSetup."Claim No. is Order No." THEN
                ClaimHeader."No." := SalesHeader."No.";
            ClaimHeader.INSERT(TRUE);
        END ELSE BEGIN
            ClaimHeader.TESTFIELD("Claim Rejected", FALSE);
            ClaimHeader.TESTFIELD("Claim Approved", FALSE);
        END;
        ClaimHeader."Order Date" := SalesHeader."Order Date";
        ClaimHeader."Posting Date" := SalesHeader."Posting Date";
        ClaimHeader."Shipment Date" := SalesHeader."Shipment Date";
        ClaimHeader."Document Date" := SalesHeader."Document Date";

        ClaimHeader."Salesperson Code" := SalesHeader."Salesperson Code";
        ClaimHeader."Location Code" := SalesHeader."Location Code";
        ClaimHeader."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
        ClaimHeader."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
        ClaimHeader."Dimension Set ID" := SalesHeader."Dimension Set ID";
        ClaimHeader."Responsibility Center" := SalesHeader."Responsibility Center";

        ClaimHeader."Vendor No." := SalesHeader."AQD Claim Vendor No.";
        ClaimHeader."Vendor Name" := Vendor.Name;
        ClaimHeader."Vendor Name 2" := Vendor."Name 2";
        ClaimHeader."Vendor Address" := Vendor.Address;
        ClaimHeader."Vendor Address 2" := Vendor."Address 2";
        ClaimHeader."Vendor City" := Vendor.City;
        ClaimHeader."Vendor Post Code" := Vendor."Post Code";
        ClaimHeader."Vendor County" := Vendor.County;
        ClaimHeader."Vendor Country/Region Code" := Vendor."Country/Region Code";

        ClaimHeader."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        ClaimHeader."Sell-to Name" := SalesHeader."Sell-to Customer Name";
        ClaimHeader."Sell-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        ClaimHeader."Sell-to Address" := SalesHeader."Sell-to Address";
        ClaimHeader."Sell-to Address 2" := SalesHeader."Sell-to Address 2";
        ClaimHeader."Sell-to Contact" := SalesHeader."Sell-to Contact";
        ClaimHeader."Sell-to City" := SalesHeader."Sell-to City";
        ClaimHeader."Sell-to Post Code" := SalesHeader."Sell-to Post Code";
        ClaimHeader."Sell-to County" := SalesHeader."Sell-to County";
        ClaimHeader."Sell-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";

        ClaimHeader."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        ClaimHeader."Bill-to Name" := SalesHeader."Bill-to Name";
        ClaimHeader."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
        ClaimHeader."Bill-to Address" := SalesHeader."Bill-to Address";
        ClaimHeader."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
        ClaimHeader."Bill-to Contact" := SalesHeader."Bill-to Contact";
        ClaimHeader."Bill-to City" := SalesHeader."Bill-to City";
        ClaimHeader."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
        ClaimHeader."Bill-to County" := SalesHeader."Bill-to County";
        ClaimHeader."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";

        ClaimHeader."Ship-to Code" := SalesHeader."Ship-to Code";
        ClaimHeader."Ship-to Name" := SalesHeader."Ship-to Name";
        ClaimHeader."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        ClaimHeader."Ship-to Address" := SalesHeader."Ship-to Address";
        ClaimHeader."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
        ClaimHeader."Ship-to Contact" := SalesHeader."Ship-to Contact";
        ClaimHeader."Ship-to City" := SalesHeader."Ship-to City";
        ClaimHeader."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
        ClaimHeader."Ship-to County" := SalesHeader."Ship-to County";
        ClaimHeader."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
        ClaimHeader.Status := ClaimHeader.Status::" ";

        ClaimHeader."Vendor Cr. Memo No." := SalesHeader."AQD Vendor Cr. Memo No.";
        ClaimHeader."Amount Approved" := SalesHeader."AQD Claim Approved Amount";
        ClaimHeader."Delivery Commission" := SalesHeader."AQD Claim Delivery Commission";
        ClaimHeader."Purchase Discount" := SalesHeader."AQD Claim Purchase Discount";
        ClaimHeader.Status := ClaimHeader.Status::Created;
        ClaimHeader.MODIFY;

        ClaimLine.RESET;
        ClaimLine.SetRange("Claim Type", ClaimHeader."Claim Type");
        ClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
        ClaimLine.DELETEALL;

        LocalSalesLine.RESET;
        LocalSalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        LocalSalesLine.SETRANGE("Document No.", SalesHeader."No.");
        IF LocalSalesLine.FINDFIRST THEN BEGIN
            REPEAT
                IF IsSalesLineClaimable(LocalSalesLine, FALSE) THEN BEGIN
                    ClaimLine.INIT;
                    ClaimLine."Claim Type" := ClaimLine."Claim Type"::"Full Price";
                    ClaimLine."Document No." := ClaimHeader."No.";
                    ClaimLine."Line No." := NextLineNo;
                    ClaimLine."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
                    ClaimLine."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
                    ClaimLine."Ship-To Code" := SalesHeader."Ship-to Code";
                    ClaimLine.Type := LocalSalesLine.Type;
                    ClaimLine."No." := LocalSalesLine."No.";
                    ClaimLine."Location Code" := LocalSalesLine."Location Code";
                    ClaimLine.Description := LocalSalesLine.Description;
                    ClaimLine."Description 2" := LocalSalesLine."Description 2";
                    ClaimLine."Unit of Measure" := LocalSalesLine."Unit of Measure";
                    ClaimLine."Unit of Measure Code" := LocalSalesLine."Unit of Measure Code";
                    ClaimLine.Quantity := LocalSalesLine.Quantity;
                    ClaimLine."Unit Price" := LocalSalesLine."Unit Price";
                    ClaimLine."Order Unit Price" := LocalSalesLine."Unit Price";
                    ClaimLine."Unit Cost (LCY)" := LocalSalesLine."Unit Cost (LCY)";
                    ClaimLine."Line Discount %" := LocalSalesLine."Line Discount %";
                    ClaimLine."Line Discount Amount" := LocalSalesLine."Line Discount Amount";
                    ClaimLine.Amount := LocalSalesLine.Amount;
                    ClaimLine."Amount Including VAT" := LocalSalesLine."Amount Including VAT";
                    ClaimLine."Line Amount" := LocalSalesLine."Line Amount";
                    ClaimLine."Quantity Shipped" := LocalSalesLine."Quantity Shipped";
                    ClaimLine."Order No." := ClaimHeader."Order No.";
                    ClaimLine."Order Line No." := LocalSalesLine."Line No.";
                    ClaimLine."Shortcut Dimension 1 Code" := LocalSalesLine."Shortcut Dimension 1 Code";
                    ClaimLine."Shortcut Dimension 2 Code" := LocalSalesLine."Shortcut Dimension 2 Code";
                    ClaimLine."Dimension Set ID" := LocalSalesLine."Dimension Set ID";
                    ClaimLine."Responsibility Center" := SalesHeader."Responsibility Center";
                    ClaimLine.INSERT;

                    NextLineNo += 10000;
                END;
            UNTIL LocalSalesLine.NEXT = 0;
        END;
    END;

    LOCAL procedure CreatePriceMatchClaims()
    var
        LocalSalesInvoiceLine: Record "Sales Invoice Line";
        IncludeLine: Boolean;
        ClaimIsRequired: Boolean;
        LineClaimRequired: Boolean;
        TotalAmount: Decimal;
        ClaimAmount: Decimal;
        CostDiff: Decimal;
    BEGIN
        IF SalesInvoiceHeader."AQD CustClaim Claim Type" <> SalesInvoiceHeader."AQD CustClaim Claim Type"::"Price Match" THEN
            EXIT;

        ClaimSetup.GET;
        ClaimSetup.TESTFIELD("Price Match Claims G/L Account");
        ClaimSetup.TESTFIELD("PriceMatch ClmCostDiff G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Claim Disc G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Claim DelComm Acct");
        ClaimSetup.TESTFIELD("Price Match Claim Vari G/LAcct");
        ClaimSetup.TESTFIELD("Price Match Default Pyt Method");

        ClaimError.RESET;
        ClaimError.SETRANGE("Order No.", SalesInvoiceHeader."No.");
        IF ClaimError.FINDFIRST THEN
            ClaimError.DELETEALL;

        ClaimHeader.RESET;
        ClaimHeader.SetRange("Claim Type", ClaimHeader."Claim Type"::"Price Match");
        ClaimHeader.SETRANGE("Posted Invoice No.", SalesInvoiceHeader."No.");
        ClaimHeader.SetRange("Claim Submitted", false);
        ClaimHeader.SetRange("Claim Approved", false);
        IF RecreateClaim THEN BEGIN
            IF ClaimHeader.FINDFIRST THEN BEGIN
                ClaimLine.RESET;
                ClaimLine.SetRange("Claim Type", ClaimHeader."Claim Type");
                ClaimLine.SetRange("Posted Invoice No.", ClaimHeader."Posted Invoice No.");
                ClaimLine.DeleteAll();

                ClaimHeader.DeleteAll;
            END;
        END;

        LocalSalesInvoiceLine.RESET;
        LocalSalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        LocalSalesInvoiceLine.SETFILTER(Type, '%1|%2|%3',
            LocalSalesInvoiceLine.Type::Item,
            LocalSalesInvoiceLine.Type::Resource,
            LocalSalesInvoiceLine.Type::"G/L Account");
        LocalSalesInvoiceLine.SETFILTER("No.", '<>%1', '');
        LocalSalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
        LocalSalesInvoiceLine.SETFILTER("AQD CustClaim Vendor No.", '<>%1', '');
        IF LocalSalesInvoiceLine.FINDFIRST THEN BEGIN
            REPEAT
                IncludeLine := FALSE;
                IncludeLine := IsSalesInvoiceLineClaimable(LocalSalesInvoiceLine, FALSE);
                IF IncludeLine THEN BEGIN
                    IF LocalSalesInvoiceLine."AQD CustClaim Vendor No." = '' THEN
                        ERROR(InvoiceMandtoryFieldError,
                          LocalSalesInvoiceLine.FIELDCAPTION("AQD CustClaim Vendor No."),
                          LocalSalesInvoiceLine."Document No.",
                          LocalSalesInvoiceLine."Line No.");

                    IF (ClaimSetup."Price Match ClaimProgCode Mand") AND
                       (LocalSalesInvoiceLine."AQD CustClaim Program Code" = '')
                    THEN
                        ERROR(InvoiceMandtoryFieldError,
                          LocalSalesInvoiceLine.FIELDCAPTION("AQD CustClaim Program Code"),
                          LocalSalesInvoiceLine."Document No.",
                          LocalSalesInvoiceLine."Line No.");

                    IF (ClaimSetup."Price Match ClaimServCode Mand") AND
                       (LocalSalesInvoiceLine."AQD CustClaim Service Code" = '')
                    THEN
                        ERROR(InvoiceMandtoryFieldError,
                          LocalSalesInvoiceLine.FIELDCAPTION("AQD CustClaim Service Code"),
                          LocalSalesInvoiceLine."Document No.",
                          LocalSalesInvoiceLine."Line No.");

                    IF Vendor.GET(LocalSalesInvoiceLine."AQD CustClaim Vendor No.") AND
                       Vendor."AQM Claim Vendor" AND
                       (Vendor."AQD Claim From Customer No." <> '')
                    THEN BEGIN
                        Vendor.TESTFIELD(Blocked, Vendor.Blocked::" ");
                        IF NOT TmpInvPostingBuffer.GET(LocalSalesInvoiceLine."AQD CustClaim Vendor No.") THEN BEGIN
                            TmpInvPostingBuffer.INIT;
                            TmpInvPostingBuffer."Group ID" := LocalSalesInvoiceLine."AQD CustClaim Vendor No.";
                            TmpInvPostingBuffer.INSERT;
                        END;
                    END;
                END;
            UNTIL LocalSalesInvoiceLine.NEXT = 0;
        END;

        TmpInvPostingBuffer.RESET;
        IF TmpInvPostingBuffer.FINDFIRST THEN BEGIN
            REPEAT
                TotalAmount := 0;
                ClaimAmount := 0;
                ClaimIsRequired := FALSE;

                LocalSalesInvoiceLine.RESET;
                LocalSalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
                LocalSalesInvoiceLine.SETFILTER(Type, '%1|%2|%3',
                    LocalSalesInvoiceLine.Type::Item,
                    LocalSalesInvoiceLine.Type::Resource,
                    LocalSalesInvoiceLine.Type::"G/L Account");
                LocalSalesInvoiceLine.SETFILTER("No.", '<>%1', '');
                LocalSalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
                LocalSalesInvoiceLine.SETRANGE("AQD CustClaim Vendor No.", TmpInvPostingBuffer."Group ID");
                IF LocalSalesInvoiceLine.FINDFIRST THEN BEGIN
                    REPEAT
                        IncludeLine := FALSE;
                        IncludeLine := IsSalesInvoiceLineClaimable(LocalSalesInvoiceLine, FALSE);
                        IF IncludeLine THEN BEGIN
                            IF LocalSalesInvoiceLine."Unit Cost" - LocalSalesInvoiceLine."Unit Price" > 0 THEN
                                ClaimAmount := ClaimAmount +
                                    ((LocalSalesInvoiceLine."Unit Cost" - LocalSalesInvoiceLine."Unit Price") * LocalSalesInvoiceLine.Quantity)
                            ELSE BEGIN
                                IF ClaimSetup."Price Match Always CreCostDiff" THEN
                                    ClaimAmount := ClaimAmount + 0.01;
                            END;

                            IF ClaimSetup."Price Match Always CreCommLine" THEN
                                ClaimAmount := ClaimAmount + 0.01; // For Delivery Commission Default Value
                        END;
                    UNTIL LocalSalesInvoiceLine.NEXT = 0;
                END;

                IF ClaimAmount > 0 THEN
                    ClaimIsRequired := TRUE;

                CreateCustomerClaimHeader(ClaimIsRequired);
                IF ClaimIsRequired THEN BEGIN
                    // Create Sales Invoice Lines
                    LocalSalesInvoiceLine.RESET;
                    LocalSalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
                    LocalSalesInvoiceLine.SETRANGE("AQD CustClaim Vendor No.", TmpInvPostingBuffer."Group ID");
                    LocalSalesInvoiceLine.SETFILTER(Type, '%1|%2|%3',
                        LocalSalesInvoiceLine.Type::Item,
                        LocalSalesInvoiceLine.Type::Resource,
                        LocalSalesInvoiceLine.Type::"G/L Account");
                    LocalSalesInvoiceLine.SETFILTER("No.", '<>%1', '');
                    LocalSalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
                    IF LocalSalesInvoiceLine.FINDFIRST THEN BEGIN
                        REPEAT
                            LineClaimRequired := FALSE;

                            IncludeLine := FALSE;
                            IncludeLine := IsSalesInvoiceLineClaimable(LocalSalesInvoiceLine, FALSE);
                            IF IncludeLine THEN BEGIN
                                CostDiff := LocalSalesInvoiceLine."Unit Cost (LCY)" - LocalSalesInvoiceLine."Unit Price";
                                IF CostDiff <= 0 THEN BEGIN
                                    IF ClaimSetup."Price Match Always CreCostDiff" THEN
                                        CostDiff := 0.01;
                                END ELSE
                                    LineClaimRequired := TRUE;

                                IF CostDiff > 0 THEN BEGIN
                                    ClaimLineType := ClaimLineType::"Cost of Good Sold";
                                    CreatePriceMatchClaimLine(LocalSalesInvoiceLine,
                                        '',  // This is not required for cost difference
                                        LocalSalesInvoiceLine.Quantity,
                                        CostDiff,
                                        '',  // This is not required for cost difference
                                        LineClaimRequired,
                                        ClaimLineType);
                                END;
                            END;
                        UNTIL LocalSalesInvoiceLine.NEXT = 0;
                    END;

                    // Function to be implemented Current Returned Fixed Value 0 to disable it
                    EstimateDeliveryCommission := 0;
                    IF EstimateDeliveryCommission = 0 THEN
                        IF ClaimSetup."Price Match Always CreCommLine" THEN
                            EstimateDeliveryCommission := 0.01;

                    IF EstimateDeliveryCommission <> 0 THEN BEGIN
                        ClaimLineType := ClaimLineType::"Delivery Commission";
                        CreatePriceMatchClaimLine(LocalSalesInvoiceLine,
                                       ClaimSetup."Price Match Claim DelComm Acct",
                                       1,
                                       EstimateDeliveryCommission,
                                       EstimateDeliveryCommissionLbl,
                                       LineClaimRequired,
                                       ClaimLineType);
                        TotalAmount := TotalAmount + EstimateDeliveryCommission;
                    END;
                END;
            UNTIL TmpInvPostingBuffer.NEXT = 0;
        END;
    END;

    local procedure CreateCustomerClaimHeader(ClaimIsRequired: Boolean)
    BEGIN
        Vendor.GET(TmpInvPostingBuffer."Group ID");

        ClaimHeader.RESET;
        ClaimHeader.SETRANGE("Claim Type", ClaimHeader."Claim Type"::"Price Match");
        ClaimHeader.SETRANGE("Posted Invoice No.", SalesInvoiceHeader."No.");
        ClaimHeader.SETRANGE("Vendor No.", TmpInvPostingBuffer."Group ID");
        IF ClaimHeader.FINDFIRST THEN BEGIN
            ClaimLine.RESET;
            ClaimLine.SetRange("Claim Type", ClaimHeader."Claim Type");
            ClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
            IF ClaimLine.FINDFIRST THEN
                ClaimLine.DELETEALL;

            IF NOT ClaimIsRequired THEN
                ClaimHeader.DELETE;
        END ELSE BEGIN
            IF ClaimIsRequired THEN BEGIN
                ClaimHeader.INIT;
                ClaimHeader."Claim Type" := ClaimHeader."Claim Type"::"Price Match";
                ClaimHeader."Order No." := SalesInvoiceHeader."Order No.";
                ClaimHeader."Posted Invoice No." := SalesInvoiceHeader."No.";
                ClaimHeader."No." := '';
                ClaimHeader.INSERT(TRUE);
            END;
        END;

        IF NOT ClaimIsRequired THEN
            EXIT;

        ClaimHeader."Order Date" := SalesInvoiceHeader."Order Date";
        ClaimHeader."Posting Date" := SalesInvoiceHeader."Posting Date";
        ClaimHeader."Shipment Date" := SalesInvoiceHeader."Shipment Date";
        ClaimHeader."Document Date" := SalesInvoiceHeader."Document Date";

        ClaimHeader."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
        ClaimHeader."Location Code" := SalesInvoiceHeader."Location Code";
        ClaimHeader."Shortcut Dimension 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
        ClaimHeader."Shortcut Dimension 2 Code" := SalesInvoiceHeader."Shortcut Dimension 2 Code";
        ClaimHeader."Dimension Set ID" := SalesInvoiceHeader."Dimension Set ID";
        ClaimHeader."Responsibility Center" := SalesInvoiceHeader."Responsibility Center";

        ClaimHeader."Vendor No." := TmpInvPostingBuffer."Group ID";
        ClaimHeader."Vendor Name" := Vendor.Name;
        ClaimHeader."Vendor Name 2" := Vendor."Name 2";
        ClaimHeader."Vendor Address" := Vendor.Address;
        ClaimHeader."Vendor Address 2" := Vendor."Address 2";
        ClaimHeader."Vendor City" := Vendor.City;
        ClaimHeader."Vendor Post Code" := Vendor."Post Code";
        ClaimHeader."Vendor County" := Vendor.County;
        ClaimHeader."Vendor Country/Region Code" := Vendor."Country/Region Code";

        ClaimHeader."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        ClaimHeader."Sell-to Name" := SalesInvoiceHeader."Sell-to Customer Name";
        ClaimHeader."Sell-to Name 2" := SalesInvoiceHeader."Sell-to Customer Name 2";
        ClaimHeader."Sell-to Address" := SalesInvoiceHeader."Sell-to Address";
        ClaimHeader."Sell-to Address 2" := SalesInvoiceHeader."Sell-to Address 2";
        ClaimHeader."Sell-to Contact" := SalesInvoiceHeader."Sell-to Contact";
        ClaimHeader."Sell-to City" := SalesInvoiceHeader."Sell-to City";
        ClaimHeader."Sell-to Post Code" := SalesInvoiceHeader."Sell-to Post Code";
        ClaimHeader."Sell-to County" := SalesInvoiceHeader."Sell-to County";
        ClaimHeader."Sell-to Country/Region Code" := SalesInvoiceHeader."Sell-to Country/Region Code";

        ClaimHeader."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        ClaimHeader."Bill-to Name" := SalesInvoiceHeader."Bill-to Name";
        ClaimHeader."Bill-to Name 2" := SalesInvoiceHeader."Bill-to Name 2";
        ClaimHeader."Bill-to Address" := SalesInvoiceHeader."Bill-to Address";
        ClaimHeader."Bill-to Address 2" := SalesInvoiceHeader."Bill-to Address 2";
        ClaimHeader."Bill-to Contact" := SalesInvoiceHeader."Bill-to Contact";
        ClaimHeader."Bill-to City" := SalesInvoiceHeader."Bill-to City";
        ClaimHeader."Bill-to Post Code" := SalesInvoiceHeader."Bill-to Post Code";
        ClaimHeader."Bill-to County" := SalesInvoiceHeader."Bill-to County";
        ClaimHeader."Bill-to Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";

        ClaimHeader."Ship-to Code" := SalesInvoiceHeader."Ship-to Code";
        ClaimHeader."Ship-to Name" := SalesInvoiceHeader."Ship-to Name";
        ClaimHeader."Ship-to Name 2" := SalesInvoiceHeader."Ship-to Name 2";
        ClaimHeader."Ship-to Address" := SalesInvoiceHeader."Ship-to Address";
        ClaimHeader."Ship-to Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        ClaimHeader."Ship-to Contact" := SalesInvoiceHeader."Ship-to Contact";
        ClaimHeader."Ship-to City" := SalesInvoiceHeader."Ship-to City";
        ClaimHeader."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        ClaimHeader."Ship-to County" := SalesInvoiceHeader."Ship-to County";
        ClaimHeader."Ship-to Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";
        ClaimHeader.Status := ClaimHeader.Status::Created;
        ClaimHeader."Purchase Credit Memo No." := '';
        ClaimHeader."Supplementary Invoice No." := '';
        ClaimHeader.MODIFY;
    END;

    local procedure CreatePriceMatchClaimLine(SalesInvoiceLineIn: Record "Sales Invoice Line"; ClaimGLAccountNo: Code[20]; ClaimQuantity: Decimal; UnitClaimPrice: Decimal; ClaimLineDescription: Text[100]; LineClaimRequired: Boolean; ClaimLineTypeIn: enum "AQD CustClmPrcMthClaimLineType")
    begin
        ClaimLine.RESET;
        ClaimLine.SetRange("Claim Type", ClaimHeader."Claim Type");
        ClaimLine.SetRange("Document No.", ClaimHeader."No.");
        IF ClaimLine.FINDLAST THEN
            NextLineNo := ClaimLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        ClaimLine.INIT;
        ClaimLine."Claim Type" := ClaimHeader."Claim Type";
        ClaimLine."Document No." := ClaimHeader."No.";
        ClaimLine."Line No." := NextLineNo;
        ClaimLine."Posted Invoice No." := SalesInvoiceLineIn."Document No.";
        ClaimLine."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        ClaimLine."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        ClaimLine."Ship-To Code" := SalesInvoiceHeader."Ship-to Code";
        IF ClaimGLAccountNo <> '' THEN BEGIN
            ClaimLine.Type := ClaimLine.Type::"G/L Account";
            ClaimLine."No." := ClaimGLAccountNo;
        END ELSE BEGIN
            ClaimLine.Type := SalesInvoiceLineIn.Type;
            ClaimLine."No." := SalesInvoiceLineIn."No.";
        END;
        ClaimLine."Location Code" := SalesInvoiceLineIn."Location Code";
        ClaimLine.Description := SalesInvoiceLineIn.Description;
        IF ClaimLineDescription <> '' THEN
            ClaimLine.Description := ClaimLineDescription;
        ClaimLine."Description 2" := SalesInvoiceLineIn."Description 2";
        ClaimLine."Unit of Measure" := SalesInvoiceLineIn."Unit of Measure";
        ClaimLine."Unit of Measure Code" := SalesInvoiceLineIn."Unit of Measure Code";
        ClaimLine.Quantity := ClaimQuantity;
        ClaimLine."Unit Price" := UnitClaimPrice;
        ClaimLine."Order Unit Price" := SalesInvoiceLineIn."Unit Price";
        ClaimLine."Unit Cost (LCY)" := SalesInvoiceLineIn."Unit Cost (LCY)";
        ClaimLine."Line Discount %" := 0;
        ClaimLine."Line Discount Amount" := 0;
        ClaimLine.Amount := ROUND(ClaimLine.Quantity * ClaimLine."Unit Price", 0.01);
        ClaimLine."Amount Including VAT" := ClaimLine.Amount;
        IF LineClaimRequired THEN BEGIN
            ClaimLine."Approved Unit Price" := ClaimLine."Unit Price";
            ClaimLine."Approved Amount" := ClaimLine.Amount;
        END;
        ClaimLine."Line Amount" := ClaimLine.Amount;
        ClaimLine."Order No." := ClaimHeader."Posted Invoice No."; // For Price Match, This will be Invoice No.
        ClaimLine."Order Line No." := SalesInvoiceLineIn."Line No.";
        ClaimLine."Shortcut Dimension 1 Code" := SalesInvoiceLineIn."Shortcut Dimension 1 Code";
        ClaimLine."Shortcut Dimension 2 Code" := SalesInvoiceLineIn."Shortcut Dimension 2 Code";
        ClaimLine."Dimension Set ID" := SalesInvoiceLineIn."Dimension Set ID";
        ClaimLine."Responsibility Center" := SalesInvoiceHeader."Responsibility Center";
        ClaimLine."Claim Line Type" := ClaimLineTypeIn;
        ClaimLine."Claim Line" := LineClaimRequired;
        ClaimLine."Cust Claim Mfg Product Code" := SalesInvoiceLineIn."AQM CustClaim Mfg Product Code";
        ClaimLine."Cust Claim Program Code" := SalesInvoiceLineIn."AQD CustClaim Program Code";
        ClaimLine."Cust Claim Service Code" := SalesInvoiceLineIn."AQD CustClaim Service Code";
        ClaimLine.INSERT;
    end;
}