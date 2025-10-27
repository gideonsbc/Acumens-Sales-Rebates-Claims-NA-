codeunit 14277042 "AQD Vendor Rebate Events Mgt"
{
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchRcptLineInsert, '', false, false)]
    local procedure Cod90_PurchPost_OnAfterPurchRcptLineInsert(PurchaseLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; var TempTrackingSpecification: Record "Tracking Specification" temporary; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; xPurchLine: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary)
    var
        VendorPurchRebateSetup: Record "AQD Vendor Rebate Rate";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        RebateItemCategory: Record "AQD Rebate Item Category";
        RebateCategoryLine: Record "AQD Rebate Category Lines";
        RebateProgramCodeRec: Record "AQD Rebate Program Code";
        Item: Record Item;
        Resource: Record Resource;
        FixedAsset: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        GLAccount: Record "G/L Account";
        VendorItemRebateEligibility: Record "AQD VendItem Rebate Eligib";
        ChkVendItemRebateElig: Codeunit "AQD ChkVendItemRebateElig Mgt";
        InsertSetupRec: Boolean;
        LineRebatable: Boolean;
        IsRebatable: Boolean;

        RebateCategoryCode: Code[20];
    begin
        IF PurchRcptLine.IsTemporary then
            EXIT;

        IF PurchRcptLine.Correction then
            exit;

        IF NOT RebateSetup.GET then
            EXIT;

        IF NOT RebateSetup.AutoCreatePurRebateRateonRcpt then
            EXIT;

        //"Item Type", "Item No.", "Variant Code", "Vendor No.", "Rebate Code", 
        //"Starting Date", "Unit of Measure Code", "Minimum Quantity")

        LineRebatable := FALSE;
        RebateCategoryCode := '';

        Case PurchRcptLine.Type of
            PurchRcptLine.TYPE::Item:
                begin
                    IF Item.GET(PurchRcptLine."No.") THEN begin
                        LineRebatable := Item."AQD Vendor Rebatable";
                        RebateCategoryCode := Item."AQD Rebate Category Code";
                    end;
                end;
            PurchRcptLine.Type::"G/L Account":
                begin
                    IF GLAccount.get(PurchRcptLine."No.") then begin
                        LineRebatable := GLAccount."AQD Vendor Rebatable";
                        RebateCategoryCode := GLAccount."AQD Rebate Category Code";
                    end;
                end;
            PurchRcptLine.Type::Resource:
                begin
                    IF Resource.GET(PurchRcptLine."No.") then begin
                        LineRebatable := Resource."AQD Vendor Rebatable";
                        RebateCategoryCode := Resource."AQD Rebate Category Code";
                    end;
                end;
            PurchRcptLine.Type::"Fixed Asset":
                begin
                    IF FixedAsset.GET(PurchRcptLine."No.") then begin
                        LineRebatable := FixedAsset."AQD Vendor Rebatable";
                        RebateCategoryCode := FixedAsset."AQD Rebate Category Code";
                    end;
                end;
            PurchRcptLine.Type::"Charge (Item)":
                begin
                    IF ItemCharge.GET(PurchRcptLine."No.") then begin
                        LineRebatable := ItemCharge."AQD Vendor Rebatable";
                        RebateCategoryCode := ItemCharge."AQD Rebate Category Code";
                    end;
                end;
        End;

        IF NOT LineRebatable THEN
            EXIT;

        //key(Key1; "Item Type", "Item No.", "Variant Code", "Vendor No.", "Rebate Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        VendorPurchRebateSetup.RESET;
        case PurchRcptLine.Type of
            PurchRcptLine.Type::Item:
                BEGIN
                    VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::Item);
                    VendorPurchRebateSetup.SetRange("No.", PurchRcptLine."No.");
                END;
            PurchRcptLine.Type::"G/L Account":
                begin
                    VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::"G/L Account");
                    VendorPurchRebateSetup.SetRange("No.", PurchRcptLine."No.");
                end;
            PurchRcptLine.Type::"Fixed Asset":
                begin
                    VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::"Fixed Asset");
                    VendorPurchRebateSetup.SetRange("No.", PurchRcptLine."No.");
                end;
            PurchRcptLine.Type::"Charge (Item)":
                begin
                    VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::"Charge (Item)");
                    VendorPurchRebateSetup.SetRange("No.", PurchRcptLine."No.");
                end;
            PurchRcptLine.Type::Resource:
                begin
                    VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::Resource);
                    VendorPurchRebateSetup.SetRange("No.", PurchRcptLine."No.");
                end;
        END;
        VendorPurchRebateSetup.SetRange("Vendor No.", PurchRcptLine."Pay-to Vendor No.");
        VendorPurchRebateSetup.SetFilter("Starting Date", '%1|<=%2', 0D, PurchRcptLine."Posting Date");
        VendorPurchRebateSetup.SetFilter("Ending Date", '%1|>=%2', 0D, PurchRcptLine."Posting Date");
        IF VendorPurchRebateSetup.FindFirst() then
            EXIT;

        IF RebateSetup."Default Setup Rebate Type" = RebateSetup."Default Setup Rebate Type"::"Rebate Category" THEN begin
            IF RebateCategoryCode = '' then
                EXIT;

            VendorPurchRebateSetup.SetRange("Line Type", VendorPurchRebateSetup."Line Type"::"Rebate Category");
            VendorPurchRebateSetup.SetRange("No.", RebateCategoryCode);
            IF VendorPurchRebateSetup.FindFirst() then
                EXIT;
        end;

        VendorPurchRebateSetup.Init();
        case PurchRcptLine.Type of
            PurchRcptLine.Type::Item:
                begin
                    VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::Item;
                    VendorPurchRebateSetup."No." := PurchRcptLine."No.";
                    VendorPurchRebateSetup.Description := PurchRcptLine.Description;
                    InsertSetupRec := true;
                end;
            PurchRcptLine.Type::"G/L Account":
                begin
                    VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::"G/L Account";
                    VendorPurchRebateSetup."No." := PurchRcptLine."No.";
                    VendorPurchRebateSetup.Description := PurchRcptLine.Description;
                    InsertSetupRec := true;
                end;
            PurchRcptLine.Type::Resource:
                begin
                    VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::Resource;
                    VendorPurchRebateSetup."No." := PurchRcptLine."No.";
                    VendorPurchRebateSetup.Description := PurchRcptLine.Description;
                    InsertSetupRec := true;
                end;
            PurchRcptLine.Type::"Fixed Asset":
                begin
                    VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::"Fixed Asset";
                    VendorPurchRebateSetup."No." := PurchRcptLine."No.";
                    VendorPurchRebateSetup.Description := PurchRcptLine.Description;
                    InsertSetupRec := true;
                end;
            PurchRcptLine.Type::"Charge (Item)":
                begin
                    VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::"Charge (Item)";
                    VendorPurchRebateSetup."No." := PurchRcptLine."No.";
                    VendorPurchRebateSetup.Description := PurchRcptLine.Description;
                    InsertSetupRec := true;
                end;
        END;

        IF RebateSetup."Default Setup Rebate Type" = RebateSetup."Default Setup Rebate Type"::"Rebate Category" THEN BEGIN
            VendorPurchRebateSetup."Line Type" := VendorPurchRebateSetup."Line Type"::"Rebate Category";
            Case PurchRcptLine.Type of
                PurchRcptLine.TYPE::Item:
                    begin
                        IF Item.GET(PurchRcptLine."No.") THEN begin
                            IF Item."AQD Rebate Category Code" <> '' then BEGIN
                                VendorPurchRebateSetup."No." := Item."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(Item."AQD Rebate Category Code") then
                                    VendorPurchRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                PurchRcptLine.Type::"G/L Account":
                    begin
                        IF GLAccount.get(PurchRcptLine."No.") then begin
                            IF GLAccount."AQD Rebate Category Code" <> '' then BEGIN
                                VendorPurchRebateSetup."No." := GLAccount."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(GLAccount."AQD Rebate Category Code") then
                                    VendorPurchRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                PurchRcptLine.Type::Resource:
                    begin
                        IF Resource.GET(PurchRcptLine."No.") then begin
                            IF Resource."AQD Rebate Category Code" <> '' THEN BEGIN
                                VendorPurchRebateSetup."No." := Resource."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(Resource."AQD Rebate Category Code") then
                                    VendorPurchRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                PurchRcptLine.Type::"Fixed Asset":
                    begin
                        IF FixedAsset.GET(PurchRcptLine."No.") then begin
                            IF FixedAsset."AQD Rebate Category Code" <> '' then BEGIN
                                VendorPurchRebateSetup."No." := FixedAsset."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(FixedAsset."AQD Rebate Category Code") then
                                    VendorPurchRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
                PurchRcptLine.Type::"Charge (Item)":
                    begin
                        IF ItemCharge.GET(PurchRcptLine."No.") then begin
                            IF ItemCharge."AQD Rebate Category Code" <> '' THEN BEGIN
                                VendorPurchRebateSetup."No." := ItemCharge."AQD Rebate Category Code";
                                IF RebateItemCategory.GET(ItemCharge."AQD Rebate Category Code") then
                                    VendorPurchRebateSetup.Description := RebateItemCategory.Description;
                                InsertSetupRec := TRUE;
                            END;
                        end;
                    end;
            End;
        END;

        IF InsertSetupRec THEN BEGIN
            VendorPurchRebateSetup."Variant Code" := PurchRcptLine."Variant Code";
            VendorPurchRebateSetup."Vendor No." := PurchRcptLine."Pay-to Vendor No.";
            VendorPurchRebateSetup."Minimum Quantity" := 0;
            VendorPurchRebateSetup."Unit of Measure Code" := PurchRcptLine."Unit of Measure Code";
            IF RebateSetup.BlockAutoCreatedPurRebateRate then
                VendorPurchRebateSetup.Validate(Blocked, TRUE);

            RebateCategoryLine.RESET;
            RebateCategoryLine.SetRange("Rebate Category Code", RebateCategoryCode);
            IF RebateCategoryLine.FindFirst() THEN begin
                repeat
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");

                    VendorPurchRebateSetup."Rebate Type" := RebateProgramCodeRec."Vendor Default Rebate Type";
                    VendorPurchRebateSetup."Rebate %" := RebateProgramCodeRec."Vendor Default Rebate %";
                    VendorPurchRebateSetup."Rebate Per Quantity" := RebateProgramCodeRec."Vendor Def Rebate Per Quantity";

                    IsRebatable := FALSE;
                    IsRebatable := ChkVendItemRebateElig.IsPayToVendorEligibleForRebate(VendorItemRebateEligibility,
                                                                                        PurchRcptLine."Pay-to Vendor No.",
                                                                                        PurchRcptLine.Type,
                                                                                        PurchRcptLine."No.",
                                                                                        PurchRcptLine."Posting Date",
                                                                                        RebateCategoryLine."Rebate Program Code");
                    //IF IsRebatable THEN BEGIN
                    VendorPurchRebateSetup."Rebate Program Code" := RebateCategoryLine."Rebate Program Code";
                    IF FORMAT(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt) <> '' THEN
                        VendorPurchRebateSetup."Starting Date" := CalcDate(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt, PurchRcptLine."Posting Date")
                    else
                        VendorPurchRebateSetup."Starting Date" := PurchRcptLine."Posting Date";
                    VendorPurchRebateSetup.INSERT;
                //END;
                until RebateCategoryLine.Next() = 0;
            end ELSE begin
                IF RebateSetup."Default Rebate Program Code" <> '' THEN BEGIN
                    RebateProgramCodeRec.GET(RebateCategoryLine."Rebate Program Code");

                    VendorPurchRebateSetup."Rebate Type" := RebateProgramCodeRec."Vendor Default Rebate Type";
                    VendorPurchRebateSetup."Rebate %" := RebateProgramCodeRec."Vendor Default Rebate %";
                    VendorPurchRebateSetup."Rebate Per Quantity" := RebateProgramCodeRec."Vendor Def Rebate Per Quantity";

                    IsRebatable := FALSE;
                    IsRebatable := ChkVendItemRebateElig.IsPayToVendorEligibleForRebate(VendorItemRebateEligibility,
                                                                                        PurchRcptLine."Pay-to Vendor No.",
                                                                                        PurchRcptLine.Type,
                                                                                        PurchRcptLine."No.",
                                                                                        PurchRcptLine."Posting Date",
                                                                                        RebateCategoryLine."Rebate Program Code");
                    //IF IsRebatable THEN BEGIN
                    VendorPurchRebateSetup."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
                    IF FORMAT(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt) <> '' THEN
                        VendorPurchRebateSetup."Starting Date" := CalcDate(VendorItemRebateEligibility.EligiblePeriodAfterFirstRcpt, PurchRcptLine."Posting Date")
                    else
                        VendorPurchRebateSetup."Starting Date" := PurchRcptLine."Posting Date";
                    VendorPurchRebateSetup.INSERT;
                    //END;
                END;
            END;
        END;
    END;

    [EventSubscriber(ObjectType::Table, 38, 'OnAfterValidateEvent', 'Pay-To Vendor No.', true, false)]
    local procedure Table38_PurchaseHeader_PayToVendorNo(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(Rec."Pay-To Vendor No.") then
            Vendor.Init;
        if Vendor."AQD Enroll for Rebate" then begin
            //Rec."AQD Rebate %" := Vendor."AQD Rebate %";
            //Rec."AQD Rebate Customer No" := Vendor."AQD Rebate Customer No";
            if Vendor."AQD Rebate Vendor No" <> '' then
                Rec."AQD Rebate Vendor No" := Vendor."AQD Rebate Vendor No"
            else
                Rec."AQD Rebate Vendor No" := Vendor."No.";
            Rec."AQD Rebate Last Changed By" := UserId;
            Rec."AQD Rebate LastChangd DateTime" := CurrentDateTime;
        end;
    end;
}