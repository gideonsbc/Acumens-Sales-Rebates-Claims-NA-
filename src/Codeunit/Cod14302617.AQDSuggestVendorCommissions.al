codeunit 14302617 "AQD Suggest Vendor Commissions"
{
    Permissions = TableData "Gen. Journal Template" = RM, tabledata "Vendor Ledger Entry" = RM;


    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
        Window: Dialog;
        BalancingDocumentNo: Code[20];
        IsSummarizeByProgramCode: Boolean;
        DefaultPostingDate: Date;
        GenJnlLine: Record "Gen. Journal Line";
        TotalAmount: Decimal;
        EndingDate: Date;
        StartingDate: Date;
        JnlBatchName: Code[10];
        JnlTemplateName: Code[10];
        FormartedDescription: Text[100];

    procedure SetDefaultValues(DocumentNo: Code[20]; PostingDate: Date; SummarizeByProgramCode: Boolean; FromDate: Date; ToDate: Date; CommissionPaymentJnlTemp: Code[10]; CommissionPaymentJnlBatch: Code[10])
    begin
        BalancingDocumentNo := DocumentNo;
        DefaultPostingDate := PostingDate;
        IsSummarizeByProgramCode := SummarizeByProgramCode;
        StartingDate := FromDate;
        EndingDate := ToDate;
        JnlTemplateName := CommissionPaymentJnlTemp;
        JnlBatchName := CommissionPaymentJnlBatch;
    end;

    procedure SuggestVendorCommissionInvoices(var ProgrameCodesRec: Record "AQD Cust Rebate Program Code"; var VendLedgEntry: Record "Vendor Ledger Entry")
    begin

        if VendLedgEntry.GetFilter("Vendor No.") <> '' then
            ProgrameCodesRec.SetRange("Payee No.", VendLedgEntry.GetFilter("Vendor No."));

        if IsSummarizeByProgramCode then begin
            SummarizebyProgramCode(ProgrameCodesRec, VendLedgEntry);
        end else begin
            SummarizebyVendor(ProgrameCodesRec, VendLedgEntry);
        end;
    end;

    local procedure SummarizebyVendor(var ProgrameCodesRec: Record "AQD Cust Rebate Program Code"; var VendLedgEntry: Record "Vendor Ledger Entry")
    var
        TempVendorBuffer: Record "Item Vendor" temporary;
        // TempVendorBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        TempProgrameCodesRec: Record "AQD Cust Rebate Program Code" temporary;
        TotalVendors: Integer;
    begin
        TotalVendors := 0;
        if TempVendorBuffer.IsTemporary then
            TempVendorBuffer.DeleteAll();

        if TempProgrameCodesRec.IsTemporary then
            TempProgrameCodesRec.DeleteAll();

        Window.Open('Processing... @1@@@@@@@@@@@@@@@');

        //Collect vendors to process based on the program codes
        ProgrameCodesRec.SetCurrentKey(Code);
        if ProgrameCodesRec.FindFirst() then
            repeat
                //write a record to temp table for each program code to get distinct list of vendors to process in the next step
                TempVendorBuffer.Reset();
                TempVendorBuffer.SetRange("Vendor No.", ProgrameCodesRec."AQD Pay-to Vendor No.");
                if not TempVendorBuffer.FindFirst() then begin
                    TempVendorBuffer.Init();
                    TempVendorBuffer."Vendor No." := ProgrameCodesRec."AQD Pay-to Vendor No.";
                    TempVendorBuffer.Insert();
                end;
            until ProgrameCodesRec.Next() = 0;

        ProgrameCodesRec.SetCurrentKey(Code);
        if ProgrameCodesRec.FindFirst() then
            repeat
                //write a record to temp table for each program code to get distinct list of vendors to process in the next step
                TempProgrameCodesRec.Reset();
                TempProgrameCodesRec.SetRange(Code, ProgrameCodesRec.Code);
                if not TempProgrameCodesRec.FindFirst() then begin
                    TempProgrameCodesRec.Init();
                    TempProgrameCodesRec := ProgrameCodesRec;
                    TempProgrameCodesRec.Insert();
                end;
            until ProgrameCodesRec.Next() = 0;


        TempVendorBuffer.Reset();
        TempVendorBuffer.SetCurrentKey("Vendor No.");
        if TempVendorBuffer.FindFirst() then begin
            repeat
                TotalAmount := 0;// Reset total amount for each program code

                TempProgrameCodesRec.Reset();
                TempProgrameCodesRec.SetCurrentKey(Code);
                TempProgrameCodesRec.SetRange("AQD Pay-to Vendor No.", TempVendorBuffer."Vendor No.");
                if TempProgrameCodesRec.FindFirst() then begin
                    repeat
                        VendLedgEntry.SetRange("Vendor No.", TempProgrameCodesRec."Payee No.");
                        VendLedgEntry.SetRange("AQD CR Rebate Program Code", TempProgrameCodesRec.Code);
                        //  VendLedgEntry.SetRange(Open, true);
                        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
                        if (StartingDate <> 0D) and (EndingDate <> 0D) then
                            VendLedgEntry.SetFilter("Posting Date", '%1..%2', StartingDate, EndingDate)
                        else if (StartingDate = 0D) and (EndingDate <> 0D) then
                            VendLedgEntry.SetFilter("Posting Date", '..%1', EndingDate)
                        else if (StartingDate <> 0D) and (EndingDate = 0D) then
                            VendLedgEntry.SetFilter("Posting Date", '>=%1', StartingDate);
                        SetPayableDueDateFilter(VendLedgEntry);

                        if VendLedgEntry.FindFirst() then begin
                            repeat
                                VendLedgEntry.CalcFields("Remaining Amount", "AQD CR Rebate Approval Status");
                                IF VendLedgEntry."AQD CR Rebate Approval Status" = VendLedgEntry."AQD CR Rebate Approval Status"::Approved then begin

                                    if VendLedgEntry."Remaining Amount" <> 0 then begin
                                        Window.Update(1, VendLedgEntry."Vendor No.");

                                        GenJnlLine.Reset();
                                        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
                                        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                                        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                                        GenJnlLine.SetRange("Account No.", TempProgrameCodesRec."Payee No.");
                                        GenJnlLine.SetRange("AQD CR Pay-to Vendor No.", VendLedgEntry."AQD CR Pay-to Vendor No.");
                                        GenJnlLine.SetRange("AQD CR Rebate Program Code", '');
                                        GenJnlLine.SetRange("AQD Cust Rebate Journal", true);
                                        if GenJnlLine.FindFirst() then begin
                                            GenJnlLine.Validate(Amount, (GenJnlLine.Amount + -VendLedgEntry."Remaining Amount"));
                                            TotalAmount += -VendLedgEntry."Remaining Amount";

                                            VendLedgEntry."Applies-to ID" := GenJnlLine."Document No.";
                                            VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
                                            IF VendLedgEntry.Modify() then;
                                            CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);

                                            GenJnlLine."Applies-to ID" := GenJnlLine."Document No.";
                                            GenJnlLine.Modify();

                                        end else begin
                                            // Create Credit Memo line
                                            GenJnlLine.Init();
                                            GenJnlLine."Journal Template Name" := JnlTemplateName;
                                            GenJnlLine."Journal Batch Name" := JnlBatchName;
                                            GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                                            GenJnlLine.Validate("Posting Date", DefaultPostingDate);
                                            GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
                                            GenJnlLine."Document No." := BalancingDocumentNo;
                                            GenJnlLine."External Document No." := BalancingDocumentNo;
                                            RunIncrementDocumentNo(GenJnlLine);
                                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                                            GenJnlLine.Validate("Account No.", TempProgrameCodesRec."Payee No.");
                                            GenJnlLine."AQD CR Pay-to Vendor No." := VendLedgEntry."AQD CR Pay-to Vendor No.";
                                            GenJnlLine.Validate(Amount, -VendLedgEntry."Remaining Amount");
                                            FormartedDescription := 'Commission ' + Format(EndingDate, 0, '<Month Text>') + ' ' + Format(EndingDate, 0, '<Year4>');
                                            GenJnlLine.Description := FormartedDescription;

                                            GenJnlLine."AQD Cust Rebate Journal" := true;
                                            GenJnlLine."Journal Batch Id" := GenJnlBatch.SystemId;
                                            GenJnlLine.Insert();

                                            TotalAmount += GenJnlLine.Amount;

                                            VendLedgEntry."Applies-to ID" := GenJnlLine."Document No.";
                                            VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
                                            IF VendLedgEntry.Modify() then;
                                            CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);

                                            GenJnlLine."Applies-to ID" := GenJnlLine."Document No.";
                                            GenJnlLine.Modify();
                                        end;
                                    end;
                                end;
                            until VendLedgEntry.Next() = 0;
                        end;
                    until TempProgrameCodesRec.Next() = 0;
                end;

                // Create consolidated invoice for Target Vendor
                if TotalAmount <> 0 then begin
                    GenJnlLine.Init();
                    GenJnlLine."Journal Template Name" := JnlTemplateName;
                    GenJnlLine."Journal Batch Name" := JnlBatchName;
                    GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                    GenJnlLine.Validate("Posting Date", DefaultPostingDate);
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
                    GenJnlLine."Document No." := BalancingDocumentNo;
                    GenJnlLine."External Document No." := BalancingDocumentNo;
                    RunIncrementDocumentNo(GenJnlLine);
                    //  GenJnlLine."External Document No." := TempVendorBuffer."Vendor No.";
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                    GenJnlLine.Validate("Account No.", TempVendorBuffer."Vendor No.");
                    GenJnlLine.Validate(Amount, -TotalAmount);

                    FormartedDescription := 'Commission ' + Format(EndingDate, 0, '<Month Text>') + ' ' + Format(EndingDate, 0, '<Year4>');

                    GenJnlLine.Description := FormartedDescription;
                    GenJnlLine."Journal Batch Id" := GenJnlBatch.SystemId;
                    GenJnlLine.Insert();
                end;

            until TempVendorBuffer.Next() = 0;
        end;

        Window.Close();

    end;

    local procedure SummarizebyProgramCode(var ProgrameCodesRec: Record "AQD Cust Rebate Program Code"; var VendLedgEntry: Record "Vendor Ledger Entry")
    var
        TempVendorBuffer: Record "Item Vendor" temporary;
        TempProgrameCodesRec: Record "AQD Cust Rebate Program Code";
    begin
        if TempVendorBuffer.IsTemporary then
            TempVendorBuffer.DeleteAll();

        TotalAmount := 0;
        GenJnlBatch.Get(JnlTemplateName, JnlBatchName);
        GenJnlTemplate.Get(JnlTemplateName);
        IF GenJnlTemplate."Force Doc. Balance" then begin
            GenJnlTemplate."Force Doc. Balance" := false;
            if GenJnlTemplate.Modify(false) then;
            OnAfterDisableForceDocBalance(GenJnlTemplate);
        end;


        Window.Open('Processing... @1@@@@@@@@@@@@@@@');

        //Collect vendors to process based on the program codes
        ProgrameCodesRec.SetCurrentKey(Code);
        if ProgrameCodesRec.FindFirst() then
            repeat
                //write a record to temp table for each program code to get distinct list of vendors to process in the next step
                TempVendorBuffer.Reset();
                TempVendorBuffer.SetRange("Vendor No.", ProgrameCodesRec."Payee No.");
                TempVendorBuffer.SetRange("Item No.", ProgrameCodesRec."AQD Pay-to Vendor No.");
                TempVendorBuffer.SetRange("Variant Code", ProgrameCodesRec.Code);
                if not TempVendorBuffer.FindFirst() then begin
                    TempVendorBuffer.Init();
                    TempVendorBuffer."Vendor No." := ProgrameCodesRec."Payee No.";
                    TempVendorBuffer."Item No." := ProgrameCodesRec."AQD Pay-to Vendor No.";
                    TempVendorBuffer."Variant Code" := ProgrameCodesRec.Code;
                    TempVendorBuffer.Insert();
                end;
            until ProgrameCodesRec.Next() = 0;


        TempVendorBuffer.Reset();
        TempVendorBuffer.SetCurrentKey("Vendor No.", "Item No.", "Variant Code");
        if TempVendorBuffer.FindFirst() then
            repeat
                TotalAmount := 0;// Reset total amount for each program code

                TempProgrameCodesRec.Get(TempVendorBuffer."Variant Code");

                VendLedgEntry.SetRange("Vendor No.", TempVendorBuffer."Vendor No.");
                VendLedgEntry.SetRange("AQD CR Rebate Program Code", TempVendorBuffer."Variant Code");
                // VendLedgEntry.SetRange(Open, true);
                VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
                if (StartingDate <> 0D) and (EndingDate <> 0D) then
                    VendLedgEntry.SetFilter("Posting Date", '%1..%2', StartingDate, EndingDate)
                else if (StartingDate = 0D) and (EndingDate <> 0D) then
                    VendLedgEntry.SetFilter("Posting Date", '..%1', EndingDate)
                else if (StartingDate <> 0D) and (EndingDate = 0D) then
                    VendLedgEntry.SetFilter("Posting Date", '>=%1', StartingDate);
                SetPayableDueDateFilter(VendLedgEntry);

                if VendLedgEntry.FindFirst() then begin
                    repeat
                        VendLedgEntry.CalcFields("Remaining Amount", "AQD CR Rebate Approval Status");
                        IF VendLedgEntry."AQD CR Rebate Approval Status" = VendLedgEntry."AQD CR Rebate Approval Status"::Approved then begin
                            if VendLedgEntry."Remaining Amount" <> 0 then begin
                                Window.Update(1, VendLedgEntry."Vendor No.");

                                GenJnlLine.Reset();
                                GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
                                GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                                GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                                GenJnlLine.SetRange("Account No.", TempVendorBuffer."Vendor No.");
                                GenJnlLine.SetRange("AQD CR Rebate Program Code", TempVendorBuffer."Variant Code");
                                GenJnlLine.SetRange("AQD Cust Rebate Journal", true);
                                if GenJnlLine.FindFirst() then begin
                                    GenJnlLine.Validate(Amount, (GenJnlLine.Amount + -VendLedgEntry."Remaining Amount"));
                                    TotalAmount += -VendLedgEntry."Remaining Amount";

                                    VendLedgEntry."Applies-to ID" := GenJnlLine."Document No.";
                                    VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
                                    IF VendLedgEntry.Modify() then;
                                    CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);

                                    GenJnlLine."Applies-to ID" := GenJnlLine."Document No.";
                                    GenJnlLine.Modify();

                                end else begin
                                    // Create Credit Memo line
                                    GenJnlLine.Init();
                                    GenJnlLine."Journal Template Name" := JnlTemplateName;
                                    GenJnlLine."Journal Batch Name" := JnlBatchName;
                                    GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                                    GenJnlLine.Validate("Posting Date", DefaultPostingDate);
                                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
                                    GenJnlLine."Document No." := BalancingDocumentNo;
                                    RunIncrementDocumentNo(GenJnlLine);
                                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                                    GenJnlLine.Validate("Account No.", TempVendorBuffer."Vendor No.");
                                    GenJnlLine.Validate(Amount, -VendLedgEntry."Remaining Amount");
                                    FormartedDescription := 'Commission ' + CopyStr(Format(EndingDate, 0, '<Month Text>') + ' ' + Format(EndingDate, 0, '<Year4>') + ' ' + TempProgrameCodesRec.Description, 1, MaxStrLen(GenJnlLine.Description));
                                    GenJnlLine.Description := FormartedDescription;
                                    GenJnlLine."AQD CR Rebate Program Code" := VendLedgEntry."AQD CR Rebate Program Code";
                                    GenJnlLine."AQD Cust Rebate Journal" := true;
                                    GenJnlLine."Journal Batch Id" := GenJnlBatch.SystemId;
                                    GenJnlLine.Insert();

                                    TotalAmount += GenJnlLine.Amount;

                                    VendLedgEntry."Applies-to ID" := GenJnlLine."Document No.";
                                    VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
                                    IF VendLedgEntry.Modify() then;
                                    CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);


                                    GenJnlLine."Applies-to ID" := GenJnlLine."Document No.";
                                    GenJnlLine.Modify();
                                end;
                            end;
                        end;
                    until VendLedgEntry.Next() = 0;
                end;

                // Create consolidated invoice for Target Vendor
                if TotalAmount <> 0 then begin

                    GenJnlLine.Init();
                    GenJnlLine."Journal Template Name" := JnlTemplateName;
                    GenJnlLine."Journal Batch Name" := JnlBatchName;
                    GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                    GenJnlLine.Validate("Posting Date", DefaultPostingDate);
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
                    GenJnlLine."Document No." := BalancingDocumentNo;
                    RunIncrementDocumentNo(GenJnlLine);
                    // GenJnlLine."External Document No." := TempVendorBuffer."Vendor No.";
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                    GenJnlLine.Validate("Account No.", TempVendorBuffer."Item No.");
                    GenJnlLine.Validate(Amount, -TotalAmount);
                    FormartedDescription := 'Commission ' + CopyStr(Format(EndingDate, 0, '<Month Text>') + ' ' + Format(EndingDate, 0, '<Year4>') + ' ' + TempProgrameCodesRec.Description, 1, MaxStrLen(GenJnlLine.Description));
                    GenJnlLine.Description := FormartedDescription;
                    GenJnlLine."AQD CR Rebate Program Code" := TempProgrameCodesRec.Code;
                    GenJnlLine."Journal Batch Id" := GenJnlBatch.SystemId;
                    GenJnlLine.Insert();
                end;
            // until ProgrameCodesRec.Next() = 0;
            until TempVendorBuffer.Next() = 0;

        Window.Close();
    end;

    local procedure InsertSummarybyVendortoJournal()
    var
    begin
    end;

    local procedure InsertSummarybyProgramCodetoJournal()
    var
    begin
    end;

    // Only commissions due for payment by the end of the period (End Date + 1D) per the program's Payment Frequency
    local procedure SetPayableDueDateFilter(var VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if EndingDate <> 0D then
            VendLedgEntry.SetFilter("AQD CR Payable Due Date", '..%1', CalcDate('<1D>', EndingDate))
        else
            VendLedgEntry.SetRange("AQD CR Payable Due Date");
    end;

    local procedure RunIncrementDocumentNo(GenJnlLine: Record "Gen. Journal Line")
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
        IsHandled: Boolean;
    begin
        if GenJnlBatch."No. Series" <> '' then
            BalancingDocumentNo := NoSeriesBatch.SimulateGetNextNo(GenJnlBatch."No. Series", GenJnlLine."Posting Date", BalancingDocumentNo)
        else
            BalancingDocumentNo := IncStr(BalancingDocumentNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDisableForceDocBalance(var GenJnlTemplate: Record "Gen. Journal Template")
    begin
    end;
}
