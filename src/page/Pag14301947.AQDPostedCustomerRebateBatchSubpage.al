namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14301947 "AQD Posted Cust Rebate Subpage"
{
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Batches';
    PageType = ListPart;
    SourceTable = "AQD Posted Cust Rebate Header";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'Lines';
                ShowCaption = false;

                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';

                    trigger OnDrillDown()
                    var
                        PostedCustomerRebatePg: Page "AQD Posted Customer Rebate Doc";
                    begin
                        clear(PostedCustomerRebatePg);
                        PostedCustomerRebatePg.SetRecord(Rec);
                        PostedCustomerRebatePg.Run();
                    end;
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Sell-To Customer No. field.', Comment = '%';
                }
                field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                {
                    ToolTip = 'Specifies the value of the Sell-To Customer Name field.', Comment = '%';
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                }
                field("Bill-To Name"; Rec."Bill-To Name")
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the value of the Salesperson Code field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
            }
        }
    }
}
