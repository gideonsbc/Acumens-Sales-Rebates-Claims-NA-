codeunit 14277045 "AQD Vendor Rebate Post"
{
    Permissions = tabledata "Purch. Inv. Header" = rimd, tabledata "Purch. Cr. Memo Hdr." = rimd;

    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
        Vendor: Record Vendor;
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendorRebateLine: Record "AQD Vendor Rebate Line";
        VendorRebateDetails: Record "AQD Vendor Rebate Details";
        Rebatecomments: Record "AQD Vendor Rebate Comments";
        JnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line";
        TmpInvoicePostingBuffer: Record "Invoice Posting Buffer" Temporary;
        TmpInovoiceBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        TmpCrMemoBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        PurchInvoice: Record "Purchase Header";
        PurchaseCredirMemo: Record "Purchase Header";
        PurchaseCrMemoLine: Record "Purchase Line";
        PurchInvoiceLine: Record "Purchase Line";
        ItemChargeAssignmentPurchase: Record "Item Charge Assignment (Purch)";
        PostedVendorRebateLineDetails: Record "AQD Posted Ven Reb Details";
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        NoSeriesMgt: Codeunit "No. Series";
        TempRebateSummary: Record "Invoice Posting Buffer";
        GlobalGroupID: Text[20];
        PurchaseRebateForText: Label 'Purchase Rebate for ';

    procedure PostVendorRebateBatch(var VendorRebateBatch: Record "AQD Vendor Rebate Batch")
    var
        VendorRebateHeader: Record "AQD Vendor Rebate Header";
        SavedRecords: Boolean;
    begin
        SavedRecords := FALSE;

        RebateSetup.Get();

        VendorRebateBatch.TestField(BatchID);

        VendorRebateHeader.RESET;
        VendorRebateHeader.SetCurrentKey(BatchID);
        VendorRebateHeader.SetRange("Batch Entry No.", VendorRebateBatch."Entry No.");
        VendorRebateHeader.SetRange(BatchID, VendorRebateBatch.BatchID);
        IF VendorRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                IF VendorRebateHeader."Posting Date" <> VendorRebateBatch."Posting Date" then begin
                    VendorRebateHeader.Validate("Posting Date", VendorRebateBatch."Posting Date");
                    VendorRebateHeader.Modify();
                    SavedRecords := TRUE;
                end;
            until VendorRebateHeader.Next() = 0;
            IF SavedRecords then
                Commit();
        end;

        IF VendorRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                OnBeforePostVendorRebates(VendorRebateHeader);
                // CASE RebateSetup."Vendor Rebate Posting" OF
                //     RebateSetup."Vendor Rebate Posting"::"Post To G/L By Rebate Document":
                //         PostRebateToGLByRebateDocument(VendorRebateHeader);
                //     RebateSetup."Vendor Rebate Posting"::"Post To G/L By Rebate Line":
                //         PostRebateToGLByRebateLine(VendorRebateHeader);
                // END;
                PostVendorRebate(VendorRebateHeader, FALSE);
                OnAfterPostVendorRebates(VendorRebateHeader);
            until VendorRebateHeader.Next() = 0;
        END
    end;

    procedure PostVendorRebate(var VendorRebateHeader: Record "AQD Vendor Rebate Header"; ShowDialogue: Boolean)
    var
        UserConfirmLabel: Label 'Do you want to post Rebate %1?';
    begin
        IF ShowDialogue THEN
            IF NOT Confirm(StrSubstNo(UserConfirmLabel, VendorRebateHeader."No.")) then
                EXIT;

        OnBeforePostVendorRebates(VendorRebateHeader);

        TempRebateSummary.RESET;
        IF TempRebateSummary.IsTemporary then
            TempRebateSummary.DeleteAll();
        GlobalGroupID := 'G00000001';

        RebateSetup.Get();

        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        //VendorRebateLine.SetRange(Posted, false);
        if VendorRebateLine.FindSet() then begin
            repeat
                VendorRebateLine.CalcFields("Vendor Rebate Amount");
                if VendorRebateLine."Vendor Rebate Amount" = 0 then begin
                    VendorRebateLine.Exclude := true;
                    VendorRebateLine.Modify(true);
                end;
            until VendorRebateLine.Next() = 0;
        end;
        // CASE RebateSetup."Vendor Rebate Posting" OF
        //     RebateSetup."Vendor Rebate Posting"::"Post To G/L By Rebate Document":
        //         PostRebateToGLByRebateDocument(VendorRebateHeader);
        //     RebateSetup."Vendor Rebate Posting"::"Post To G/L By Rebate Line":
        //         PostRebateToGLByRebateLine(VendorRebateHeader);
        // END;

        UpdatePosted(VendorRebateHeader);
        UpdateExcluded(VendorRebateHeader);
        MoveVendorRebates(VendorRebateHeader);

        OnAfterPostVendorRebates(VendorRebateHeader);
    end;

    local procedure UpdatePosted(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        if VendorRebateLine.FindSet() then begin
            repeat
                case VendorRebateLine."Document Type" of
                    VendorRebateLine."Document Type"::Invoice:
                        begin
                            if PurchaseInvHeader.Get(VendorRebateLine."Document No.") then begin
                                PurchaseInvHeader."AQD Rebate Status" := PurchaseInvHeader."AQD Rebate Status"::Posted;
                                PurchaseInvHeader."AQD Rebate Vendor No" := VendorRebateLine."Rebate No.";
                                PurchaseInvHeader.Modify(true);
                            end;
                        end;
                    VendorRebateLine."Document Type"::"Credit Memo":
                        begin
                            if PurchCrMemoHeader.Get(VendorRebateLine."Document No.") then begin
                                PurchCrMemoHeader."AQD Rebate Status" := PurchCrMemoHeader."AQD Rebate Status"::Posted;
                                PurchCrMemoHeader."AQD Rebate No." := VendorRebateLine."Rebate No.";
                                PurchCrMemoHeader.Modify(true);
                            end;
                        end;
                end;

                RebateItemLdgrEntry.RESET;
                RebateItemLdgrEntry.SetRange("AQD Rebate No", VendorRebateLine."Rebate No.");
                RebateItemLdgrEntry.SetRange("AQD Rebate Line No", VendorRebateLine."Line No.");
                IF RebateItemLdgrEntry.FindFirst() THEN begin
                    repeat
                        RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                        RebateItemLdgrEntry.Modify();
                    until RebateItemLdgrEntry.Next() = 0;
                end;
            until VendorRebateLine.Next() = 0;
        end;
    end;

    local procedure UpdateExcluded(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        VendorRebateLine: Record "AQD Vendor Rebate Line";
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        VendorRebateLine.SetRange(Exclude, true);
        if VendorRebateLine.FindSet() then begin
            repeat
                VendorRebateLine.CalcFields("Vendor Rebate Amount");
                case VendorRebateLine."Document Type" of
                    VendorRebateLine."Document Type"::Invoice:
                        begin
                            if PurchaseInvHeader.Get(VendorRebateLine."Document No.") then begin
                                PurchaseInvHeader."AQD Do Not Pay Rebate" := true;
                                PurchaseInvHeader.Modify(true);
                            end;
                        end;
                    VendorRebateLine."Document Type"::"Credit Memo":
                        begin
                            if PurchCrMemoHeader.Get(VendorRebateLine."Document No.") then begin
                                PurchCrMemoHeader."AQD Do Not Pay Rebate" := true;
                                PurchCrMemoHeader.Modify(true);
                            end;
                        end;
                end;

                RebateItemLdgrEntry.RESET;
                RebateItemLdgrEntry.SetRange("AQD Rebate No", VendorRebateLine."Rebate No.");
                RebateItemLdgrEntry.SetRange("AQD Rebate Line No", VendorRebateLine."Line No.");
                IF RebateItemLdgrEntry.FindFirst() THEN begin
                    repeat
                        RebateItemLdgrEntry."AQD Do Not Pay Rebate" := VendorRebateLine.Exclude;
                        RebateItemLdgrEntry.Modify();
                    until RebateItemLdgrEntry.Next() = 0;
                end;
            until VendorRebateLine.Next() = 0;
        end;
    end;

    local procedure MoveVendorRebates(VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header";
        PostedVendorRebateBatch: Record "AQD Posted Vendor Rebate Batch";
        LocalVendorRebateHeader: Record "AQD Vendor Rebate Header";
        VendorRebateBatch: Record "AQD Vendor Rebate Batch";
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin
        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        if VendorRebateLine.FindFirst() then begin
            PostedVendorRebateHeader.Init();
            PostedVendorRebateHeader.TransferFields(VendorRebateHeader);
            PostedVendorRebateHeader.Insert();

            MoveVendorRebateLine(VendorRebateHeader);
            MoveVendorRebateComments(VendorRebateHeader);

            VendorRebateHeader.Delete();

            IF RebateSetup."Rebate Cr. Memo Posting" <> RebateSetup."Rebate Cr. Memo Posting"::Manual THEN BEGIN
                CreatePurchaseDocument(PostedVendorRebateHeader, false);

                IF RebateSetup."Rebate Cr. Memo Posting" = RebateSetup."Rebate Cr. Memo Posting"::"Create and Post Cr. Memo" THEN BEGIN
                    TmpInovoiceBuffer.RESET;
                    IF TmpInovoiceBuffer.FindFirst() THEN begin
                        REPEAT
                            IF PurchaseHeader.GET(TmpInovoiceBuffer."Order Line No.",
                                                  TmpInovoiceBuffer."Order No.")
                            THEN BEGIN
                                PurchaseHeader.Receive := TRUE;
                                PurchaseHeader.Invoice := TRUE;
                                PurchPost.Run(PurchaseHeader);
                            END;
                        UNTIL TmpInovoiceBuffer.Next() = 0;
                    end;

                    TmpCrMemoBuffer.RESET;
                    IF TmpCrMemoBuffer.FindFirst() THEN begin
                        REPEAT
                            IF PurchaseHeader.GET(TmpCrMemoBuffer."Order Line No.",
                                                  TmpCrMemoBuffer."Order No.")
                            THEN BEGIN
                                PurchaseHeader.Ship := TRUE;
                                PurchaseHeader.Invoice := TRUE;
                                PurchPost.Run(PurchaseHeader);
                            END;
                        UNTIL TmpCrMemoBuffer.Next() = 0;
                    end;
                END;
            END;
        end;

        IF VendorRebateHeader.BatchID <> '' THEN BEGIN
            LocalVendorRebateHeader.RESET;
            LocalVendorRebateHeader.SetRange("Batch Entry No.", VendorRebateHeader."Batch Entry No.");
            LocalVendorRebateHeader.SetRange(BatchID, VendorRebateHeader.BatchID);
            IF NOT LocalVendorRebateHeader.FindFirst() THEN begin
                VendorRebateBatch.RESET;
                VendorRebateBatch.SetRange("Entry No.", VendorRebateHeader."Batch Entry No.");
                VendorRebateBatch.SETRANGE(BatchID, VendorRebateHeader.BatchID);
                IF VendorRebateBatch.FindFirst() THEN BEGIN
                    PostedVendorRebateBatch.Init();
                    PostedVendorRebateBatch.TransferFields(VendorRebateBatch);
                    PostedVendorRebateBatch.Insert();
                    VendorRebateBatch.Delete();
                END;
            end;
        END;
    end;

    local procedure MoveVendorRebateLine(VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line";
    begin
        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        if VendorRebateLine.FindSet() then begin
            repeat
                //f VendorRebateLine.Posted or VendorRebateLine.Exclude then begin
                MoveVendorRebateDetails(VendorRebateLine);
                PostedVendorRebateLine.Init();
                PostedVendorRebateLine.TransferFields(VendorRebateLine);
                if PostedVendorRebateLine.Insert() then
                    VendorRebateLine.Delete();
            //end;
            until VendorRebateLine.Next() = 0;
        end;
    end;

    local procedure MoveVendorRebateDetails(VendorRebateLine: Record "AQD Vendor Rebate Line")
    var
        PostedVendorRebateDetails: Record "AQD Posted Ven Reb Details";
    begin
        VendorRebateDetails.Reset();
        VendorRebateDetails.SetRange("Rebate No.", VendorRebateLine."Rebate No.");
        VendorRebateDetails.SetRange("Rebate Line No.", VendorRebateLine."Line No.");
        if VendorRebateDetails.FindSet() then begin
            repeat
                PostedVendorRebateDetails.Init();
                PostedVendorRebateDetails.TransferFields(VendorRebateDetails);
                if PostedVendorRebateDetails.Insert() then
                    VendorRebateDetails.Delete();
            until VendorRebateDetails.Next() = 0;
        end;
    end;

    local procedure MoveVendorRebateComments(VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        PostedRebateComments: Record "AQD Posted Ven Reb Comment";
    begin
        Rebatecomments.Reset();
        Rebatecomments.SetRange("Rebate No.", VendorRebateHeader."No.");
        if Rebatecomments.FindSet() then begin
            repeat
                PostedRebateComments.Init();
                PostedRebateComments.TransferFields(Rebatecomments);
                if PostedRebateComments.Insert() then
                    Rebatecomments.Delete();
            until Rebatecomments.Next() = 0;
        end;
    end;

    //>> Create Purchase Invoice/Credit Memo from Posted Rebate Document
    procedure CreatePurchaseDocument(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header"; ShowDialogue: Boolean)
    var
        RebateStatusError: Label 'Rebate Status must not be %1.';
        UserConfirmMsg: Label 'Do you want to create Purchase Document for Posted Rebate %1';
        SuccessfulMsg: Label 'Purchase Document is created successfully for Posted Vendor Rebate %1.';
    begin
        IF ShowDialogue THEN
            IF NOT CONFIRM(StrSubstNo(UserConfirmMsg, PostedVendorRebateHeader."No.")) then
                EXIT;

        RebateSetup.GET;

        TmpInovoiceBuffer.RESET;
        IF TmpInovoiceBuffer.IsTemporary then
            TmpInovoiceBuffer.DeleteAll();

        TmpCrMemoBuffer.RESET;
        IF TmpCrMemoBuffer.IsTemporary then
            TmpCrMemoBuffer.DeleteAll();

        //IF PostedVendorRebateHeader."AQD Rebate Status" <> PostedVendorRebateHeader."AQD Rebate Status"::" " THEN
        //    Error(RebateStatusError, PostedVendorRebateHeader."AQD Rebate Status");

        PostedVendorRebateLine.Reset();
        PostedVendorRebateLine.SetRange("Rebate No.", PostedVendorRebateHeader."No.");
        PostedVendorRebateLine.SetRange(Posted, false);
        PostedVendorRebateLine.SetRange("Rebate Status", PostedVendorRebateLine."Rebate Status"::" ");
        PostedVendorRebateLine.SetRange(Exclude, false);
        If PostedVendorRebateLine.FindFirst() Then Begin
            Repeat
                PostedVendorRebateLine.CalcFields("Vendor Rebate Amount");
                IF PostedVendorRebateLine."Vendor Rebate Amount" > 0 THEN Begin
                    //Create Purchase Credit Memo
                    CreatePurchaseCrMemoLine(PostedVendorRebateHeader, PostedVendorRebateLine);
                END ELSE IF PostedVendorRebateLine."Vendor Rebate Amount" < 0 THEN Begin
                    //Create Purchase Invoice
                    CreatePurchaseInvoiceLine(PostedVendorRebateHeader, PostedVendorRebateLine);
                END;
            Until PostedVendorRebateLine.Next() = 0;
        End;
        IF ShowDialogue then
            Message(StrSubstNo(SuccessfulMsg, PostedVendorRebateHeader."No."));
    End;

    local procedure CreatePurchaseCrMemoLine(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header"; var PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line")
    var
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        NextLineNo: Integer;
    begin
        PostedVendorRebateLine.CalcFields("Vendor Rebate Amount", "Vendor Rebate Amt(Item Charge)", "Vendor Rebate Amt (GL)");

        TmpCrMemoBuffer.RESET;
        IF NOT TmpCrMemoBuffer.FindFirst() THEN begin
            //Create Purchase Credit Memo Header
            PurchaseCredirMemo.INIT;
            PurchaseCredirMemo.SetHideValidationDialog(TRUE);
            PurchaseCredirMemo."Document Type" := PurchaseCredirMemo."Document Type"::"Credit Memo";
            PurchaseCredirMemo."No." := '';
            PurchaseCredirMemo.Insert(TRUE);
            PurchaseCredirMemo.Validate("Buy-from Vendor No.", PostedVendorRebateLine."Buy-from Vendor No.");
            PurchaseCredirMemo.VALIDATE("Pay-to Vendor No.", PostedVendorRebateLine."Pay-to Vendor No.");
            PurchaseCredirMemo.validate("Location Code", PostedVendorRebateHeader."Location Code");
            PurchaseCredirMemo.Validate("Posting Date", PostedVendorRebateHeader."Posting Date");
            PurchaseCredirMemo."Posting Description" := PostedVendorRebateHeader."Posting Description";
            PurchaseCredirMemo.Validate("Posting Date", PostedVendorRebateHeader."Posting Date");
            PurchaseCredirMemo."Vendor Cr. Memo No." := PostedVendorRebateHeader."No.";
            PurchaseCredirMemo."AQD Vendor Rebate No" := PostedVendorRebateHeader."No.";
            PurchaseCredirMemo.Modify(TRUE);

            PostedVendorRebateHeader."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateHeader.Modify;

            TmpCrMemoBuffer.INIT;
            TmpCrMemoBuffer."Order No." := PurchaseCredirMemo."No.";
            TmpCrMemoBuffer."Order Line No." := PurchaseCredirMemo."Document Type".AsInteger();
            TmpCrMemoBuffer.INSERT;
        end;

        IF PostedVendorRebateLine."Vendor Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            PurchaseCrMemoLine.RESET;
            PurchaseCrMemoLine.SETRANGE("Document Type", PurchaseCrMemoLine."Document Type"::"Credit Memo");
            PurchaseCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF PurchaseCrMemoLine.FINDLAST THEN
                NextLineNo := PurchaseCrMemoLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            PurchaseCrMemoLine.INIT;
            PurchaseCrMemoLine."Document Type" := PurchaseCrMemoLine."Document Type"::"Credit Memo";
            PurchaseCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
            PurchaseCrMemoLine."Line No." := NextLineNo;
            PurchaseCrMemoLine.Insert(TRUE);
            PurchaseCrMemoLine.Validate(Type, PurchaseCrMemoLine.Type::"Charge (Item)");
            PurchaseCrMemoLine.Validate("No.", RebateSetup."Default Item Charge No.");
            PurchaseCrMemoLine.Description := CopyStr(PurchaseRebateForText +
                                                      PostedVendorRebateLine.Description + ' ' +
                                                      PostedVendorRebateHeader."Posting Description",
                                                      1, MaxStrLen(PurchaseCrMemoLine.Description));
            PurchaseCrMemoLine.Validate("Location Code", PostedVendorRebateLine."Location Code");
            PurchaseCrMemoLine.Validate(Quantity, 1);
            PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedVendorRebateLine."Vendor Rebate Amt(Item Charge)");
            IF PostedVendorRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedVendorRebateLine."Shortcut Dimension 1 Code");
            IF PostedVendorRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedVendorRebateLine."Shortcut Dimension 2 Code");
            PurchaseCrMemoLine."AQD Rebate Document No." := PostedVendorRebateLine."Rebate No.";
            PurchaseCrMemoLine."AQD Rebate Document Line No" := PostedVendorRebateLine."Line No.";
            PurchaseCrMemoLine.Modify(TRUE);

            PostedVendorRebateLine."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateLine."Rebate Purchase Doc Type"::"Purchase Credit Memo";
            PostedVendorRebateLine."Purchase Document No." := PurchaseCrMemoLine."Document No.";
            PostedVendorRebateLine."Purchase Document Line No." := PurchaseCrMemoLine."Line No.";
            PostedVendorRebateLine.Modify();

            NextLineNo := 0;
            PostedVendorRebateLineDetails.RESET;
            PostedVendorRebateLineDetails.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
            PostedVendorRebateLineDetails.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
            PostedVendorRebateLineDetails.SetRange(Type, PostedVendorRebateLineDetails.Type::Item);
            PostedVendorRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedVendorRebateLineDetails.SetRange("AQD Rebate Posting Type", PostedVendorRebateLineDetails."AQD Rebate Posting Type"::"Item Charge");
            PostedVendorRebateLineDetails.SetRange(Exclude, false);
            IF PostedVendorRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentPurchase.Init();
                    ItemChargeAssignmentPurchase."Document Type" := PurchaseCrMemoLine."Document Type";
                    ItemChargeAssignmentPurchase."Document No." := PurchaseCrMemoLine."Document No.";
                    ItemChargeAssignmentPurchase."Document Line No." := PurchaseCrMemoLine."Line No.";
                    ItemChargeAssignmentPurchase."Line No." := NextLineNo;
                    ItemChargeAssignmentPurchase."Item Charge No." := PurchaseCrMemoLine."No.";
                    ItemChargeAssignmentPurchase."Item No." := PostedVendorRebateLineDetails."No.";
                    ItemChargeAssignmentPurchase.Description := PostedVendorRebateLineDetails.Description;
                    ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
                    ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
                    ItemChargeAssignmentPurchase."Unit Cost" := PostedVendorRebateLineDetails."Vendor Rebate Amount";
                    ItemChargeAssignmentPurchase."Amount to Assign" := 0;
                    ItemChargeAssignmentPurchase."Amount to Handle" := 0;
                    CASE PostedVendorRebateLineDetails."Applies-to Doc. Type" OF
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::Receipt:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Receipt;
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::"Return Shipment":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Shipment";
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedVendorRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedVendorRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentPurchase."AQD Rebate Document No." := PostedVendorRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentPurchase."AQD Rebate Document Line No" := PostedVendorRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentPurchase."AQD Rebate Line No" := PostedVendorRebateLineDetails."Line No.";
                    ItemChargeAssignmentPurchase.Insert(TRUE);

                    PostedVendorRebateLineDetails."Rebate Purchase Doc Type" := PostedVendorRebateLineDetails."Rebate Purchase Doc Type"::"Purchase Credit Memo";
                    PostedVendorRebateLineDetails."Purchase Document No." := ItemChargeAssignmentPurchase."Document No.";
                    PostedVendorRebateLineDetails."Purchase Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
                    PostedVendorRebateLineDetails."Purchase Line No." := ItemChargeAssignmentPurchase."Line No.";
                    PostedVendorRebateLineDetails."Rebate Status" := PostedVendorRebateLineDetails."Rebate Status"::Created;
                    PostedVendorRebateLineDetails.Modify;
                until PostedVendorRebateLineDetails.Next() = 0;

                //AssignItemChargePurch.SuggestAssgnt(PurchaseCrMemoLine, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount);
                CLEAR(AssignItemChargePurch);
                AssignItemChargePurch.AssignItemCharges(PurchaseCrMemoLine, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, 'By Amount');
            END;
        END;

        IF PostedVendorRebateLine."Vendor Rebate Amt (GL)" <> 0 THEN BEGIN
            PurchaseCrMemoLine.RESET;
            PurchaseCrMemoLine.SETRANGE("Document Type", PurchaseCrMemoLine."Document Type"::"Credit Memo");
            PurchaseCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF PurchaseCrMemoLine.FINDLAST THEN
                NextLineNo := PurchaseCrMemoLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            PurchaseCrMemoLine.INIT;
            PurchaseCrMemoLine."Document Type" := PurchaseCrMemoLine."Document Type"::"Credit Memo";
            PurchaseCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
            PurchaseCrMemoLine."Line No." := NextLineNo;
            PurchaseCrMemoLine.Insert(TRUE);
            PurchaseCrMemoLine.Validate(Type, PurchaseCrMemoLine.Type::"G/L Account");
            PurchaseCrMemoLine.Validate("No.", RebateSetup."Rebate Expense Account");
            PurchaseCrMemoLine.Description := CopyStr(PurchaseRebateForText +
                                                      PostedVendorRebateLine.Description + ' ' +
                                                      PostedVendorRebateHeader."Posting Description",
                                                      1, MaxStrLen(PurchaseCrMemoLine.Description));
            PurchaseCrMemoLine.Validate("Location Code", PostedVendorRebateLine."Location Code");
            PurchaseCrMemoLine.Validate(Quantity, 1);
            PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedVendorRebateLine."Vendor Rebate Amt (GL)");
            IF PostedVendorRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedVendorRebateLine."Shortcut Dimension 1 Code");
            IF PostedVendorRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedVendorRebateLine."Shortcut Dimension 2 Code");
            PurchaseCrMemoLine."AQD Rebate Document No." := PostedVendorRebateLine."Rebate No.";
            PurchaseCrMemoLine."AQD Rebate Document Line No" := PostedVendorRebateLine."Line No.";
            PurchaseCrMemoLine.Modify(TRUE);

            PostedVendorRebateLine."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateLine."Rebate Purchase Doc Type"::"Purchase Credit Memo";
            PostedVendorRebateLine."Purchase Document No." := PurchaseCrMemoLine."Document No.";
            PostedVendorRebateLine."Purchase Document Line No." := PurchaseCrMemoLine."Line No.";
            PostedVendorRebateLine.Modify();

            PostedVendorRebateLineDetails.RESET;
            PostedVendorRebateLineDetails.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
            PostedVendorRebateLineDetails.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
            //PostedVendorRebateLineDetails.SetRange(Type, PostedVendorRebateLineDetails.Type::Item);
            PostedVendorRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedVendorRebateLineDetails.SetRange("AQD Rebate Posting Type", PostedVendorRebateLineDetails."AQD Rebate Posting Type"::"G/L Account");
            PostedVendorRebateLineDetails.SetRange(Exclude, false);
            IF PostedVendorRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedVendorRebateLineDetails."Rebate Purchase Doc Type" := PostedVendorRebateLineDetails."Rebate Purchase Doc Type"::"Purchase Credit Memo";
                    PostedVendorRebateLineDetails."Purchase Document No." := PurchaseCrMemoLine."Document No.";
                    PostedVendorRebateLineDetails."Purchase Document Line No." := PurchaseCrMemoLine."Line No.";
                    PostedVendorRebateLineDetails."Purchase Line No." := 0;
                    PostedVendorRebateLineDetails."Rebate Status" := PostedVendorRebateLineDetails."Rebate Status"::Created;
                    PostedVendorRebateLineDetails.Modify;
                Until PostedVendorRebateLineDetails.Next() = 0;
            END;
        END;
    END;

    local procedure CreatePurchaseInvoiceLine(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header"; var PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line")
    var
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        NextLineNo: Integer;
    begin
        TmpInovoiceBuffer.RESET;
        IF NOT TmpInovoiceBuffer.FindFirst() THEN begin
            //Create Purchase Invoice Header
            PurchInvoice.INIT;
            PurchInvoice."Document Type" := PurchInvoice."Document Type"::Invoice;
            PurchInvoice."No." := '';
            PurchInvoice.Insert(TRUE);

            PurchInvoice.SetHideValidationDialog(TRUE);
            PurchInvoice.Validate("Buy-from Vendor No.", PostedVendorRebateLine."Buy-from Vendor No.");
            PurchInvoice.VALIDATE("Pay-to Vendor No.", PostedVendorRebateLine."Pay-to Vendor No.");
            PurchInvoice.validate("Location Code", PostedVendorRebateHeader."Location Code");
            PurchInvoice.Validate("Posting Date", PostedVendorRebateHeader."Posting Date");
            PurchInvoice."Posting Description" := PostedVendorRebateHeader."Posting Description";
            PurchInvoice.Validate("Posting Date", PostedVendorRebateHeader."Posting Date");
            PurchInvoice."Vendor Invoice No." := PostedVendorRebateHeader."No.";
            PurchInvoice."AQD Vendor Rebate No" := PostedVendorRebateHeader."No.";
            PurchInvoice.Modify(TRUE);

            PostedVendorRebateHeader."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateHeader.Modify;

            TmpInovoiceBuffer.INIT;
            TmpInovoiceBuffer."Order No." := PurchInvoice."No.";
            TmpInovoiceBuffer."Order Line No." := PurchaseCredirMemo."Document Type".AsInteger();
            TmpInovoiceBuffer.INSERT;
        end;

        IF PostedVendorRebateLine."Vendor Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document Type", PurchInvoiceLine."Document Type"::Invoice);
            PurchInvoiceLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF PurchInvoiceLine.FINDLAST THEN
                NextLineNo := PurchInvoiceLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            PurchInvoiceLine.INIT;
            PurchInvoiceLine."Document Type" := PurchInvoiceLine."Document Type"::Invoice;
            PurchInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
            PurchInvoiceLine."Line No." := NextLineNo;
            PurchInvoiceLine.Insert(TRUE);

            PurchInvoiceLine.Validate(Type, PurchInvoiceLine.Type::"Charge (Item)");
            PurchInvoiceLine.Validate("No.", RebateSetup."Default Item Charge No.");
            PurchInvoiceLine.Description := CopyStr(PostedVendorRebateLine.Description + ' ' +
                                                    PostedVendorRebateHeader."Posting Description",
                                                    1, MaxStrLen(PurchInvoiceLine.Description));
            PurchInvoiceLine.Validate("Location Code", PostedVendorRebateLine."Location Code");
            PurchInvoiceLine.Validate(Quantity, 1);
            PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedVendorRebateLine."Vendor Rebate Amt(Item Charge)"));
            IF PostedVendorRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedVendorRebateLine."Shortcut Dimension 1 Code");
            IF PostedVendorRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedVendorRebateLine."Shortcut Dimension 2 Code");
            PurchInvoiceLine."AQD Rebate Document No." := PostedVendorRebateLine."Rebate No.";
            PurchInvoiceLine."AQD Rebate Document Line No" := PostedVendorRebateLine."Line No.";
            PurchInvoiceLine.Modify(TRUE);

            PostedVendorRebateLine."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateLine."Rebate Purchase Doc Type"::"Purchase Invoice";
            PostedVendorRebateLine."Purchase Document No." := PurchInvoiceLine."Document No.";
            PostedVendorRebateLine."Purchase Document Line No." := PurchInvoiceLine."Line No.";
            PostedVendorRebateLine.Modify();

            NextLineNo := 0;
            PostedVendorRebateLineDetails.RESET;
            PostedVendorRebateLineDetails.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
            PostedVendorRebateLineDetails.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
            PostedVendorRebateLineDetails.SetRange(Type, PostedVendorRebateLineDetails.Type::Item);
            PostedVendorRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedVendorRebateLineDetails.SetRange("AQD Rebate Posting Type", PostedVendorRebateLineDetails."AQD Rebate Posting Type"::"Item Charge");
            PostedVendorRebateLineDetails.SetRange(Exclude, false);
            IF PostedVendorRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentPurchase.Init();
                    ItemChargeAssignmentPurchase."Document Type" := PurchInvoiceLine."Document Type";
                    ItemChargeAssignmentPurchase."Document No." := PurchInvoiceLine."Document No.";
                    ItemChargeAssignmentPurchase."Document Line No." := PurchInvoiceLine."Line No.";
                    ItemChargeAssignmentPurchase."Line No." := NextLineNo;
                    ItemChargeAssignmentPurchase."Item Charge No." := PurchInvoiceLine."No.";
                    ItemChargeAssignmentPurchase."Item No." := PostedVendorRebateLineDetails."No.";
                    ItemChargeAssignmentPurchase.Description := PostedVendorRebateLineDetails.Description;
                    ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
                    ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
                    ItemChargeAssignmentPurchase."Unit Cost" := PostedVendorRebateLineDetails."Vendor Rebate Amount";
                    ItemChargeAssignmentPurchase."Amount to Assign" := 0;
                    ItemChargeAssignmentPurchase."Amount to Handle" := 0;
                    CASE PostedVendorRebateLineDetails."Applies-to Doc. Type" OF
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::Receipt:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Receipt;
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::"Return Shipment":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Shipment";
                        PostedVendorRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedVendorRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedVendorRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentPurchase."AQD Rebate Document No." := PostedVendorRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentPurchase."AQD Rebate Document Line No" := PostedVendorRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentPurchase."AQD Rebate Line No" := PostedVendorRebateLineDetails."Line No.";
                    ItemChargeAssignmentPurchase.Insert(TRUE);

                    PostedVendorRebateLineDetails."Rebate Purchase Doc Type" := PostedVendorRebateLineDetails."Rebate Purchase Doc Type"::"Purchase Invoice";
                    PostedVendorRebateLineDetails."Purchase Document No." := ItemChargeAssignmentPurchase."Document No.";
                    PostedVendorRebateLineDetails."Purchase Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
                    PostedVendorRebateLineDetails."Purchase Line No." := ItemChargeAssignmentPurchase."Line No.";
                    PostedVendorRebateLineDetails."Rebate Status" := PostedVendorRebateLineDetails."Rebate Status"::Created;
                    PostedVendorRebateLineDetails.Modify();
                until PostedVendorRebateLineDetails.Next() = 0;

                //AssignItemChargePurch.SuggestAssgnt(PurchInvoiceLine, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount);
                CLEAR(AssignItemChargePurch);
                AssignItemChargePurch.AssignItemCharges(PurchInvoiceLine, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, 'By Amount');
            end;
        END;

        IF PostedVendorRebateLine."Vendor Rebate Amt (GL)" <> 0 THEN BEGIN
            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document Type", PurchInvoiceLine."Document Type"::Invoice);
            PurchInvoiceLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF PurchInvoiceLine.FINDLAST THEN
                NextLineNo := PurchInvoiceLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            PurchInvoiceLine.INIT;
            PurchInvoiceLine."Document Type" := PurchInvoiceLine."Document Type"::Invoice;
            PurchInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
            PurchInvoiceLine."Line No." := NextLineNo;
            PurchInvoiceLine.Insert(TRUE);

            PurchInvoiceLine.Validate(Type, PurchInvoiceLine.Type::"G/L Account");
            PurchInvoiceLine.Validate("No.", RebateSetup."Vendor Rebate Expense G/L");
            PurchInvoiceLine.Description := CopyStr(PostedVendorRebateLine.Description + ' ' +
                                                    PostedVendorRebateHeader."Posting Description",
                                                    1, MaxStrLen(PurchInvoiceLine.Description));
            PurchInvoiceLine.Validate("Location Code", PostedVendorRebateLine."Location Code");
            PurchInvoiceLine.Validate(Quantity, 1);
            PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedVendorRebateLine."Vendor Rebate Amt (GL)"));
            IF PostedVendorRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedVendorRebateLine."Shortcut Dimension 1 Code");
            IF PostedVendorRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedVendorRebateLine."Shortcut Dimension 2 Code");
            PurchInvoiceLine."AQD Rebate Document No." := PostedVendorRebateLine."Rebate No.";
            PurchInvoiceLine."AQD Rebate Document Line No" := PostedVendorRebateLine."Line No.";
            PurchInvoiceLine.Modify(TRUE);

            PostedVendorRebateLine."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
            PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateLine."Rebate Purchase Doc Type"::"Purchase Invoice";
            PostedVendorRebateLine."Purchase Document No." := PurchInvoiceLine."Document No.";
            PostedVendorRebateLine."Purchase Document Line No." := PurchInvoiceLine."Line No.";
            PostedVendorRebateLine.Modify();

            PostedVendorRebateLineDetails.RESET;
            PostedVendorRebateLineDetails.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
            PostedVendorRebateLineDetails.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
            //PostedVendorRebateLineDetails.SetRange(Type, PostedVendorRebateLineDetails.Type::Item);
            PostedVendorRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedVendorRebateLineDetails.SetRange("AQD Rebate Posting Type", PostedVendorRebateLineDetails."AQD Rebate Posting Type"::"G/L Account");
            PostedVendorRebateLineDetails.SetRange(Exclude, false);
            IF PostedVendorRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedVendorRebateLineDetails."Rebate Purchase Doc Type" := PostedVendorRebateLineDetails."Rebate Purchase Doc Type"::"Purchase Invoice";
                    PostedVendorRebateLineDetails."Purchase Document No." := PurchInvoiceLine."Document No.";
                    PostedVendorRebateLineDetails."Purchase Document Line No." := PurchInvoiceLine."Line No.";
                    PostedVendorRebateLineDetails."Purchase Line No." := 0;
                    PostedVendorRebateLineDetails."Rebate Status" := PostedVendorRebateLineDetails."Rebate Status"::Created;
                    PostedVendorRebateLineDetails.Modify();
                Until PostedVendorRebateLineDetails.Next() = 0;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab38_PurchaseHeader_OnBeforeDelete(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        PostedRebateHeader: Record "AQD Posted Vend Rebate Header";
        PostedRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedRebateDetailLine: Record "AQD Posted Ven Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Vendor Rebate No" = '' THEN
            EXIT;

        IF PostedRebateHeader.GET(Rec."AQD Vendor Rebate No") THEN begin
            PostedRebateHeader."Rebate Status" := PostedRebateHeader."Rebate Status"::" ";
            PostedRebateHeader."Rebate Purchase Doc Type" := PostedRebateHeader."Rebate Purchase Doc Type"::" ";
            PostedRebateHeader."Purchase Jnl Template Name" := '';
            PostedRebateHeader."Purchase Jnl Batch Name" := '';
            PostedRebateHeader."Purchae Jnl Line No." := 0;
            PostedRebateHeader.Modify();
        end;

        PurchaseLine.RESET;
        PurchaseLine.SetRange("Document Type", Rec."Document Type");
        PurchaseLine.SetRange("Document No.", Rec."No.");
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.SetFilter(Quantity, '<>%1', 0);
        IF PurchaseLine.FINDFIRST THEN begin
            Repeat
                PostedRebateLine.RESET;
                PostedRebateLine.SetRange("Rebate No.", PurchaseLine."AQD Rebate Document No.");
                PostedRebateLine.SetRange("Line No.", PurchaseLine."AQD Rebate Document Line No");
                PostedRebateLine.SetRange(Exclude, FALSE);
                IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::Invoice then
                    PostedRebateLine.SetRange("Rebate Purchase Doc Type", PostedRebateLine."Rebate Purchase Doc Type"::"Purchase Invoice")
                ELSE IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Credit Memo" then
                    PostedRebateLine.SetRange("Rebate Purchase Doc Type", PostedRebateLine."Rebate Purchase Doc Type"::"Purchase Credit Memo");
                PostedRebateLine.SetRange("Purchase Document No.", PurchaseLine."Document No.");
                PostedRebateLine.SetRange("Purchase Document Line No.", PurchaseLine."Line No.");
                IF PostedRebateLine.FindFirst() THEN BEGIN
                    REPEAT
                        PostedRebateLine."Rebate Status" := PostedRebateLine."Rebate Status"::" ";
                        PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::" ";
                        PostedRebateLine."Purchase Document No." := '';
                        PostedRebateLine."Purchase Document Line No." := 0;
                        PostedRebateLine.Modify();

                        PostedRebateDetailLine.RESET;
                        PostedRebateDetailLine.SetRange("Rebate No.", PostedRebateLine."Rebate No.");
                        PostedRebateDetailLine.SetRange("Rebate Line No.", PostedRebateLine."Line No.");
                        PostedRebateDetailLine.SetRange(Exclude, false);
                        If PostedRebateDetailLine.FindFirst() THEN begin
                            REPEAT
                                PostedRebateDetailLine."Rebate Status" := PostedRebateDetailLine."Rebate Status"::" ";
                                PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::" ";
                                PostedRebateLine."Purchase Document No." := '';
                                PostedRebateLine."Purchase Document Line No." := 0;
                                PostedRebateDetailLine.Modify();
                            UNTIL PostedRebateDetailLine.Next() = 0;
                        end;
                    UNTIL PostedRebateLine.Next() = 0;
                END;
            Until PurchaseLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge Assignment (Purch)", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab5805_ItemChargeAssignmentPurch_OnBeforeDelete(var Rec: Record "Item Charge Assignment (Purch)"; RunTrigger: Boolean)
    var
        PostedRebateDetailLine: Record "AQD Posted Ven Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Rebate Document No." = '' THEN
            EXIT;

        PostedVendorRebateLineDetails.RESET;
        PostedVendorRebateLineDetails.SETRANGE("Purchase Document No.", ItemChargeAssignmentPurchase."Document No.");
        PostedVendorRebateLineDetails.SETRANGE("Purchase Document Line No.", ItemChargeAssignmentPurchase."Document Line No.");
        PostedVendorRebateLineDetails.SETRANGE("Purchase Line No.", ItemChargeAssignmentPurchase."Line No.");
        IF PostedVendorRebateLineDetails.FindFirst() then begin
            PostedVendorRebateLineDetails."Purchase Document No." := '';
            PostedVendorRebateLineDetails."Purchase Document Line No." := 0;
            PostedVendorRebateLineDetails."Purchase Line No." := 0;
            PostedVendorRebateLineDetails."Rebate Status" := PostedVendorRebateLineDetails."Rebate Status"::" ";
            PostedVendorRebateLineDetails.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnCheckAndUpdateOnAfterSetSourceCode, '', false, false)]
    local procedure Cod90_PurchPost_OnCheckAndUpdateOnAfterSetSourceCode(var PurchHeader: Record "Purchase Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        RebateSetup.GET;
        IF PurchHeader."AQD Vendor Rebate No" <> '' then
            SrcCode := RebateSetup."Vendor Rebate Source Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure Cod90_PurchPost_OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PostedRebateHeader: Record "AQD Posted Vend Rebate Header";
        PostedRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedRebateDetailLine: Record "AQD Posted Ven Reb Details";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.GET;
        IF PurchInvHdrNo <> '' THEN begin
            PurchInvHdr.get(PurchInvHdrNo);
            IF (PurchInvHdr."Source Code" <> SourceCodeSetup."Deleted Document") AND
              (PurchInvHdr."AQD Rebate Vendor No" <> '')
            then begin
                PurchInvLine.RESET;
                PurchInvLine.SetRange("Document No.", PurchInvHdrNo);
                PurchInvLine.SetRange(Type, PurchInvLine.Type::"Charge (Item)");
                PurchInvLine.SetFilter("No.", '<>%1', '');
                IF PurchInvLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedRebateLine.GET(PurchInvLine."AQD Rebate Document No.",
                                                PurchInvLine."AQD Rebate Document Line No") AND
                           (NOT PostedRebateLine.Exclude)
                        THEN BEGIN

                            IF PostedRebateHeader.GET(PurchInvLine."AQD Rebate Document No.") THEN begin
                                PostedRebateHeader."Rebate Status" := PostedRebateHeader."Rebate Status"::Posted;
                                PostedRebateHeader."Rebate Purchase Doc Type" := PostedRebateHeader."Rebate Purchase Doc Type"::" ";
                                PostedRebateHeader.Modify();
                            end;

                            PostedRebateLine."Rebate Status" := PostedRebateLine."Rebate Status"::Posted;
                            PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::"Purchase Invoice";
                            PostedRebateLine."Purchase Document No." := PurchInvLine."Document No.";
                            PostedRebateLine."Purchase Document Line No." := PurchInvLine."Line No.";
                            PostedRebateLine.Modify();

                            PostedRebateDetailLine.RESET;
                            PostedRebateDetailLine.SetRange("Rebate No.", PostedRebateLine."Rebate No.");
                            PostedRebateDetailLine.SetRange("Rebate Line No.", PostedRebateLine."Line No.");
                            PostedRebateDetailLine.SetRange(Exclude, false);
                            If PostedRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedRebateDetailLine."Rebate Status" := PostedRebateDetailLine."Rebate Status"::Posted;
                                    PostedRebateDetailLine."Rebate Purchase Doc Type" := PostedRebateDetailLine."Rebate Purchase Doc Type"::"Purchase Invoice";
                                    PostedRebateDetailLine."Purchase Document No." := PurchInvLine."Document No.";
                                    PostedRebateDetailLine."Purchase Document Line No." := PurchInvLine."Line No.";
                                    PostedRebateDetailLine.Modify();
                                until PostedRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until PurchInvLine.Next() = 0;
                end;
            end;
        end;

        if PurchCrMemoHdrNo <> '' then begin
            PurchCrMemoHeader.GET(PurchCrMemoHdrNo);
            IF (PurchCrMemoHeader."Source Code" <> SourceCodeSetup."Deleted Document") AND
              (PurchCrMemoHeader."AQD Rebate Vendor No" <> '')
            then begin
                PurchCrMemoLine.RESET;
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdrNo);
                PurchCrMemoLine.SetRange(Type, PurchCrMemoLine.Type::"Charge (Item)");
                PurchCrMemoLine.SetFilter("No.", '<>%1', '');
                IF PurchCrMemoLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedRebateLine.GET(PurchCrMemoLine."AQD Rebate Document No.",
                                                PurchCrMemoLine."AQD Rebate Document Line No") AND
                           (NOT PostedRebateLine.Exclude)
                        THEN BEGIN

                            IF PostedRebateHeader.GET(PurchCrMemoLine."AQD Rebate Document No.") THEN begin
                                PostedRebateHeader."Rebate Status" := PostedRebateHeader."Rebate Status"::Posted;
                                PostedRebateHeader."Rebate Purchase Doc Type" := PostedRebateHeader."Rebate Purchase Doc Type"::" ";
                                PostedRebateHeader.Modify();
                            end;

                            PostedRebateLine."Rebate Status" := PostedRebateLine."Rebate Status"::Posted;
                            PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::"Purchase Credit Memo";
                            PostedRebateLine."Purchase Document No." := PurchCrMemoLine."Document No.";
                            PostedRebateLine."Purchase Document Line No." := PurchCrMemoLine."Line No.";
                            PostedRebateLine.Modify();

                            PostedRebateDetailLine.RESET;
                            PostedRebateDetailLine.SetRange("Rebate No.", PostedRebateLine."Rebate No.");
                            PostedRebateDetailLine.SetRange("Rebate Line No.", PostedRebateLine."Line No.");
                            PostedRebateDetailLine.SetRange(Exclude, false);
                            If PostedRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedRebateDetailLine."Rebate Status" := PostedRebateDetailLine."Rebate Status"::Posted;
                                    PostedRebateDetailLine."Rebate Purchase Doc Type" := PostedRebateDetailLine."Rebate Purchase Doc Type"::"Purchase Credit Memo";
                                    PostedRebateDetailLine."Purchase Document No." := PurchCrMemoLine."Document No.";
                                    PostedRebateDetailLine."Purchase Document Line No." := PurchCrMemoLine."Line No.";
                                    PostedRebateDetailLine.Modify();
                                until PostedRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until PurchCrMemoLine.Next() = 0;
                end;
            end;
        end;
    end;
    //<< Create Purchase Invoice/Credit Memo and Post using Charge Assignment

    [IntegrationEvent(false, false)]
    procedure OnBeforePostVendorRebates(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostVendorRebates(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInitValueEntryOnAfterSetValueEntryInventoriable, '', false, false)]
    local procedure Cod22_ItemJnlPostLine_OnInitValueEntryOnAfterSetValueEntryInventoriable(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //Original Condition for Inventoriable is change for Rebate
        IF NOT ItemJournalLine."AQD Rebate Journal" then
            EXIT;

        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") OR
           (ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::Output, ItemJournalLine."Entry Type"::"Assembly Output"]) OR
           ItemJournalLine.Adjustment
       then begin
            IF Item.GET(ItemJournalLine."Item No.") then
                ValueEntry.Inventoriable := Item.Type = Item.Type::Inventory;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnPostItemJnlLineOnAfterCopyDocumentFields, '', false, false)]
    local procedure Cod90_PurchPost_OnPostItemJnlLineOnAfterCopyDocumentFields(var ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; PurchRcptHeader: Record "Purch. Rcpt. Header"; GenJnlLineExtDocNo: Code[35]; QtyToBeInvoiced: Decimal)
    begin
        ItemJournalLine."AQD Rebate Journal" := PurchaseLine."AQD Rebate Document No." <> '';
        ItemJournalLine."AQD Rebate Document No." := PurchaseLine."AQD Rebate Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", OnRunCheckOnBeforeTestFieldAppliesToEntry, '', false, false)]
    local procedure Cod21_ItemJnlCheckLine_OnRunCheckOnBeforeTestFieldAppliesToEntry(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") AND (ItemJournalLine."Item Charge No." <> '') then
            IF ItemJournalLine."Inventory Value Per" = ItemJournalLine."Inventory Value Per"::" " then
                ItemJournalLine."Inventory Value Per" := ItemJournalLine."Inventory Value Per"::Item
    end;

    //>> To Vendor Rebate By Rebate Document to G/L - Not In Use
    local procedure PostRebateToGLByRebateDocument(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        VendorRebateLine: Record "AQD Vendor Rebate Line";
        VendorRebateDetailLine: Record "AQD Vendor Rebate Details";
        DocumentNo: Code[20];
        VendorNo: Code[20];
        LineNo: Integer;
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");
        RebateSetup.TestField("Vendor Rebate Expense G/L");

        Vendor.Get(VendorRebateHeader."Pay-to Vendor No.");
        VendorNo := Vendor."No.";
        if Vendor."AQD Rebate Vendor No" <> '' then
            VendorNo := Vendor."AQD Rebate Vendor No";

        VendorRebateHeader.CalcFields("Vendor Rebate Amount");

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Purch Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Purch Journal Batch Name");
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll;

        Clear(DocumentNo);
        GeneralJournalInit(DocumentNo);
        IF DocumentNo = '' then
            DocumentNo := VendorRebateHeader."No.";

        GenJnlTemplate.Get(JnlBatch."Journal Template Name");

        LineNo += 10000;
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine.UpdateJournalBatchID();
        GenJnlLine.SetHideValidation(true);
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Posting Date" := VendorRebateHeader."Posting Date";
        if PostedVendorRebateLine."Vendor Rebate Amount" > 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
        else if PostedVendorRebateLine."Vendor Rebate Amount" < 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine.Validate("Account No.", VendorNo);
        GenJnlLine.Description := VendorRebateHeader."Posting Description";
        GenJnlLine.Validate(Amount, VendorRebateHeader."Vendor Rebate Amount");
        GenJnlLine."Shortcut Dimension 1 Code" := VendorRebateHeader."Shortcut Dimension 1 Code";
        GenJnlLine.Validate("Shortcut Dimension 1 Code");
        GenJnlLine."Shortcut Dimension 2 Code" := VendorRebateHeader."Shortcut Dimension 2 Code";
        GenJnlLine.Validate("Shortcut Dimension 2 Code");
        GenJnlLine."External Document No." := GenJnlLine."Document No.";
        if GenJnlLine."External Document No." = '' then
            GenJnlLine."External Document No." := VendorRebateHeader."External Document No.";
        IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice THEN
            GenJnlLine."AQD Rebate Document Type" := GenJnlLine."AQD Rebate Document Type"::Invoice
        ELSE IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" THEN
            GenJnlLine."AQD Rebate Document Type" := GenJnlLine."AQD Rebate Document Type"::"Credit Memo";
        GenJnlLine."AQD Rebate Document No." := VendorRebateHeader."No.";
        GenJnlLine."AQD Journal Document No." := GenJnlLine."Document No.";
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", RebateSetup."Vendor Rebate Expense G/L");
        GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
        if GenJnlLine.Amount <> 0 then
            GenJnlLine.Insert();

        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);

        VendorRebateHeader."Rebate Status" := VendorRebateHeader."Rebate Status"::Posted;
        VendorRebateHeader.Modify();

        VendorRebateLine.RESET;
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        VendorRebateLine.SetRange(Exclude, FALSE);
        IF VendorRebateLine.FindFirst() THEN BEGIN
            repeat
                VendorRebateLine."Rebate Status" := VendorRebateLine."Rebate Status"::Posted;
                VendorRebateLine.Modify();

                VendorRebateDetailLine.RESET;
                VendorRebateDetailLine.SetRange("Rebate No.", VendorRebateLine."Rebate No.");
                VendorRebateDetailLine.SetRange("Rebate Line No.", VendorRebateLine."Line No.");
                VendorRebateDetailLine.SetRange(Exclude, false);
                If VendorRebateDetailLine.FindFirst() THEN begin
                    repeat
                        VendorRebateDetailLine."Rebate Status" := VendorRebateDetailLine."Rebate Status"::Posted;
                        VendorRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", VendorRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", VendorRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", VendorRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                            RebateItemLdgrEntry.Modify;
                        end;
                    until VendorRebateDetailLine.Next() = 0;
                end;
            until VendorRebateLine.Next() = 0;
        END;
    end;
    // To Vendor Rebate By Rebate Document Line to G/L - Not In Use
    local procedure PostRebateToGLByRebateLine(var VendorRebateHeader: Record "AQD Vendor Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        VendorRebateLine: Record "AQD Vendor Rebate Line";
        VendorRebateDetailLine: Record "AQD Vendor Rebate Details";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        DocumentNo: Code[20];
        VendorNo: Code[20];
        LineNo: Integer;
        LineToPost: Boolean;
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");
        RebateSetup.TestField("Vendor Rebate Expense G/L");

        VendorRebateLine.Reset();
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        VendorRebateLine.SETFILTER("Rebate Status", '<>%1', VendorRebateLine."Rebate Status"::Posted);
        VendorRebateLine.SetRange(Exclude, false);
        if VendorRebateLine.FindSet() then begin
            GenJnlLine.Reset;
            GenJnlLine.SetRange("Journal Template Name", RebateSetup."Purch Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Purch Journal Batch Name");
            if GenJnlLine.FindFirst() then
                GenJnlLine.DeleteAll;
            repeat
                Clear(DocumentNo);
                GeneralJournalInit(DocumentNo);
                IF DocumentNo = '' then
                    DocumentNo := VendorRebateHeader."No.";

                Vendor.Get(VendorRebateHeader."Pay-to Vendor No.");
                VendorRebateLine.CalcFields("Vendor Rebate Amount");

                GenJnlTemplate.Get(JnlBatch."Journal Template Name");

                LineNo += 10000;
                GenJnlLine.Init;
                GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                GenJnlLine."Line No." := LineNo;
                GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                GenJnlLine.UpdateJournalBatchID();
                GenJnlLine.SetHideValidation(true);
                GenJnlLine."Document No." := DocumentNo;
                GenJnlLine."Posting Date" := VendorRebateHeader."Posting Date";
                GenJnlLine.Description := VendorRebateHeader."Posting Description";
                VendorNo := Vendor."No.";
                if Vendor."AQD Rebate Vendor No" <> '' then
                    VendorNo := Vendor."AQD Rebate Vendor No";

                if VendorRebateLine."Vendor Rebate Amount" > 0 then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                else
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                GenJnlLine.Validate("Account No.", VendorNo);
                GenJnlLine.Validate("Currency Code", VendorRebateLine."Currency Code");
                GenJnlLine.Validate(Amount, VendorRebateLine."Vendor Rebate Amount");

                GenJnlLine."Shortcut Dimension 1 Code" := VendorRebateLine."Shortcut Dimension 1 Code";
                GenJnlLine.Validate("Shortcut Dimension 1 Code");
                GenJnlLine."Shortcut Dimension 2 Code" := VendorRebateLine."Shortcut Dimension 2 Code";
                GenJnlLine.Validate("Shortcut Dimension 2 Code");
                GenJnlLine."External Document No." := VendorRebateHeader."External Document No." + '-' + FORMAT(VendorRebateLine."Line No.");
                if GenJnlLine."External Document No." = '' then
                    GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                GenJnlLine."AQD Rebate Document Type" := VendorRebateLine."Document Type";
                GenJnlLine."AQD Rebate Document No." := VendorRebateLine."Rebate No.";
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", RebateSetup."Vendor Rebate Expense G/L");
                GenJnlLine."AQD Journal Document No." := GenJnlLine."Document No.";
                GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
                if GenJnlLine.Amount <> 0 then BEGIN
                    GenJnlLine.Insert();
                    LineToPost := true;
                END;
            until VendorRebateLine.Next() = 0;

            IF LineToPost THEN begin
                GenJnlLine.RESET;
                GenJnlLine.SETRANGE("Journal Template Name", JnlBatch."Journal Template Name");
                GenJnlLine.SETRANGE("Journal Batch Name", JnlBatch.Name);
                IF GenJnlLine.FindFirst() then
                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
            END;
        end;

        VendorRebateHeader."Rebate Status" := VendorRebateHeader."Rebate Status"::Posted;
        VendorRebateHeader.Modify();

        VendorRebateLine.RESET;
        VendorRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        VendorRebateLine.SetRange(Exclude, FALSE);
        IF VendorRebateLine.FindFirst() THEN BEGIN
            REPEAT
                VendorRebateLine."Rebate Status" := VendorRebateLine."Rebate Status"::Posted;
                VendorRebateLine.Modify();

                VendorRebateDetailLine.RESET;
                VendorRebateDetailLine.SetRange("Rebate No.", VendorRebateLine."Rebate No.");
                VendorRebateDetailLine.SetRange("Rebate Line No.", VendorRebateLine."Line No.");
                VendorRebateDetailLine.SetRange(Exclude, false);
                IF VendorRebateDetailLine.FindFirst() THEN begin
                    repeat
                        VendorRebateDetailLine."Rebate Status" := VendorRebateDetailLine."Rebate Status"::Posted;
                        VendorRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", VendorRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", VendorRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", VendorRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                            RebateItemLdgrEntry.Modify;
                        end;
                    until VendorRebateDetailLine.Next() = 0;
                END;
            UNTIL VendorRebateLine.Next() = 0;
        END;
    END;

    //>> Create Purchase Journal from Posted Rebate Document
    local procedure GeneralJournalInit(var DocumentNo: Code[20])
    begin
        JnlBatch.Init;
        JnlBatch."Journal Template Name" := RebateSetup."Purch Journal Template Name";
        JnlBatch.Name := RebateSetup."Purch Journal Batch Name";
        if not JnlBatch.Get(RebateSetup."Purch Journal Template Name", RebateSetup."Purch Journal Batch Name") then
            JnlBatch.Insert;

        IF JnlBatch."No. Series" = '' then
            EXIT;

        DocumentNo := NoSeriesMgt.GetNextNo(JnlBatch."No. Series", Today, true);
    end;

    procedure CreateVendorRebatePurchJournal(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header")
    var
        VendRebateCreateJnlType: Label '&Create Purch Jnl By Rebate Document,Create &Purch Jnl By Rebate Line';
        Selection: Integer;
    BEGIN
        Selection := StrMenu(VendRebateCreateJnlType, 0);
        IF Selection = 0 THEN
            EXIT;

        RebateSetup.Get();
        CASE Selection OF
            1: //Create Purch Jnl By Rebate Document
                CreateRebateToGLByRebateDocument(PostedVendorRebateHeader);
            2: //Create Purch Jnl By Rebate Line
                CreateRebateToGLByRebateLine(PostedVendorRebateHeader);
        END;
    END;

    local procedure CreateRebateToGLByRebateDocument(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedVendorRebateDetailLine: Record "AQD Posted Ven Reb Details";
        DocumentNo: Code[20];
        VendorNo: Code[20];
        LineNo: Integer;
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");
        RebateSetup.TestField("Vendor Rebate Expense G/L");

        IF PostedVendorRebateHeader."Rebate Status" <> PostedVendorRebateHeader."Rebate Status"::" " THEN
            Error(RebateStatusError, PostedVendorRebateHeader."Rebate Status");

        Vendor.Get(PostedVendorRebateHeader."Pay-to Vendor No.");
        VendorNo := Vendor."No.";
        if Vendor."AQD Rebate Vendor No" <> '' then
            VendorNo := Vendor."AQD Rebate Vendor No";

        PostedVendorRebateHeader.CalcFields("Vendor Rebate Amount");

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Purch Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Purch Journal Batch Name");
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll;

        Clear(DocumentNo);
        GeneralJournalInit(DocumentNo);
        IF DocumentNo = '' then
            DocumentNo := PostedVendorRebateHeader."No.";

        GenJnlTemplate.Get(JnlBatch."Journal Template Name");

        LineNo += 10000;
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine.UpdateJournalBatchID();
        GenJnlLine.SetHideValidation(true);
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Posting Date" := PostedVendorRebateHeader."Posting Date";
        if PostedVendorRebateHeader."Vendor Rebate Amount" > 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
        else if PostedVendorRebateHeader."Vendor Rebate Amount" < 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine.Validate("Account No.", VendorNo);
        GenJnlLine.Description := PostedVendorRebateHeader."Posting Description";
        GenJnlLine.Validate(Amount, PostedVendorRebateHeader."Vendor Rebate Amount");
        GenJnlLine."Shortcut Dimension 1 Code" := PostedVendorRebateHeader."Shortcut Dimension 1 Code";
        GenJnlLine.Validate("Shortcut Dimension 1 Code");
        GenJnlLine."Shortcut Dimension 2 Code" := PostedVendorRebateHeader."Shortcut Dimension 2 Code";
        GenJnlLine.Validate("Shortcut Dimension 2 Code");
        GenJnlLine."External Document No." := PostedVendorRebateHeader."External Document No.";
        if GenJnlLine."External Document No." = '' then
            GenJnlLine."External Document No." := GenJnlLine."Document No.";
        IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice THEN
            GenJnlLine."AQD Rebate Document Type" := GenJnlLine."AQD Rebate Document Type"::Invoice
        ELSE IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" THEN
            GenJnlLine."AQD Rebate Document Type" := GenJnlLine."AQD Rebate Document Type"::"Credit Memo";
        GenJnlLine."AQD Rebate Document No." := PostedVendorRebateHeader."No.";
        GenJnlLine."AQD Journal Document No." := GenJnlLine."Document No.";
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", RebateSetup."Vendor Rebate Expense G/L");
        GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
        if GenJnlLine.Amount <> 0 then
            GenJnlLine.Insert();

        PostedVendorRebateHeader."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
        PostedVendorRebateHeader."Rebate Purchase Doc Type" := PostedVendorRebateHeader."Rebate Purchase Doc Type"::Journal;
        PostedVendorRebateHeader."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
        PostedVendorRebateHeader."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        PostedVendorRebateHeader."Purchae Jnl Line No." := GenJnlLine."Line No.";
        PostedVendorRebateHeader.Modify();

        PostedVendorRebateLine.RESET;
        PostedVendorRebateLine.SetRange("Rebate No.", PostedVendorRebateHeader."No.");
        PostedVendorRebateLine.SetRange("Rebate Status", PostedVendorRebateLine."Rebate Status"::" ");
        PostedVendorRebateLine.SetRange(Exclude, FALSE);
        IF PostedVendorRebateLine.FindFirst() THEN BEGIN
            REPEAT
                PostedVendorRebateLine."Rebate Status" := PostedVendorRebateLine."Rebate Status"::Created;
                PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateHeader."Rebate Purchase Doc Type"::Journal;
                PostedVendorRebateLine."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
                PostedVendorRebateLine."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                PostedVendorRebateLine."Purchae Jnl Line No." := GenJnlLine."Line No.";
                PostedVendorRebateLine.Modify();

                PostedVendorRebateDetailLine.RESET;
                PostedVendorRebateDetailLine.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
                PostedVendorRebateDetailLine.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
                PostedVendorRebateDetailLine.SetRange(Exclude, false);
                If PostedVendorRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedVendorRebateDetailLine."Rebate Status" := PostedVendorRebateDetailLine."Rebate Status"::Created;
                        PostedVendorRebateDetailLine."Rebate Purchase Doc Type" := PostedVendorRebateDetailLine."Rebate Purchase Doc Type"::Journal;
                        PostedVendorRebateDetailLine."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
                        PostedVendorRebateDetailLine."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                        PostedVendorRebateDetailLine."Purchae Jnl Line No." := GenJnlLine."Line No.";
                        PostedVendorRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedVendorRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedVendorRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedVendorRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Created;
                            RebateItemLdgrEntry.Modify;
                        end;
                    until PostedVendorRebateDetailLine.Next() = 0;
                end;
            UNTIL PostedVendorRebateLine.Next() = 0;
        END;
    end;

    local procedure CreateRebateToGLByRebateLine(var PostedVendorRebateHeader: Record "AQD Posted Vend Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        PostedVendorRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedVendorRebateDetailLine: Record "AQD Posted Ven Reb Details";
        DocumentNo: Code[20];
        VendorNo: Code[20];
        LineNo: Integer;
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");
        RebateSetup.TestField("Vendor Rebate Expense G/L");

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Purch Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Purch Journal Batch Name");
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll;

        IF PostedVendorRebateHeader."Rebate Status" <> PostedVendorRebateHeader."Rebate Status"::" " THEN
            Error(RebateStatusError, PostedVendorRebateHeader."Rebate Status");

        PostedVendorRebateLine.Reset();
        PostedVendorRebateLine.SetRange("Rebate No.", PostedVendorRebateHeader."No.");
        PostedVendorRebateLine.SetRange("Rebate Status", PostedVendorRebateLine."Rebate Status"::" ");
        PostedVendorRebateLine.SetRange(Exclude, false);
        if PostedVendorRebateLine.FindSet() then begin
            repeat
                Clear(DocumentNo);
                GeneralJournalInit(DocumentNo);
                IF DocumentNo = '' then
                    DocumentNo := PostedVendorRebateHeader."No.";

                Vendor.Get(PostedVendorRebateHeader."Pay-to Vendor No.");
                PostedVendorRebateLine.CalcFields("Vendor Rebate Amount");

                GenJnlTemplate.Get(JnlBatch."Journal Template Name");

                LineNo += 10000;
                GenJnlLine.Init;
                GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := JnlBatch.Name;
                GenJnlLine."Line No." := LineNo;
                GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
                GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
                GenJnlLine.UpdateJournalBatchID();
                GenJnlLine.SetHideValidation(true);
                GenJnlLine."Document No." := DocumentNo;
                GenJnlLine."Posting Date" := PostedVendorRebateHeader."Posting Date";
                GenJnlLine.Description := PostedVendorRebateHeader."Posting Description";
                VendorNo := Vendor."No.";
                if Vendor."AQD Rebate Vendor No" <> '' then
                    VendorNo := Vendor."AQD Rebate Vendor No";

                if PostedVendorRebateLine."Vendor Rebate Amount" > 0 then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                else
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                GenJnlLine.Validate("Account No.", VendorNo);
                GenJnlLine.Validate("Currency Code", PostedVendorRebateLine."Currency Code");
                GenJnlLine.Validate(Amount, PostedVendorRebateLine."Vendor Rebate Amount");

                GenJnlLine."Shortcut Dimension 1 Code" := PostedVendorRebateLine."Shortcut Dimension 1 Code";
                GenJnlLine.Validate("Shortcut Dimension 1 Code");
                GenJnlLine."Shortcut Dimension 2 Code" := PostedVendorRebateLine."Shortcut Dimension 2 Code";
                GenJnlLine.Validate("Shortcut Dimension 2 Code");
                GenJnlLine."External Document No." := PostedVendorRebateHeader."External Document No." + '-' + FORMAT(PostedVendorRebateLine."Line No.");
                if GenJnlLine."External Document No." = '' then
                    GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", RebateSetup."Vendor Rebate Expense G/L");

                GenJnlLine."AQD Rebate Document Type" := PostedVendorRebateLine."Document Type";
                GenJnlLine."AQD Rebate Document No." := PostedVendorRebateLine."Rebate No.";
                GenJnlLine."AQD Journal Document No." := GenJnlLine."Document No.";
                GenJnlLine."Source Code" := RebateSetup."Vendor Rebate Source Code";
                if GenJnlLine.Amount <> 0 then
                    GenJnlLine.Insert();

                PostedVendorRebateLine."Rebate Status" := PostedVendorRebateLine."Rebate Status"::Created;
                PostedVendorRebateLine."Rebate Purchase Doc Type" := PostedVendorRebateLine."Rebate Purchase Doc Type"::Journal;
                PostedVendorRebateLine."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
                PostedVendorRebateLine."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                PostedVendorRebateLine."Purchae Jnl Line No." := GenJnlLine."Line No.";
                PostedVendorRebateLine.Modify();

                PostedVendorRebateDetailLine.RESET;
                PostedVendorRebateDetailLine.SetRange("Rebate No.", PostedVendorRebateLine."Rebate No.");
                PostedVendorRebateDetailLine.SetRange("Rebate Line No.", PostedVendorRebateLine."Line No.");
                PostedVendorRebateDetailLine.SetRange(Exclude, false);
                If PostedVendorRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedVendorRebateDetailLine."Rebate Status" := PostedVendorRebateDetailLine."Rebate Status"::Created;
                        PostedVendorRebateDetailLine."Rebate Purchase Doc Type" := PostedVendorRebateDetailLine."Rebate Purchase Doc Type"::Journal;
                        PostedVendorRebateDetailLine."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
                        PostedVendorRebateDetailLine."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                        PostedVendorRebateDetailLine."Purchae Jnl Line No." := GenJnlLine."Line No.";
                        PostedVendorRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedVendorRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedVendorRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedVendorRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Created;
                            RebateItemLdgrEntry.Modify;
                        end;
                    until PostedVendorRebateDetailLine.Next() = 0;
                end;
            until PostedVendorRebateLine.Next() = 0;
        end;

        PostedVendorRebateHeader."Rebate Status" := PostedVendorRebateHeader."Rebate Status"::Created;
        PostedVendorRebateHeader."Rebate Purchase Doc Type" := PostedVendorRebateHeader."Rebate Purchase Doc Type"::Journal;
        PostedVendorRebateHeader."Purchase Jnl Template Name" := GenJnlLine."Journal Template Name";
        PostedVendorRebateHeader."Purchase Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        PostedVendorRebateHeader."Purchae Jnl Line No." := 0;
        PostedVendorRebateHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnAfterPostGenJournalLine, '', false, false)]
    local procedure Cod13_GenJnlPostBatch_OnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")

    var
        PostedRebateHeader: Record "AQD Posted Vend Rebate Header";
        PostedRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedRebateDetailLine: Record "AQD Posted Ven Reb Details";
    begin
        IF GenJournalLine.IsTemporary THEN
            EXIT;

        IF GenJournalLine."AQD Rebate Document No." = '' THEN
            EXIT;

        IF PostedRebateHeader.GET(GenJournalLine."AQD Rebate Document No.") THEN begin
            PostedRebateHeader."Rebate Status" := PostedRebateHeader."Rebate Status"::Posted;
            PostedRebateHeader."Rebate Purchase Doc Type" := PostedRebateHeader."Rebate Purchase Doc Type"::" ";
            PostedRebateHeader."Purchase Jnl Template Name" := '';
            PostedRebateHeader."Purchase Jnl Batch Name" := '';
            PostedRebateHeader."Purchae Jnl Line No." := 0;
            PostedRebateHeader.Modify();
        end;

        PostedRebateLine.RESET;
        PostedRebateLine.SetRange("Rebate No.", GenJournalLine."AQD Rebate Document No.");
        PostedRebateLine.SetRange("Purchase Jnl Template Name", GenJournalLine."Journal Template Name");
        PostedRebateLine.SetRange("Purchase Jnl Batch Name", GenJournalLine."Journal Batch Name");
        PostedRebateLine.SetFilter("Purchae Jnl Line No.", '%1|%2', 0, GenJournalLine."Line No.");
        IF PostedRebateLine.FINDFIRST THEN begin
            Repeat
                PostedRebateLine."Rebate Status" := PostedRebateLine."Rebate Status"::Posted;
                PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::" ";
                PostedRebateLine."Purchase Jnl Template Name" := '';
                PostedRebateLine."Purchase Jnl Batch Name" := '';
                PostedRebateLine."Purchae Jnl Line No." := 0;
                PostedRebateLine.Modify();

                PostedRebateDetailLine.RESET;
                PostedRebateDetailLine.SetRange("Rebate No.", PostedRebateLine."Rebate No.");
                PostedRebateDetailLine.SetRange("Rebate Line No.", PostedRebateLine."Line No.");
                PostedRebateDetailLine.SetRange(Exclude, false);
                If PostedRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedRebateDetailLine."Rebate Status" := PostedRebateDetailLine."Rebate Status"::Posted;
                        PostedRebateDetailLine."Rebate Purchase Doc Type" := PostedRebateDetailLine."Rebate Purchase Doc Type"::" ";
                        PostedRebateDetailLine."Purchase Jnl Template Name" := '';
                        PostedRebateDetailLine."Purchase Jnl Batch Name" := '';
                        PostedRebateDetailLine."Purchae Jnl Line No." := 0;
                        PostedRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                            RebateItemLdgrEntry.Modify;
                        end;
                    until PostedRebateDetailLine.Next() = 0;
                end;
            Until PostedRebateLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnBeforeDelete(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        PostedRebateHeader: Record "AQD Posted Vend Rebate Header";
        PostedRebateLine: Record "AQD Posted Vend Rebate Line";
        PostedRebateDetailLine: Record "AQD Posted Ven Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Rebate Document No." = '' THEN
            EXIT;

        IF PostedRebateHeader.GET(Rec."AQD Rebate Document No.") THEN begin
            PostedRebateHeader."Rebate Status" := PostedRebateHeader."Rebate Status"::" ";
            PostedRebateHeader."Rebate Purchase Doc Type" := PostedRebateHeader."Rebate Purchase Doc Type"::" ";
            PostedRebateHeader."Purchase Jnl Template Name" := '';
            PostedRebateHeader."Purchase Jnl Batch Name" := '';
            PostedRebateHeader."Purchae Jnl Line No." := 0;
            PostedRebateHeader.Modify();
        end;

        PostedRebateLine.RESET;
        PostedRebateLine.SetRange("Rebate No.", Rec."AQD Rebate Document No.");
        IF PostedRebateLine.FINDFIRST THEN begin
            Repeat
                PostedRebateLine."Rebate Status" := PostedRebateLine."Rebate Status"::" ";
                PostedRebateLine."Rebate Purchase Doc Type" := PostedRebateLine."Rebate Purchase Doc Type"::" ";
                PostedRebateLine."Purchase Jnl Template Name" := '';
                PostedRebateLine."Purchase Jnl Batch Name" := '';
                PostedRebateLine."Purchae Jnl Line No." := 0;
                PostedRebateLine.Modify();

                PostedRebateDetailLine.RESET;
                PostedRebateDetailLine.SetRange("Rebate No.", PostedRebateLine."Rebate No.");
                PostedRebateDetailLine.SetRange("Rebate Line No.", PostedRebateLine."Line No.");
                PostedRebateDetailLine.SetRange(Exclude, false);
                If PostedRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedRebateDetailLine."Rebate Status" := PostedRebateDetailLine."Rebate Status"::" ";
                        PostedRebateDetailLine."Rebate Purchase Doc Type" := PostedRebateDetailLine."Rebate Purchase Doc Type"::" ";
                        PostedRebateDetailLine."Purchase Jnl Template Name" := '';
                        PostedRebateDetailLine."Purchase Jnl Batch Name" := '';
                        PostedRebateDetailLine."Purchae Jnl Line No." := 0;
                        PostedRebateDetailLine.Modify();

                        RebateItemLdgrEntry.RESET;
                        RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedRebateDetailLine."Rebate No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedRebateDetailLine."Rebate Line No.");
                        RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedRebateDetailLine."Line No.");
                        IF RebateItemLdgrEntry.FindFirst() THEN begin
                            RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::" ";
                            RebateItemLdgrEntry."AQD Rebate Entry Created" := FALSE;
                            RebateItemLdgrEntry."AQD Rebate Last Changed By" := '';
                            RebateItemLdgrEntry."AQD Rebate LastChangd DateTime" := 0DT;
                            RebateItemLdgrEntry."AQD Rebate No" := '';
                            RebateItemLdgrEntry."AQD Rebate Line No" := 0;
                            RebateItemLdgrEntry."AQD Rebate Detail Line No." := 0;
                            RebateItemLdgrEntry.Modify;
                        end;

                    until PostedRebateDetailLine.Next() = 0;
                end;
            Until PostedRebateLine.Next() = 0;
        end;
    end;
    //<< Create Purchase Journal from Posted Rebate Document
}