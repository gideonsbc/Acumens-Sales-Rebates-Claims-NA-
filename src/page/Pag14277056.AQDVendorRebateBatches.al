namespace AcumenseRebatesBC.AcumenseRebatesBC;
page 14277056 "AQD Vendor Rebate Batches"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Batches';
    CardPageId = "AQD Vendor Rebate Batch";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "AQD Vendor Rebate Batch";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(BatchID; Rec.BatchID)
                {
                    NotBlank = true;
                    ToolTip = 'Specifies the value of the BatchId field.', Comment = '%';
                }
                field("AQD Rebate Batch Frequency"; Rec."AQD Rebate Batch Frequency")
                {
                    ToolTip = 'Specifies the value of the Rebate Batch Frequency field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount field.', Comment = '%';
                }
                field("Purchase Amount Including VAT"; Rec."Purchase Amount Including VAT")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount Including VAT field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.', Comment = '%';
                }
                field("Created By"; Rec."Created By")
                {
                    ToolTip = 'Specifies the value of the Created By field.', Comment = '%';
                }
            }
        }
    }
}
