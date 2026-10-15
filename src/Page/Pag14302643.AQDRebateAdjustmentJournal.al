page 14302643 "AQD Rebate Adjustment Journal"
{
    ApplicationArea = All;
    Caption = 'Rebate Adjustment Journal';
    PageType = Worksheet;
    SourceTable = "Gen. Journal Line";
    //SourceTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
    UsageCategory = Tasks;


    AdditionalSearchTerms = 'rebates journal';

    AutoSplitKey = true;

    DataCaptionExpression = Rec.DataCaption();
    DelayedInsert = true;

    AboutTitle = 'About Rebate Journals';
    AboutText = 'Record and process rebates to vendors and  to customers, apply rebates to invoices or credit memos, and manage payment methods including printing checks and exporting electronic payment files.';
    SaveValues = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }

                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("AQD CR Rebate Program Code"; Rec."AQD CR Rebate Program Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        AQDCustRebateProgramCode: Record "AQD Cust Rebate Program Code";
                    begin
                        if Rec."AQD CR Rebate Program Code" = '' then
                            rec."Bal. Account No." := ''
                        else begin
                            if not AQDCustRebateProgramCode.Get(Rec."AQD CR Rebate Program Code") then
                                Error('Invalid AQD CR Rebate Program Code');
                            AQDCustRebateProgramCode.TestField("Rebate Expense AC");
                            rec."Bal. Account Type" := rec."Bal. Account Type"::"G/L Account";
                            Rec."Bal. Account No." := AQDCustRebateProgramCode."Rebate Expense AC";
                        end;


                    end;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;

                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = All;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("AQD Post Rebate Adjustments")
            {
                ApplicationArea = All;
                Caption = 'Post Rebate Adjustments';
                Image = Post;
                ToolTip = 'Post the calculated rebate amounts entered in this rebate journal batch.';

                trigger OnAction()
                var
                    GenJournalBatch: Record "Gen. Journal Batch";
                    GenJournalLine: Record "Gen. Journal Line";
                    ConfirmPostQst: Label 'Post all lines in rebate journal batch %1?';
                    RebateBatchRequiredErr: Label 'This action is only available for a batch designated as a Rebate Adjustment Journal.';
                    NoLinesErr: Label 'There are no journal lines to post in this batch.';
                begin
                    CurrPage.SaveRecord();
                    if not Confirm(ConfirmPostQst, false, Rec."Journal Batch Name") then
                        exit;
                    if not GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
                        Error(RebateBatchRequiredErr);
                    if not GenJournalBatch."AQD Customer Rebate" then
                        Error(RebateBatchRequiredErr);

                    GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if GenJournalLine.IsEmpty() then
                        Error(NoLinesErr);
                    if GenJournalLine.FindSet() then
                        repeat
                            // Perform actions on each line

                            GenJournalLine.TestField("AQD CR Rebate Program Code");
                            GenJournalLine.TestField("Bal. Account No.");
                            GenJournalLine.TestField("Amount");
                            GenJournalLine."AQD Cust Rebate Journal" := true;
                            GenJournalLine.Modify();
                        until GenJournalLine.Next() = 0;



                    GenJournalLine.ModifyAll("AQD Cust Rebate Journal", true);
                    GenJournalLine.Reset();
                    GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    //GenJournalLine.SetRange("AQD Cust Rebate Journal", true);
                    //GenJournalLine.FindFirst();
                    Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine);
                    CurrPage.Update();
                    //Rec.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        AdjustmentBatchRequiredErr: Label 'Open this page from a batch designated as a Rebate Adjustment Journal.';
    begin
        // if (Rec.GetFilter("Journal Template Name") = '') or (Rec.GetFilter("Journal Batch Name") = '') then
        //     Error(AdjustmentBatchRequiredErr);

        // if not GenJournalBatch.Get(Rec.GetRangeMin("Journal Template Name"), Rec.GetRangeMin("Journal Batch Name")) then
        //     Error(AdjustmentBatchRequiredErr);
        // if not GenJournalBatch."AQD Customer Rebate" then
        //     Error(AdjustmentBatchRequiredErr);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec, 0, BelowxRec);
    end;
}