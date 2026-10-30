table 14302522 "AQD Rebate Journal Batch"
{
    Caption = 'Rebate Journal Batch';
    DataCaptionFields = Name, Description;
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Rebate Journal Batches";
    LookupPageId = "AQD Rebate Journal Batches";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Description)
        {
        }
    }

    trigger OnDelete()
    var
        RebateJournalLine: Record "AQD Rebate Journal Line";
    begin
        RebateJournalLine.SetRange("Batch Name", Name);
        RebateJournalLine.DeleteAll(true);
    end;

    trigger OnRename()
    var
        RebateJournalLine: Record "AQD Rebate Journal Line";
        RenameWithLinesErr: Label 'You cannot rename batch %1 because it contains journal lines.';
    begin
        RebateJournalLine.SetRange("Batch Name", xRec.Name);
        if not RebateJournalLine.IsEmpty() then
            Error(RenameWithLinesErr, xRec.Name);
    end;

    procedure CreateDefaultBatch()
    var
        DefaultBatchNameTxt: Label 'DEFAULT', Locked = true;
        DefaultBatchDescTxt: Label 'Default Journal';
    begin
        if Get(DefaultBatchNameTxt) then
            exit;
        Init();
        Name := DefaultBatchNameTxt;
        Description := DefaultBatchDescTxt;
        Insert();
    end;
}
