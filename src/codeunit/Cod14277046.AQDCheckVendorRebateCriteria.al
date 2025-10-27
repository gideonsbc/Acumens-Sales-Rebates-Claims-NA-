codeunit 14277046 "AQD ChkVendItemRebateElig Mgt"
{

    trigger OnRun()
    begin
    end;

    procedure IsPayToVendorEligibleForRebate(var VendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib"; VendorNo: Code[20]; DocumentLine_Type: Enum "Purchase Line Type"; DocumentLine_No: Code[20]; PostingDate: Date; RebateCode: Code[10]): Boolean
    var
        LocalVendor: Record Vendor;
        ItemCard: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        IsHandled: Boolean;
        RebateCategoryCode: Code[20];
        IsVendorEligible: Boolean;
    begin
        IsVendorEligible := FALSE;
        RebateSetup.GET;

        IF NOT RebateSetup."Use Vendor Rebate Criteria" then
            EXIT(TRUE);

        VendorItemRebateEligibility.RESET;
        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                begin
                    ItemCard.GET(DocumentLine_No);
                    RebateCategoryCode := ItemCard."AQD Rebate Category Code";
                    VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::Item);
                end;
            DocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(DocumentLine_No);
                    RebateCategoryCode := Resource."AQD Rebate Category Code";
                    VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::Resource);
                END;
            DocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(DocumentLine_No);
                    RebateCategoryCode := GLAccount."AQD Rebate Category Code";
                    VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::"G/L Account");
                END;
            DocumentLine_Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(DocumentLine_No);
                    RebateCategoryCode := ItemCharge."AQD Rebate Category Code";
                    VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::"Charge (Item)");
                END;
            DocumentLine_Type::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(DocumentLine_No);
                    RebateCategoryCode := FixedAsset."AQD Rebate Category Code";
                    VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::"Fixed Asset");
                END;
        END;
        VendorItemRebateEligibility.SetFilter("No.", '%1|%2', ' ', DocumentLine_No);
        VendorItemRebateEligibility.SetRange("Rebate Program Code", RebateCode);
        VendorItemRebateEligibility.SETRANGE(Blocked, false);

        VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::All);
        VendorItemRebateEligibility.SetRange("Vendor No.");
        IF VendorItemRebateEligibility.FindFirst() THEN begin
            IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    VendorItemRebateEligibility,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsVendorEligible);
        end;

        VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::Vendor);
        VendorItemRebateEligibility.SetFilter("Vendor No.", '%1|%2', ' ', VendorNo);
        IF VendorItemRebateEligibility.FindFirst() THEN begin
            IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    VendorItemRebateEligibility,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsVendorEligible);
        end;

        IF LocalVendor.GET(VendorNo) THEN BEGIN
            IF LocalVendor."AQD Rebate Vendor Type" <> '' then begin
                VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::"Vendor Type");
                VendorItemRebateEligibility.SetFilter("Vendor No.", '%1|%2', ' ', LocalVendor."AQD Rebate Vendor Type");
                IF VendorItemRebateEligibility.FindFirst() THEN begin
                    IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                            DocumentLine_Type,
                                            DocumentLine_No,
                                            VendorItemRebateEligibility,
                                            PostingDate,
                                            RebateCode);

                    EXIT(IsVendorEligible);
                end;
            end;
        END;

        VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::All);
        VendorItemRebateEligibility.SetRange("Vendor No.");
        VendorItemRebateEligibility.SetRange("Line Type", VendorItemRebateEligibility."Line Type"::"Rebate Category");
        VendorItemRebateEligibility.SetFilter("No.", '%1|%2', ' ', RebateCategoryCode);
        IF VendorItemRebateEligibility.FindFirst() THEN begin
            IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    VendorItemRebateEligibility,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsVendorEligible);
        end;

        VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::Vendor);
        VendorItemRebateEligibility.SetFilter("Vendor No.", '%1|%2', ' ', VendorNo);
        IF VendorItemRebateEligibility.FindFirst() THEN begin
            IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    VendorItemRebateEligibility,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsVendorEligible);
        end;

        IF LocalVendor.GET(VendorNo) THEN BEGIN
            IF LocalVendor."AQD Rebate Vendor Type" <> '' then begin
                VendorItemRebateEligibility.SetRange("Vendor Type", VendorItemRebateEligibility."Vendor Type"::"Vendor Type");
                VendorItemRebateEligibility.SetFilter("Vendor No.", '%1|%2', ' ', LocalVendor."AQD Rebate Vendor Type");
                IF VendorItemRebateEligibility.FindFirst() THEN begin
                    IsVendorEligible := CheckVendorItemRebateEligibility(VendorNo,
                                            DocumentLine_Type,
                                            DocumentLine_No,
                                            VendorItemRebateEligibility,
                                            PostingDate,
                                            RebateCode);
                    EXIT(IsVendorEligible);
                end;
            end;
        END;
    END;

    local procedure CopyVendorPurchaseRebateToVendorPurchaseRebate(var FromVendItemRebateEligibility: Record "AQD VendItem Rebate Eligib"; var ToVendItemRebateEligibility: Record "AQD VendItem Rebate Eligib" temporary)
    begin
        IF FromVendItemRebateEligibility.FINDSET THEN
            REPEAT
                ToVendItemRebateEligibility := FromVendItemRebateEligibility;
                ToVendItemRebateEligibility.INSERT;
            UNTIL FromVendItemRebateEligibility.NEXT = 0;
    END;

    local procedure CheckVendorItemRebateEligibility(VendorNo: Code[20]; DocumentLine_Type: Enum "Purchase Line Type"; DocumentLine_No: Code[20]; var VendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib"; PostingDate: Date; RebateCode: Code[10]): Boolean
    var
        LocalItem: Record Item;
        LocalItemLedgerEntry: Record "Item Ledger Entry";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        IsEligible: Boolean;
        FirstReceiptDateCriteria: Date;
    begin
        IsEligible := FALSE;
        RebateSetup.GET;
        if not RebateSetup."Use Vendor Rebate Criteria" then
            EXIT(TRUE);

        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                begin
                    LocalItem.GET(DocumentLine_No);
                    LocalItem.CalcFields("AQD Purchases (Qty.)", "Purchases (LCY)");

                    IF (VendorItemRebateEligibility."Purchase Quantity Threshold" <> 0) AND
                        (VendorItemRebateEligibility."Purchase Quantity Threshold" < LocalItem."AQD Purchases (Qty.)")
                    THEN
                        IsEligible := true;

                    IF (VendorItemRebateEligibility."Purchase Amount Threshold" <> 0) AND
                        (VendorItemRebateEligibility."Purchase Amount Threshold" < LocalItem."Purchases (LCY)")
                    THEN
                        IsEligible := TRUE;

                    IF (FORMAT(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt) <> '')
                    THEN BEGIN
                        FirstReceiptDateCriteria := CalcDate('-' + FORMAT(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt), PostingDate);

                        LocalItemLedgerEntry.RESET;
                        LocalItemLedgerEntry.SetRange("Entry Type", LocalItemLedgerEntry."Entry Type"::Purchase);
                        LocalItemLedgerEntry.SETFILTER("Document Type", '%1|%2',
                            LocalItemLedgerEntry."Document Type"::"Purchase Receipt",
                            LocalItemLedgerEntry."Document Type"::"Purchase Invoice");
                        LocalItemLedgerEntry.SETRANGE("Item No.", DocumentLine_No);
                        LocalItemLedgerEntry.SETRANGE("Source Type", LocalItemLedgerEntry."Source Type"::Vendor);
                        LocalItemLedgerEntry.SETRANGE("Source No.", VendorNo);
                        LocalItemLedgerEntry.SETFILTER("Posting Date", '<=%1', FirstReceiptDateCriteria);
                        IF LocalItemLedgerEntry.FindFirst() THEN
                            IsEligible := TRUE
                        ELSE
                            IsEligible := FALSE;
                    END;
                END;
            // Currently Not Implement for other Types
            DocumentLine_Type::Resource:
                BEGIN
                END;
            DocumentLine_Type::"G/L Account":
                BEGIN
                END;
            DocumentLine_Type::"Charge (Item)":
                BEGIN
                END;
            DocumentLine_Type::"Fixed Asset":
                BEGIN
                END;
        END;
        EXIT(IsEligible);
    end;

    var
        TempVendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib" temporary;
}