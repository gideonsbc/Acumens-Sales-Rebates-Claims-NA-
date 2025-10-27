namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14277060 "AQD Posted Vendor Rebate Batch"
{
    ApplicationArea = All;
    Caption = 'Posted Vendor Rebate Batch';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "AQD Posted Vendor Rebate Batch";

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
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount field.', Comment = '%';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.', Comment = '%';
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
            part("AQD PostedVendorRebate Subpage"; "AQD PostedVendorRebate Subpage")
            {
                ApplicationArea = All;
                Caption = 'Posted Vendor Rebate Documents';
                SubPageLink = "Batch Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
        }
    }
}
