namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14301930 "AQD Item Cust Rebate Matrix"
{
    ApplicationArea = All;
    Caption = 'Item Customer Rebate Matrix';
    PageType = List;
    SourceTable = "AQD Cust Item Rebate Matrix";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer Type"; Rec."Customer Type")
                {
                    ToolTip = 'Specifies the value of the Customer Type field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the value of the Line Type field.', Comment = '%';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ToolTip = 'Specifies the value of the Rebate Program Code field.', Comment = '%';
                }
                field("Sales Quantity Threshold"; Rec."Sales Quantity Threshold")
                {
                    ToolTip = 'Specifies the value of the Sales Quantity Threshold field.', Comment = '%';
                }
                field("Sales Quantity Threshold (YTD)"; Rec."Sales Quantity Threshold (YTD)")
                {
                    ToolTip = 'Specifies the value of the Sales Quantity Threshold (YTD) field.', Comment = '%';
                }
                field("Sales Amount Threshold"; Rec."Sales Amount Threshold")
                {
                    ToolTip = 'Specifies the value of the Sales Amount Threshold field.', Comment = '%';
                }
                field("Sales Amount Threshold (YTD)"; Rec."Sales Amount Threshold (YTD)")
                {
                    ToolTip = 'Specifies the value of the Sales Amount Threshold (YTD) field.', Comment = '%';
                }
                field(EligiblePeriodAfterFirstShpt; Rec.EligiblePeriodAfterFirstShpt)
                {
                    ToolTip = 'Specifies the value of the Eligible Period After First Shipment field.', Comment = '%';
                }
                field(Blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                    ToolTip = 'Specifies the value of the Blocked field.', Comment = '%';
                }
            }
        }
    }
}
