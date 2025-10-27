namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14277024 "AQD CustItem Rebate Eligib"
{
    ApplicationArea = All;
    Caption = 'Customer Item Rebate Eligibility';
    PageType = List;
    SourceTable = "AQD Cust Item Rebate Eligib";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor Type"; Rec."Customer Type")
                {
                    ToolTip = 'Specifies the value of the Customer Type field.', Comment = '%';
                }
                field("Vendor No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the value of the Line Type field.', Comment = '%';
                    Visible = FALSE;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ToolTip = 'Specifies the value of the Rebate Program Code field.', Comment = '%';
                }
                field("Purchase Quantity Threshold"; Rec."Sales Quantity Threshold")
                {
                    ToolTip = 'Specifies the value of the Sales Quantity Threshold field.', Comment = '%';
                }
                field("Purchase Amount Threshold"; Rec."Sales Amount Threshold")
                {
                    ToolTip = 'Specifies the value of the Sales Amount Threshold field.', Comment = '%';
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