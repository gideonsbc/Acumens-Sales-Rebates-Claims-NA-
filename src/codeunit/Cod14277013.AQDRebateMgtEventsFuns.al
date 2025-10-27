codeunit 14277013 "AQD Rebate Mgt Events&Funs"
{

    trigger OnRun()
    begin
    end;

    var
        RebateSingleInstance: Codeunit "AQD Rebate Single Instance";
        CalledFromRebate: Boolean;
        RebateSetup: Record "AQD Acumens Rebate Setup";

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure Tab15_GLAccount_OnBeforeInsert(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebatable" := RebateSetup."G/L Account Rebatable";
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table18_Customer_OnBeforeInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if not RebateSetup.Get then
            exit;

        Rec."AQD Rebate Payment Method" := RebateSetup."Def. Rebate Payment Method";
        Rec."AQD Rebate Type" := RebateSetup."Default Rebate Type";
        Rec."AQD Rebate Per Quantity" := RebateSetup."Default Rebate Per Quantity";
        Rec."AQD Rebate %" := RebateSetup."Default Rebate %";
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table27_Item_OnBeforeInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebatable" := RebateSetup."Item Rebatable";
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table156_Resource_OnBeforeInsert(var Rec: Record Resource; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebatable" := RebateSetup."Resource Rebatable";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table5600_FixedAsset_OnBeforeInsert(var Rec: Record "Fixed Asset"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebatable" := RebateSetup."Fixed Asset Rebatable";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table5800_ItemCharge_OnBeforeInsert(var Rec: Record "Item Charge"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebatable" := RebateSetup."G/L Account Rebatable";
    end;


    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateReferencedIdsVendorOnInsert(var Rec: Record Vendor; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if not RebateSetup.Get then
            exit;

        Rec."AQD Rebate Payment Method" := RebateSetup."Def. Rebate Payment Method";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', true, false)]
    local procedure Table36_SalesHeader_OnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        UpdateSalespersonRebateInfo(SalesHeader, Customer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', true, false)]
    local procedure Table36_SalesHeader_BilltoCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        CustomerRec: Record Customer;
    begin
        if not CustomerRec.Get(Rec."Sell-to Customer No.") then
            CustomerRec.Init;
        UpdateSalespersonRebateInfo(Rec, CustomerRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeLookupName', '', true, false)]
    local procedure Cod230_GenJnlManagement_OnBeforeLookupName(var GenJnlBatch: Record "Gen. Journal Batch")
    begin
        // To Show Rebate Batch From Rebate Purchase / Payment Journal
        RebateSingleInstance.GetCalledFromRebate(CalledFromRebate);
        GenJnlBatch.FilterGroup(2);
        GenJnlBatch.SetRange(GenJnlBatch."AQD Rebate", CalledFromRebate);
        GenJnlBatch.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesShptLineInsert, '', false, false)]
    local procedure Cod80_SalesPost_OnAfterSalesShptLineInsert(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesInvoiceHeader: Record "Sales Invoice Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    var
        SalesRebateSetup: Record "AQD Sales Rebates Setup";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        RebateItemCategory: Record "AQD Rebate Item Category";
        RebateCategoryLine: Record "AQD Rebate Category Lines";
        RebateProgramCodeRec: Record "AQD Rebate Program Code";
        Item: Record Item;
        Resource: Record Resource;
        FixedAsset: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        GLAccount: Record "G/L Account";
        InsertSetupRec: Boolean;
        LineRebatable: Boolean;
        RebateCategoryCode: Code[20];
    begin
        IF SalesShipmentLine.IsTemporary then
            EXIT;

        IF SalesShipmentLine.Correction then
            exit;

        IF NOT RebateSetup.GET then
            EXIT;

        IF NOT RebateSetup.AutoCreateSaleRebateRateonRcpt then
            EXIT;

        //"Item Type", "Item No.", "Variant Code", "Vendor No.", "Rebate Code", 
        //"Starting Date", "Unit of Measure Code", "Minimum Quantity")

        LineRebatable := FALSE;
        RebateCategoryCode := '';

        Case SalesShipmentLine.Type of
            SalesShipmentLine.TYPE::Item:
                begin
                    IF Item.GET(SalesShipmentLine."No.") THEN begin
                        LineRebatable := Item."AQD Customer Rebatable";
                        RebateCategoryCode := Item."AQD Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"G/L Account":
                begin
                    IF GLAccount.get(SalesShipmentLine."No.") then begin
                        LineRebatable := GLAccount."AQD Customer Rebatable";
                        RebateCategoryCode := GLAccount."AQD Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::Resource:
                begin
                    IF Resource.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := Resource."AQD Vendor Rebatable";
                        RebateCategoryCode := Resource."AQD Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"Fixed Asset":
                begin
                    IF FixedAsset.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := FixedAsset."AQD Vendor Rebatable";
                        RebateCategoryCode := FixedAsset."AQD Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"Charge (Item)":
                begin
                    IF ItemCharge.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := ItemCharge."AQD Vendor Rebatable";
                        RebateCategoryCode := ItemCharge."AQD Rebate Category Code";
                    end;
                end;
        End;

        IF NOT LineRebatable THEN
            EXIT;

        //key(Key1; "Item Type", "Item No.", "Variant Code", "Vendor No.", "Rebate Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        SalesRebateSetup.RESET;
        case SalesShipmentLine.Type of
            SalesShipmentLine.Type::Item:
                BEGIN
                    SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::Item);
                    SalesRebateSetup.SetRange("No.", SalesShipmentLine."No.");
                END;
            SalesShipmentLine.Type::"G/L Account":
                begin
                    SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::"G/L Account");
                    SalesRebateSetup.SetRange("No.", SalesShipmentLine."No.");
                end;
            SalesShipmentLine.Type::"Fixed Asset":
                begin
                    SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::"Fixed Asset");
                    SalesRebateSetup.SetRange("No.", SalesShipmentLine."No.");
                end;
            SalesShipmentLine.Type::"Charge (Item)":
                begin
                    SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::"Charge (Item)");
                    SalesRebateSetup.SetRange("No.", SalesShipmentLine."No.");
                end;
            SalesShipmentLine.Type::Resource:
                begin
                    SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::Resource);
                    SalesRebateSetup.SetRange("No.", SalesShipmentLine."No.");
                end;
        END;
        SalesRebateSetup.SetRange("Customer No.", SalesShipmentLine."Bill-to Customer No.");
        SalesRebateSetup.SetFilter("Starting Date", '%1|<=%2', 0D, SalesShipmentLine."Posting Date");
        SalesRebateSetup.SetFilter("Ending Date", '%1|>=%2', 0D, SalesShipmentLine."Posting Date");
        IF SalesRebateSetup.FindFirst() then
            EXIT;

        IF RebateSetup."Default Setup Rebate Type" = RebateSetup."Default Setup Rebate Type"::"Rebate Category" THEN begin
            IF RebateCategoryCode = '' then
                EXIT;

            SalesRebateSetup.SetRange("Line Type", SalesRebateSetup."Line Type"::"Rebate Category");
            SalesRebateSetup.SetRange("No.", RebateCategoryCode);
            IF SalesRebateSetup.FindFirst() then
                EXIT;
        end;

        SalesRebateSetup.Init();
        case SalesShipmentLine.Type of
            SalesShipmentLine.Type::Item:
                begin
                    SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::Item;
                    SalesRebateSetup."No." := SalesShipmentLine."No.";
                    SalesRebateSetup.Description := SalesShipmentLine.Description;
                    InsertSetupRec := true;
                end;
            SalesShipmentLine.Type::"G/L Account":
                begin
                    SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::"G/L Account";
                    SalesRebateSetup."No." := SalesShipmentLine."No.";
                    SalesRebateSetup.Description := SalesShipmentLine.Description;
                    InsertSetupRec := true;
                end;
            SalesShipmentLine.Type::Resource:
                begin
                    SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::Resource;
                    SalesRebateSetup."No." := SalesShipmentLine."No.";
                    SalesRebateSetup.Description := SalesShipmentLine.Description;
                    InsertSetupRec := true;
                end;
            SalesShipmentLine.Type::"Fixed Asset":
                begin
                    SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::"Fixed Asset";
                    SalesRebateSetup."No." := SalesShipmentLine."No.";
                    SalesRebateSetup.Description := SalesShipmentLine.Description;
                    InsertSetupRec := true;
                end;
            SalesShipmentLine.Type::"Charge (Item)":
                begin
                    SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::"Charge (Item)";
                    SalesRebateSetup."No." := SalesShipmentLine."No.";
                    SalesRebateSetup.Description := SalesShipmentLine.Description;
                    InsertSetupRec := true;
                end;
        END;

        IF RebateSetup."Default Setup Rebate Type" = RebateSetup."Default Setup Rebate Type"::"Rebate Category" THEN BEGIN
            SalesRebateSetup."Line Type" := SalesRebateSetup."Line Type"::"Rebate Category";
            Case SalesShipmentLine.Type of
                SalesShipmentLine.TYPE::Item:
                    begin
                        IF Item.GET(SalesShipmentLine."No.") THEN begin
                            IF Item."AQD Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := Item."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(Item."AQD Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"G/L Account":
                    begin
                        IF GLAccount.get(SalesShipmentLine."No.") then begin
                            IF GLAccount."AQD Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := GLAccount."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(GLAccount."AQD Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::Resource:
                    begin
                        IF Resource.GET(SalesShipmentLine."No.") then begin
                            IF Resource."AQD Rebate Category Code" <> '' THEN BEGIN
                                SalesRebateSetup."No." := Resource."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(Resource."AQD Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"Fixed Asset":
                    begin
                        IF FixedAsset.GET(SalesShipmentLine."No.") then begin
                            IF FixedAsset."AQD Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := FixedAsset."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(FixedAsset."AQD Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"Charge (Item)":
                    begin
                        IF ItemCharge.GET(SalesShipmentLine."No.") then begin
                            IF ItemCharge."AQD Rebate Category Code" <> '' THEN BEGIN
                                SalesRebateSetup."No." := ItemCharge."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(ItemCharge."AQD Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
            End;
        END;

        IF InsertSetupRec THEN BEGIN
            SalesRebateSetup."Variant Code" := SalesShipmentLine."Variant Code";
            SalesRebateSetup."Customer No." := SalesShipmentLine."Bill-to Customer No.";
            SalesRebateSetup."Minimum Quantity" := 0;
            SalesRebateSetup."Rebate Type" := RebateSetup."Default Rebate Type";
            SalesRebateSetup."Rebate %" := RebateSetup."Default Rebate %";
            SalesRebateSetup."Rebate Per Quantity" := RebateSetup."Default Rebate Per Quantity";
            SalesRebateSetup."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
            IF RebateSetup.BlockAutoCreatedPurRebateRate then
                SalesRebateSetup.Validate(Blocked, TRUE);

            RebateCategoryLine.RESET;
            RebateCategoryLine.SetRange("Rebate Category Code", RebateCategoryCode);
            IF RebateCategoryLine.FindFirst() THEN begin
                repeat
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");
                    SalesRebateSetup."Rebate Program Code" := RebateCategoryLine."Rebate Program Code";
                    // IF FORMAT(RebateCodeRec."Start Date Cal Formula") <> '' THEN
                    //     SalesRebateSetup."Starting Date" := CalcDate(RebateCodeRec."Start Date Cal Formula", SalesShipmentLine."Posting Date")
                    // else
                    SalesRebateSetup."Starting Date" := SalesShipmentLine."Posting Date";
                    SalesRebateSetup.INSERT;
                until RebateCategoryLine.Next() = 0;
            end ELSE begin
                IF RebateSetup."Default Rebate Program Code" <> '' THEN BEGIN
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");
                    SalesRebateSetup."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
                    // IF FORMAT(RebateCodeRec."Start Date Cal Formula") <> '' THEN
                    //     SalesRebateSetup."Starting Date" := CalcDate(RebateCodeRec."Start Date Cal Formula", SalesShipmentLine."Posting Date")
                    // else
                    SalesRebateSetup."Starting Date" := SalesShipmentLine."Posting Date";
                    SalesRebateSetup.INSERT;
                END;
            END;
        END;
    END;

    local procedure UpdateSalespersonRebateInfo(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        //SalesHeader."AQD Rebate %" := Customer."AQD Rebate %";
        SalesHeader."AQD Rebate Vendor No" := Customer."AQD Rebate Vendor No";
    end;

    procedure ShowDocument(RebateJnlLine: Record "AQD Rebate Journal Line")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDocument(RebateJnlLine, IsHandled);
        if IsHandled then
            exit;

        case RebateJnlLine."AQDDocument Type" of
            RebateJnlLine."AQDDocument Type"::Invoice:
                begin
                    SalesInvHeader.Get(RebateJnlLine."AQDDocument No.");
                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;
            RebateJnlLine."AQDDocument Type"::"Credit Memo":
                begin
                    SalesCrMemoHeader.Get(RebateJnlLine."AQDDocument No.");
                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
        end;
    end;

    procedure CalcBalance(var RebateJnlLine: Record "AQD Rebate Journal Line"; var TotalBaseAmount: Decimal; var TotalProfitAmount: Decimal; var TotalRebateAmount: Decimal)
    var
        TmpRebateJnlLine: Record "AQD Rebate Journal Line";
    begin
        TmpRebateJnlLine.CopyFilters(RebateJnlLine);
        TmpRebateJnlLine.CalcSums("AQDBase Amount", "AQDProfit Amount", "AQDRebate Amount");

        TotalBaseAmount := TmpRebateJnlLine."AQDBase Amount";
        TotalProfitAmount := TmpRebateJnlLine."AQDProfit Amount";
        TotalRebateAmount := TmpRebateJnlLine."AQDRebate Amount";
    end;

    procedure ShowPostedDocument(DocumentType: Enum "AQD Rebate Document Type"; DocumentNo: COde[20])
    var
        PostedPurchInvoice: Record "Purch. Inv. Header";
        PostedPurchCrMemo: Record "Purch. Cr. Memo Hdr.";
        PostedPurchReceiptHeader: Record "Purch. Rcpt. Header";
        PostedReturnShptHeader: Record "Return Shipment Header";
        PostedPurchInvoicePage: Page "Posted Purchase Invoice";
        PostedPurchCrMemoPage: Page "Posted Purchase Credit Memo";
        PostedPurchReceiptPage: Page "Posted Purchase Receipt";
        PostedReturnShptPage: Page "Posted Return Shipment";
    begin
        CASE DocumentType of
            DocumentType::Invoice:
                begin
                    PostedPurchInvoice.GET(DocumentNo);

                    clear(PostedPurchInvoicePage);
                    PostedPurchInvoicePage.SetRecord(PostedPurchInvoice);
                    PostedPurchInvoicePage.Run();
                end;
            DocumentType::"Credit Memo":
                begin
                    PostedPurchCrMemo.GET(DocumentNo);

                    clear(PostedPurchCrMemoPage);
                    PostedPurchCrMemoPage.SetRecord(PostedPurchCrMemo);
                    PostedPurchCrMemoPage.Run();
                end;
            DocumentType::Receipt:
                begin
                    PostedPurchReceiptHeader.GET(DocumentNo);

                    clear(PostedPurchReceiptPage);
                    PostedPurchReceiptPage.SetRecord(PostedPurchReceiptHeader);
                    PostedPurchReceiptPage.Run();
                end;
            DocumentType::"Return Shipment":
                begin
                    PostedReturnShptHeader.GET(DocumentNo);

                    clear(PostedReturnShptPage);
                    PostedReturnShptPage.SetRecord(PostedReturnShptHeader);
                    PostedReturnShptPage.Run();
                end;
        END;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDocument(RebateJnlLine: Record "AQD Rebate Journal Line"; var IsHandled: Boolean)
    begin
    end;
}

