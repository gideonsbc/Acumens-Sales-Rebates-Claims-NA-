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
                    IF RebateSetup."Auto Post Customer Rebate" THEN BEGIN
                        IF NOT CustomerRebateBatch.Approved THEN BEGIN
                            CustomerRebateBatch.Validate(Approved, TRUE);
                            CustomerRebateBatch.Validate("Posting Date", Today);
                            CustomerRebateBatch.Modify();
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
        IF NOT CustomerRebateBatch.Approved THEN
            Error('Customer Rebate Batch is not approved. Please approve it before posting.');

        SavedRecords := FALSE;

        RebateSetup.Get();

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
                    CustomerRebateLine.Exclude := true;
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
        CustomerRebateLine.SetRange(Exclude, true);
        if CustomerRebateLine.FindSet() then begin
            repeat
                CustomerRebateLine.CalcFields("Customer Rebate Amount");
                case CustomerRebateLine."Document Type" of
                    CustomerRebateLine."Document Type"::Invoice:
                        begin
                            if SalesInvoiceHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesInvoiceHeader."AQD Do Not Pay Cust Rebate" := true;
                                SalesInvoiceHeader.Modify(true);
                            end;
                        end;
                    CustomerRebateLine."Document Type"::"Credit Memo":
                        begin
                            if SalesCrMemoHeader.Get(CustomerRebateLine."Document No.") then begin
                                SalesCrMemoHeader."AQD Do Not Pay Cust Rebate" := true;
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
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", CustomerRebateHeader."No.");
        if CustomerRebateLine.FindFirst() then begin
            PostedCustRebateHeader.Init();
            PostedCustRebateHeader.TransferFields(CustomerRebateHeader);
            PostedCustRebateHeader.Insert();

            MoveVendorRebateLine(CustomerRebateHeader);
            MoveVendorRebateComments(CustomerRebateHeader);

            CustomerRebateHeader.Delete();

            IF RebateSetup."Rebate Cr. Memo Posting" <> RebateSetup."Rebate Cr. Memo Posting"::Manual THEN BEGIN
                BillToCustomer.GET(PostedCustRebateHeader."Bill-To Customer No.");

                CASE BillToCustomer."AQD Rebate Payment Method" OF
                    BillToCustomer."AQD Rebate Payment Method"::"Credit Memo":
                        BEGIN
                            CreateSalesDocument(PostedCustRebateHeader, false);

                            IF RebateSetup."Rebate Cr. Memo Posting" = RebateSetup."Rebate Cr. Memo Posting"::"Create and Post Cr. Memo" THEN BEGIN
                                TmpInovoiceBuffer.RESET;
                                IF TmpInovoiceBuffer.FindFirst() THEN begin
                                    REPEAT
                                        IF SalesHeader.GET(TmpInovoiceBuffer."Order Line No.",
                                                              TmpInovoiceBuffer."Order No.")
                                        THEN BEGIN
                                            SalesHeader.Ship := TRUE;
                                            SalesHeader.Invoice := TRUE;
                                            SalesPost.Run(SalesHeader);
                                        END;
                                    UNTIL TmpInovoiceBuffer.Next() = 0;
                                end;

                                TmpCrMemoBuffer.RESET;
                                IF TmpCrMemoBuffer.FindFirst() THEN begin
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
                    BillToCustomer."AQD Rebate Payment Method"::Check:
                        BEGIN
                            CreatePurchaseDocument(PostedCustRebateHeader, false);

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
                                END;
                            END;
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

    local procedure MoveVendorRebateLine(VendorRebateHeader: Record "AQD Customer Rebate Header")
    var
        PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line";
    begin
        CustomerRebateLine.Reset();
        CustomerRebateLine.SetRange("Rebate No.", VendorRebateHeader."No.");
        IF CustomerRebateLine.FindFirst() THEN BEGIN
            repeat
                IF CustomerRebateLine.Posted or CustomerRebateLine.Exclude THEN BEGIN
                    MoveVendorRebateDetails(CustomerRebateLine);
                    PostedCustomerRebateLine.Init();
                    PostedCustomerRebateLine.TransferFields(CustomerRebateLine);
                    if PostedCustomerRebateLine.Insert() THEN
                        CustomerRebateLine.Delete();
                END;
            until CustomerRebateLine.Next() = 0;
        END;
    END;

    local procedure MoveVendorRebateDetails(VendorRebateLine: Record "AQD Customer Rebate Line")
    var
        PostedVendorRebateDetails: Record "AQD Posted Cust Reb Details";
    begin
        CustomerRebateDetails.Reset();
        CustomerRebateDetails.SetRange("Rebate No.", VendorRebateLine."Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", VendorRebateLine."Line No.");
        IF CustomerRebateDetails.FindSet() THEN BEGIN
            REPEAT
                PostedVendorRebateDetails.Init();
                PostedVendorRebateDetails.TransferFields(CustomerRebateDetails);
                if PostedVendorRebateDetails.Insert() then
                    CustomerRebateDetails.Delete();
            UNTIL CustomerRebateDetails.Next() = 0;
        END;
    END;

    local procedure MoveVendorRebateComments(CustomerRebateHeader: Record "AQD Customer Rebate Header")
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
    procedure CreatePurchaseDocument(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; ShowDialogue: Boolean)
    var
        RebateStatusError: Label 'Rebate Status must not be %1.';
        UserConfirmMsg: Label 'Do you want to Sales Purchase Document for Posted Rebate %1';
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

        //IF PostedCustomerRebateHeader."AQD Rebate Status" <> PostedCustomerRebateHeader."AQD Rebate Status"::" " THEN
        //    Error(RebateStatusError, PostedCustomerRebateHeader."AQD Rebate Status");

        PostedCustomerRebateLine.Reset();
        PostedCustomerRebateLine.SetRange("Rebate No.", PostedCustomerRebateHeader."No.");
        PostedCustomerRebateLine.SetRange(Posted, false);
        PostedCustomerRebateLine.SetRange("Rebate Status", PostedCustomerRebateLine."Rebate Status"::" ");
        PostedCustomerRebateLine.SetRange(Exclude, false);
        If PostedCustomerRebateLine.FindFirst() Then Begin
            Repeat
                PostedCustomerRebateLine.CalcFields("Customer Rebate Amount");
                IF PostedCustomerRebateLine."Customer Rebate Amount" > 0 THEN Begin
                    //Create Purchase Credit Memo
                    CreatePurchaseCrMemoLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END ELSE IF PostedCustomerRebateLine."Customer Rebate Amount" < 0 THEN Begin
                    //Create Purchase Invoice
                    CreatePurchaseInvoiceLine(PostedCustomerRebateHeader, PostedCustomerRebateLine);
                END;
            Until PostedCustomerRebateLine.Next() = 0;
        End;
        IF ShowDialogue then
            Message(StrSubstNo(SuccessfulMsg, PostedCustomerRebateHeader."No."));
    End;

    local procedure CreatePurchaseCrMemoLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        PurchaseCredirMemo: Record "Purchase Header";
        PurchaseCrMemoLine: Record "Purchase Line";
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        NextLineNo: Integer;
    begin
        PostedCustomerRebateLine.CalcFields("Customer Rebate Amount", "Cust Rebate Amt(Item Charge)", "Customer Rebate Amt (GL)");

        TmpCrMemoBuffer.RESET;
        IF NOT TmpCrMemoBuffer.FindFirst() THEN begin
            //Create Purchase Credit Memo Header
            PurchaseCredirMemo.INIT;
            PurchaseCredirMemo.SetHideValidationDialog(TRUE);
            PurchaseCredirMemo."Document Type" := PurchaseCredirMemo."Document Type"::"Credit Memo";
            PurchaseCredirMemo."No." := '';
            PurchaseCredirMemo.Insert(TRUE);
            PurchaseCredirMemo.Validate("Buy-from Vendor No.", PostedCustomerRebateLine."Buy-from Vendor No.");
            PurchaseCredirMemo.VALIDATE("Pay-to Vendor No.", PostedCustomerRebateLine."Pay-to Vendor No.");
            PurchaseCredirMemo.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            PurchaseCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            PurchaseCredirMemo."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            PurchaseCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            PurchaseCredirMemo."Vendor Cr. Memo No." := PostedCustomerRebateHeader."No.";
            PurchaseCredirMemo."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            PurchaseCredirMemo.Modify(TRUE);

            PostedCustomerRebateHeader."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            TmpCrMemoBuffer.INIT;
            TmpCrMemoBuffer."Order No." := PurchaseCredirMemo."No.";
            TmpCrMemoBuffer."Order Line No." := PurchaseCredirMemo."Document Type".AsInteger();
            TmpCrMemoBuffer.INSERT;
        end;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
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
                                                      PostedCustomerRebateLine.Description + ' ' +
                                                      PostedCustomerRebateHeader."Posting Description",
                                                      1, MaxStrLen(PurchaseCrMemoLine.Description));
            PurchaseCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            PurchaseCrMemoLine.Validate(Quantity, 1);
            PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)");
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            PurchaseCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            PurchaseCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            PurchaseCrMemoLine.Modify(TRUE);

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
            PostedCustomerRebateLine."Credit Document No." := PurchaseCrMemoLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
            PostedCustomerRebateLine.Modify();

            NextLineNo := 0;
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentPurchase.Init();
                    ItemChargeAssignmentPurchase."Document Type" := PurchaseCrMemoLine."Document Type";
                    ItemChargeAssignmentPurchase."Document No." := PurchaseCrMemoLine."Document No.";
                    ItemChargeAssignmentPurchase."Document Line No." := PurchaseCrMemoLine."Line No.";
                    ItemChargeAssignmentPurchase."Line No." := NextLineNo;
                    ItemChargeAssignmentPurchase."Item Charge No." := PurchaseCrMemoLine."No.";
                    ItemChargeAssignmentPurchase."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentPurchase.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
                    ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
                    ItemChargeAssignmentPurchase."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentPurchase."Amount to Assign" := 0;
                    ItemChargeAssignmentPurchase."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::Receipt:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Receipt;
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::"Return Shipment":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Shipment";
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Purch Applies-to Doc. No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Purch Applies-to Doc. Line No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Document No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentPurchase.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Credit Memo";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentPurchase."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentPurchase."Line No.";
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify;
                until PostedCustomerRebateLineDetails.Next() = 0;

                CLEAR(AssignItemChargePurch);
                AssignItemChargePurch.AssignItemCharges(PurchaseCrMemoLine, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, PurchaseCrMemoLine.Quantity, PurchaseCrMemoLine.Amount, 'By Amount');
            END;
        END;

        IF PostedCustomerRebateLine."customer Rebate Amt (GL)" <> 0 THEN BEGIN
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
                                                      PostedCustomerRebateLine.Description + ' ' +
                                                      PostedCustomerRebateHeader."Posting Description",
                                                      1, MaxStrLen(PurchaseCrMemoLine.Description));
            PurchaseCrMemoLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            PurchaseCrMemoLine.Validate(Quantity, 1);
            PurchaseCrMemoLine.Validate("Direct Unit Cost", PostedCustomerRebateLine."customer Rebate Amt (GL)");
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchaseCrMemoLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            PurchaseCrMemoLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            PurchaseCrMemoLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            PurchaseCrMemoLine.Modify(TRUE);

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
            PostedCustomerRebateLine."Credit Document No." := PurchaseCrMemoLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Credit Memo";
                    PostedCustomerRebateLineDetails."Credit Document No." := PurchaseCrMemoLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := PurchaseCrMemoLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify;
                Until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;
    END;

    local procedure CreatePurchaseInvoiceLine(var PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header"; var PostedCustomerRebateLine: Record "AQD Posted Cust Rebate Line")
    var
        PurchInvoice: Record "Purchase Header";
        PurchInvoiceLine: Record "Purchase Line";
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
            PurchInvoice.Validate("Buy-from Vendor No.", PostedCustomerRebateLine."Buy-from Vendor No.");
            PurchInvoice.VALIDATE("Pay-to Vendor No.", PostedCustomerRebateLine."Pay-to Vendor No.");
            PurchInvoice.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            PurchInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            PurchInvoice."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            PurchInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            PurchInvoice."Vendor Invoice No." := PostedCustomerRebateHeader."No.";
            PurchInvoice."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            PurchInvoice.Modify(TRUE);

            PostedCustomerRebateHeader."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateHeader.Modify;

            TmpInovoiceBuffer.INIT;
            TmpInovoiceBuffer."Order No." := PurchInvoice."No.";
            TmpInovoiceBuffer."Order Line No." := PurchInvoice."Document Type".AsInteger();
            TmpInovoiceBuffer.INSERT;
        end;

        IF PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)" <> 0 THEN BEGIN
            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document Type", PurchInvoiceLine."Document Type"::Invoice);
            PurchInvoiceLine.SETRANGE("Document No.", TmpInovoiceBuffer."Order No.");
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
            PurchInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                    PostedCustomerRebateHeader."Posting Description",
                                                    1, MaxStrLen(PurchInvoiceLine.Description));
            PurchInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            PurchInvoiceLine.Validate(Quantity, 1);
            PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedCustomerRebateLine."Cust Rebate Amt(Item Charge)"));
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            PurchInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            PurchInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            PurchInvoiceLine.Modify(TRUE);

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Invoice";
            PostedCustomerRebateLine."Credit Document No." := PurchInvoiceLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := PurchInvoiceLine."Line No.";
            PostedCustomerRebateLine.Modify();

            NextLineNo := 0;
            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"Item Charge");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    NextLineNo += 10000;
                    ItemChargeAssignmentPurchase.Init();
                    ItemChargeAssignmentPurchase."Document Type" := PurchInvoiceLine."Document Type";
                    ItemChargeAssignmentPurchase."Document No." := PurchInvoiceLine."Document No.";
                    ItemChargeAssignmentPurchase."Document Line No." := PurchInvoiceLine."Line No.";
                    ItemChargeAssignmentPurchase."Line No." := NextLineNo;
                    ItemChargeAssignmentPurchase."Item Charge No." := PurchInvoiceLine."No.";
                    ItemChargeAssignmentPurchase."Item No." := PostedCustomerRebateLineDetails."No.";
                    ItemChargeAssignmentPurchase.Description := PostedCustomerRebateLineDetails.Description;
                    ItemChargeAssignmentPurchase."Qty. to Assign" := 0;
                    ItemChargeAssignmentPurchase."Qty. to Handle" := 0;
                    ItemChargeAssignmentPurchase."Unit Cost" := PostedCustomerRebateLineDetails."Customer Rebate Amount";
                    ItemChargeAssignmentPurchase."Amount to Assign" := 0;
                    ItemChargeAssignmentPurchase."Amount to Handle" := 0;
                    CASE PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::Receipt:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Receipt;
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::"Return Shipment":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Return Shipment";
                        PostedCustomerRebateLineDetails."Purch Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentPurchase."Applies-to Doc. Type" := ItemChargeAssignmentPurchase."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentPurchase."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Purch Applies-to Doc. No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Purch Applies-to Doc. Line No.";
                    ItemChargeAssignmentPurchase."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Document No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentPurchase."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentPurchase.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Invoice";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentPurchase."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentPurchase."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentPurchase."Line No.";
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();
                until PostedCustomerRebateLineDetails.Next() = 0;

                CLEAR(AssignItemChargePurch);
                AssignItemChargePurch.AssignItemCharges(PurchInvoiceLine, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, PurchInvoiceLine.Quantity, PurchInvoiceLine.Amount, 'By Amount');
            end;
        END;

        IF PostedCustomerRebateLine."Customer Rebate Amt (GL)" <> 0 THEN BEGIN
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
            PurchInvoiceLine.Validate("No.", RebateSetup."Rebate Expense Account");
            PurchInvoiceLine.Description := CopyStr(PostedCustomerRebateLine.Description + ' ' +
                                                    PostedCustomerRebateHeader."Posting Description",
                                                    1, MaxStrLen(PurchInvoiceLine.Description));
            PurchInvoiceLine.Validate("Location Code", PostedCustomerRebateLine."Location Code");
            PurchInvoiceLine.Validate(Quantity, 1);
            PurchInvoiceLine.Validate("Direct Unit Cost", ABS(PostedCustomerRebateLine."Customer Rebate Amt (GL)"));
            IF PostedCustomerRebateLine."Shortcut Dimension 1 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 1 Code", PostedCustomerRebateLine."Shortcut Dimension 1 Code");
            IF PostedCustomerRebateLine."Shortcut Dimension 2 Code" <> '' THEN
                PurchInvoiceLine.Validate("Shortcut Dimension 2 Code", PostedCustomerRebateLine."Shortcut Dimension 2 Code");
            PurchInvoiceLine."AQD Cust Rebate Document No." := PostedCustomerRebateLine."Rebate No.";
            PurchInvoiceLine."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLine."Line No.";
            PurchInvoiceLine.Modify(TRUE);

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Purchase Invoice";
            PostedCustomerRebateLine."Credit Document No." := PurchInvoiceLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := PurchInvoiceLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Purchase Invoice";
                    PostedCustomerRebateLineDetails."Credit Document No." := PurchInvoiceLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := PurchInvoiceLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();
                Until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;
    end;

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

        //IF PostedCustomerRebateHeader."AQD Rebate Status" <> PostedCustomerRebateHeader."AQD Rebate Status"::" " THEN
        //    Error(RebateStatusError, PostedCustomerRebateHeader."AQD Rebate Status");

        PostedCustomerRebateLine.Reset();
        PostedCustomerRebateLine.SetRange("Rebate No.", PostedCustomerRebateHeader."No.");
        PostedCustomerRebateLine.SetRange(Posted, false);
        PostedCustomerRebateLine.SetRange("Rebate Status", PostedCustomerRebateLine."Rebate Status"::" ");
        PostedCustomerRebateLine.SetRange(Exclude, false);
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
            SalesCredirMemo.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Buy-from Vendor No.");
            SalesCredirMemo.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Pay-to Vendor No.");
            SalesCredirMemo.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesCredirMemo.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesCredirMemo."External Document No." := PostedCustomerRebateHeader."No.";
            SalesCredirMemo."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesCredirMemo.Modify(TRUE);

            PostedCustomerRebateHeader."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
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
            SalesCrMemoLine.Validate("No.", RebateSetup."Default Item Charge No.");
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

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Sales Credit Memo";
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
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
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
                    CASE PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Sales Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Sales Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Sales Credit Memo";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
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

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Sales Credit Memo";
            PostedCustomerRebateLine."Credit Document No." := SalesCrMemoLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesCrMemoLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Sales Credit Memo";
                    PostedCustomerRebateLineDetails."Credit Document No." := SalesCrMemoLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := SalesCrMemoLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
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
        TmpInovoiceBuffer.RESET;
        IF NOT TmpInovoiceBuffer.FindFirst() THEN begin
            //Create Sales Invoice Header
            SalesInvoice.INIT;
            SalesInvoice."Document Type" := SalesInvoice."Document Type"::Invoice;
            SalesInvoice."No." := '';
            SalesInvoice.Insert(TRUE);

            SalesInvoice.SetHideValidationDialog(TRUE);
            SalesInvoice.Validate("Sell-To Customer No.", PostedCustomerRebateLine."Buy-from Vendor No.");
            SalesInvoice.VALIDATE("Bill-To Customer No.", PostedCustomerRebateLine."Pay-to Vendor No.");
            SalesInvoice.validate("Location Code", PostedCustomerRebateHeader."Location Code");
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."Posting Description" := PostedCustomerRebateHeader."Posting Description";
            SalesInvoice.Validate("Posting Date", PostedCustomerRebateHeader."Posting Date");
            SalesInvoice."External Document No." := PostedCustomerRebateHeader."No.";
            SalesInvoice."AQD Customer Rebate No" := PostedCustomerRebateHeader."No.";
            SalesInvoice.Modify(TRUE);

            PostedCustomerRebateHeader."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
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
            SalesInvoiceLine.Validate("No.", RebateSetup."Default Item Charge No.");
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

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Sales Invoice";
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
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
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
                    CASE PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type" OF
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::Shipment:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::Invoice:
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice;
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::"Return Receipt":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
                        PostedCustomerRebateLineDetails."Sales Applies-to Doc. Type"::"Credit Memo":
                            ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo";
                    END;
                    ItemChargeAssignmentSales."Applies-to Doc. No." := PostedCustomerRebateLineDetails."Sales Applies-to Doc. No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line No." := PostedCustomerRebateLineDetails."Sales Applies-to Doc. Line No.";
                    ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := 0;
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc No." := PostedCustomerRebateLineDetails."Rebate No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Doc Line No" := PostedCustomerRebateLineDetails."Rebate Line No.";
                    ItemChargeAssignmentSales."AQD Cust Rebate Line No" := PostedCustomerRebateLineDetails."Line No.";
                    ItemChargeAssignmentSales.Insert(TRUE);

                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Sales Invoice";
                    PostedCustomerRebateLineDetails."Credit Document No." := ItemChargeAssignmentSales."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := ItemChargeAssignmentSales."Document Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := ItemChargeAssignmentSales."Line No.";
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
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

            PostedCustomerRebateLine."Rebate Status" := PostedCustomerRebateHeader."Rebate Status"::Created;
            PostedCustomerRebateLine."Rebate Credit Doc Type" := PostedCustomerRebateLine."Rebate Credit Doc Type"::"Sales Invoice";
            PostedCustomerRebateLine."Credit Document No." := SalesInvoiceLine."Document No.";
            PostedCustomerRebateLine."Credit Document Line No." := SalesInvoiceLine."Line No.";
            PostedCustomerRebateLine.Modify();

            PostedCustomerRebateLineDetails.RESET;
            PostedCustomerRebateLineDetails.SetRange("Rebate No.", PostedCustomerRebateLine."Rebate No.");
            PostedCustomerRebateLineDetails.SetRange("Rebate Line No.", PostedCustomerRebateLine."Line No.");
            //PostedCustomerRebateLineDetails.SetRange(Type, PostedCustomerRebateLineDetails.Type::Item);
            PostedCustomerRebateLineDetails.SetFilter("No.", '<>%1', '');
            PostedCustomerRebateLineDetails.SetRange("AQD Cust Rebate Posting Type", PostedCustomerRebateLineDetails."AQD Cust Rebate Posting Type"::"G/L Account");
            PostedCustomerRebateLineDetails.SetRange(Exclude, false);
            IF PostedCustomerRebateLineDetails.FindFirst() THEN begin
                Repeat
                    PostedCustomerRebateLineDetails."Rebate Credit Doc Type" := PostedCustomerRebateLineDetails."Rebate Credit Doc Type"::"Sales Invoice";
                    PostedCustomerRebateLineDetails."Credit Document No." := SalesInvoiceLine."Document No.";
                    PostedCustomerRebateLineDetails."Credit Document Line No." := SalesInvoiceLine."Line No.";
                    PostedCustomerRebateLineDetails."Credit Line No." := 0;
                    PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::Created;
                    PostedCustomerRebateLineDetails.Modify();
                Until PostedCustomerRebateLineDetails.Next() = 0;
            END;
        END;
    end;

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
            PostedCustRebateHeader."Rebate Status" := PostedCustRebateHeader."Rebate Status"::" ";
            PostedCustRebateHeader."Rebate Purchase Doc Type" := PostedCustRebateHeader."Rebate Purchase Doc Type"::" ";
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
                PostedCustRebateLine.SetRange(Exclude, FALSE);
                IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::Invoice then
                    PostedCustRebateLine.SetRange("Rebate Credit Doc Type", PostedCustRebateLine."Rebate Credit Doc Type"::"Purchase Invoice")
                ELSE IF PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Credit Memo" then
                    PostedCustRebateLine.SetRange("Rebate Credit Doc Type", PostedCustRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo");
                PostedCustRebateLine.SetRange("Credit Document No.", PurchaseLine."Document No.");
                PostedCustRebateLine.SetRange("Credit Document Line No.", PurchaseLine."Line No.");
                IF PostedCustRebateLine.FindFirst() THEN BEGIN
                    REPEAT
                        PostedCustRebateLine."Rebate Status" := PostedCustRebateLine."Rebate Status"::" ";
                        PostedCustRebateLine."Rebate Credit Doc Type" := PostedCustRebateLine."Rebate Credit Doc Type"::" ";
                        PostedCustRebateLine."Credit Document No." := '';
                        PostedCustRebateLine."Credit Document Line No." := 0;
                        PostedCustRebateLine.Modify();

                        PostedCustRebateDetailLine.RESET;
                        PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                        PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                        PostedCustRebateDetailLine.SetRange(Exclude, false);
                        If PostedCustRebateDetailLine.FindFirst() THEN begin
                            REPEAT
                                PostedCustRebateDetailLine."Rebate Status" := PostedCustRebateDetailLine."Rebate Status"::" ";
                                PostedCustRebateDetailLine."Rebate Credit Doc Type" := PostedCustRebateLine."Rebate Credit Doc Type"::" ";
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
            PostedCustomerRebateLineDetails."Rebate Status" := PostedCustomerRebateLineDetails."Rebate Status"::" ";
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
                           (NOT PostedCustRebateLine.Exclude)
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(PurchInvLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Rebate Status" := PostedCustRebateHeader."Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Purchase Doc Type" := PostedCustRebateHeader."Rebate Purchase Doc Type"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Rebate Status" := PostedCustRebateLine."Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Credit Doc Type" := PostedCustRebateLine."Rebate Credit Doc Type"::"Purchase Invoice";
                            PostedCustRebateLine."Credit Document No." := PurchInvLine."Document No.";
                            PostedCustRebateLine."Credit Document Line No." := PurchInvLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange(Exclude, false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Rebate Status" := PostedCustRebateDetailLine."Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Credit Doc Type" := PostedCustRebateDetailLine."Rebate Credit Doc Type"::"Purchase Invoice";
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
                           (NOT PostedCustRebateLine.Exclude)
                        THEN BEGIN

                            IF PostedCustRebateHeader.GET(PurchCrMemoLine."AQD Cust Rebate Document No.") THEN begin
                                PostedCustRebateHeader."Rebate Status" := PostedCustRebateHeader."Rebate Status"::Posted;
                                PostedCustRebateHeader."Rebate Purchase Doc Type" := PostedCustRebateHeader."Rebate Purchase Doc Type"::" ";
                                PostedCustRebateHeader.Modify();
                            end;

                            PostedCustRebateLine."Rebate Status" := PostedCustRebateLine."Rebate Status"::Posted;
                            PostedCustRebateLine."Rebate Credit Doc Type" := PostedCustRebateLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
                            PostedCustRebateLine."Credit Document No." := PurchCrMemoLine."Document No.";
                            PostedCustRebateLine."Credit Document Line No." := PurchCrMemoLine."Line No.";
                            PostedCustRebateLine.Modify();

                            PostedCustRebateDetailLine.RESET;
                            PostedCustRebateDetailLine.SetRange("Rebate No.", PostedCustRebateLine."Rebate No.");
                            PostedCustRebateDetailLine.SetRange("Rebate Line No.", PostedCustRebateLine."Line No.");
                            PostedCustRebateDetailLine.SetRange(Exclude, false);
                            If PostedCustRebateDetailLine.FindFirst() THEN begin
                                repeat
                                    PostedCustRebateDetailLine."Rebate Status" := PostedCustRebateDetailLine."Rebate Status"::Posted;
                                    PostedCustRebateDetailLine."Rebate Credit Doc Type" := PostedCustRebateDetailLine."Rebate Credit Doc Type"::"Purchase Credit Memo";
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
}