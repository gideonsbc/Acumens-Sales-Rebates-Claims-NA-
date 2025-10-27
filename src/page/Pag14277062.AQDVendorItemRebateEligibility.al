namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14277062 "AQD VendItem Rebate Eligib"
{
    ApplicationArea = All;
    Caption = 'Vendor Item Rebate Eligibility';
    PageType = List;
    SourceTable = "AQD VendItem Rebate Eligib";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor Type"; Rec."Vendor Type")
                {
                    ToolTip = 'Specifies the value of the Vendor Type field.', Comment = '%';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
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
                field("Purchase Quantity Threshold"; Rec."Purchase Quantity Threshold")
                {
                    ToolTip = 'Specifies the value of the Purchase Quantity Threshold field.', Comment = '%';
                }
                field("Purchase Amount Threshold"; Rec."Purchase Amount Threshold")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount Threshold field.', Comment = '%';
                }
                field(EligiblePeriodAfterFirstRcpt; Rec.EligiblePeriodAfterFirstRcpt)
                {
                    ToolTip = 'Specifies the value of the Eligible Period After First Receipt field.', Comment = '%';
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
