namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14301946 "AQD Posted Cust Rebate Batch"
{
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Batch';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "AQD Posted Cust Rebate Batch";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved Date Time"; Rec."Approved Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            // part("AQD PostedCustomerRebate Subpage"; "AQD PostedCustomerRebate Subpage")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Posted Customer Rebate Documents';
            //     SubPageLink = "Batch Entry No." = field("Entry No.");
            //     UpdatePropagation = Both;
            // }
        }
    }
}
