namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301952 "AQD CR Vend Emp Customer Filt"
{
    ApplicationArea = All;
    Caption = 'Vendor Employee Customer Filter';
    PageType = List;
    SourceTable = "AQD CR Vend Emp Customer Filt";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                    Visible = not CalledFromMasterPage;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                    Visible = not CalledFromMasterPage;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.', Comment = '%';
                }
            }
        }
    }
    procedure SetCalledFromMasterPage(CalledFromMasterPageIn: Boolean)
    begin
        CalledFromMasterPage := CalledFromMasterPageIn;
    end;

    var
        CalledFromMasterPage: Boolean;
}
