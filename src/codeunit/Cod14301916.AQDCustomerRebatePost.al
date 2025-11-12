codeunit 14301916 "AQD Customer Rebate Post"
{
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm;

    trigger OnRun()
    begin
        RebateSetup.GET;
        CASE RunBy OF
            RunBy::"Customer Rebate Batch":
                BEGIN
                    IF RebateSetup."Require Cust Rebate Approval" THEN BEGIN
                        IF RebateSetup."Job Queue Auto Approve Rebate" AND
                           NOT GuiAllowed
                        THEN BEGIN
                            IF NOT CustomerRebateBatch.Approved THEN BEGIN
                                CustomerRebateBatch.Validate(Approved, TRUE);
                                CustomerRebateBatch.Validate("Posting Date", Today);
                                CustomerRebateBatch.Modify();
                            END;
                        END;
                    END;
                    PostCustomerRebateBatch(CustomerRebateBatch);
                END;
        END;
    END;

    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        CustomerRebatecomments: Record "AQD Customer Rebate Comments";
        JnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line";
        TmpInvoicePostingBuffer: Record "Invoice Posting Buffer" Temporary;
        TmpInovoiceBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        TmpCrMemoBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        SalesInvoice: Record "Sales Header";
        SalesCredirMemo: Record "Sales Header";
        SalesCrMemoLine: Record "Sales Line";
        SalesInvoiceLine: Record "Sales Line";
        ItemChargeAssignmentPurchase: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        PostedCustomerRebateLineDetails: Record "AQD Posted Cust Reb Details";
        //RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        NoSeriesMgt: Codeunit "No. Series";
        TempRebateSummary: Record "Invoice Posting Buffer";
        RunBy: Enum "AQD Customer Rebate Posting";
        GlobalGroupID: Text[20];
        PurchaseRebateForText: Label 'Purchase Rebate for ';
        SalesRebateForText: Label 'Sales Rebate For';

    procedure SetVendorRebateBatchParameters(var RunByIn: Enum "AQD Customer Rebate Posting"; var CustomerRebateBatchIn: Record "AQD Customer Rebate Batch")
    begin
        RunBy := RunByIn;
        CustomerRebateBatch := CustomerRebateBatchIn;
        CustomerRebateBatch.SetRecFilter();
    end;

    procedure PostCustomerRebateBatch(var CustomerRebateBatch: Record "AQD Customer Rebate Batch")
    var
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        SavedRecords: Boolean;
    begin
        RebateSetup.Get();
        IF RebateSetup."Require Cust Rebate Approval" THEN
            IF NOT CustomerRebateBatch.Approved THEN
                Error('Customer Rebate Batch is not approved. Please approve it before posting.');

        SavedRecords := FALSE;

        CustomerRebateBatch.TestField(BatchID);

        CustomerRebateHeader.RESET;
        CustomerRebateHeader.SetCurrentKey(BatchID);
        CustomerRebateHeader.SetRange("Batch Entry No.", CustomerRebateBatch."Entry No.");
        CustomerRebateHeader.SetRange(BatchID, CustomerRebateBatch.BatchID);
        IF CustomerRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                IF CustomerRebateHeader."Posting Date" <> CustomerRebateBatch."Posting Date" then begin
                    CustomerRebateHeader.Validate("Posting Date", CustomerRebateBatch."Posting Date");
                    CustomerRebateHeader.Modify();
                    SavedRecords := TRUE;
                end;
            until CustomerRebateHeader.Next() = 0;
            IF SavedRecords then
                Commit();
        end;

        IF CustomerRebateHeader.FindFirst() THEN BEGIN
            REPEAT
                OnBeforePostCustomerRebates(CustomerRebateHeader);
                PostCustomerRebate(CustomerRebateHeader, FALSE);
                OnAfterPostCustomerRebates(CustomerRebateHeader);
            until CustomerRebateHeader.Next() = 0;
        END
    end;

    procedure PostCustomerRebate(var CustomerRebateHeader: Record "AQD Customer Rebate Header"; ShowDialogue: Boolean)
    var
        UserConfirmLabel: Label 'Do you want to post Customer Rebate %1?';
    begin
        IF ShowDialogue THEN
            IF NOT Confirm(StrSubstNo(UserConfirmLabel, CustomerRebateHeader."No.")) then
                EXIT;

        OnBeforePostCustomerRebates(CustomerRebateHeader);

        TempRebateSummary.RESET;
        IF TempRebateSummary.IsTemporary then
            TempRebateSummary.DeleteAll();
        GlobalGroupID := 'G00000001';

        RebateSetup.Get();

        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindSet() then begin
            repeat
                CustomerRebateLine.CalcFields("Customer Rebate Amount");
                if CustomerRebateLine."Customer Rebate Amount" = 0 then begin
                    CustomerRebateLine."Do Not Credit" := true;
                    CustomerRebateLine.Modify(true);
                end;
            until CustomerRebateLine.Next() = 0;
        end;
        UpdatePosted(CustomerRebateHeader);
        UpdateExcluded(CustomerRebateHeader);
        MoveCustomerRebates(CustomerRebateHeader);

        OnAfterPostCustomerRebates(CustomerRebateHeader);
    end;

    local procedure UpdatePosted(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    //var
    //RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindFirst() then begin
            repeat
                case CustomerRebateLine."Document Type" of
                    CustomerRebateLine."Document Type"::Invoice:
                        begin
                            if SalesInvoiceHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD Customer Rebate Status" := SalesInvoiceHeader."AQD Customer Rebate Status"::Posted;
                                SalesInvoiceHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                SalesInvoiceHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD Customer Rebate Status" := SalesCrMemoHeader."AQD Customer Rebate Status"::Posted;
                                SalesCrMemoHeader."AQD Customer Rebate No" := CustomerRebateLine."Rebate No.";
                                SalesCrMemoHeader.Modify(true);
                            end;
                        end;
                end;

            // RebateItemLdgrEntry.RESET;
            // RebateItemLdgrEntry.SetRange("AQD Rebate No", CustomerRebateLine."Rebate No.");
            // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", CustomerRebateLine."Line No.");
            // IF RebateItemLdgrEntry.FindFirst() THEN begin
            //     repeat
            //         RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
            //         RebateItemLdgrEntry.Modify();
            //     until RebateItemLdgrEntry.Next() = 0;
            // end;
            until CustomerRebateLine.Next() = 0;
        end;
    end;

    local procedure UpdateExcluded(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        CustomerRebateLine: Record "AQD Customer Rebate Line";
    //RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        CustomerRebateLine.SetRange("Do Not Credit", true);
        if CustomerRebateLine.FindSet() then begin
            repeat
                CustomerRebateLine.CalcFields("Customer Rebate Amount");
                case CustomerRebateLine."Document Type" of
                    CustomerRebateLine."Document Type"::Invoice:
                        begin
                            if SalesInvoiceHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD No Customer Rebate" := true;
                                SalesInvoiceHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD No Customer Rebate" := true;
                                SalesCrMemoHeader.Modify(true);
                            end;
                        end;
                end;

            // RebateItemLdgrEntry.RESET;
            // RebateItemLdgrEntry.SetRange("AQD Rebate No", CustomerRebateLine."Rebate No.");
            // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", CustomerRebateLine."Line No.");
            // IF RebateItemLdgrEntry.FindFirst() THEN begin
            //     repeat
            //         RebateItemLdgrEntry."AQD Do Not Pay Rebate" := CustomerRebateLine.Exclude;
            //         RebateItemLdgrEntry.Modify();
            //     until RebateItemLdgrEntry.Next() = 0;
            // end;
            until CustomerRebateLine.Next() = 0;
        end;
    end;

    local procedure MoveCustomerRebates(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustomerRebateBatch: Record "AQD Posted Cust Rebate Batch";
        LocalCustomerRebateHeader: Record "AQD Customer Rebate Header";
        CustomerRebateBatch: Record "AQD Customer Rebate Batch";
        BillToCustomer: Record Customer;
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindFirst() then begin
            PostedCustRebateHeader.Init();
            PostedCustRebateHeader.TransferFields(CustomerRebateHeader);
            PostedCustRebateHeader.Insert();

            MoveCustomerRebateLine(CustomerRebateHeader);
            MoveCustomerRebateComments(CustomerRebateHeader);

            CustomerRebateHeader.Delete();

            IF RebateSetup."Rebate Cr. Memo Posting" <> RebateSetup."Rebate Cr. Memo Posting"::Manual THEN BEGIN
                BillToCustomer.GET(PostedCustRebateHeader."Bill-To Customer No.");

                Case RebateSetup."Post Customer Rebate Using" OF
                    RebateSetup."Post Customer Rebate Using"::"Sales Document":
                        BEGIN
                            CreateSalesDocument(PostedCustRebateHeader, false);

                            IF RebateSetup."Rebate Cr. Memo Posting" = RebateSetup."Rebate Cr. Memo Posting"::"Auto Create and Post" THEN BEGIN
                                TmpInovoiceBuffer.RESET;
                                IF TmpInovoiceBuffer.FindFirst() THEN BEGIN
                                    REPEAT
                                        IF SalesHeader.GET(TmpInovoiceBuffer."Order Line No.",
                                                           TmpInovoiceBuffer."Order No.")
                                        THEN BEGIN
                                            SalesHeader.Ship := TRUE;
                                            SalesHeader.Invoice := TRUE;
                                            SalesPost.Run(SalesHeader);
                                        END;
                                    UNTIL TmpInovoiceBuffer.Next() = 0;
                                END;

                                TmpCrMemoBuffer.RESET;
                                IF TmpCrMemoBuffer.FindFirst() THEN BEGIN
                                    REPEAT
                                        IF SalesHeader.GET(TmpCrMemoBuffer."Order Line No.",
                                                           TmpCrMemoBuffer."Order No.")
                                        THEN BEGIN
                                            SalesHeader.Receive := TRUE;
                                            SalesHeader.Invoice := TRUE;
                                            SalesPost.Run(SalesHeader);
                                        END;
                                    UNTIL TmpCrMemoBuffer.Next() = 0;
                                END;
                            END
                        END;
                    RebateSetup."Post Customer Rebate Using"::"Sales Journal By Rebate Doc":
                        BEGIN
                            CreateRebateToGLByRebateDocument(PostedCustRebateHeader);
                            IF RebateSetup."Rebate Cr. Memo Posting" = RebateSetup."Rebate Cr. Memo Posting"::"Auto Create and Post" THEN BEGIN
                                GenJnlLine.RESET;
                                GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                                GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                                IF GenJnlLine.FindFirst() THEN
                                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                            END;
                        END;
                    RebateSetup."Post Customer Rebate Using"::"Sales Journal By Rebate Doc Line":
                        BEGIN
                            CreateRebateToGLByRebateLine(PostedCustRebateHeader);
                            IF RebateSetup."Rebate Cr. Memo Posting" = RebateSetup."Rebate Cr. Memo Posting"::"Auto Create and Post" THEN BEGIN
                                GenJnlLine.RESET;
                                GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
                                GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
                                IF GenJnlLine.FindFirst() THEN
                                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJnlLine);
                            END;
                        END;
                END;

                IF CustomerRebateHeader.BatchID <> '' THEN BEGIN
                    LocalCustomerRebateHeader.RESET;
                    LocalCustomerRebateHeader.SetRange("Batch Entry No.", CustomerRebateHeader."Batch Entry No.");
                    LocalCustomerRebateHeader.SetRange(BatchID, CustomerRebateHeader.BatchID);
                    IF NOT LocalCustomerRebateHeader.FindFirst() THEN begin
                        CustomerRebateBatch.RESET;
                        CustomerRebateBatch.SetRange("Entry No.", CustomerRebateHeader."Batch Entry No.");
                        CustomerRebateBatch.SETRANGE(BatchID, CustomerRebateHeader.BatchID);
                        IF CustomerRebateBatch.FindFirst() THEN BEGIN
                            PostedCustomerRebateBatch.Init();
                            PostedCustomerRebateBatch.TransferFields(CustomerRebateBatch);
                            PostedCustomerRebateBatch.Insert();
                            CustomerRebateBatch.Delete();
                        END;
                    END;
                END;
            END;
        END;
    END;

    local procedure MoveCustomerRebateLine(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        IF CustomerRebateLine.FindFirst() THEN BEGIN
            repeat
                //IF CustomerRebateLine.Posted or CustomerRebateLine.Exclude THEN BEGIN
                MoveCustomerRebateDetails(CustomerRebateLine);

                PostedCustomerRebateLine.Init();
                PostedCustomerRebateLine.TransferFields(CustomerRebateLine);
                if PostedCustomerRebateLine.Insert() THEN
                    CustomerRebateLine.Delete();
            //END;
            until CustomerRebateLine.Next() = 0;
        END;
    END;

    local procedure MoveCustomerRebateDetails(CustomerRebateLine: Record "AQD Customer Rebate Line")
    var
        PostedCustomerRebateDetails: Record "AQD Posted Cust Reb Details";
    begin
        CustomerRebateDetails.Reset();
        CustomerRebateDetails.SetRange("Rebate No.", CustomerRebateLine."Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", CustomerRebateLine."Line No.");
        IF CustomerRebateDetails.FindSet() THEN BEGIN
            REPEAT
                PostedCustomerRebateDetails.Init();
                PostedCustomerRebateDetails.TransferFields(CustomerRebateDetails);
                if PostedCustomerRebateDetails.Insert() then
                    CustomerRebateDetails.Delete();
            UNTIL CustomerRebateDetails.Next() = 0;
        END;
    END;

    local procedure MoveCustomerRebateComments(CustomerRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustomerRebateComments: Record "AQD Posted Cust Reb Comment";
    BEGIN
        CustomerRebatecomments.Reset();
        CustomerRebatecomments.SetRange("Rebate No.", CustomerRebateHeader."No.");
        IF CustomerRebatecomments.FINDFIRST THEN BEGIN
            REPEAT
                PostedCustomerRebateComments.Init();
                PostedCustomerRebateComments.TransferFields(CustomerRebatecomments);
                IF PostedCustomerRebateComments.Insert() THEN
                    CustomerRebatecomments.Delete();
            UNTIL CustomerRebatecomments.Next() = 0;
        END;
    END;

    //>> Create Purchase Invoice/Credit Memo from Posted Rebate Document
    // procedure CreatePurchaseDocument(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialogue: Boolean)
    // var
    //     RebateStatusError: Label 'Rebate Status must not be %1.';
    //     UserConfirmMsg: Label 'Do you want to Sales Purchase Document for Posted Rebate %1';
    //     SuccessfulMsg: Label 'Sales Document is created successfully for Posted Customer Rebate %1.';
    // begin
    //     IF ShowDialogue THEN
    //         IF NOT CONFIRM(StrSubstNo(UserConfirmMsg, PostedCustomerRebateHeader."No.")) then
    //             EXIT;

    //     RebateSetup.GET;

    //     TmpInovoiceBuffer.RESET;
    //     IF TmpInovoiceBuffer.IsTemporary then
    //         TmpInovoiceBuffer.DeleteAll();

    //     TmpCrMemoBuffer.RESET;
    //     IF TmpCrMemoBuffer.IsTemporary then
    //         TmpCrMemoBuffer.DeleteAll();

    //     IF PostedCustomerRebateHeader."Customer Rebate Status" <> PostedCustomerRebateHeader."Customer Rebate Status"::" " THEN
    //         Error(RebateStatusError, PostedCustomerRebateHeader."Customer Rebate Status");

    //     PostedCustomerRebateLine.Reset();
    //     PostedCustomerRebateLine.SetRange("Rebate No.", PostedCustomerRebateHeader."No.");
    //     PostedCustomerRebateLine.SetRange(Posted, false);
    //     PostedCustomerRebateLine.SetRange("Customer Rebate Status", PostedCustomerRebateLine."Customer Rebate Status"::" ");
    //     PostedCustomerRebateLine.SetRange("Do Not Credit", false);
    //     If PostedCustomerRebateLine.FindFirst() Then Begin
    //         Repeat
    //             PostedCustomerRebateLine.CalcFields("Customer Rebate Amount");
    //             IF PostedCustomerRebateLine."Customer Rebate Amount" < 0 THEN Begin
    //                 //Create Purchase Credit Memo
    //                 CreatePurchaseCrMemoLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
    //             END ELSE IF PostedCustomerRebateLine."Customer Rebate Amount" > 0 THEN Begin
    //                 //Create Purchase Invoice
    //                 CreatePurchaseInvoiceLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
    //             END;
    //         Until PostedCustomerRebateLine.Next() = 0;
    //     End;
    //     IF ShowDialogue then
    //         Message(StrSubstNo(SuccessfulMsg, PostedCustomerRebateHeader."No."));
    // End;

    // local procedure CreatePurchaseCrMemoLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    // var
    //     PurchaseCredirMemo: Record "Purchase Header";
    //     PurchaseCrMemoLine: Record "Purchase Line";
    //     AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
    //     NextLineNo: Integer;
    // begin
    //     PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)");

    //     TmpCrMemoBuffer.RESET;
    //     IF NOT TmpCrMemoBuffer.FindFirst() THEN begin
    //         //Create Purchase Credit Memo Header
    //         PurchaseCredirMemo.INIT;
    //         PurchaseCredirMemo.SetHideValidationDialog(TRUE);
    //         PurchaseCredirMemo."Document Type" := PurchaseCredirMemo."Document Type"::"Credit Memo";
    //         PurchaseCredirMemo."No." := '';
    //         PurchaseCredirMemo.Insert(TRUE);
    //         PurchaseCredirMemo.Validate("Buy-from Vendor No.", PostedCustomerRebateLine."Rebate-To Customer No.");
    //         PurchaseCredirMemo.VALIDATE("Pay-to Vendor No.", PostedCustomerRebateLine."Rebate-To Customer No.");
    //         PurchaseCredirMemo.validate("Location Code", PostedCustomerRebateHeader."Location Code");
    //         PurchaseCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
    //         PurchaseCredirMemo."Posting Description" := PostedCustomerRebateHeader."Posting Description";
    //         PurchaseCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
    //         PurchaseCredirMemo."Vendor Cr. Memo No." := PostedCustomerRebateHeader."No.";
    //         PurchaseCredirMemo."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
    //         PurchaseCredirMemo.Modify(TRUE);

    //         PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateHeader.Modify;

    //         TmpCrMemoBuffer.INIT;
    //         TmpCrMemoBuffer."Order No." := PurchaseCredirMemo."No.";
    //         TmpCrMemoBuffer."Order Line No." := PurchaseCredirMemo."Document Type".AsInteger();
    //         TmpCrMemoBuffer.INSERT;
    //     end;

    //     IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
    //         PurchaseCrMemoLine.RESET;
    //         PurchaseCrMemoLine.SETRANGE("Document Type", PurchaseCrMemoLine."Document Type"::"Credit Memo");
    //         PurchaseCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
    //         IF PurchaseCrMemoLine.FINDLAST THEN
    //             NextLineNo := PurchaseCrMemoLine."Line No." + 10000
    //         ELSE
    //             NextLineNo := 10000;

    //         PurchaseCrMemoLine.INIT;
    //         PurchaseCrMemoLine."Document Type" := PurchaseCrMemoLine."Document Type"::"Credit Memo";
    //         PurchaseCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
    //         PurchaseCrMemoLine."Line No." := NextLineNo;
    //         PurchaseCrMemoLine.Insert(TRUE);
    //         PurchaseCrMemoLine.Validate(Type, PurchaseCrMemoLine.Type::"Charge (Item)");
    //         PurchaseCrMemoLine.Validate("No.", RebateSetup."Purchase Item Charge No.");
    //         PurchaseCrMemoLine.Description := CopyStr(PurchaseRebateForText +
    //                                                   PostedCustomerRebateLine.Description + ' ' +
    //                                                   PostedCustomerRebateHeader."Posting Description",
    //                                                   1, MaxStrLen(PurchaseCrMemoLine.Description));
    //         PurchaseCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
    //         PurchaseCrMemoLine.Validate(Quantity, 1);
    //         PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
    //             PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
    //             PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
    //         PurchaseCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
    //         PurchaseCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
    //         PurchaseCrMemoLine.Modify(TRUE);

    //         PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
    //         PostedCustomerRebateLine."Credit Document No." := PurchaseCrMemoLine."Document No.";
    //         PostedCustomerRebateLine."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
    //         PostedCustomerRebateLine.Modify();

    //         NextLineNo := 0;
    //         PostedCustomerRebateLineDetails.RESET;
    //         PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
    //         PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
    //         PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
    //         PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
    //         PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
    //         PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
    //         IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
    //             Repeat
    //                 NextLineNo += 10000;
    //                 ItemChargeAssignmentPurchase.Init();
    //                 ItemChargeAssignmentPurchase."Document Type" := PurchaseCrMemoLine."Document Type";
    //                 ItemChargeAssignmentPurchase."Document No." := PurchaseCrMemoLine."Document No.";
    //                 ItemChargeAssignmentPurchase."Document Line No." := PurchaseCrMemoLine."Line No.";
    //                 ItemChargeAssignmentPurchase."Line No." := NextLineNo;
    //                 ItemChargeAssignmentPurchase."Item Charge No." := PurchaseCrMemoLine."No.";
    //                 ItemChargeAssignmentPurchase."Item No." := PostedCustomerRebateLineDetails."No.";
    //                 ItemChargeAssignmentPurchase.Description := PostedCustomerRebateLineDetails.Description;
    //                 ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
    //                 ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
    //                 ItemChargeAssignmentPurchase."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
    //                 ItemChargeAssignmentPurchase."Amount to Assign" := 0;
    //                 ItemChargeAssignmentPurchase."Amount to Handle" := 0;
    //                 CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Sales Shipment";
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Receipt";
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
    //                 END;
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Document No." := PostedCustomerRebateLineDetails."Rebate No.";
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
    //                 ItemChargeAssignmentPurchase.Insert(TRUE);

    //                 PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Credit Memo";
    //                 PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentPurchase."Document No.";
    //                 PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
    //                 PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentPurchase."Line No.";
    //                 PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
    //                 PostedCustomerRebateLineDetails.Modify;
    //             until PostedCustomerRebateLineDetails.Next() = 0;

    //             CLEAR(AssignItemChargePurch);
    //             AssignItemChargePurch.AssignItemCharges(PurchaseCrMemoLine, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, 'By Amount');
    //         END;
    //     END;

    //     IF PostedCustomerRebateLine."customer Rebate Amt (GL)" <> 0 THEN BEGIN
    //         PurchaseCrMemoLine.RESET;
    //         PurchaseCrMemoLine.SETRANGE("Document Type", PurchaseCrMemoLine."Document Type"::"Credit Memo");
    //         PurchaseCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
    //         IF PurchaseCrMemoLine.FINDLAST THEN
    //             NextLineNo := PurchaseCrMemoLine."Line No." + 10000
    //         ELSE
    //             NextLineNo := 10000;

    //         PurchaseCrMemoLine.INIT;
    //         PurchaseCrMemoLine."Document Type" := PurchaseCrMemoLine."Document Type"::"Credit Memo";
    //         PurchaseCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
    //         PurchaseCrMemoLine."Line No." := NextLineNo;
    //         PurchaseCrMemoLine.Insert(TRUE);
    //         PurchaseCrMemoLine.Validate(Type, PurchaseCrMemoLine.Type::"G/L Account");
    //         PurchaseCrMemoLine.Validate("No.", RebateSetup."Rebate Expense Account");
    //         PurchaseCrMemoLine.Description := CopyStr(PurchaseRebateForText +
    //                                                   PostedCustomerRebateLine.Description + ' ' +
    //                                                   PostedCustomerRebateHeader."Posting Description",
    //                                                   1, MaxStrLen(PurchaseCrMemoLine.Description));
    //         PurchaseCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
    //         PurchaseCrMemoLine.Validate(Quantity, 1);
    //         PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedCustomerRebateLine."customer Rebate Amt (GL)");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
    //             PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
    //             PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
    //         PurchaseCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
    //         PurchaseCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
    //         PurchaseCrMemoLine.Modify(TRUE);

    //         PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
    //         PostedCustomerRebateLine."Credit Document No." := PurchaseCrMemoLine."Document No.";
    //         PostedCustomerRebateLine."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
    //         PostedCustomerRebateLine.Modify();

    //         PostedCustomerRebateLineDetails.RESET;
    //         PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
    //         PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
    //         //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
    //         PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
    //         PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
    //         PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
    //         IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
    //             Repeat
    //                 PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Credit Memo";
    //                 PostedCustomerRebateLineDetails."Credit Document No." := PurchaseCrMemoLine."Document No.";
    //                 PostedCustomerRebateLineDetails."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
    //                 PostedCustomerRebateLineDetails."Credit Line No." := 0;
    //                 PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
    //                 PostedCustomerRebateLineDetails.Modify;
    //             Until PostedCustomerRebateLineDetails.Next() = 0;
    //         END;
    //     END;
    // END;

    // local procedure CreatePurchaseInvoiceLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    // var
    //     PurchInvoice: Record "Purchase Header";
    //     PurchInvoiceLine: Record "Purchase Line";
    //     AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
    //     NextLineNo: Integer;
    // begin
    //     PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)");

    //     TmpInovoiceBuffer.RESET;
    //     IF NOT TmpInovoiceBuffer.FindFirst() THEN begin
    //         //Create Purchase Invoice Header
    //         PurchInvoice.INIT;
    //         PurchInvoice."Document Type" := PurchInvoice."Document Type"::Invoice;
    //         PurchInvoice."No." := '';
    //         PurchInvoice.Insert(TRUE);

    //         PurchInvoice.SetHideValidationDialog(TRUE);
    //         PurchInvoice.Validate("Buy-from Vendor No.", PostedCustomerRebateLine."Rebate-To Customer No.");
    //         PurchInvoice.VALIDATE("Pay-to Vendor No.", PostedCustomerRebateLine."Rebate-To Customer No.");
    //         PurchInvoice.validate("Location Code", PostedCustomerRebateHeader."Location Code");
    //         PurchInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
    //         PurchInvoice."Posting Description" := PostedCustomerRebateHeader."Posting Description";
    //         PurchInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
    //         PurchInvoice."Vendor Invoice No." := PostedCustomerRebateHeader."No.";
    //         PurchInvoice."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
    //         PurchInvoice.Modify(TRUE);

    //         PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateHeader.Modify;

    //         TmpInovoiceBuffer.INIT;
    //         TmpInovoiceBuffer."Order No." := PurchInvoice."No.";
    //         TmpInovoiceBuffer."Order Line No." := PurchInvoice."Document Type".AsInteger();
    //         TmpInovoiceBuffer.INSERT;
    //     end;
    //     IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
    //         PurchInvoiceLine.RESET;
    //         PurchInvoiceLine.SETRANGE("Document Type", PurchInvoiceLine."Document Type"::Invoice);
    //         PurchInvoiceLine.SETRANGE("Document No.", TmpInovoiceBuffer."Order No.");
    //         IF PurchInvoiceLine.FINDLAST THEN
    //             NextLineNo := PurchInvoiceLine."Line No." + 10000
    //         ELSE
    //             NextLineNo := 10000;

    //         PurchInvoiceLine.INIT;
    //         PurchInvoiceLine."Document Type" := PurchInvoiceLine."Document Type"::Invoice;
    //         PurchInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
    //         PurchInvoiceLine."Line No." := NextLineNo;
    //         PurchInvoiceLine.Insert(TRUE);

    //         PurchInvoiceLine.Validate(Type, PurchInvoiceLine.Type::"Charge (Item)");
    //         PurchInvoiceLine.Validate("No.", RebateSetup."Purchase Item Charge No.");
    //         PurchInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
    //                                                 PostedCustomerRebateHeader."Posting Description",
    //                                                 1, MaxStrLen(PurchInvoiceLine.Description));
    //         PurchInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
    //         PurchInvoiceLine.Validate(Quantity, 1);
    //         PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)"));
    //         IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
    //             PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
    //             PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
    //         PurchInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
    //         PurchInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
    //         PurchInvoiceLine.Modify(TRUE);

    //         PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Invoice";
    //         PostedCustomerRebateLine."Credit Document No." := PurchInvoiceLine."Document No.";
    //         PostedCustomerRebateLine."Credit Document Line No." := PurchInvoiceLine."Line No.";
    //         PostedCustomerRebateLine.Modify();

    //         NextLineNo := 0;
    //         PostedCustomerRebateLineDetails.RESET;
    //         PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
    //         PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
    //         PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
    //         PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
    //         PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
    //         PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
    //         IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
    //             Repeat
    //                 NextLineNo += 10000;
    //                 ItemChargeAssignmentPurchase.Init();
    //                 ItemChargeAssignmentPurchase."Document Type" := PurchInvoiceLine."Document Type";
    //                 ItemChargeAssignmentPurchase."Document No." := PurchInvoiceLine."Document No.";
    //                 ItemChargeAssignmentPurchase."Document Line No." := PurchInvoiceLine."Line No.";
    //                 ItemChargeAssignmentPurchase."Line No." := NextLineNo;
    //                 ItemChargeAssignmentPurchase."Item Charge No." := PurchInvoiceLine."No.";
    //                 ItemChargeAssignmentPurchase."Item No." := PostedCustomerRebateLineDetails."No.";
    //                 ItemChargeAssignmentPurchase.Description := PostedCustomerRebateLineDetails.Description;
    //                 ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
    //                 ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
    //                 ItemChargeAssignmentPurchase."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
    //                 ItemChargeAssignmentPurchase."Amount to Assign" := 0;
    //                 ItemChargeAssignmentPurchase."Amount to Handle" := 0;
    //                 CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Sales Shipment";
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Receipt";
    //                     PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
    //                         ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
    //                 END;
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
    //                 ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Document No." := PostedCustomerRebateLineDetails."Rebate No.";
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
    //                 ItemChargeAssignmentPurchase."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
    //                 ItemChargeAssignmentPurchase.Insert(TRUE);

    //                 PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Invoice";
    //                 PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentPurchase."Document No.";
    //                 PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
    //                 PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentPurchase."Line No.";
    //                 PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
    //                 PostedCustomerRebateLineDetails.Modify();
    //             until PostedCustomerRebateLineDetails.Next() = 0;

    //             CLEAR(AssignItemChargePurch);
    //             AssignItemChargePurch.AssignItemCharges(PurchInvoiceLine, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, 'By Amount');
    //         end;
    //     END;

    //     IF PostedCustomerRebateLine."Customer Rebate Amt (GL)" <> 0 THEN BEGIN
    //         PurchInvoiceLine.RESET;
    //         PurchInvoiceLine.SETRANGE("Document Type", PurchInvoiceLine."Document Type"::Invoice);
    //         PurchInvoiceLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
    //         IF PurchInvoiceLine.FINDLAST THEN
    //             NextLineNo := PurchInvoiceLine."Line No." + 10000
    //         ELSE
    //             NextLineNo := 10000;

    //         PurchInvoiceLine.INIT;
    //         PurchInvoiceLine."Document Type" := PurchInvoiceLine."Document Type"::Invoice;
    //         PurchInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
    //         PurchInvoiceLine."Line No." := NextLineNo;
    //         PurchInvoiceLine.Insert(TRUE);

    //         PurchInvoiceLine.Validate(Type, PurchInvoiceLine.Type::"G/L Account");
    //         PurchInvoiceLine.Validate("No.", RebateSetup."Rebate Expense Account");
    //         PurchInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
    //                                                 PostedCustomerRebateHeader."Posting Description",
    //                                                 1, MaxStrLen(PurchInvoiceLine.Description));
    //         PurchInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
    //         PurchInvoiceLine.Validate(Quantity, 1);
    //         PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedCustomerRebateLine."Customer Rebate Amt (GL)"));
    //         IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
    //             PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
    //         IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
    //             PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
    //         PurchInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
    //         PurchInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
    //         PurchInvoiceLine.Modify(TRUE);

    //         PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
    //         PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Invoice";
    //         PostedCustomerRebateLine."Credit Document No." := PurchInvoiceLine."Document No.";
    //         PostedCustomerRebateLine."Credit Document Line No." := PurchInvoiceLine."Line No.";
    //         PostedCustomerRebateLine.Modify();

    //         PostedCustomerRebateLineDetails.RESET;
    //         PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
    //         PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
    //         //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
    //         PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
    //         PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
    //         PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
    //         IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
    //             Repeat
    //                 PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Invoice";
    //                 PostedCustomerRebateLineDetails."Credit Document No." := PurchInvoiceLine."Document No.";
    //                 PostedCustomerRebateLineDetails."Credit Document Line No." := PurchInvoiceLine."Line No.";
    //                 PostedCustomerRebateLineDetails."Credit Line No." := 0;
    //                 PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
    //                 PostedCustomerRebateLineDetails.Modify();
    //             Until PostedCustomerRebateLineDetails.Next() = 0;
    //         END;
    //     END;
    // end;

    procedure CreateSalesDocument(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialogue: Boolean)
    var
        RebateStatusError: Label 'Rebate Status must not be %1.';
        UserConfirmMsg: Label 'Do you want to create Sales Document for Posted Rebate %1';
        SuccessfulMsg: Label 'Sales Document is created successfully for Posted Customer Rebate %1.';
    begin
        IF ShowDialogue THEN
            IF NOT CONFIRM(StrSubstNo(UserConfirmMsg, PostedCustomerRebateHeader."No.")) then
                EXIT;

        RebateSetup.GET;

        TmpInovoiceBuffer.RESET;
        IF TmpInovoiceBuffer.IsTemporary then
            TmpInovoiceBuffer.DeleteAll();

        TmpCrMemoBuffer.RESET;
        IF TmpCrMemoBuffer.IsTemporary then
            TmpCrMemoBuffer.DeleteAll();

        IF PostedCustomerRebateHeader."Customer Rebate Status" <> PostedCustomerRebateHeader."Customer Rebate Status"::" " THEN
            Error(RebateStatusError, PostedCustomerRebateHeader."Customer Rebate Status");

        PostedCustomerRebateLine.Reset();
        PostedCustomerRebateLine.SetRange("Rebate No.", PostedCustomerRebateHeader."No.");
        PostedCustomerRebateLine.SetRange(Posted, false);
        PostedCustomerRebateLine.SetRange("Customer Rebate Status", PostedCustomerRebateLine."Customer Rebate Status"::" ");
        PostedCustomerRebateLine.SetRange("Do Not Credit", false);
        If PostedCustomerRebateLine.FindFirst() Then Begin
            Repeat
                PostedCustomerRebateLine.CalcFields("Customer Rebate Amount");
                IF PostedCustomerRebateLine."Customer Rebate Amount" > 0 THEN Begin
                    //Create Sales Credit Memo
                    CreateSalesCrMemoLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END ELSE IF PostedCustomerRebateLine."Customer Rebate Amount" < 0 THEN Begin
                    //Create Sales Invoice
                    CreateSalesInvoiceLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END;
            Until PostedCustomerRebateLine.Next() = 0;
        End;
        IF ShowDialogue then
            Message(StrSubstNo(SuccessfulMsg, PostedCustomerRebateHeader."No."));
    End;

    local procedure CreateSalesCrMemoLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        SalesCredirMemo: Record "Sales Header";
        SalesCrMemoLine: Record "Sales Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        NextLineNo: Integer;
    begin
        PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)");

        TmpCrMemoBuffer.RESET;
        IF NOT TmpCrMemoBuffer.FindFirst() THEN begin
            //Create Sales Credit Memo Header
            SalesCredirMemo.INIT;
            SalesCredirMemo.SetHideValidationDialog(TRUE);
            SalesCredirMemo."Document Type" := SalesCredirMemo."Document Type"::"Credit Memo";
            SalesCredirMemo."No." := '';
            SalesCredirMemo.Insert(TRUE);
            SalesCredirMemo.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Bill-To Customer No.");
            SalesCredirMemo.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Rebate-To Customer No.");
            SalesCredirMemo.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."External Document No." := PostedCustomerRebateHeader."No.";
            SalesCredirMemo."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesCredirMemo.Modify(TRUE);

            PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            TmpCrMemoBuffer.INIT;
            TmpCrMemoBuffer."Order No." := SalesCredirMemo."No.";
            TmpCrMemoBuffer."Order Line No." := SalesCredirMemo."Document Type".AsInteger();
            TmpCrMemoBuffer.INSERT;
        end;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document Type", SalesCrMemoLine."Document Type"::"Credit Memo");
            SalesCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF SalesCrMemoLine.FINDLAST THEN
                NextLineNo := SalesCrMemoLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            SalesCrMemoLine.INIT;
            SalesCrMemoLine."Document Type" := SalesCrMemoLine."Document Type"::"Credit Memo";
            SalesCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
            SalesCrMemoLine."Line No." := NextLineNo;
            SalesCrMemoLine.Insert(TRUE);
            SalesCrMemoLine.Validate(Type, SalesCrMemoLine.Type::"Charge (Item)");
            SalesCrMemoLine.Validate("No.", RebateSetup."Sales Item Charge No.");
            SalesCrMemoLine.Description := CopyStr(SalesRebateForText +
                                                   PostedCustomerRebateLine.Description + ' ' +
                                                   PostedCustomerRebateHeader."Posting Description",
                                                   1, MaxStrLen(SalesCrMemoLine.Description));
            SalesCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            SalesCrMemoLine.Validate(Quantity, 1);
            SalesCrMemoLine.Validate("Unit Price", PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)");
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                SalesCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                SalesCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            SalesCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            SalesCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            SalesCrMemoLine.Modify(TRUE);

            PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Sales Doc Type" := PostedCustomerRebateLine."Rebate Sales Doc Type"::"Sales Document";
            PostedCustomerRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesCrMemoLine."Line No.";
            PostedCustomerRebateLine.Modify();

            NextLineNo := 0;
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentSales.Init();
                    ItemChargeAssignmentSales."Document Type" := SalesCrMemoLine."Document Type";
                    ItemChargeAssignmentSales."Document No." := SalesCrMemoLine."Document No.";
                    ItemChargeAssignmentSales."Document Line No." := SalesCrMemoLine."Line No.";
                    ItemChargeAssignmentSales."Line No." := NextLineNo;
                    ItemChargeAssignmentSales."Item Charge No." := SalesCrMemoLine."No.";
                    ItemChargeAssignmentSales."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentSales.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentSales."Qty. to Assign" := 0;
                    ItemChargeAssignmentSales."Qty. to Handle" := 0;
                    ItemChargeAssignmentSales."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentSales."Amount to Assign" := 0;
                    ItemChargeAssignmentSales."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Sales Doc Type" := PostedCustomerRebateLineDetails."Rebate Sales Doc Type"::"Sales Document";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify;
                until PostedCustomerRebateLineDetails.Next() = 0;

                CLEAR(AssignItemChargeSales);
                AssignItemChargeSales.AssignItemCharges(SalesCrMemoLine, SalesCrMemoLine.Quantity, SalesCrMemoLine.Amount, SalesCrMemoLine.Quantity, SalesCrMemoLine.Amount, 'By Amount');
            END;
        END;

        IF PostedCustomerRebateLine."customer Rebate Amt (GL)" <> 0 THEN BEGIN
            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document Type", SalesCrMemoLine."Document Type"::"Credit Memo");
            SalesCrMemoLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF SalesCrMemoLine.FINDLAST THEN
                NextLineNo := SalesCrMemoLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            SalesCrMemoLine.INIT;
            SalesCrMemoLine."Document Type" := SalesCrMemoLine."Document Type"::"Credit Memo";
            SalesCrMemoLine."Document No." := TmpCrMemoBuffer."Order No.";
            SalesCrMemoLine."Line No." := NextLineNo;
            SalesCrMemoLine.Insert(TRUE);
            SalesCrMemoLine.Validate(Type, SalesCrMemoLine.Type::"G/L Account");
            SalesCrMemoLine.Validate("No.", RebateSetup."Rebate Expense Account");
            SalesCrMemoLine.Description := CopyStr(SalesRebateForText +
                                                      PostedCustomerRebateLine.Description + ' ' +
                                                      PostedCustomerRebateHeader."Posting Description",
                                                      1, MaxStrLen(SalesCrMemoLine.Description));
            SalesCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            SalesCrMemoLine.Validate(Quantity, 1);
            SalesCrMemoLine.Validate("Unit Price", PostedCustomerRebateLine."customer Rebate Amt (GL)");
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                SalesCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                SalesCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            SalesCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            SalesCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            SalesCrMemoLine.Modify(TRUE);

            PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Sales Doc Type" := PostedCustomerRebateLine."Rebate Sales Doc Type"::"Sales Document";
            PostedCustomerRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesCrMemoLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Sales Doc Type" := PostedCustomerRebateLineDetails."Rebate Sales Doc Type"::"Sales Document";
                    PostedCustomerRebateLineDetails."Credit Document No." := SalesCrMemoLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := SalesCrMemoLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify;
                Until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;
    END;

    local procedure CreateSalesInvoiceLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        SalesInvoice: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        NextLineNo: Integer;
    begin
        PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)");

        TmpInovoiceBuffer.RESET;
        IF NOT TmpInovoiceBuffer.FindFirst() THEN begin
            //Create Sales Invoice Header
            SalesInvoice.INIT;
            SalesInvoice."Document Type" := SalesInvoice."Document Type"::Invoice;
            SalesInvoice."No." := '';
            SalesInvoice.Insert(TRUE);

            SalesInvoice.SetHideValidationDialog(TRUE);
            SalesInvoice.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Bill-To Customer No.");
            SalesInvoice.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Rebate-To Customer No.");
            SalesInvoice.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."External Document No." := PostedCustomerRebateHeader."No.";
            SalesInvoice."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesInvoice.Modify(TRUE);

            PostedCustomerRebateHeader."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            TmpInovoiceBuffer.INIT;
            TmpInovoiceBuffer."Order No." := SalesInvoice."No.";
            TmpInovoiceBuffer."Order Line No." := SalesInvoice."Document Type".AsInteger();
            TmpInovoiceBuffer.INSERT;
        end;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document Type", SalesInvoiceLine."Document Type"::Invoice);
            SalesInvoiceLine.SETRANGE("Document No.", TmpInovoiceBuffer."Order No.");
            IF SalesInvoiceLine.FINDLAST THEN
                NextLineNo := SalesInvoiceLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            SalesInvoiceLine.INIT;
            SalesInvoiceLine."Document Type" := SalesInvoiceLine."Document Type"::Invoice;
            SalesInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
            SalesInvoiceLine."Line No." := NextLineNo;
            SalesInvoiceLine.Insert(TRUE);

            SalesInvoiceLine.Validate(Type, SalesInvoiceLine.Type::"Charge (Item)");
            SalesInvoiceLine.Validate("No.", RebateSetup."Sales Item Charge No.");
            SalesInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                    PostedCustomerRebateHeader."Posting Description",
                                                    1, MaxStrLen(SalesInvoiceLine.Description));
            SalesInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            SalesInvoiceLine.Validate(Quantity, 1);
            SalesInvoiceLine.Validate("Unit Price", ABS(PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)"));
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                SalesInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                SalesInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            SalesInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            SalesInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            SalesInvoiceLine.Modify(TRUE);

            PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Sales Doc Type" := PostedCustomerRebateLine."Rebate Sales Doc Type"::"Sales Document";
            PostedCustomerRebateLine."Credit Document No." := SalesInvoiceLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesInvoiceLine."Line No.";
            PostedCustomerRebateLine.Modify();

            NextLineNo := 0;
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentSales.Init();
                    ItemChargeAssignmentSales."Document Type" := SalesInvoiceLine."Document Type";
                    ItemChargeAssignmentSales."Document No." := SalesInvoiceLine."Document No.";
                    ItemChargeAssignmentSales."Document Line No." := SalesInvoiceLine."Line No.";
                    ItemChargeAssignmentSales."Line No." := NextLineNo;
                    ItemChargeAssignmentSales."Item Charge No." := SalesInvoiceLine."No.";
                    ItemChargeAssignmentSales."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentSales.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentSales."Qty. to Assign" := 0;
                    ItemChargeAssignmentSales."Qty. to Handle" := 0;
                    ItemChargeAssignmentSales."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentSales."Amount to Assign" := 0;
                    ItemChargeAssignmentSales."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Sales Doc Type" := PostedCustomerRebateLineDetails."Rebate Sales Doc Type"::"Sales Document";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();
                until PostedCustomerRebateLineDetails.Next() = 0;

                CLEAR(AssignItemChargeSales);
                AssignItemChargeSales.AssignItemCharges(SalesInvoiceLine, SalesInvoiceLine.Quantity, SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity, SalesInvoiceLine.Amount, 'By Amount');
            end;
        END;

        IF PostedCustomerRebateLine."Customer Rebate Amt (GL)" <> 0 THEN BEGIN
            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document Type", SalesInvoiceLine."Document Type"::Invoice);
            SalesInvoiceLine.SETRANGE("Document No.", TmpCrMemoBuffer."Order No.");
            IF SalesInvoiceLine.FINDLAST THEN
                NextLineNo := SalesInvoiceLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            SalesInvoiceLine.INIT;
            SalesInvoiceLine."Document Type" := SalesInvoiceLine."Document Type"::Invoice;
            SalesInvoiceLine."Document No." := TmpInovoiceBuffer."Order No.";
            SalesInvoiceLine."Line No." := NextLineNo;
            SalesInvoiceLine.Insert(TRUE);

            SalesInvoiceLine.Validate(Type, SalesInvoiceLine.Type::"G/L Account");
            SalesInvoiceLine.Validate("No.", RebateSetup."Rebate Expense Account");
            SalesInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                    PostedCustomerRebateHeader."Posting Description",
                                                    1, MaxStrLen(SalesInvoiceLine.Description));
            SalesInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            SalesInvoiceLine.Validate(Quantity, 1);
            SalesInvoiceLine.Validate("Unit Price", ABS(PostedCustomerRebateLine."Customer Rebate Amt (GL)"));
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                SalesInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                SalesInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            SalesInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            SalesInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            SalesInvoiceLine.Modify(TRUE);

            PostedCustomerRebateLine."Customer Rebate Status" := PostedCustomerRebateHeader."Customer Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Sales Doc Type" := PostedCustomerRebateLine."Rebate Sales Doc Type"::"Sales Document";
            PostedCustomerRebateLine."Credit Document No." := SalesInvoiceLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesInvoiceLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange("Do Not Credit", false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Sales Doc Type" := PostedCustomerRebateLineDetails."Rebate Sales Doc Type"::"Sales Document";
                    PostedCustomerRebateLineDetails."Credit Document No." := SalesInvoiceLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := SalesInvoiceLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();
                Until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;
    end;

    //>> Create Sales Journal
    local procedure CreateRebateToGLByRebateDocument(var PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
        LocalBillToCustomer: Record Customer;
        LocalBillToCustomerType: Record "AQD CustRbt RebateCustomerType";
        DocumentNo: Code[20];
        LineNo: Integer;
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");

        IF PostedCustRebateHeader."Customer Rebate Status" <> PostedCustRebateHeader."Customer Rebate Status"::" " THEN
            Error(RebateStatusError, PostedCustRebateHeader."Customer Rebate Status");

        LocalBillToCustomer.Get(PostedCustRebateHeader."Bill-To Customer No.");
        LocalBillToCustomerType.GET(LocalBillToCustomer."AQD Rebate Customer Type");

        PostedCustRebateHeader.CalcFields("Customer Rebate Amount");

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Sales Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Sales Journal Batch Name");
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll;

        Clear(DocumentNo);
        GeneralJournalInit(DocumentNo);
        IF DocumentNo = '' then
            DocumentNo := PostedCustRebateHeader."No.";

        GenJnlTemplate.Get(JnlBatch."Journal Template Name");

        LineNo += 10000;
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := JnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := JnlBatch.Name;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Source Code" := RebateSetup."Cust Rebate Source Code";
        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine.UpdateJournalBatchID();
        GenJnlLine.SetHideValidation(true);
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Posting Date" := PostedCustRebateHeader."Posting Date";
        if PostedCustRebateHeader."Customer Rebate Amount" > 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
        else if PostedCustRebateHeader."Customer Rebate Amount" < 0 then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Account No.", LocalBillToCustomerType."G/L Account No.");
        GenJnlLine.Description := PostedCustRebateHeader."Posting Description";
        GenJnlLine.Validate(Amount, PostedCustRebateHeader."Customer Rebate Amount");
        GenJnlLine."Shortcut Dimension 1 Code" := PostedCustRebateHeader."Shortcut Dimension 1 Code";
        GenJnlLine.Validate("Shortcut Dimension 1 Code");
        GenJnlLine."Shortcut Dimension 2 Code" := PostedCustRebateHeader."Shortcut Dimension 2 Code";
        GenJnlLine.Validate("Shortcut Dimension 2 Code");
        GenJnlLine."External Document No." := PostedCustRebateHeader."External Document No.";
        if GenJnlLine."External Document No." = '' then
            GenJnlLine."External Document No." := GenJnlLine."Document No.";
        IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice THEN
            GenJnlLine."AQD Cust Rebate Document Type" := GenJnlLine."AQD Cust Rebate Document Type"::Invoice
        ELSE IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" THEN
            GenJnlLine."AQD Cust Rebate Document Type" := GenJnlLine."AQD Cust Rebate Document Type"::"Credit Memo";
        GenJnlLine."AQD Cust Rebate Document No." := PostedCustRebateHeader."No.";
        GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Bal. Account No.", LocalBillToCustomerType."Bal. G/ Account No.");
        GenJnlLine."Source Code" := RebateSetup."Cust Rebate Source Code";
        if GenJnlLine.Amount <> 0 then
            GenJnlLine.Insert();

        PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Created;
        PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
        PostedCustRebateHeader."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
        PostedCustRebateHeader."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        PostedCustRebateHeader."Sales Jnl Line No." := GenJnlLine."Line No.";
        PostedCustRebateHeader.Modify();

        PostedCustRebateLine.RESET;
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateLine.SetRange("Customer Rebate Status", PostedCustRebateLine."Customer Rebate Status"::" ");
        PostedCustRebateLine.SetRange("Do Not Credit", FALSE);
        IF PostedCustRebateLine.FindFirst() THEN BEGIN
            REPEAT
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Created;
                PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
                PostedCustRebateLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                PostedCustRebateLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                PostedCustRebateLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Created;
                        PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                        PostedCustRebateDetailLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Created;
                    //     RebateItemLdgrEntry.Modify;
                    // end;
                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            UNTIL PostedCustRebateLine.Next() = 0;
        END;
    end;

    local procedure CreateRebateToGLByRebateLine(var PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
        LocalBillToCustomer: Record Customer;
        LocalBillToCustomerType: Record "AQD CustRbt RebateCustomerType";
        DocumentNo: Code[20];
        LineNo: Integer;
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        RebateSetup.TestField("General Journal Template Name");
        RebateSetup.TestField("General Journal Batch Name");

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RebateSetup."Purch Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RebateSetup."Purch Journal Batch Name");
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll;

        IF PostedCustRebateHeader."Customer Rebate Status" <> PostedCustRebateHeader."Customer Rebate Status"::" " THEN
            Error(RebateStatusError, PostedCustRebateHeader."Customer Rebate Status");

        PostedCustRebateLine.Reset();
        PostedCustRebateLine.SetRange("Rebate No.", PostedCustRebateHeader."No.");
        PostedCustRebateLine.SetRange("Customer Rebate Status", PostedCustRebateLine."Customer Rebate Status"::" ");
        PostedCustRebateLine.SetRange("Do Not Credit", false);
        if PostedCustRebateLine.FindSet() then begin
            repeat
                Clear(DocumentNo);
                GeneralJournalInit(DocumentNo);
                IF DocumentNo = '' then
                    DocumentNo := PostedCustRebateHeader."No.";

                LocalBillToCustomer.Get(PostedCustRebateHeader."Bill-To Customer No.");
                LocalBillToCustomerType.GET(LocalBillToCustomer."AQD Rebate Customer Type");

                PostedCustRebateLine.CalcFields("Customer Rebate Amount");

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
                GenJnlLine."Posting Date" := PostedCustRebateHeader."Posting Date";
                GenJnlLine.Description := PostedCustRebateHeader."Posting Description";
                if PostedCustRebateLine."Customer Rebate Amount" > 0 then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo")
                else
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                GenJnlLine.Validate("Account No.", LocalBillToCustomerType."G/L Account No.");
                GenJnlLine.Validate("Currency Code", PostedCustRebateLine."Currency Code");
                GenJnlLine.Validate(Amount, PostedCustRebateLine."Customer Rebate Amount");

                GenJnlLine."Shortcut Dimension 1 Code" := PostedCustRebateLine."Shortcut Dimension 1 Code";
                GenJnlLine.Validate("Shortcut Dimension 1 Code");
                GenJnlLine."Shortcut Dimension 2 Code" := PostedCustRebateLine."Shortcut Dimension 2 Code";
                GenJnlLine.Validate("Shortcut Dimension 2 Code");
                GenJnlLine."External Document No." := PostedCustRebateHeader."External Document No." + '-' + FORMAT(PostedCustRebateLine."Line No.");
                if GenJnlLine."External Document No." = '' then
                    GenJnlLine."External Document No." := GenJnlLine."Document No." + '-' + FORMAT(GenJnlLine."Line No.");
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Bal. Account No.", LocalBillToCustomerType."Bal. G/ Account No.");

                GenJnlLine."AQD Cust Rebate Document Type" := PostedCustRebateLine."Document Type";
                GenJnlLine."AQD Cust Rebate Document No." := PostedCustRebateLine."Rebate No.";
                GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                GenJnlLine."Source Code" := RebateSetup."Cust Rebate Source Code";
                if GenJnlLine.Amount <> 0 then
                    GenJnlLine.Insert();

                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Created;
                PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
                PostedCustRebateLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                PostedCustRebateLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                PostedCustRebateLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Created;
                        PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
                        PostedCustRebateDetailLine."Sales Jnl Line No." := GenJnlLine."Line No.";
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Created;
                    //     RebateItemLdgrEntry.Modify;
                    // end;
                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            until PostedCustRebateLine.Next() = 0;
        end;

        PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Created;
        PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc";
        PostedCustRebateHeader."Sales Jnl Template Name" := GenJnlLine."Journal Template Name";
        PostedCustRebateHeader."Sales Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        PostedCustRebateHeader."Sales Jnl Line No." := 0;
        PostedCustRebateHeader.Modify();
    end;

    local procedure GeneralJournalInit(var DocumentNo: Code[20])
    begin
        JnlBatch.Init;
        JnlBatch."Journal Template Name" := RebateSetup."Sales Journal Template Name";
        JnlBatch.Name := RebateSetup."Sales Journal Batch Name";
        if not JnlBatch.Get(RebateSetup."Sales Journal Template Name", RebateSetup."Sales Journal Batch Name") then
            JnlBatch.Insert;

        IF JnlBatch."No. Series" = '' then
            EXIT;

        DocumentNo := NoSeriesMgt.GetNextNo(JnlBatch."No. Series", Today, true);
    end;
    //<< Create Sales Journal

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab38_SalesHeader_OnBeforeDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Customer Rebate No" = '' THEN
            EXIT;

        IF PostedCustRebateHeader.GET(Rec."AQD Customer Rebate No") THEN begin
            PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::" ";
            PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::" ";
            PostedCustRebateHeader.Modify();
        end;

        PurchaseLine.RESET;
        PurchaseLine.SetRange("Document Type", Rec."Document Type");
        PurchaseLine.SetRange("Document No.", Rec."No.");
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.SetFilter(Quantity, '<>%1', 0);
        IF PurchaseLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine.RESET;
                PostedCustRebateLine.SetRange("Rebate No.", PurchaseLine."AQD Cust Rebate Document No.");
                PostedCustRebateLine.SetRange("Line No.", PurchaseLine."AQD Cust Rebate Doc Line No");
                PostedCustRebateLine.SetRange("Do Not Credit", FALSE);
                IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::Invoice then
                    PostedCustRebateLine.SetRange("Rebate Sales Doc Type", PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc")
                ELSE IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Credit Memo" then
                    PostedCustRebateLine.SetRange("Rebate Sales Doc Type", PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Journal By Rebate Doc");
                PostedCustRebateLine.SetRange("Credit Document No.", PurchaseLine."Document No.");
                PostedCustRebateLine.SetRange("Credit Document Line No.", PurchaseLine."Line No.");
                IF PostedCustRebateLine.FindFirst() THEN BEGIN
                    REPEAT
                        PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::" ";
                        PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Document";
                        PostedCustRebateLine."Credit Document No." := '';
                        PostedCustRebateLine."Credit Document Line No." := 0;
                        PostedCustRebateLine.Modify();

                        PostedCustRebateDetailLine.RESET;
                        PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                        PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                        PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                        If PostedCustRebateDetailLine.FindFirst() THEN begin
                            REPEAT
                                PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::" ";
                                PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Document";
                                PostedCustRebateDetailLine."Credit Document No." := '';
                                PostedCustRebateDetailLine."Credit Document Line No." := 0;
                                PostedCustRebateDetailLine.Modify();
                            UNTIL PostedCustRebateDetailLine.Next() = 0;
                        end;
                    UNTIL PostedCustRebateLine.Next() = 0;
                END;
            Until PurchaseLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge Assignment (Purch)", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab5805_ItemChargeAssignmentPurch_OnBeforeDelete(var Rec: Record "Item Charge Assignment (Purch)"; RunTrigger: Boolean)
    var
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Cust Rebate Document No." = '' THEN
            EXIT;

        PostedCustomerRebateLineDetails.RESET;
        PostedCustomerRebateLineDetails.SETRANGE("Credit Document No.", ItemChargeAssignmentPurchase."Document No.");
        PostedCustomerRebateLineDetails.SETRANGE("Credit Document Line No.", ItemChargeAssignmentPurchase."Document Line No.");
        PostedCustomerRebateLineDetails.SETRANGE("Credit Line No.", ItemChargeAssignmentPurchase."Line No.");
        IF PostedCustomerRebateLineDetails.FindFirst() then begin
            PostedCustomerRebateLineDetails."Credit Document No." := '';
            PostedCustomerRebateLineDetails."Credit Document Line No." := 0;
            PostedCustomerRebateLineDetails."Credit Line No." := 0;
            PostedCustomerRebateLineDetails."Customer Rebate Status" := PostedCustomerRebateLineDetails."Customer Rebate Status"::" ";
            PostedCustomerRebateLineDetails.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnCheckAndUpdateOnAfterSetSourceCode, '', false, false)]
    local procedure Cod90_PurchPost_OnCheckAndUpdateOnAfterSetSourceCode(var PurchHeader: Record "Purchase Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        RebateSetup.GET;
        IF PurchHeader."AQD Customer Rebate No" <> '' then
            SrcCode := RebateSetup."Customer Rebate Source Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure Cod90_PurchPost_OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.GET;
        IF PurchInvHdrNo <> '' THEN begin
            PurchInvHdr.get(PurchInvHdrNo);
            IF (PurchInvHdr."Source Code" <> SourceCodeSetup."Deleted Document") AND
              (PurchInvHdr."AQD Customer Rebate No" <> '')
            then begin
                PurchInvLine.RESET;
                PurchInvLine.SetRange("Document No.", PurchInvHdrNo);
                PurchInvLine.SetRange(Type, PurchInvLine.Type::"Charge (Item)");
                PurchInvLine.SetFilter("No.", '<>%1', '');
                IF PurchInvLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedCustRebateLine.GET(PurchInvLine."AQD Cust Rebate Document No.",
                                                    PurchInvLine."AQD Cust Rebate Doc Line No") AND
                           (NOT PostedCustRebateLine."Do Not Credit")
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(PurchInvLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Document";
                            PostedCustRebateLine."Credit Document No." := PurchInvLine."Document No.";
                            PostedCustRebateLine."Credit Document Line No." := PurchInvLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::"Sales Document";
                                    PostedCustRebateDetailLine."Credit Document No." := PurchInvLine."Document No.";
                                    PostedCustRebateDetailLine."Credit Document Line No." := PurchInvLine."Line No.";
                                    PostedCustRebateDetailLine.Modify();
                                until PostedCustRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until PurchInvLine.Next() = 0;
                end;
            end;
        end;

        if PurchCrMemoHdrNo <> '' then begin
            PurchCrMemoHeader.GET(PurchCrMemoHdrNo);
            IF (PurchCrMemoHeader."Source Code" <> SourceCodeSetup."Deleted Document") AND
              (PurchCrMemoHeader."AQD Customer Rebate No" <> '')
            then begin
                PurchCrMemoLine.RESET;
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdrNo);
                PurchCrMemoLine.SetRange(Type, PurchCrMemoLine.Type::"Charge (Item)");
                PurchCrMemoLine.SetFilter("No.", '<>%1', '');
                IF PurchCrMemoLine.FINDFIRST THEN begin
                    Repeat
                        IF PostedCustRebateLine.GET(PurchCrMemoLine."AQD Cust Rebate Document No.",
                                                    PurchCrMemoLine."AQD Cust Rebate Doc Line No") AND
                           (NOT PostedCustRebateLine."Do Not Credit")
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(PurchCrMemoLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::"Sales Document";
                            PostedCustRebateLine."Credit Document No." := PurchCrMemoLine."Document No.";
                            PostedCustRebateLine."Credit Document Line No." := PurchCrMemoLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::"Sales Document";
                                    PostedCustRebateDetailLine."Credit Document No." := PurchCrMemoLine."Document No.";
                                    PostedCustRebateDetailLine."Credit Document Line No." := PurchCrMemoLine."Line No.";
                                    PostedCustRebateDetailLine.Modify();
                                until PostedCustRebateDetailLine.Next() = 0;
                            end;
                        END;
                    Until PurchCrMemoLine.Next() = 0;
                end;
            end;
        end;
    end;
    //<< Create Purchase Invoice/Credit Memo and Post using Charge Assignment

    [IntegrationEvent(false, false)]
    procedure OnBeforePostCustomerRebates(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostCustomerRebates(var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInitValueEntryOnAfterSetValueEntryInventoriable, '', false, false)]
    local procedure Cod22_ItemJnlPostLine_OnInitValueEntryOnAfterSetValueEntryInventoriable(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        //Original Condition for Inventoriable is change for Rebate
        IF NOT ItemJournalLine."AQD Customer Rebate Journal" then
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
        ItemJournalLine."AQD Customer Rebate Journal" := PurchaseLine."AQD Cust Rebate Document No." <> '';
        ItemJournalLine."AQD Cust Rebate Document No." := PurchaseLine."AQD Cust Rebate Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", OnRunCheckOnBeforeTestFieldAppliesToEntry, '', false, false)]
    local procedure Cod21_ItemJnlCheckLine_OnRunCheckOnBeforeTestFieldAppliesToEntry(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::"Direct Cost") AND (ItemJournalLine."Item Charge No." <> '') then
            IF ItemJournalLine."Inventory Value Per" = ItemJournalLine."Inventory Value Per"::" " then
                ItemJournalLine."Inventory Value Per" := ItemJournalLine."Inventory Value Per"::Item
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterCopyGenJnlLineFromSalesHeader, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnAfterCopyGenJnlLineFromSalesHeader(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    BEGIN
        IF NOT SalesHeader."AQD Customer Rebate" THEN
            EXIT;

        GenJournalLine."AQD Cust Rebate Journal" := SalesHeader."AQD Customer Rebate";
        GenJournalLine."AQD CR Sell-To Customer No." := SalesHeader."Sell-To Customer No.";
        GenJournalLine."AQD CR Bill-To Customer No." := SalesHeader."Bill-to Customer No.";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostCustOnAfterInitCustLedgEntry, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnPostCustOnAfterInitCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var CustLedgEntry: Record "Cust. Ledger Entry"; Cust: Record Customer; CustPostingGr: Record "Customer Posting Group")
    BEGIN
        IF NOT GenJnlLine."AQD Cust Rebate Journal" THEN
            EXIT;

        CustLedgEntry."AQD Customer Rebate" := GenJnlLine."AQD Cust Rebate Journal";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlobalGLEntry, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; FiscalYearStartDate: Date)
    BEGIN
        IF NOT GenJournalLine."AQD Cust Rebate Journal" THEN
            EXIT;

        GlobalGLEntry."AQD Customer Rebate" := GenJournalLine."AQD Cust Rebate Journal";
        GlobalGLEntry."AQD CR Sell-To Customer No." := GenJournalLine."AQD CR Sell-To Customer No.";
        GlobalGLEntry."AQD CR Bill-To Customer No." := GenJournalLine."AQD CR Bill-To Customer No.";
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnAfterPostGenJournalLine, '', false, false)]
    local procedure Cod13_GenJnlPostBatch_OnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")

    var
        PostedRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF GenJournalLine.IsTemporary THEN
            EXIT;

        IF GenJournalLine."AQD Cust Rebate Document No." = '' THEN
            EXIT;

        IF PostedRebateHeader.GET(GenJournalLine."AQD Cust Rebate Document No.") THEN begin
            PostedRebateHeader."Customer Rebate Status" := PostedRebateHeader."Customer Rebate Status"::Posted;
            PostedRebateHeader."Rebate Sales Doc Type" := PostedRebateHeader."Rebate Sales Doc Type"::" ";
            PostedRebateHeader."Sales Jnl Template Name" := '';
            PostedRebateHeader."Sales Jnl Batch Name" := '';
            PostedRebateHeader."Sales Jnl Line No." := 0;
            PostedRebateHeader.Modify();
        end;

        PostedCustRebateLine.RESET;
        PostedCustRebateLine.SetRange("Rebate No.", GenJournalLine."AQD Cust Rebate Document No.");
        PostedCustRebateLine.SetRange("Sales Jnl Template Name", GenJournalLine."Journal Template Name");
        PostedCustRebateLine.SetRange("Sales Jnl Batch Name", GenJournalLine."Journal Batch Name");
        PostedCustRebateLine.SetFilter("Sales Jnl Line No.", '%1|%2', 0, GenJournalLine."Line No.");
        IF PostedCustRebateLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::Posted;
                PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::" ";
                PostedCustRebateLine."Sales Jnl Template Name" := '';
                PostedCustRebateLine."Sales Jnl Batch Name" := '';
                PostedCustRebateLine."Sales Jnl Line No." := 0;
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::Posted;
                        PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::" ";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Line No." := 0;
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::Posted;
                    //     RebateItemLdgrEntry.Modify;
                    // end;
                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            Until PostedCustRebateLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', FALSE, FALSE)]
    local procedure Tab81_GenJnlLine_OnBeforeDelete(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        PostedCustRebateHeader: Record "AQD Posted Cust Rebate Header";
        PostedCustRebateLine: Record "AQD Posted Cust Rebate Line";
        PostedCustRebateDetailLine: Record "AQD Posted Cust Reb Details";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF NOT RunTrigger THEN // This means Record is deleted by User from Page
            EXIT;

        IF Rec."AQD Cust Rebate Document No." = '' THEN
            EXIT;

        IF PostedCustRebateHeader.GET(Rec."AQD Cust Rebate Document No.") THEN begin
            PostedCustRebateHeader."Customer Rebate Status" := PostedCustRebateHeader."Customer Rebate Status"::" ";
            PostedCustRebateHeader."Rebate Sales Doc Type" := PostedCustRebateHeader."Rebate Sales Doc Type"::" ";
            PostedCustRebateHeader."Sales Jnl Template Name" := '';
            PostedCustRebateHeader."Sales Jnl Batch Name" := '';
            PostedCustRebateHeader."Sales Jnl Line No." := 0;
            PostedCustRebateHeader.Modify();
        end;

        PostedCustRebateLine.RESET;
        PostedCustRebateLine.SetRange("Rebate No.", Rec."AQD Cust Rebate Document No.");
        IF PostedCustRebateLine.FINDFIRST THEN begin
            Repeat
                PostedCustRebateLine."Customer Rebate Status" := PostedCustRebateLine."Customer Rebate Status"::" ";
                PostedCustRebateLine."Rebate Sales Doc Type" := PostedCustRebateLine."Rebate Sales Doc Type"::" ";
                PostedCustRebateLine."Sales Jnl Template Name" := '';
                PostedCustRebateLine."Sales Jnl Batch Name" := '';
                PostedCustRebateLine."Sales Jnl Line No." := 0;
                PostedCustRebateLine.Modify();

                PostedCustRebateDetailLine.RESET;
                PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                PostedCustRebateDetailLine.SetRange("Do Not Credit", false);
                If PostedCustRebateDetailLine.FindFirst() THEN begin
                    repeat
                        PostedCustRebateDetailLine."Customer Rebate Status" := PostedCustRebateDetailLine."Customer Rebate Status"::" ";
                        PostedCustRebateDetailLine."Rebate Sales Doc Type" := PostedCustRebateDetailLine."Rebate Sales Doc Type"::" ";
                        PostedCustRebateDetailLine."Sales Jnl Template Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Batch Name" := '';
                        PostedCustRebateDetailLine."Sales Jnl Line No." := 0;
                        PostedCustRebateDetailLine.Modify();

                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("AQD Rebate No", PostedCustRebateDetailLine."Rebate No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Line No", PostedCustRebateDetailLine."Rebate Line No.");
                    // RebateItemLdgrEntry.SetRange("AQD Rebate Detail Line No.", PostedCustRebateDetailLine."Line No.");
                    // IF RebateItemLdgrEntry.FindFirst() THEN begin
                    //     RebateItemLdgrEntry."AQD Rebate Status" := RebateItemLdgrEntry."AQD Rebate Status"::" ";
                    //     RebateItemLdgrEntry."AQD Rebate Entry Created" := FALSE;
                    //     RebateItemLdgrEntry."AQD Rebate Last Changed By" := '';
                    //     RebateItemLdgrEntry."AQD Rebate LastChangd DateTime" := 0DT;
                    //     RebateItemLdgrEntry."AQD Rebate No" := '';
                    //     RebateItemLdgrEntry."AQD Rebate Line No" := 0;
                    //     RebateItemLdgrEntry."AQD Rebate Detail Line No." := 0;
                    //     RebateItemLdgrEntry.Modify;
                    // end;

                    until PostedCustRebateDetailLine.Next() = 0;
                end;
            Until PostedCustRebateLine.Next() = 0;
        end;
    end;
}