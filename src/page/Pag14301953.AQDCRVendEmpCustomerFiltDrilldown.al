namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301953 "AQD CR VendEmp Cust Filt Drill"
{
    ApplicationArea = All;
    Caption = 'Vendor Employee Customer Filter';
    PageType = Worksheet;
    SourceTable = "AQD CR Vend Emp Customer Filt";

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
    procedure SetCalledFromMasterPage(var CalledFromMasterPageIn: Boolean)
    begin
        CalledFromMasterPage := CalledFromMasterPageIn;
    end;

    var
        CalledFromMasterPage: Boolean;
}
