namespace AcumenseRebatesBC.AcumenseRebatesBC;
page 14301942 "AQD Customer Rebate Batches"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Batches';
    CardPageId = "AQD Customer Rebate Batch";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "AQD Customer Rebate Batch";
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
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                    Visible = ShowBillToCustomer;
                }
                field("Bill-To Customer Name"; Rec."Bill-To Customer Name")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer Name field.', Comment = '%';
                    Visible = ShowBillToCustomer;
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
                    Visible = false;
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

    trigger OnOpenPage()
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF NOT RebateSetup.GET THEN
            RebateSetup.INIT;
        ShowBillToCustomer := RebateSetup."Post Rebates by Bill-To Cust";
    end;

    var
        ShowBillToCustomer: Boolean;
}
