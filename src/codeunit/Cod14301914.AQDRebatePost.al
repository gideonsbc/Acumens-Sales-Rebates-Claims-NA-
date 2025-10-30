codeunit 14301914 "AQD Customer Rebate Post"
{
    TableNo = "AQD Cust Rebate Journal Line";

    trigger OnRun()
    begin
        CustRebateJournalLine.Copy(Rec);
        PostRebateJournal(CustRebateJournalLine);
    end;

    var
        UserConfirmMsg: Label 'Do you want to create Rebate Purchase Journal?';
        CustRebateJournalLine: Record "AQD Cust Rebate Journal Line";
        GenJnlLine: Record "Gen. Journal Line";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        RebateUserSetup: Record "AQD Customer Rebate User Setup";
        RebateDocEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
        RebateRegister: Record "AQD Customer Rebate Register";
        TmpRebateRegister: Record "AQD Customer Rebate Register" temporary;
        Vendor: Record Vendor;
        Customer: Record Customer;
        LastGenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        RebatePostRep: Report "AQD Cust Rebate Post By";
        ConfirmManagement: Codeunit "Confirm Management";
        SalesUserConfirmMsg: Label 'Do you want to create Rebate Sales Journal?';
        NothingToPost: Label 'There is nothing to post.';
        RebateCalculationError: Label 'Rebate Journal Lines are created to review Rebate.\ Please recreate Rebate Journal Lines to process.';
        SummaryByRebateType: Boolean;
        SummaryByRebateCode: Boolean;
        SummayByLocation: Boolean;
        SummayByCounty: Boolean;
        SummayByGlobalDim1: Boolean;
        SummayByGlobalDim2: Boolean;
        SummaryByDocNo: Boolean;
        BottomLine: Boolean;
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        PaymentCheckNo: Code[20];
        Balance: Decimal;
        PaymentDate: Date;
        Window: Dialog;
        NextLineNo: Integer;
        JnlBatchTemplateError: Label '%1 and %2 must be defined on either %3 or %4. Current values: %1 = %5, %2 = %6.';
        NextRegisterNo: Integer;
        PeriodTextConst: Label '  Period:';
        JnlPostSuccessfulMsg: Label 'Rebate Journal is posted successfully.';
        DoNotPayRebateError: Label 'Purchase Journal cannot be posted because %1 %2 has "Do Not Pay Rebate" = True.\\Identification Fields: "Journal Template Name": %3, "Journal Batch Name": %4, "Line No." = %5.';
        RebateRegisterAlreadyPosted: Label 'Rebate Register Status must not  be %1. It cannot be voided.';
        RebateRegisterAlreadyPaid: Label 'Rebate Register is already Paid. It cannot be voided.';
        RebateRegisterAlreadyVoided: Label 'Rebate Register is already voided.';
        NothingToUpdateError: Label 'There is no Rebate Register in provided filter.';
        Vendor1099NotUpdateError: Label '1099 Vendor cannot be updated using this function.';
        Text001: Label 'Processing Rebate Register    #1##########\\';
        NoOfRecords: Integer;
        LineCount: Integer;
        VoidUserConfirmMsg: Label 'Do you want to void selected Rebate Register?';
        VoidSuccessfulMsg: Label 'Rebate Register is voided.';
        PmtInfocannotUpdateOnVoidedError: Label 'Payment Information cannot be updated on Voided register.';
        UserPostingPermissionError: Label 'Rebate Journal can be posted by User having Rebate Role %1 o %2.';
        PurchaseJnlPostSuccessfulMsg: Label 'Rebate Purchase Journal is created successfully.';
        SalesJnlPostSuccessfulMsg: Label 'Rebate Sales Journal is created successfully.';
        NothingToCreatePurchJnl: Label 'No Rebate Register is selected to create Purchase Journal.';
        NothingToVoid: Label 'No Rebate Register is selected to Void.';
        RebateText: Label 'Rebate For ';
        NextRegNo: Integer;


    procedure PostRebateJournal(var CustRebateJournalLine: Record "AQD Cust Rebate Journal Line")
    var
        RebateJnlIsPosted: Label 'Customer Rebate Purchase Journal is posted.';
        DoNotPayRebateError: Label 'Purchase Journal cannot be posted because %1 %2 has "Do Not Pay Rebate" = True.\\Identification Fields: "Journal Template Name": %3, "Journal Batch Name": %4, "Line No." = %5.';
    begin
        CustRebateJournalLine.SetRange("AQD Run For", CustRebateJournalLine."AQD Run For"::Review);
        if not CustRebateJournalLine.IsEmpty then
            Error(RebateCalculationError);

        TmpRebateRegister.Reset;
        if TmpRebateRegister.IsTemporary then
            TmpRebateRegister.DeleteAll;

        CustRebateJournalLine.SetRange("AQD Run For");
        if not CustRebateJournalLine.FindFirst then
            Error(NothingToPost);

        Clear(RebatePostRep);
        RebatePostRep.RunModal;
        RebatePostRep.GetSummaryByInfo(SummaryByRebateType, SummaryByRebateCode, SummayByLocation, SummayByCounty, SummayByGlobalDim1, SummayByGlobalDim2, SummaryByDocNo);
        if not RebatePostRep.GetActionResult then
            exit;
        Commit; // There is nothing to commit

        RebateSetup.Get;
        RebateUserSetup.Get(UserId);
        if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then
            Error(UserPostingPermissionError,
              RebateUserSetup."Rebate Role"::"Sales Manager",
              RebateUserSetup."Rebate Role"::Admin);

        if GuiAllowed then begin
            Window.Open(Text001);
            Window.Update(1, CustRebateJournalLine."AQD User ID");
        end;

        NoOfRecords := CustRebateJournalLine.Count;
        RebateRegister.Reset;
        if RebateRegister.FindLast then
            NextRegisterNo := RebateRegister."AQD Entry No." + 1
        else
            NextRegisterNo := 1;

        if CustRebateJournalLine.FindFirst then begin
            repeat
                if GuiAllowed then
                    LineCount := LineCount + 1;

                case CustRebateJournalLine."AQD Pay-To Rebate Type" of
                    CustRebateJournalLine."AQD Pay-To Rebate Type"::Customer:
                        begin
                            Customer.Get(CustRebateJournalLine."AQD Rebate Code");
                        end;
                    CustRebateJournalLine."AQD Pay-To Rebate Type"::Vendor:
                        begin
                            Vendor.Get(CustRebateJournalLine."AQD Rebate Code");
                        end;
                end;

                TmpRebateRegister.Reset;
                TmpRebateRegister.SetRange("AQD Payee Type", CustRebateJournalLine."AQD Payee Type");
                if SummaryByRebateType then
                    TmpRebateRegister.SetRange("AQD Rebate Type", CustRebateJournalLine."AQD Pay-To Rebate Type");
                if SummaryByRebateCode then
                    TmpRebateRegister.SetRange("AQD Rebate Code", CustRebateJournalLine."AQD Rebate Code");
                if SummayByLocation then
                    TmpRebateRegister.SetRange("AQD Location Code", CustRebateJournalLine."AQD Location Code");
                if SummayByGlobalDim1 then
                    TmpRebateRegister.SetRange("AQD Shortcut Dimension 1 Code", CustRebateJournalLine."AQD Shortcut Dimension 1 Code");
                if SummayByGlobalDim2 then
                    TmpRebateRegister.SetRange("AQD Shortcut Dimension 2 Code", CustRebateJournalLine."AQD Shortcut Dimension 2 Code");
                if SummayByCounty then
                    TmpRebateRegister.SetRange("AQD State", CustRebateJournalLine."AQD State");
                if not TmpRebateRegister.FindFirst then begin
                    RebateRegister.Init;
                    RebateRegister."AQD Entry No." := NextRegisterNo;
                    RebateRegister."AQD Payee Type" := CustRebateJournalLine."AQD Payee Type";
                    if SummaryByRebateType then
                        RebateRegister."AQD Rebate Type" := CustRebateJournalLine."AQD Pay-To Rebate Type";
                    if SummaryByRebateCode then
                        RebateRegister."AQD Rebate Code" := CustRebateJournalLine."AQD Rebate Code";
                    if SummayByLocation then
                        RebateRegister."AQD Location Code" := CustRebateJournalLine."AQD Location Code";
                    if SummayByGlobalDim1 then
                        RebateRegister."AQD Shortcut Dimension 1 Code" := CustRebateJournalLine."AQD Shortcut Dimension 1 Code";
                    if SummayByGlobalDim2 then
                        RebateRegister."AQD Shortcut Dimension 2 Code" := CustRebateJournalLine."AQD Shortcut Dimension 2 Code";
                    if SummayByCounty then
                        RebateRegister."AQD State" := CustRebateJournalLine."AQD State";
                    RebateRegister."AQD Start Date" := CustRebateJournalLine."AQD Start Date";
                    RebateRegister."AQD End Date" := CustRebateJournalLine."AQD End Date";
                    RebateRegister."AQD Creation DateTime" := CurrentDateTime;
                    RebateRegister."AQD Created By User ID" := UserId;
                    RebateRegister.Insert;
                    NextRegisterNo += 1;

                    TmpRebateRegister.Init;
                    TmpRebateRegister := RebateRegister;
                    TmpRebateRegister.Insert;
                end else
                    RebateRegister.Get(TmpRebateRegister."AQD Entry No.");

                RebateRegister."AQD Batch Name" := CustRebateJournalLine."AQD User ID";
                if RebateRegister."AQD Payee Type" = RebateRegister."AQD Payee Type"::"W2 Employee" then
                    RebateRegister."AQD Status" := RebateRegister."AQD Status"::Posted // W2 will have directly Journal Initially
                else
                    if RebateRegister."AQD Payee Type" in
                 [RebateRegister."AQD Payee Type"::" ",
                  RebateRegister."AQD Payee Type"::"1099 Vendor"]
               then
                        RebateRegister."AQD Status" := RebateRegister."AQD Status"::Approved; // 1099 will have directly Journal Initially
                RebateRegister.Modify;

                if RebateDocEntry.Get(CustRebateJournalLine."AQD Rebate Code",
                  CustRebateJournalLine."AQD Document Type",
                  CustRebateJournalLine."AQD Document No.",
                  CustRebateJournalLine."AQD Pay-To Rebate Type")
                then begin
                    RebateDocEntry."Rebate Register No." := RebateRegister."AQD Entry No.";
                    RebateDocEntry."Journal Template Name" := '';
                    RebateDocEntry."Journal Batch Name" := CustRebateJournalLine."AQD User ID";
                    RebateDocEntry."Journal Line No." := 0;
                    RebateDocEntry."Journal Document No." := '';
                    RebateDocEntry."Rebate Approved" := true;
                    RebateDocEntry."Rebate Approved By" := UserId;
                    RebateDocEntry."Rebate Approved Date" := Today;
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Approved;
                    if RebateRegister."AQD Payee Type" = RebateRegister."AQD Payee Type"::"W2 Employee" then begin
                        RebateDocEntry.Payable := true;
                        RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Posted;
                    end else
                        if RebateRegister."AQD Payee Type" in
                            [RebateRegister."AQD Payee Type"::" ",
                             RebateRegister."AQD Payee Type"::"1099 Vendor"]
                        then begin
                            RebateDocEntry.Payable := false;
                            RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Approved;
                        end;
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry."Rebate Register No." := RebateRegister."AQD Entry No.";
                            RebateEntry."Journal Template Name" := '';
                            RebateEntry."Journal Batch Name" := CustRebateJournalLine."AQD User ID";
                            RebateEntry."Journal Line No." := 0;
                            RebateEntry."Journal Document No." := '';
                            case RebateRegister."AQD Payee Type" of
                                RebateRegister."AQD Payee Type"::" ":
                                    RebateEntry.Payable := true;
                                RebateRegister."AQD Payee Type"::"W2 Employee":
                                    RebateEntry.Payable := true;
                                RebateRegister."AQD Payee Type"::"1099 Vendor":
                                    RebateEntry.Payable := false;
                            end;
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                end;
            until CustRebateJournalLine.Next = 0;
            CustRebateJournalLine.DeleteAll;
        end;

        if GuiAllowed then
            Window.Close;
        Message(JnlPostSuccessfulMsg);
    end;


    procedure CreateRebatePurchJnlFromRegister(var GenJournalLineIn: Record "Gen. Journal Line")
    var
        RebateDocEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
        RebateJnlIsPosted: Label 'Rebate Purchase Journal is posted.';
        DoNotPayRebateError: Label 'Purchase Journal cannot be posted because %1 %2 has "Do Not Pay Rebate" = True.\\Identification Fields: "Journal Template Name": %3, "Journal Batch Name": %4, "Line No." = %5.';
        RebateRegisterPage: Page "AQD Customer Rebate Register";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        NextRegNo: Integer;
    begin
        if not ConfirmManagement.GetResponseOrDefault(UserConfirmMsg, true) then
            exit;

        RebateRegister.Reset;
        RebateRegister.FilterGroup(2);
        RebateRegister.SetRange("AQD Status", RebateRegister."AQD Status"::Approved);
        //RebateRegister.SETRANGE("Rebate Type",RebateRegister."Rebate Type"::Vendor);
        RebateRegister.SetRange("AQD Payee Type", RebateRegister."AQD Payee Type"::"1099 Vendor");
        RebateRegister.FilterGroup(0);
        Clear(RebateRegisterPage);
        RebateRegisterPage.Editable(false);
        RebateRegisterPage.LookupMode(true);
        RebateRegisterPage.SetTableView(RebateRegister);
        if RebateRegisterPage.RunModal = ACTION::LookupOK then
            RebateRegisterPage.GetSelectionFilters(RebateRegister)
        else
            exit;

        if not RebateRegister.FindFirst then
            Error(NothingToCreatePurchJnl);

        RebateSetup.Get;

        JnlTemplateName := GenJournalLineIn."Journal Template Name";
        JnlBatchName := GenJournalLineIn."Journal Batch Name";

        GenJnlLine.LockTable;
        GenJnlTemplate.Get(JnlTemplateName);
        GenJnlBatch.Get(JnlTemplateName, JnlBatchName);

        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        if GuiAllowed then begin
            Window.Open(Text001);
            Window.Update(1, RebateRegister."AQD Entry No.");
        end;

        NoOfRecords := RebateRegister.Count;

        //1099 Vendor
        RebateSetup.TestField("Rebate Expense Account");
        GenJnlBatch.TestField("No. Series");
        repeat
            if GuiAllowed then
                LineCount := LineCount + 1;

            GenJnlLine.Reset;
            GenJnlLine.SetRange("AQD Cust Rebate Register No.", RebateRegister."AQD Entry No.");
            GenJnlLine.DeleteAll;

            RebateDocEntry.Reset;
            RebateDocEntry.SetCurrentKey("Rebate Register No.");
            RebateDocEntry.SetRange("Rebate Register No.", RebateRegister."AQD Entry No.");
            RebateDocEntry.SetRange("Vendor Ledger Entry No.", 0);
            RebateDocEntry.SetRange(Open, true);
            RebateDocEntry.SetRange(Payable, false);
            RebateDocEntry.SetRange("Rebate Approved", true);
            if RebateDocEntry.FindFirst then begin
                repeat
                    Vendor.Get(RebateDocEntry."Rebate Code");

                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
                    GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                    GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                    GenJnlLine.SetRange("Account No.", Vendor."No.");
                    GenJnlLine.SetRange("AQD Cust Rebate Register No.", RebateRegister."AQD Entry No.");
                    if not GenJnlLine.FindFirst then begin
                        Clear(GenJnlLine);
                        GenJnlLine.Init;
                        GenJnlLine."Journal Template Name" := JnlTemplateName;
                        GenJnlLine."Journal Batch Name" := JnlBatchName;
                        SetUpNewLine();
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."AQD Cust Rebate Journal" := true;
                        GenJnlLine.Insert(true);
                        NextLineNo += 10000;

                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
                        //GenJnlLine.VALIDATE("Document No.",''); // It must be using No. series from Journal Batch.
                        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Vendor);
                        GenJnlLine."External Document No." := GenJnlLine."Document No.";
                        GenJnlLine.Validate("Account No.", Vendor."No.");
                        GenJnlLine.Description := CopyStr(RebateText + ' ' +
                          PeriodTextConst + ' : ' +
                          Format(RebateRegister."AQD Start Date") + '..' +
                          Format(RebateRegister."AQD End Date"),
                          1, MaxStrLen(GenJnlLine.Description));
                        GenJnlLine."AQD Cust Rebate Type" := RebateRegister."AQD Rebate Type";
                        GenJnlLine."AQD Cust Rebate Code" := RebateRegister."AQD Rebate Code";
                        if RebateRegister."AQD Shortcut Dimension 1 Code" <> '' then
                            GenJnlLine.Validate("Shortcut Dimension 1 Code", RebateRegister."AQD Shortcut Dimension 1 Code");
                        if RebateRegister."AQD Shortcut Dimension 2 Code" <> '' then
                            GenJnlLine.Validate("Shortcut Dimension 2 Code", RebateRegister."AQD Shortcut Dimension 2 Code");
                        GenJnlLine."AQD CustRbt Location Code" := RebateRegister."AQD Location Code";
                        GenJnlLine."AQD CustRbt State" := RebateRegister."AQD State";
                        GenJnlLine."AQD Cust Rebate Document Type" := RebateRegister."AQD Document Type";
                        GenJnlLine."AQD Cust Rebate Document No." := RebateRegister."AQDDocument No.";

                        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                        GenJnlLine.Validate("Bal. Account No.", RebateSetup."Rebate Expense Account");
                        GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                        GenJnlLine."AQD Cust Rebate Register No." := RebateRegister."AQD Entry No.";
                        LastGenJnlLine := GenJnlLine;
                    end;

                    RebateDocEntry.CalcFields("Rebate Amount", "Base Amount", "Profit Amount");
                    GenJnlLine.Validate(Amount, (Abs(GenJnlLine.Amount) + RebateDocEntry."Rebate Amount") * -1);
                    GenJnlLine.Validate("AQD CustRbt Base Amount", GenJnlLine."AQD CustRbt Base Amount" + RebateDocEntry."Base Amount");
                    GenJnlLine.Validate("AQD CustRbt Profit Amount", GenJnlLine."AQD CustRbt Profit Amount" + RebateDocEntry."Profit Amount");
                    GenJnlLine.Modify(true);

                    RebateDocEntry."Journal Template Name" := GenJnlLine."Journal Template Name";
                    RebateDocEntry."Journal Batch Name" := GenJnlLine."Journal Batch Name";
                    RebateDocEntry."Journal Line No." := GenJnlLine."Line No.";
                    RebateDocEntry."Journal Document No." := GenJnlLine."Document No.";
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Journal;
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry."Journal Template Name" := RebateDocEntry."Journal Template Name";
                            RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                            RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                            RebateEntry."Journal Document No." := RebateDocEntry."Journal Document No.";
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                until RebateDocEntry.Next = 0;
            end;

            RebateRegister."AQD Batch Name" := GenJnlLine."Journal Batch Name";
            RebateRegister.Modify;
            LastGenJnlLine := GenJnlLine;
        until RebateRegister.Next = 0;

        GenJnlLine.Reset;
        if GenJnlLine.FindFirst then;

        if GuiAllowed then
            Window.Close;
        Message(PurchaseJnlPostSuccessfulMsg);
    end;


    procedure CreateRebateSalesJnlFromRegister(var GenJournalLineIn: Record "Gen. Journal Line")
    var
        RebateDocEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
        CommJnlIsPosted: Label 'Rebate Sales Journal is posted.';
        DoNotPayRebateError: Label 'Purchase Journal cannot be posted because %1 %2 has "Do Not Pay Rebate" = True.\\Identification Fields: "Journal Template Name": %3, "Journal Batch Name": %4, "Line No." = %5.';
        RebateRegisterPage: Page "AQD Customer Rebate Register";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        NextRegNo: Integer;
    begin
        if not ConfirmManagement.GetResponseOrDefault(SalesUserConfirmMsg, true) then
            exit;

        RebateRegister.Reset;
        RebateRegister.FilterGroup(2);
        RebateRegister.SetRange("AQD Status", RebateRegister."AQD Status"::Approved);
        //RebateRegister.SETRANGE("Rebate Type",RebateRegister."Rebate Type"::Customer);
        RebateRegister.SetRange("AQD Payee Type", RebateRegister."AQD Payee Type"::" "); // Blank will be for Customer
        RebateRegister.FilterGroup(0);
        Clear(RebateRegisterPage);
        RebateRegisterPage.Editable(false);
        RebateRegisterPage.LookupMode(true);
        RebateRegisterPage.SetTableView(RebateRegister);
        if RebateRegisterPage.RunModal = ACTION::LookupOK then
            RebateRegisterPage.GetSelectionFilters(RebateRegister)
        else
            exit;

        if not RebateRegister.FindFirst then
            Error(NothingToCreatePurchJnl);

        RebateSetup.Get;

        JnlTemplateName := GenJournalLineIn."Journal Template Name";
        JnlBatchName := GenJournalLineIn."Journal Batch Name";

        GenJnlLine.LockTable;
        GenJnlTemplate.Get(JnlTemplateName);
        GenJnlBatch.Get(JnlTemplateName, JnlBatchName);

        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        if GuiAllowed then begin
            Window.Open(Text001);
            Window.Update(1, RebateRegister."AQD Entry No.");
        end;

        NoOfRecords := RebateRegister.Count;

        //1099 Vendor
        RebateSetup.TestField("Rebate Expense Account");
        GenJnlBatch.TestField("No. Series");
        repeat
            if GuiAllowed then
                LineCount := LineCount + 1;

            GenJnlLine.Reset;
            GenJnlLine.SetRange("AQD Cust Rebate Register No.", RebateRegister."AQD Entry No.");
            GenJnlLine.DeleteAll;

            RebateDocEntry.Reset;
            RebateDocEntry.SetCurrentKey("Rebate Register No.");
            RebateDocEntry.SetRange("Rebate Register No.", RebateRegister."AQD Entry No.");
            RebateDocEntry.SetRange("Vendor Ledger Entry No.", 0);
            RebateDocEntry.SetRange(Open, true);
            RebateDocEntry.SetRange(Payable, false);
            RebateDocEntry.SetRange("Rebate Approved", true);
            if RebateDocEntry.FindFirst then begin
                repeat
                    Customer.Get(RebateDocEntry."Rebate Code");
                    Customer.TestField("AQD Enroll for Rebate", true);

                    GenJnlLine.Reset;
                    GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
                    GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                    GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Customer);
                    GenJnlLine.SetRange("Account No.", Customer."No.");
                    GenJnlLine.SetRange("AQD Cust Rebate Register No.", RebateRegister."AQD Entry No.");
                    if not GenJnlLine.FindFirst then begin
                        Clear(GenJnlLine);
                        GenJnlLine.Init;
                        GenJnlLine."Journal Template Name" := JnlTemplateName;
                        GenJnlLine."Journal Batch Name" := JnlBatchName;
                        SetUpNewLine();
                        GenJnlLine."Line No." := NextLineNo;
                        GenJnlLine."AQD Cust Rebate Journal" := true;
                        GenJnlLine.Insert(true);
                        NextLineNo += 10000;

                        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                        //GenJnlLine.VALIDATE("Document No.",''); // It must be using No. series from Journal Batch.
                        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
                        GenJnlLine."External Document No." := GenJnlLine."Document No.";
                        GenJnlLine.Validate("Account No.", Customer."No.");
                        GenJnlLine.Description := CopyStr(RebateText + ' ' +
                          PeriodTextConst + ' : ' +
                          Format(RebateRegister."AQD Start Date") + '..' +
                          Format(RebateRegister."AQD End Date"),
                          1, MaxStrLen(GenJnlLine.Description));
                        GenJnlLine."AQD Cust Rebate Type" := RebateRegister."AQD Rebate Type";
                        GenJnlLine."AQD Cust Rebate Code" := RebateRegister."AQD Rebate Code";
                        if RebateRegister."AQD Shortcut Dimension 1 Code" <> '' then
                            GenJnlLine.Validate("Shortcut Dimension 1 Code", RebateRegister."AQD Shortcut Dimension 1 Code");
                        if RebateRegister."AQD Shortcut Dimension 2 Code" <> '' then
                            GenJnlLine.Validate("Shortcut Dimension 2 Code", RebateRegister."AQD Shortcut Dimension 2 Code");
                        GenJnlLine."AQD CustRbt Location Code" := RebateRegister."AQD Location Code";
                        GenJnlLine."AQD CustRbt State" := RebateRegister."AQD State";
                        GenJnlLine."AQD Cust Rebate Document Type" := RebateRegister."AQD Document Type";
                        GenJnlLine."AQD Cust Rebate Document No." := RebateRegister."AQDDocument No.";

                        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                        GenJnlLine.Validate("Bal. Account No.", RebateSetup."Rebate Expense Account");
                        GenJnlLine."AQD Cust Journal Document No." := GenJnlLine."Document No.";
                        GenJnlLine."AQD Cust Rebate Register No." := RebateRegister."AQD Entry No.";
                        LastGenJnlLine := GenJnlLine;
                    end;

                    RebateDocEntry.CalcFields("Rebate Amount", "Base Amount", "Profit Amount");
                    GenJnlLine.Validate(Amount, (Abs(GenJnlLine.Amount) + RebateDocEntry."Rebate Amount") * -1);
                    GenJnlLine.Validate("AQD CustRbt Base Amount", GenJnlLine."AQD CustRbt Base Amount" + RebateDocEntry."Base Amount");
                    GenJnlLine.Validate("AQD CustRbt Profit Amount", GenJnlLine."AQD CustRbt Profit Amount" + RebateDocEntry."Profit Amount");
                    GenJnlLine.Modify(true);

                    RebateDocEntry."Journal Template Name" := GenJnlLine."Journal Template Name";
                    RebateDocEntry."Journal Batch Name" := GenJnlLine."Journal Batch Name";
                    RebateDocEntry."Journal Line No." := GenJnlLine."Line No.";
                    RebateDocEntry."Journal Document No." := GenJnlLine."Document No.";
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Journal;
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry."Journal Template Name" := RebateDocEntry."Journal Template Name";
                            RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                            RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                            RebateEntry."Journal Document No." := RebateDocEntry."Journal Document No.";
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                until RebateDocEntry.Next = 0;
            end;

            RebateRegister."AQD Batch Name" := GenJnlLine."Journal Batch Name";
            RebateRegister.Modify;
            LastGenJnlLine := GenJnlLine;
        until RebateRegister.Next = 0;

        GenJnlLine.Reset;
        if GenJnlLine.FindFirst then;

        if GuiAllowed then
            Window.Close;
        Message(SalesJnlPostSuccessfulMsg);
    end;

    procedure SetUpNewLine()
    var
        NoSeriesMgt: Codeunit "No. Series";
    begin
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document Date" := Today;
        if GenJnlBatch."No. Series" <> '' then begin
            GenJnlLine."Document No." := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", GenJnlLine."Posting Date", true);
            Clear(NoSeriesMgt);
        end;

        if GenJnlTemplate.Type = GenJnlTemplate.Type::Payments then begin
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        end;
        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
        GenJnlLine."Bal. Account Type" := GenJnlBatch."Bal. Account Type";
        if (GenJnlLine."Account Type" in
             [GenJnlLine."Account Type"::Customer,
              GenJnlLine."Account Type"::Vendor,
              GenJnlLine."Account Type"::"Fixed Asset"]) and
           (GenJnlLine."Bal. Account Type" in
             [GenJnlLine."Bal. Account Type"::Customer,
              GenJnlLine."Bal. Account Type"::Vendor,
              GenJnlLine."Bal. Account Type"::"Fixed Asset"])
        then
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", GenJnlBatch."Bal. Account No.");

        GenJnlLine.Description := '';

        GenJnlLine.UpdateJournalBatchID;
    end;


    procedure VoidRebateRegister(var RebateRegister: Record "AQD Customer Rebate Register")
    begin
        if not RebateRegister.FindFirst then
            Error(NothingToVoid);

        RebateRegister.TestField("AQD Entry No.");

        RebateRegister.SetRange("AQD Voided", true);
        if RebateRegister.FindFirst then
            Error(RebateRegisterAlreadyVoided);

        RebateRegister.SetRange("AQD Voided");
        RebateRegister.FindFirst;

        RebateRegister.CalcFields("AQD Status");

        // ,Approved,Journal,Posted,Paid
        case RebateRegister."AQD Payee Type" of
            RebateRegister."AQD Payee Type"::" ",
            RebateRegister."AQD Payee Type"::"1099 Vendor":
                begin
                    if RebateRegister."AQD Status" > RebateRegister."AQD Status"::Journal then
                        Error(RebateRegisterAlreadyPosted, RebateRegister."AQD Status");
                end;
            RebateRegister."AQD Payee Type"::"W2 Employee":
                begin
                    if RebateRegister."AQD Status" = RebateRegister."AQD Status"::Paid then
                        Error(RebateRegisterAlreadyPaid);
                end;
        end;

        if GuiAllowed then begin
            if not Confirm(VoidUserConfirmMsg) then
                exit;
        end;

        repeat
            if (RebateRegister."AQD Payee Type" = RebateRegister."AQD Payee Type"::" ") or
              (RebateRegister."AQD Payee Type" = RebateRegister."AQD Payee Type"::"1099 Vendor")
            then begin
                GenJnlLine.Reset;
                GenJnlLine.SetRange("AQD Cust Rebate Register No.", RebateRegister."AQD Entry No.");
                GenJnlLine.DeleteAll;
            end;

            RebateRegister."AQD Voided" := true;
            RebateRegister."AQD Voided By User ID" := UserId;
            RebateRegister."AQD Voided DateTime" := CurrentDateTime;
            RebateRegister."AQD Batch Name" := '';
            RebateRegister.Modify;

            RebateDocEntry.Reset;
            RebateDocEntry.SetCurrentKey("Rebate Register No.");
            RebateDocEntry.SetRange("Rebate Register No.", RebateRegister."AQD Entry No.");
            if RebateDocEntry.FindFirst then begin
                repeat
                    RebateDocEntry.TestField("Vendor Ledger Entry No.", 0);

                    RebateDocEntry."Journal Template Name" := '';
                    RebateDocEntry."Journal Batch Name" := '';
                    RebateDocEntry."Journal Line No." := 0;
                    RebateDocEntry."Journal Document No." := '';
                    RebateDocEntry."Rebate Register No." := 0;
                    RebateDocEntry."Rebate Approved" := false;
                    RebateDocEntry."Rebate Approved By" := '';
                    RebateDocEntry."Rebate Approved Date" := 0D;
                    RebateDocEntry.Payable := false;
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::" ";
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry."Journal Template Name" := RebateDocEntry."Journal Template Name";
                            RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                            RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                            RebateEntry."Journal Document No." := RebateDocEntry."Journal Document No.";
                            RebateEntry."Rebate Register No." := RebateDocEntry."Rebate Register No.";
                            RebateEntry.Payable := false;
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                until RebateDocEntry.Next = 0;
            end;
        until RebateRegister.Next = 0;

        Message(VoidSuccessfulMsg);
    end;


    procedure UpdateW2EmployeeRebatePaid(var RebateRegisterIn: Record "AQD Customer Rebate Register")
    var
        NothingToPost: Label 'There is nothing to post.';
        RebateRegisterIsPaid: Label 'Payment Information is updated for Rebate Register.';
        UserConfirmMsg: Label 'Do you want to update Payment Information on Rebate Register ?';
        ConfirmManagement: Codeunit "Confirm Management";
        CustRebateChangeToPaid: Page "AQD Cust Rebate Change To Paid";
        RebateLdgrEntryNextEntryNo: Integer;
        ActualPaidDate: Date;
        "Count": Integer;
    begin
        if not RebateRegisterIn.FindFirst then
            Error(NothingToUpdateError);

        RebateRegisterIn.SetFilter("AQD Payee Type", '%1|%2',
          RebateRegisterIn."AQD Payee Type"::" ",
          RebateRegisterIn."AQD Payee Type"::"1099 Vendor");
        if RebateRegisterIn.FindFirst then
            Error(Vendor1099NotUpdateError);

        RebateRegisterIn.SetRange("AQD Payee Type");
        RebateRegisterIn.SetRange("AQD Voided", true);
        if RebateRegisterIn.FindFirst then
            Error(PmtInfocannotUpdateOnVoidedError);

        RebateRegisterIn.SetRange("AQD Voided");
        RebateRegisterIn.SetRange("AQD Payee Type", RebateRegisterIn."AQD Payee Type"::"W2 Employee");

        if GuiAllowed then begin
            if not Confirm(UserConfirmMsg) then
                exit;
        end;

        if RebateRegisterIn.FindFirst then begin
            repeat
                RebateRegisterIn.CalcFields("AQD Status");
                RebateRegisterIn.TestField("AQD Status", RebateRegisterIn."AQD Status"::Posted);
            until RebateRegisterIn.Next = 0;
        end;

        Clear(CustRebateChangeToPaid);
        if CustRebateChangeToPaid.RunModal = ACTION::Yes then
            CustRebateChangeToPaid.GetCheckInformation(PaymentDate, PaymentCheckNo)
        else
            exit;

        if RebateRegisterIn.FindFirst then begin
            repeat
                RebateRegisterIn.CalcFields("AQD Status");

                RebateRegisterIn.TestField("AQD Entry No.");
                RebateRegisterIn.TestField("AQD Status", RebateRegisterIn."AQD Status"::Posted);

                RebateRegisterIn."AQD Payment Date" := PaymentDate;
                RebateRegisterIn."AQD Payment Ref. No." := PaymentCheckNo;
                RebateRegisterIn.Modify;

                RebateDocEntry.Reset;
                RebateDocEntry.SetCurrentKey("Rebate Register No.");
                RebateDocEntry.SetRange("Rebate Register No.", RebateRegisterIn."AQD Entry No.");
                if RebateDocEntry.FindFirst then begin
                    repeat
                        RebateDocEntry.Open := false;
                        RebateDocEntry."Rebate Paid" := true;
                        RebateDocEntry."Rebate Paid Date" := PaymentDate;
                        RebateDocEntry."Rebate Paid By" := UserId;
                        RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Paid;
                        RebateDocEntry.Modify;

                        RebateEntry.Reset;
                        RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                        RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                        RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                        RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                        RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                        if RebateEntry.FindFirst then begin
                            repeat
                                RebateEntry."Remaining Rebate Amount" := 0;
                                RebateEntry.Open := false;
                                RebateEntry.Modify;
                            until RebateEntry.Next = 0;
                        end;
                    until RebateDocEntry.Next = 0;
                end;
            until RebateRegisterIn.Next = 0;
        end;
    end;

    procedure ShowRebateDocumentEntries(RebateRegister: Record "AQD Customer Rebate Register")
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateDocumentEntryPage: Page "AQD Cust Rebate Doc Entries";
    begin
        RebateRegister.TestField("AQD Entry No.");

        RebateDocumentEntry.Reset;
        RebateDocumentEntry.FilterGroup(2);
        RebateDocumentEntry.SetCurrentKey("Rebate Register No.");
        RebateDocumentEntry.SetRange("Rebate Register No.", RebateRegister."AQD Entry No.");
        RebateDocumentEntry.FilterGroup(0);
        if RebateDocumentEntry.FindFirst then;

        Clear(RebateDocumentEntryPage);
        RebateDocumentEntryPage.Editable(false);
        RebateDocumentEntryPage.SetTableView(RebateDocumentEntry);
        RebateDocumentEntryPage.RunModal;
    end;

    procedure ShowRebateEntries(RebateRegister: Record "AQD Customer Rebate Register")
    var
        RebateEntry: Record "AQD Customer Rebate Entry";
        RebateEntriesPage: Page "AQD Customer Rebate Entries";
    begin
        RebateRegister.TestField("AQD Entry No.");

        RebateEntry.Reset;
        RebateEntry.FilterGroup(2);
        RebateEntry.SetCurrentKey("Rebate Register No.");
        RebateEntry.SetRange("Rebate Register No.", RebateRegister."AQD Entry No.");
        RebateEntry.FilterGroup(0);
        if RebateEntry.FindFirst then;

        Clear(RebateEntriesPage);
        RebateEntriesPage.Editable(false);
        RebateEntriesPage.SetTableView(RebateEntry);
        RebateEntriesPage.RunModal;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterVendLedgEntryInsert', '', false, false)]
    local procedure Cod12_GenJnlPostLine_OnAfterVendLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
    begin
        if not GenJournalLine."AQD Cust Rebate Journal" then
            exit;

        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then begin
            GenJournalLine.TestField("AQD Cust Rebate Register No.");

            RebateDocEntry.Reset;
            RebateDocEntry.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Journal Line No.");
            RebateDocEntry.SetRange("Rebate Register No.", GenJournalLine."AQD Cust Rebate Register No.");
            RebateDocEntry.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            RebateDocEntry.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            RebateDocEntry.SetRange("Journal Line No.", GenJournalLine."Line No.");
            RebateDocEntry.SetRange("Journal Document No.", GenJournalLine."AQD Cust Journal Document No.");
            //RebateDocEntry.SETRANGE("Rebate Type",GenJournalLine."AEC Rebate Type");
            //RebateDocEntry.SETRANGE("Rebate Code",GenJournalLine."AEC Rebate Code");
            if RebateDocEntry.FindFirst then begin
                repeat
                    if RebateDocEntry."Do Not Pay Rebate" then
                        Error(DoNotPayRebateError,
                          Format(RebateDocEntry."Document Type"),
                          RebateDocEntry."Document No.",
                          RebateDocEntry."Journal Template Name",
                          RebateDocEntry."Journal Batch Name",
                          RebateDocEntry."Journal Line No.");

                    RebateDocEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
                    RebateDocEntry.Payable := true;
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Posted;
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    RebateEntry.SetRange("Journal Document No.", RebateDocEntry."Journal Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry.Payable := true;
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                until RebateDocEntry.Next = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVendLedgEntry', '', false, false)]
    local procedure Cod12_GenJnlPostLine_OnAfterInitVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        InvoiceVendorLedgerEntry: Record "Vendor Ledger Entry";
        RebateRegisterFound: Boolean;
    begin
        if not GenJournalLine."AQD Cust Rebate Journal" then
            exit;

        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Payment then begin
            if (GenJournalLine."Applies-to Doc. No." = '') and (GenJournalLine."Applies-to ID" = '') then
                exit;

            InvoiceVendorLedgerEntry.Reset;
            if GenJournalLine."Applies-to Doc. No." <> '' then begin
                //IF NOT PurchInvHeader.GET(GenJournalLine."Applies-to Doc. No.") THEN
                //  EXIT;
                InvoiceVendorLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open, Positive);
                InvoiceVendorLedgerEntry.SetRange("Vendor No.", VendorLedgerEntry."Vendor No.");
                InvoiceVendorLedgerEntry.SetRange("Document Type", InvoiceVendorLedgerEntry."Document Type"::Invoice);
                InvoiceVendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            end else begin
                InvoiceVendorLedgerEntry.SetCurrentKey("Vendor No.", Open, Positive);
                InvoiceVendorLedgerEntry.SetRange("Vendor No.", VendorLedgerEntry."Vendor No.");
                InvoiceVendorLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            end;
            InvoiceVendorLedgerEntry.SetRange(Open, true);
            if not InvoiceVendorLedgerEntry.FindFirst then
                exit;

            repeat
                RebateRegisterFound := false;
                if RebateRegister.Get(InvoiceVendorLedgerEntry."AQD Cust Rebate Register No.") then begin
                    RebateRegister."AQD Payment Ref. No." := GenJournalLine."Document No.";
                    RebateRegister."AQD Payment Date" := GenJournalLine."Posting Date";
                    RebateRegister.Modify;
                    RebateRegisterFound := true;
                end;

                RebateDocEntry.Reset;
                if RebateRegisterFound then begin
                    RebateDocEntry.SetCurrentKey("Rebate Register No.");
                    RebateDocEntry.SetRange("Rebate Register No.", InvoiceVendorLedgerEntry."AQD Cust Rebate Register No.");
                    RebateDocEntry.SetRange("Vendor Ledger Entry No.", InvoiceVendorLedgerEntry."Entry No.");
                end else begin
                    RebateDocEntry.SetCurrentKey("Vendor Ledger Entry No.");
                    RebateDocEntry.SetRange("Vendor Ledger Entry No.", InvoiceVendorLedgerEntry."Entry No.");
                end;
                if RebateDocEntry.FindFirst then begin
                    repeat
                        RebateDocEntry.TestField("Vendor Ledger Entry No.");
                        RebateDocEntry."Rebate Paid" := true;
                        RebateDocEntry."Rebate Paid Date" := GenJournalLine."Posting Date";
                        RebateDocEntry."Rebate Paid By" := UserId;
                        RebateDocEntry."Payment V. Ledg. Entry No." := VendorLedgerEntry."Entry No.";
                        RebateDocEntry.Open := false;
                        RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Paid;
                        RebateDocEntry.Modify;

                        RebateEntry.Reset;
                        RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                        RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                        RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                        RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                        RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                        if RebateEntry.FindFirst then begin
                            repeat
                                RebateEntry."Remaining Rebate Amount" := 0;
                                RebateEntry.Open := false;
                                RebateEntry.Modify;
                            until RebateEntry.Next = 0;
                        end;
                    until RebateDocEntry.Next = 0;
                end;
            until InvoiceVendorLedgerEntry.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCustLedgEntryInsert', '', false, false)]
    local procedure Cod12_GenJnlPostLine_OnAfterCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        RebateDocumentEntry: Record "AQD Cust Rebate Document Entry";
        RebateEntry: Record "AQD Customer Rebate Entry";
    begin
        if not GenJournalLine."AQD Cust Rebate Journal" then
            exit;

        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::"Credit Memo" then begin
            GenJournalLine.TestField("AQD Cust Rebate Register No.");

            if RebateRegister.Get(CustLedgerEntry."AQD Rebate Register No.") then begin
                RebateRegister."AQD Payment Ref. No." := GenJournalLine."Document No.";
                RebateRegister."AQD Payment Date" := GenJournalLine."Posting Date";
                RebateRegister.Modify;
            end;

            RebateDocEntry.Reset;
            RebateDocEntry.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Journal Line No.");
            RebateDocEntry.SetRange("Rebate Register No.", GenJournalLine."AQD Cust Rebate Register No.");
            RebateDocEntry.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            RebateDocEntry.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            RebateDocEntry.SetRange("Journal Line No.", GenJournalLine."Line No.");
            RebateDocEntry.SetRange("Journal Document No.", GenJournalLine."AQD Cust Journal Document No.");
            if RebateDocEntry.FindFirst then begin
                repeat
                    if RebateDocEntry."Do Not Pay Rebate" then
                        Error(DoNotPayRebateError,
                          Format(RebateDocEntry."Document Type"),
                          RebateDocEntry."Document No.",
                          RebateDocEntry."Journal Template Name",
                          RebateDocEntry."Journal Batch Name",
                          RebateDocEntry."Journal Line No.");

                    //RebateDocEntry."Vendor Ledger Entry No." := CustLedgerEntry."Entry No.";
                    RebateDocEntry.Payable := true;
                    RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Paid; // Credit Memo shows paid
                    RebateDocEntry.Modify;

                    RebateEntry.Reset;
                    RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                    RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                    RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                    RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                    RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                    RebateEntry.SetRange("Journal Document No.", RebateDocEntry."Journal Document No.");
                    if RebateEntry.FindFirst then begin
                        repeat
                            RebateEntry.Payable := true;
                            RebateEntry.Modify;
                        until RebateEntry.Next = 0;
                    end;
                until RebateDocEntry.Next = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure Tab21_CustLedgerEntry_OnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."AQD Rebate Journal" := GenJournalLine."AQD Cust Rebate Journal";
        CustLedgerEntry."AQD Rebate Type" := GenJournalLine."AQD Cust Rebate Type";
        CustLedgerEntry."AQD Rebate Code" := GenJournalLine."AQD Cust Rebate Code";
        CustLedgerEntry."AQD Location Code" := GenJournalLine."AQD CustRbt Location Code";
        CustLedgerEntry."AQD State" := GenJournalLine."AQD CustRbt State";
        CustLedgerEntry."AQD Rebate Document Type" := GenJournalLine."AQD Cust Rebate Document Type";
        CustLedgerEntry."AQD Rebate Document No." := GenJournalLine."AQD Cust Rebate Document No.";
        CustLedgerEntry."AQD Journal Document No." := GenJournalLine."AQD Cust Journal Document No.";
        CustLedgerEntry."AQD Rebate Register No." := GenJournalLine."AQD Cust Rebate Register No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure Tab25_VendorLedgerEntry_OnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."AQD Cust Rebate Journal" := GenJournalLine."AQD Cust Rebate Journal";
        VendorLedgerEntry."AQD Customer Rebate Type" := GenJournalLine."AQD Cust Rebate Type";
        VendorLedgerEntry."AQD CustRbt Location Code" := GenJournalLine."AQD CustRbt Location Code";
        VendorLedgerEntry."AQD CustRbt State" := GenJournalLine."AQD CustRbt State";
        VendorLedgerEntry."AQD Cust Rebate Document Type" := GenJournalLine."AQD Cust Rebate Document Type";
        VendorLedgerEntry."AQD Cust Rebate Document No." := GenJournalLine."AQD Cust Rebate Document No.";
        VendorLedgerEntry."AQD Cust Journal Document No." := GenJournalLine."AQD Cust Journal Document No.";
        VendorLedgerEntry."AQD Cust Rebate Register No." := GenJournalLine."AQD Cust Rebate Register No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Tab81_GenJnlLine_OnAfterDelete(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        if not Rec."AQD Cust Rebate Journal" then
            exit;

        if (Rec."Document Type" <> Rec."Document Type"::Invoice) and
          (Rec."Document Type" <> Rec."Document Type"::"Credit Memo")
        then
            exit;

        RebateDocEntry.Reset;
        RebateDocEntry.SetCurrentKey("Rebate Register No.");
        RebateDocEntry.SetRange("Rebate Register No.", Rec."AQD Cust Rebate Register No.");
        RebateDocEntry.SetRange("Journal Template Name", Rec."Journal Template Name");
        RebateDocEntry.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        RebateDocEntry.SetRange("Journal Line No.", Rec."Line No.");
        RebateDocEntry.SetRange("Journal Document No.", Rec."AQD Cust Journal Document No.");
        if RebateDocEntry.FindFirst then begin
            repeat
                RebateDocEntry.TestField(Open, true);
                if RebateDocEntry."Rebate Type" = RebateDocEntry."Rebate Type"::Vendor then
                    RebateDocEntry.TestField("Vendor Ledger Entry No.", 0)
                else
                    if RebateDocEntry."Rebate Type" = RebateDocEntry."Rebate Type"::Customer then
                        RebateDocEntry.TestField("Credit C. Ledg. Entry No.", 0);
                RebateDocEntry.TestField("Payment Status", RebateDocEntry."Payment Status"::Journal);

                RebateDocEntry."Journal Template Name" := '';
                RebateDocEntry."Journal Batch Name" := '';
                RebateDocEntry."Journal Line No." := 0;
                RebateDocEntry."Journal Document No." := '';
                RebateDocEntry."Payment Status" := RebateDocEntry."Payment Status"::Approved;
                RebateDocEntry.Modify;

                RebateEntry.Reset;
                RebateEntry.SetCurrentKey("Rebate Register No.", "Rebate Type", "Rebate Code", "Document Type", "Document No.");
                RebateEntry.SetRange("Rebate Register No.", Rec."AQD Cust Rebate Register No.");
                RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                if RebateEntry.FindFirst then begin
                    repeat
                        RebateEntry.TestField(Open, true);
                        RebateEntry.TestField(Payable, false);
                        RebateEntry."Journal Template Name" := RebateDocEntry."Journal Template Name";
                        RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                        RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                        RebateEntry."Journal Document No." := RebateDocEntry."Journal Document No.";
                        RebateEntry.Modify;
                    until RebateEntry.Next = 0;
                end;
            until RebateDocEntry.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Cust Rebate Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure Tab70906_RebateJnlLine_OnAfterDelete(var Rec: Record "AQD Cust Rebate Journal Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        if Rec."AQD Run For" = Rec."AQD Run For"::Review then
            exit;

        RebateDocEntry.Reset;
        RebateDocEntry.SetCurrentKey("Rebate Code", "Document Type", "Document No.", "Rebate Type");
        RebateDocEntry.SetRange("Rebate Type", Rec."AQD Pay-To Rebate Type");
        RebateDocEntry.SetRange("Rebate Code", Rec."AQD Rebate Code");
        RebateDocEntry.SetRange("Document Type", Rec."AQD Document Type");
        RebateDocEntry.SetRange("Document No.", Rec."AQD Document No.");
        if RebateDocEntry.FindFirst then begin
            repeat
                if RebateDocEntry."Rebate Type" = RebateDocEntry."Rebate Type"::Vendor then
                    RebateDocEntry.TestField("Vendor Ledger Entry No.", 0)
                else
                    if RebateDocEntry."Rebate Type" = RebateDocEntry."Rebate Type"::Customer then
                        RebateDocEntry.TestField("Credit C. Ledg. Entry No.", 0);
                RebateDocEntry.TestField(Open, true);
                RebateDocEntry.TestField(Payable, false);
                RebateDocEntry.TestField("Rebate Approved", false);
                RebateDocEntry.TestField("Payment Status", RebateDocEntry."Payment Status"::" ");
                RebateDocEntry."Journal Template Name" := '';
                RebateDocEntry."Journal Batch Name" := '';
                RebateDocEntry."Journal Line No." := 0;
                RebateDocEntry.Modify;

                RebateEntry.Reset;
                RebateEntry.SetCurrentKey("Rebate Type", "Rebate Code", "Document Type", "Document No.");
                RebateEntry.SetRange("Rebate Type", RebateDocEntry."Rebate Type");
                RebateEntry.SetRange("Rebate Code", RebateDocEntry."Rebate Code");
                RebateEntry.SetRange("Document Type", RebateDocEntry."Document Type");
                RebateEntry.SetRange("Document No.", RebateDocEntry."Document No.");
                if RebateEntry.FindFirst then begin
                    repeat
                        RebateEntry."Journal Template Name" := RebateDocEntry."Journal Template Name";
                        RebateEntry."Journal Batch Name" := RebateDocEntry."Journal Batch Name";
                        RebateEntry."Journal Line No." := RebateDocEntry."Journal Line No.";
                        RebateEntry.Modify;
                    until RebateEntry.Next = 0;
                end;
            until RebateDocEntry.Next = 0;
        end;
    end;
}

