codeunit 14302618 "AQD Claims and Rebates Events"
{
    var
        AcumensRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        NotApprovedErr: Label 'Sales Rebate %1 has not been approved. Payment cannot be applied to this Invoice. \\Instead, invoice must be approved before making the payment.';
        EarlierReleaseDateErr: Label 'You cannot apply and post an entry to a Rebate Invoice with posting date less than the Rebates approval date.';
        CustClaimsRebatesAppr: codeunit "AQD Cust. Claims_Rebates Appr.";
        RebateClaimsWorkflowMgmt: Codeunit "AQD Cust. Claims_Rebates Appr.";
        AQDCRSingleInstanceExt: Codeunit "AQD CR Single Instance Ext";

    [EventSubscriber(ObjectType::Table, Database::"AQD Posted Cust Reb Details", 'OnAfterInsertEvent', '', false, false)]
    local procedure PostedCustRebDetails_OnAfterInsert(var Rec: Record "AQD Posted Cust Reb Details"; RunTrigger: Boolean)
    var
        SalesRebateApprovals, SalesRebateApprovalsII : Record "AQD Sales Rebate Approvals";
    begin
        SalesRebateApprovals.Reset();
        case Rec."Document Type" of
            Rec."Document Type"::" ":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::" ");
            Rec."Document Type"::"Credit Memo":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Credit Memo");
            Rec."Document Type"::Invoice:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Invoice);
            Rec."Document Type"::"Return Receipt":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Return Receipt");
            Rec."Document Type"::Shipment:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Shipment);
        end;
        SalesRebateApprovals.SetRange("Sales Document No.", Rec."Document No.");
        SalesRebateApprovals.SetRange("Rebate Program Code", Rec."Rebate Program Code");
        SalesRebateApprovals.SetRange("Entity No.", Rec."Entity No.");
        if SalesRebateApprovals.FindFirst() then begin
            SalesRebateApprovals."Rebate Amount" += Rec."Calculated Line Rebate Amount";
            if SalesRebateApprovals."Rebate %" = 0 then
                SalesRebateApprovals."Rebate %" := Rec."Rebate %";
            if SalesRebateApprovals."Rebate Per Unit" = 0 then
                SalesRebateApprovals."Rebate Per Unit" := Rec."Rebate Per Unit";

            // SalesRebateApprovals."Approval Status" := SalesRebateApprovals."Approval Status"::Open;
            SalesRebateApprovals.SetSkipStatusCheck(true);
            SalesRebateApprovals.Modify();
            SalesRebateApprovals.SetSkipStatusCheck(false);

        end else begin
            SalesRebateApprovalsII.Init();
            case Rec."Document Type" of
                Rec."Document Type"::"Credit Memo":
                    SalesRebateApprovalsII."Sales Document Type" := SalesRebateApprovalsII."Sales Document Type"::"Credit Memo";
                Rec."Document Type"::Invoice:
                    SalesRebateApprovalsII."Sales Document Type" := SalesRebateApprovalsII."Sales Document Type"::Invoice;
                Rec."Document Type"::"Return Receipt":
                    SalesRebateApprovalsII."Sales Document Type" := SalesRebateApprovalsII."Sales Document Type"::"Return Receipt";
                Rec."Document Type"::Shipment:
                    SalesRebateApprovalsII."Sales Document Type" := SalesRebateApprovalsII."Sales Document Type"::Shipment;
            end;
            SalesRebateApprovalsII."Sales Document No." := Rec."Document No.";
            SalesRebateApprovalsII."Rebate Program Code" := Rec."Rebate Program Code";
            SalesRebateApprovalsII."Document Amount" := Rec.Amount;
            SalesRebateApprovalsII."Rebate Amount" := Rec."Calculated Line Rebate Amount";
            SalesRebateApprovalsII."Rebate %" := Rec."Rebate %";
            SalesRebateApprovalsII."Rebate Per Unit" := Rec."Rebate Per Unit";
            SalesRebateApprovalsII."Entity No." := Rec."Entity No.";
            //
            SalesRebateApprovalsII."Sell-To Customer No." := Rec."Sell-To Customer No.";
            SalesRebateApprovalsII."Bill-To Customer No." := Rec."Bill-To Customer No.";
            SalesRebateApprovalsII."Rebate Pay-To Customer No." := Rec."Rebate Pay-To Customer No.";
            SalesRebateApprovalsII."Sales Document Posting Date" := Rec."Posting Date";
            //
            SalesRebateApprovalsII."Salesperson Code" := Rec."Salesperson Code";
            SalesRebateApprovalsII."Responsibility Center" := Rec."Responsibility Center";
            SalesRebateApprovalsII."Location Code" := Rec."Location Code";
            SalesRebateApprovalsII."Approval Status" := SalesRebateApprovalsII."Approval Status"::Open;
            if Rec."Customer Rebate Status" = Rec."Customer Rebate Status"::Posted then
                SalesRebateApprovalsII.Posted := true;

            SalesRebateApprovalsII.SetSkipStatusCheck(true);
            SalesRebateApprovalsII.Insert();

            if CheckPostedCustRebateLineApprovalsWorkflowEnabled(SalesRebateApprovalsII) then
                RebateClaimsWorkflowMgmt.OnSendPostedCustRebateLineForApproval(SalesRebateApprovalsII);

        end;
    end;

    procedure CheckPostedCustRebateLineApprovalsWorkflowEnabled(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if not RebateClaimsWorkflowMgmt.IsSalesClaimsandRebatesApprovalsEnabled() then
            exit(false);

        if not WorkflowManagement.CanExecuteWorkflow(PostedCustRebateLine, RebateClaimsWorkflowMgmt.RunWorkflowOnSendPostedCustRebateLineForApprovalCode())
        then
            exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Posted Cust Reb Details", 'OnAfterModifyEvent', '', false, false)]
    local procedure PostedCustRebDetails_OnAfterModify(var Rec: Record "AQD Posted Cust Reb Details"; RunTrigger: Boolean)
    var
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
    begin
        SalesRebateApprovals.Reset();
        case Rec."Document Type" of
            Rec."Document Type"::" ":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::" ");
            Rec."Document Type"::"Credit Memo":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Credit Memo");
            Rec."Document Type"::Invoice:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Invoice);
            Rec."Document Type"::"Return Receipt":
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::"Return Receipt");
            Rec."Document Type"::Shipment:
                SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Shipment);
        end;
        SalesRebateApprovals.SetRange("Sales Document No.", Rec."Document No.");
        SalesRebateApprovals.SetRange("Rebate Program Code", Rec."Rebate Program Code");
        if SalesRebateApprovals.FindFirst() then begin
            SalesRebateApprovals."Vendor Document Type" := Rec."Vendor Document Type";
            SalesRebateApprovals."Vendor Document No." := Rec."Vendor Document No.";
            SalesRebateApprovals.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Apply Vendor Entries", OnBeforeOnQueryClosePage, '', false, false)]
    local procedure Page233_Apply_Vendor_Payment_OnBeforeOnQueryClosePage(CloseAction: Action; ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry"; ApplnType: Enum "Vendor Apply-to Type"; VendorLedgerEntry: Record "Vendor Ledger Entry"; CalcType: Enum "Vendor Apply Calculation Type"; var IsHandled: Boolean)
    var
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
        IsApproved: Boolean;
        LatestApprovalDate: Date;
        RaiseErrorRebate: Boolean;
    begin
        if not CustClaimsRebatesAppr.IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if not IsRebateEntry(VendorLedgerEntry) then
            exit;

        IsApproved := false;
        LatestApprovalDate := 0D;

        SalesRebateApprovals.Reset();
        SalesRebateApprovals.SetRange("Vendor Document No.", VendorLedgerEntry."Document No.");
        //SalesRebateApprovals.SetRange("Sales Document Type", SalesRebateApprovals."Sales Document Type"::Invoice);
        SalesRebateApprovals.SetRange("Approval Status", SalesRebateApprovals."Approval Status"::Approved);
        if SalesRebateApprovals.FindFirst() then begin
            repeat

                IsApproved := true;

                if SalesRebateApprovals."AQD CRBApproval Date" <> 0D then
                    if SalesRebateApprovals."AQD CRBApproval Date" > LatestApprovalDate then
                        LatestApprovalDate := SalesRebateApprovals."AQD CRBApproval Date";

            until SalesRebateApprovals.Next() = 0;
        end;

        if not IsApproved then begin
            if CloseAction = ACTION::LookupOK then
                Error(NotApprovedErr, VendorLedgerEntry."Document No.");
        end;

        RaiseErrorRebate := ApplyingVendorLedgerEntry."Posting Date" < LatestApprovalDate;

        if (LatestApprovalDate <> 0D) and RaiseErrorRebate then begin
            if CloseAction = ACTION::LookupOK then
                Error(EarlierReleaseDateErr);
        end;
    end;

    local procedure IsRebateEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"): Boolean
    var
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
    begin
        SalesRebateApprovals.SetRange("Vendor Document No.", VendorLedgerEntry."Document No.");
        exit(SalesRebateApprovals.FindFirst());
    end;

    procedure GetSalesRebatesInvoiceNo(var VendorLedgerEntry: Record "Vendor Ledger Entry"): Code[20]
    var
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
    begin
        SalesRebateApprovals.Reset();
        SalesRebateApprovals.SetRange("Vendor Document No.", VendorLedgerEntry."Document No.");

        if SalesRebateApprovals.FindFirst() then
            exit(SalesRebateApprovals."Sales Document No.");

        exit('');
    end;

    procedure ReleaseSalesRebateForPaymentAfterApproval(var SalesRebateApprovals: Record "AQD Sales Rebate Approvals")
    var
        GLE: Record "G/L Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        Adjusted: Boolean;
    begin
        GLE.Reset;
        GLE.SetRange("Document Type", GLE."Document Type"::Invoice);
        GLE.SetRange("Document No.", SalesRebateApprovals."Vendor Document No.");
        GLE.SetRange(Reversed, false);

        if GLE.FindSet() then
            repeat
                Adjusted := false;
                VendorLedgerEntry.Reset();
                VendorLedgerEntry.SetRange("Transaction No.", GLE."Transaction No.");
                VendorLedgerEntry.SetRange(Reversed, false);

                if VendorLedgerEntry.FindSet() then
                    repeat
                        VendorLedgerEntry.Open := true;
                        VendorLedgerEntry.Modify();
                        Adjusted := true;
                    until (VendorLedgerEntry.Next() = 0) OR Adjusted;

            until GLE.Next() = 0;

        SalesRebateApprovals."AQD CRBApproval Date" := Today;
        SalesRebateApprovals."AQD CRBApproved by" := UserId;
        SalesRebateApprovals.Modify(true);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", OnGetVendLedgEntriesOnBeforeLoop, '', false, false)]
    local procedure OnGetVendLedgEntriesOnBeforeLoop(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; LastDueDateToPayReq: Date; Future: Boolean; var IsHandled: Boolean)
    var
        SalesRebateApprovals: Record "AQD Sales Rebate Approvals";
    begin
        if IsHandled then
            exit;

        CheckVendorLedgerEntryFilters(VendorLedgerEntry, IsHandled);

        if IsHandled then
            exit;

        if not CustClaimsRebatesAppr.IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        SalesRebateApprovals.Reset();
        SalesRebateApprovals.SetRange("Entity No.", VendorLedgerEntry."Vendor No.");
        SalesRebateApprovals.SetRange("Vendor Document No.", VendorLedgerEntry."Document No.");
        SalesRebateApprovals.SetRange("Rebate Program Code", VendorLedgerEntry."AQD CR Rebate Program Code");
        if not SalesRebateApprovals.FindFirst() then
            exit
        else
            IsHandled := not (SalesRebateApprovals."Approval Status" = SalesRebateApprovals."Approval Status"::Approved);

    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Payment Buffer", OnAfterCopyFieldsToGenJournalLine, '', false, false)]
    local procedure OnAfterCopyFieldsToGenJournalLine(VendorPaymentBufferSource: Record "Vendor Payment Buffer"; var GenJournalLineTarget: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if VendorLedgerEntry.get(VendorPaymentBufferSource."Vendor Ledg. Entry No.") then
            GenJournalLineTarget."AQD CR Rebate Program Code" := VendorLedgerEntry."AQD CR Rebate Program Code";
    end;

    local procedure CheckVendorLedgerEntryFilters(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var IsHandled: Boolean)
    var
        VendorLedgerRec: Record "Vendor Ledger Entry";
        ExitLoop: Boolean;
        RebateProgramCode: Record "AQD Cust Rebate Program Code";
    begin
        if IsHandled then
            exit;

        AQDCRSingleInstanceExt.GetVendorLedgerEntriesFilters(VendorLedgerRec);

        if VendorLedgerRec.GetFilter("AQD CR Rebate Program Code") = '' then
            exit;

        ExitLoop := false;

        RebateProgramCode.Reset();
        RebateProgramCode.SetFilter(Code, VendorLedgerRec.GetFilter("AQD CR Rebate Program Code"));
        if RebateProgramCode.FindFirst() then
            repeat

                ExitLoop := (RebateProgramCode.Code = VendorLedgerEntry."AQD CR Rebate Program Code");

                IsHandled := not ExitLoop;

            until (RebateProgramCode.Next() = 0) or (ExitLoop = true);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"AQD Cust Rebate Calc Mgt", OnBeforeInsertRebateDetail, '', false, false)]
    local procedure CU14302513_AQDCustRebateCalcMgt_OnBeforeInsertRebateDetail(var CustomerRebateDetails: Record "AQD Customer Rebate Details"; GlobalProcessCatchUpRebate: Boolean; GlobalBrokerVendorNo: Code[20]; var IsHandled: Boolean)
    var
        ProgramCodeRec: Record "AQD Cust Rebate Program Code";
        SalesRebateCalc: Codeunit "AQD Sales Rebate Rate Calc Mgt";
        TempSalesRebatesRate: Record "AQD Sales Rebates Rate" temporary;
        BestSalesRebateFound: Boolean;
    begin
        if CustomerRebateDetails.IsTemporary then
            exit;


        TempSalesRebatesRate.RESET;
        IF TempSalesRebatesRate.IsTemporary THEN
            TempSalesRebatesRate.DeleteAll();

        // BestSalesRebateFound := CalcBestSalesRebateRate(CustomerRebateDetails, TempSalesRebatesRate);

        // IF BestSalesRebateFound THEN BEGIN
        //     CustomerRebateDetails."AQD Trade Agreement" := TempSalesRebatesRate."AQD Trade Agreement";
        // END ELSE BEGIN
        if CustomerRebateDetails."Rebate Program Code" <> '' then begin
            ProgramCodeRec.Reset();
            if ProgramCodeRec.Get(CustomerRebateDetails."Rebate Program Code") then
                CustomerRebateDetails.Validate("AQD Default Trade Agreement", ProgramCodeRec."AQD Default Trade Agreement");
        end;
        //END;
    end;

    procedure CalcBestSalesRebateRate(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details"; var TempSalesRebatesRate: Record "AQD Sales Rebates Rate"): Boolean
    var
        BestCustomerSalesRebate: Record "AQD Sales Rebates Rate";
        CustomerSalesRebateRate: Record "AQD Sales Rebates Rate";
        ItemRec: Record Item;
        CustomerRec: Record Customer;
        BestSalesRebateFound: Boolean;
        FoundSalesRebate: Boolean;
        SalesQty: Decimal;
        SalesAmount: Decimal;
        RebateDateFilter: text;
    begin
        FoundSalesRebate := CustomerSalesRebateRate.FindFirst();
        IF FoundSalesRebate THEN BEGIN
            REPEAT
                SalesQty := 0;
                SalesAmount := 0;

                IF CustomerSalesRebateRate."Starting Date" <> 0D THEN
                    RebateDateFilter := FORMAT(CustomerSalesRebateRate."Starting Date");

                IF (CustomerSalesRebateRate."Ending Date" <> 0D) THEN BEGIN
                    RebateDateFilter := RebateDateFilter + '..' + FORMAT(CustomerSalesRebateRate."Ending Date")
                END ELSE
                    IF RebateDateFilter <> '' THEN
                        RebateDateFilter := RebateDateFilter + '..';

                SalesQty := CustomerRebateDetailsLocIn.Quantity;
                SalesAmount := CustomerRebateDetailsLocIn.Amount;

                CASE CustomerSalesRebateRate."Payee Type" OF
                    CustomerSalesRebateRate."Payee Type"::CustomerRebate:
                        begin
                            CASE CustomerSalesRebateRate."Customer Type" OF
                                CustomerSalesRebateRate."Customer Type"::Customer:
                                    BEGIN
                                        IF CustomerSalesRebateRate."CustRbt Rate Type" = CustomerSalesRebateRate."CustRbt Rate Type"::"Volume Rebate" THEN BEGIN
                                            Case CustomerSalesRebateRate."Line Type" OF
                                                CustomerSalesRebateRate."Line Type"::Item:
                                                    BEGIN
                                                        ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                                        ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                        ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                        ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                        SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                        SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                    END;
                                                CustomerSalesRebateRate."Line Type"::"Rebate Category":
                                                    BEGIN
                                                        ItemRec.RESET;
                                                        ItemRec.SETRANGE("AQD Cust Rebate Category Code", CustomerRebateDetailsLocIn."Rebate Item Category Code");
                                                        IF ItemRec.FINDFIRST THEN BEGIN
                                                            REPEAT
                                                                ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                                ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                                ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                                SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                                SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                            UNTIL ItemRec.Next() = 0;
                                                        END;
                                                    END;
                                            End;
                                        END;

                                        Case TRUE of
                                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                                BEGIN
                                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") AND
                                                       (SalesAmount >= CustomerSalesRebateRate."Minimum Amount")
                                                    THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                                BEGIN
                                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                                BEGIN
                                                    IF (SalesAmount >= CustomerSalesRebateRate."Minimum Amount") THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                                BEGIN
                                                    BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                    BestSalesRebateFound := TRUE;
                                                END;
                                        End;
                                    END;
                                CustomerSalesRebateRate."Customer Type"::"Customer Category":
                                    BEGIN
                                        CustomerRec.RESET;
                                        CustomerRec.SetRange("AQD Cust Rebate Category", CustomerSalesRebateRate."No.");
                                        IF CustomerRec.FINDFIRST THEN BEGIN
                                            REPEAT
                                                Case CustomerSalesRebateRate."Line Type" OF
                                                    CustomerSalesRebateRate."Line Type"::Item:
                                                        BEGIN
                                                            ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                                            ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                            ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                            ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                            SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                            SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                        END;
                                                    CustomerSalesRebateRate."Line Type"::"Rebate Category":
                                                        BEGIN
                                                            ItemRec.RESET;
                                                            ItemRec.SETRANGE("AQD Cust Rebate Category Code", CustomerRebateDetailsLocIn."Rebate Item Category Code");
                                                            IF ItemRec.FINDFIRST THEN BEGIN
                                                                REPEAT
                                                                    ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                                    ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                                    ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                                    SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                                    SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                                UNTIL ItemRec.Next() = 0;
                                                            END;
                                                        END;
                                                End;
                                            UNTIL CustomerRec.NEXT = 0;
                                        END;

                                        Case TRUE of
                                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                                BEGIN
                                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") AND
                                                       (SalesAmount >= CustomerSalesRebateRate."Minimum Amount")
                                                    THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                                BEGIN
                                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                                BEGIN
                                                    IF (SalesAmount >= CustomerSalesRebateRate."Minimum Amount") THEN BEGIN
                                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                        BestSalesRebateFound := TRUE;
                                                    END;
                                                END;
                                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                                BEGIN
                                                    BestCustomerSalesRebate := CustomerSalesRebateRate;
                                                    BestSalesRebateFound := TRUE;
                                                END;
                                        End;
                                    END;
                            END;
                        end;
                    else begin
                        IF CustomerSalesRebateRate."CustRbt Rate Type" = CustomerSalesRebateRate."CustRbt Rate Type"::"Volume Rebate" THEN BEGIN
                            Case CustomerSalesRebateRate."Line Type" OF
                                CustomerSalesRebateRate."Line Type"::Item:
                                    BEGIN
                                        ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                        ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                        ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                        ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                        SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                        SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                    END;
                                CustomerSalesRebateRate."Line Type"::"Rebate Category":
                                    BEGIN
                                        ItemRec.RESET;
                                        ItemRec.SETRANGE("AQD Cust Rebate Category Code", CustomerRebateDetailsLocIn."Rebate Item Category Code");
                                        IF ItemRec.FINDFIRST THEN BEGIN
                                            REPEAT
                                                ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                            UNTIL ItemRec.Next() = 0;
                                        END;
                                    END;
                            End;
                        END;

                        Case TRUE of
                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                BEGIN
                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") AND
                                       (SalesAmount >= CustomerSalesRebateRate."Minimum Amount")
                                    THEN BEGIN
                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                        BestSalesRebateFound := TRUE;
                                    END;
                                END;
                            (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                BEGIN
                                    IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                        BestSalesRebateFound := TRUE;
                                    END;
                                END;
                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                            (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                BEGIN
                                    IF (SalesAmount >= CustomerSalesRebateRate."Minimum Amount") THEN BEGIN
                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                        BestSalesRebateFound := TRUE;
                                    END;
                                END;
                            (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                            (CustomerSalesRebateRate."Minimum Amount" = 0):
                                BEGIN
                                    BestCustomerSalesRebate := CustomerSalesRebateRate;
                                    BestSalesRebateFound := TRUE;
                                END;
                        End;
                    end;
                end;
            UNTIL CustomerSalesRebateRate.NEXT = 0;
        END;

        TempSalesRebatesRate := BestCustomerSalesRebate;

        exit(BestSalesRebateFound);
    end;
}