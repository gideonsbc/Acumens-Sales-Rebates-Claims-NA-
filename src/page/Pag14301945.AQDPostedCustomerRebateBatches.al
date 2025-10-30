namespace AcumenseRebatesBC.AcumenseRebatesBC;
page 14301945 "AQD Posted Cust Rebate Batches"
{
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Batches';
    CardPageId = "AQD Posted Cust Rebate Batch";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AQD Posted Cust Rebate Batch";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(BatchID; Rec.BatchID)
                {
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
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Amount field.', Comment = '%';
                }
                field("Sales Amount Including VAT"; Rec."Sales Amount Including VAT")
                {
                    ToolTip = 'Specifies the value of the Sales Amount Including VAT field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("Created By"; Rec."Created By")
                {
                    ToolTip = 'Specifies the value of the Created By field.', Comment = '%';
                }
            }
        }
    }
}
