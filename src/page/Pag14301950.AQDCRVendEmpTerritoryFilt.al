namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301950 "AQD CR Vend Emp Territory Filt"
{
    ApplicationArea = All;
    Caption = 'Vendor Employee Territory Filter';
    PageType = List;
    SourceTable = "AQD CR Vend Emp Territory Filt";
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
                field("Territory Code"; Rec."Territory Code")
                {
                    ToolTip = 'Specifies the value of the Territory Code field.', Comment = '%';
                }
                field("Territory Name"; Rec."Territory Name")
                {
                    ToolTip = 'Specifies the value of the Territory Name field.', Comment = '%';
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