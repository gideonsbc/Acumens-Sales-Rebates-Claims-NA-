codeunit 14277044 "AQD Purch Rebate Calc. Mgt."
{

    trigger OnRun()
    begin
    end;

    procedure FindPurchLineRebate(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details")
    var
        IsHandled: Boolean;
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShptLine: Record "Return Shipment Line";
    begin
        TempVendorPurchRebates.RESET;
        IF TempVendorPurchRebates.IsTemporary THEN
            TempVendorPurchRebates.DeleteAll();

        Case VendorRebateDetailsLocIn."Document Type" OF
            VendorRebateDetailsLocIn."Document Type"::Invoice:
                begin
                    PurchInvLine.GET(VendorRebateDetailsLocIn."Document No.", VendorRebateDetailsLocIn."Document Line No.");
                    PurchInvLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(PurchInvLine."Unit of Measure Code",
                           ABS(VendorRebateDetailsLocIn.Quantity),
                           PurchInvLine."Qty. per Unit of Measure");
                    PostingDate := PurchInvLine."Posting Date";
                    UOM := PurchInvLine."Unit of Measure Code";
                end;
            VendorRebateDetailsLocIn."Document Type"::"Credit Memo":
                BEGIN
                    PurchCrMemoLine.GET(VendorRebateDetailsLocIn."Document No.", VendorRebateDetailsLocIn."Document Line No.");
                    PurchCrMemoLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(PurchCrMemoLine."Unit of Measure Code",
                           ABS(VendorRebateDetailsLocIn.Quantity),
                           PurchCrMemoLine."Qty. per Unit of Measure");
                    PostingDate := PurchCrMemoLine."Posting Date";
                    UOM := PurchCrMemoLine."Unit of Measure Code";
                END;
            VendorRebateDetailsLocIn."Document Type"::Receipt:
                begin
                    PurchRcptLine.GET(VendorRebateDetailsLocIn."Document No.", VendorRebateDetailsLocIn."Document Line No.");
                    PurchRcptLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(PurchRcptLine."Unit of Measure Code",
                           ABS(VendorRebateDetailsLocIn.Quantity),
                           PurchRcptLine."Qty. per Unit of Measure");
                    PostingDate := PurchRcptLine."Posting Date";
                    UOM := PurchRcptLine."Unit of Measure Code";
                end;
            VendorRebateDetailsLocIn."Document Type"::"Return Shipment":
                BEGIN
                    ReturnShptLine.GET(VendorRebateDetailsLocIn."Document No.", VendorRebateDetailsLocIn."Document Line No.");
                    ReturnShptLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(ReturnShptLine."Unit of Measure Code",
                           ABS(VendorRebateDetailsLocIn.Quantity),
                           ReturnShptLine."Qty. per Unit of Measure");
                    PostingDate := ReturnShptLine."Posting Date";
                    UOM := ReturnShptLine."Unit of Measure Code";
                END;
        End;

        Vend.GET(VendorRebateDetailsLocIn."Pay-to Vendor No.");
        PurchLineRebateExists(VendorRebateDetailsLocIn);
        CalcBestPurchaseRebate(TempVendorPurchRebates);

        VendorRebateDetailsLocIn."Rebate Type" := TempVendorPurchRebates."Rebate Type";
        VendorRebateDetailsLocIn."Rebate %" := TempVendorPurchRebates."Rebate %";
        VendorRebateDetailsLocIn."Rebate Per Quantity" := TempVendorPurchRebates."Rebate Per Quantity";
    END;

    procedure PurchLineRebateExists(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details"): Boolean;
    var
        IsHandled: Boolean;
    begin
        FindPurchaseRebate(VendorRebateDetailsLocIn);
        EXIT(TempVendorPurchRebates.FINDFIRST);
    end;

    procedure FindPurchaseRebate(var VendorRebateDetailsLocIn: Record "AQD Vendor Rebate Details")
    var
        VendorFromPurchRebates: Record "AQD Vendor Rebate Rate";
        LocalVendor: Record Vendor;
        ItemCard: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        ItemRebateCategories: Record "AQD Rebate Item Category";
        RebateCategoryCodeFilter: Code[50];
    begin
        TempVendorPurchRebates.RESET;
        IF TempVendorPurchRebates.ISTEMPORARY THEN
            TempVendorPurchRebates.DELETEALL;

        VendorFromPurchRebates.RESET;
        CASE VendorRebateDetailsLocIn.Type OF
            VendorRebateDetailsLocIn.Type::Item:
                begin
                    ItemCard.GET(VendorRebateDetailsLocIn."No.");
                    VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::Item);
                end;
            VendorRebateDetailsLocIn.Type::Resource:
                BEGIN
                    Resource.GET(VendorRebateDetailsLocIn."No.");
                    VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::Resource);
                END;
            VendorRebateDetailsLocIn.Type::"G/L Account":
                BEGIN
                    GLAccount.GET(VendorRebateDetailsLocIn."No.");
                    VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::"G/L Account");
                END;
            VendorRebateDetailsLocIn.Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(VendorRebateDetailsLocIn."No.");
                    VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::"Charge (Item)");
                END;
            VendorRebateDetailsLocIn.TYPE::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(VendorRebateDetailsLocIn."No.");
                    VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::"Fixed Asset");
                END;
        END;
        VendorFromPurchRebates.SetFilter("No.", '%1|%2', ' ', VendorRebateDetailsLocIn."No.");
        VendorFromPurchRebates.SETFILTER("Variant Code", '%1|%2', '', '');
        VendorFromPurchRebates.SETFILTER("Ending Date", '%1|>=%2', 0D, PostingDate);
        IF UOM <> '' THEN
            VendorFromPurchRebates.SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
        VendorFromPurchRebates.SETRANGE("Starting Date", 0D, PostingDate);
        VendorFromPurchRebates.SETRANGE(Blocked, false);
        VendorFromPurchRebates.SetRange("Rebate Program Code", VendorRebateDetailsLocIn."Rebate Program Code");
        VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::All);
        VendorFromPurchRebates.SetRange("Vendor No.");
        CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);

        VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::Vendor);
        VendorFromPurchRebates.SetFilter("Vendor No.", '%1|%2', ' ', VendorRebateDetailsLocIn."Pay-to Vendor No.");
        CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);

        IF LocalVendor.GET(VendorRebateDetailsLocIn."Pay-to Vendor No.") THEN BEGIN
            IF LocalVendor."AQD Rebate Vendor Type" <> '' then begin
                VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::"Vendor Type");
                VendorFromPurchRebates.SetFilter("Vendor No.", '%1|%2', ' ', LocalVendor."AQD Rebate Vendor Type");
                CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);
            end;
        END;

        VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::All);
        VendorFromPurchRebates.SetRange("Vendor No.");
        VendorFromPurchRebates.SetRange("Line Type", VendorFromPurchRebates."Line Type"::"Rebate Category");
        VendorFromPurchRebates.SetFilter("No.", '%1|%2', ' ', VendorRebateDetailsLocIn."Rebate Item Category Code");
        VendorFromPurchRebates.SetRange("Variant Code");
        VendorFromPurchRebates.SetRange("Unit of Measure Code");
        CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);

        VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::Vendor);
        VendorFromPurchRebates.SetFilter("Vendor No.", '%1|%2', ' ', VendorRebateDetailsLocIn."Pay-to Vendor No.");
        CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);

        IF LocalVendor.GET(VendorRebateDetailsLocIn."Pay-to Vendor No.") THEN BEGIN
            IF LocalVendor."AQD Rebate Vendor Type" <> '' then begin
                VendorFromPurchRebates.SetRange("Vendor Type", VendorFromPurchRebates."Vendor Type"::"Vendor Type");
                VendorFromPurchRebates.SetFilter("Vendor No.", '%1|%2', ' ', LocalVendor."AQD Rebate Vendor Type");
                CopyVendorPurchaseRebateToVendorPurchaseRebate(VendorFromPurchRebates, TempVendorPurchRebates);
            end;
        END;
    END;

    procedure CalcBestPurchaseRebate(var VendorPurchRebates: Record "AQD Vendor Rebate Rate")
    var
        BestVendorPurchaseRebate: Record "AQD Vendor Rebate Rate";
        BestPurchaseRebateFound: Boolean;
        FoundPurchaseRebate: Boolean;
    begin
        WITH VendorPurchRebates DO BEGIN
            FoundPurchaseRebate := FINDSET;
            IF FoundPurchaseRebate THEN
                REPEAT
                    IF IsInMinQty("Minimum Quantity") THEN BEGIN
                        CASE TRUE OF
                            ((BestVendorPurchaseRebate."Variant Code" = '') OR ("Variant Code" <> '')):
                                BEGIN
                                    BestVendorPurchaseRebate := VendorPurchRebates;
                                    BestPurchaseRebateFound := TRUE;
                                END;
                        END;
                    END;
                UNTIL NEXT = 0;
        END;
        TempVendorPurchRebates := BestVendorPurchaseRebate;
    end;

    local procedure CopyVendorPurchaseRebateToVendorPurchaseRebate(var FromVendorPurchRebates: Record "AQD Vendor Rebate Rate"; var ToVendorPurchRebates: Record "AQD Vendor Rebate Rate" temporary)
    begin
        WITH ToVendorPurchRebates DO BEGIN
            IF FromVendorPurchRebates.FINDSET THEN
                REPEAT
                    ToVendorPurchRebates := FromVendorPurchRebates;
                    INSERT;
                UNTIL FromVendorPurchRebates.NEXT = 0;
        END;
    end;

    LOCAL procedure SetUoM(UnitofMeasureCode2: Code[10]; Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        UnitofMeasureCode := UnitofMeasureCode2;
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure IsInMinQty(MinQty: Decimal): Boolean
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;

    var
        TempVendorPurchRebates: Record "AQD Vendor Rebate Rate" temporary;
        //Item: Record Item;
        Vend: Record Vendor;
        UnitofMeasureCode: Code[10];
        PostingDate: Date;
        Qty: decimal;
        QtyPerUOM: Decimal;
        UOM: Code[10];
}