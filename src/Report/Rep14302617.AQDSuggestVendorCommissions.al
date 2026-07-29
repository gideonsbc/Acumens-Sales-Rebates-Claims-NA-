report 14302617 "AQD Suggest Vendor Commissions"
{
    ApplicationArea = All;
    Caption = 'Suggest Vendor Commissions & Rebates';
    UsageCategory = None;
    ProcessingOnly = true;
    dataset
    {
        dataitem("AQD Cust Rebate Program Code"; "AQD Cust Rebate Program Code")
        {
            DataItemTableView = where("Payee Type" = filter("Vendor Commission"), "AQD Pay-to Vendor No." = filter(<> ''));
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                GenJnlLine.TestField("Journal Template Name");
                GenJnlLine.TestField("Journal Batch Name");

                CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin

            end;
        }
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            DataItemTableView = where("AQD CR Rebate Program Code" = filter(<> ''), Open = filter(true), "Document Type" = filter(Invoice));
            RequestFilterFields = "Vendor No.", "Posting Date";
        }
    }
    requestpage
    {
        Caption = 'Suggest Vendor Commissions';
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BalancingDocumentNo; BalancingDocumentNo)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the next available number in the number series for the journal batch that is linked to the purchase journal. When you run the batch job, this is the document number that appears on the balancing journal line. You can also fill in this field manually.';
                        trigger OnValidate()
                        begin
                            if BalancingDocumentNo <> '' then
                                if IncStr(BalancingDocumentNo) = '' then
                                    Error(StartingDocumentNoErr);
                        end;
                    }
                    field(FromDate; FromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date Filter';

                    }
                    field(ToDate; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date Filter';
                        trigger OnValidate()
                        begin
                            PostingDate := ToDate;
                        end;

                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                    }
                    field(SummarizeByProgramCode; SummarizeByProgramCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Summarize by Program Code';
                        ToolTip = 'Specifies whether to summarize the suggested commission amounts by program code. If you select this option, the system will create one journal line per program code with the total commission amount for that program code. If you clear this option, the system will create one journal line per invoice.';
                    }
                }
                group(JournalDetails)
                {
                    ShowCaption = false;
                    Visible = false;
                    field(JournalTemplateName; JnlTemplateName)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        ToolTip = 'Specifies the journal template name of the purchase journal.';
                        Visible = false;
                    }
                    field(JournalBatchName; JnlBatchName)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        ToolTip = 'Specifies the journal batch name of the purchase journal.';
                        Visible = false;
                    }
                }
            }

        }

        trigger OnInit()
        begin
            SummarizeByProgramCode := false;
        end;

        trigger OnOpenPage()
        var
            RecodRestrictions: Record "Restricted Record";
        begin
            // RecodRestrictions.Reset();
            // RecodRestrictions.DeleteAll();
            // Initialize filters
            FromDate := 0D;
            ToDate := 0D;

            ValidateDocumentNo();
            ToDate := CalcDate('-CM-1D', Today);
            PostingDate := ToDate;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction in [CloseAction::OK] then begin
                if BalancingDocumentNo = '' then
                    Error('Please specify a valid Document No.');

                if PostingDate = 0D then
                    Error('Posting date must not be blank.');

                if ToDate = 0D then
                    Error('End Date Filter must not be blank.');
            end;
        end;
    }


    trigger OnPostReport()
    begin
        SuggestVendorCommissionInvoices.SetDefaultValues(BalancingDocumentNo, PostingDate, SummarizeByProgramCode, FromDate, ToDate,
                                                                         GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");

        SuggestVendorCommissionInvoices.SuggestVendorCommissionInvoices("AQD Cust Rebate Program Code", "Vendor Ledger Entry");

    end;

    var
        GenJnlBatch: Record "Gen. Journal Batch";
        FromDate: Date;
        PostingDate: Date;
        ToDate: Date;
        BalancingDocumentNo: Code[20];
        SuggestVendorCommissionInvoices: Codeunit "AQD Suggest Vendor Commissions";
        GenJnlLine: Record "Gen. Journal Line";
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        StartingDocumentNoErr: Label 'The value in the Balancing Document No. field must have a number so that we can assign the next number in the series.';
        SummarizeByProgramCode: Boolean;

    procedure SetGenJnlLine(NewGenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine := NewGenJnlLine;
    end;

    local procedure ValidateDocumentNo()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if not GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name") then
            GenJnlBatch.Get(JnlTemplateName, JnlBatchName)
        else begin
            JnlTemplateName := GenJnlLine."Journal Template Name";
            JnlBatchName := GenJnlLine."Journal Batch Name";
        end;

        if GenJnlBatch."No. Series" = '' then
            BalancingDocumentNo := ''
        else
            BalancingDocumentNo := NoSeries.PeekNextNo(GenJnlBatch."No. Series", Today);
    end;
}