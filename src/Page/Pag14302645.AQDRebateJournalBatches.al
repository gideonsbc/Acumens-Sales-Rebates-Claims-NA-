page 14302645 "AQD Rebate Journal Batches"
{
    ApplicationArea = All;
    Caption = 'Rebate Journal Batches';
    PageType = List;
    SourceTable = "AQD Rebate Journal Batch";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the rebate journal batch.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the rebate journal batch.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used to assign document numbers to new lines in this batch.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditJournal)
            {
                ApplicationArea = All;
                Caption = 'Edit Journal';
                Image = OpenJournal;
                ShortcutKey = 'Return';
                ToolTip = 'Open the rebate journal for the selected batch.';

                trigger OnAction()
                var
                    RebateJournal: Page "AQD Rebate Journal";
                begin
                    RebateJournal.SetBatchName(Rec.Name);
                    RebateJournal.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(EditJournal_Promoted; EditJournal)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
    begin
        RebateJournalBatch.CreateDefaultBatch();
    end;
}
