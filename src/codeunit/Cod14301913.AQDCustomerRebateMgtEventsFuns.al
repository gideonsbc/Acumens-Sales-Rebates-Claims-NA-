codeunit 14301913 "AQD CustRbtMgt EventsFunctions"
{

    trigger OnRun()
    begin
    end;

    var
        RebateSingleInstance: Codeunit "AQD Cust Rebate SingleInstance";
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

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table18_Customer_OnBeforeInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if not RebateSetup.Get then
            exit;

        Rec."AQD Rebate Payment Method" := RebateSetup."Def. Rebate Payment Method";
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
        SalesHeader."AQD Customer Rebate Order Date" := SalesHeader."Order Date";
    end;

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

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table5600_FixedAsset_OnBeforeInsert(var Rec: Record "Fixed Asset"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebate Enabled" := RebateSetup."Fixed Asset Rebate Enabled";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', true, false)]
    local procedure Table5800_ItemCharge_OnBeforeInsert(var Rec: Record "Item Charge"; RunTrigger: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec.ISTEMPORARY THEN
            EXIT;

        IF NOT RebateSetup.GET THEN
            EXIT;

        Rec."AQD Customer Rebate Enabled" := RebateSetup."G/L Account Rebate Enabled";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeLookupName', '', true, false)]
    local procedure Cod230_GenJnlManagement_OnBeforeLookupName(var GenJnlBatch: Record "Gen. Journal Batch")
    begin
        // To Show Rebate Batch From Rebate Purchase / Payment Journal
        RebateSingleInstance.GetCalledFromRebate(CalledFromRebate);
        GenJnlBatch.FilterGroup(2);
        GenJnlBatch.SetRange(GenJnlBatch."AQD Customer Rebate", CalledFromRebate);
        GenJnlBatch.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesShptLineInsert, '', false, false)]
    local procedure Cod80_SalesPost_OnAfterSalesShptLineInsert(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesInvoiceHeader: Record "Sales Invoice Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    var
        SalesRebateSetup: Record "AQD Sales Rebates Rate";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        RebateItemCategory: Record "AQD Cust Rebate Item Category";
        RebateCategoryLine: Record "AQD Cust Rebate Category Lines";
        RebateProgramCodeRec: Record "AQD Cust Rebate Program Code";
        CustItemRebateMatrix: record "AQD Cust Item Rebate Matrix";
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

        IF NOT RebateSetup.AutoCreateSaleRebateRateonShpt then
            EXIT;

        //"Item Type", "Item No.", "Variant Code", "Vendor No.", "Rebate Code", 
        //"Starting Date", "Unit of Measure Code", "Minimum Quantity")

        LineRebatable := FALSE;
        RebateCategoryCode := '';

        Case SalesShipmentLine.Type of
            SalesShipmentLine.TYPE::Item:
                begin
                    IF Item.GET(SalesShipmentLine."No.") THEN begin
                        LineRebatable := Item."AQD Customer Rebate Enabled";
                        RebateCategoryCode := Item."AQD Cust Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"G/L Account":
                begin
                    IF GLAccount.get(SalesShipmentLine."No.") then begin
                        LineRebatable := GLAccount."AQD Customer Rebate Enabled";
                        RebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::Resource:
                begin
                    IF Resource.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := Resource."AQD Customer Rebate Enabled";
                        RebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"Fixed Asset":
                begin
                    IF FixedAsset.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := FixedAsset."AQD Customer Rebate Enabled";
                        RebateCategoryCode := FixedAsset."AQD Cust Rebate Category Code";
                    end;
                end;
            SalesShipmentLine.Type::"Charge (Item)":
                begin
                    IF ItemCharge.GET(SalesShipmentLine."No.") then begin
                        LineRebatable := ItemCharge."AQD Customer Rebate Enabled";
                        RebateCategoryCode := ItemCharge."AQD Cust Rebate Category Code";
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
                            IF Item."AQD Cust Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := Item."AQD Cust Rebate Category Code";
                                IF RebateItemCategory.GET(Item."AQD Cust Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"G/L Account":
                    begin
                        IF GLAccount.get(SalesShipmentLine."No.") then begin
                            IF GLAccount."AQD Cust Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := GLAccount."AQD Cust Rebate Category Code";
                                IF RebateItemCategory.GET(GLAccount."AQD Cust Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::Resource:
                    begin
                        IF Resource.GET(SalesShipmentLine."No.") then begin
                            IF Resource."AQD Cust Rebate Category Code" <> '' THEN BEGIN
                                SalesRebateSetup."No." := Resource."AQD Cust Rebate Category Code";
                                IF RebateItemCategory.GET(Resource."AQD Cust Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"Fixed Asset":
                    begin
                        IF FixedAsset.GET(SalesShipmentLine."No.") then begin
                            IF FixedAsset."AQD Cust Rebate Category Code" <> '' then BEGIN
                                SalesRebateSetup."No." := FixedAsset."AQD Cust Rebate Category Code";
                                IF RebateItemCategory.GET(FixedAsset."AQD Cust Rebate Category Code") then
                                    SalesRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                SalesShipmentLine.Type::"Charge (Item)":
                    begin
                        IF ItemCharge.GET(SalesShipmentLine."No.") then begin
                            IF ItemCharge."AQD Cust Rebate Category Code" <> '' THEN BEGIN
                                SalesRebateSetup."No." := ItemCharge."AQD Cust Rebate Category Code";
                                IF RebateItemCategory.GET(ItemCharge."AQD Cust Rebate Category Code") then
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
            SalesRebateSetup."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
            IF RebateSetup.BlockAutoCreatedSaleRebateRate then
                SalesRebateSetup.Validate(Blocked, TRUE);

            RebateCategoryLine.RESET;
            RebateCategoryLine.SetRange("Rebate Category Code", RebateCategoryCode);
            IF RebateCategoryLine.FindFirst() THEN begin
                repeat
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");
                    SalesRebateSetup.validatE("Rebate Program Code", RebateCategoryLine."Rebate Program Code");
                    IF FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt) <> '' THEN
                        SalesRebateSetup."Starting Date" := CalcDate(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt, SalesShipmentLine."Posting Date")
                    else
                        SalesRebateSetup."Starting Date" := SalesShipmentLine."Posting Date";
                    SalesRebateSetup.INSERT;
                until RebateCategoryLine.Next() = 0;
            end ELSE begin
                IF RebateSetup."Default Rebate Program Code" <> '' THEN BEGIN
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");
                    SalesRebateSetup.validate("Rebate Program Code", RebateSetup."Default Rebate Program Code");
                    // IF FORMAT(RebateCodeRec."Start Date Cal Formula") <> '' THEN
                    //     SalesRebateSetup."Starting Date" := CalcDate(RebateCodeRec."Start Date Cal Formula", SalesShipmentLine."Posting Date")
                    // else
                    SalesRebateSetup."Starting Date" := SalesShipmentLine."Posting Date";
                    SalesRebateSetup.INSERT;
                END;
            END;
        END;
    END;

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
}