namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301951 "AQD CR VenEmpTeritoryFiltDrill"
{
    ApplicationArea = All;
    Caption = 'Vendor Employee Territory Filter';
    PageType = Worksheet;
    SourceTable = "AQD CR Vend Emp Territory Filt";

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
    procedure SetCalledFromMasterPage(CalledFromMasterPageIn: Boolean)
    begin
        CalledFromMasterPage := CalledFromMasterPageIn;
    end;

    var
        CalledFromMasterPage: Boolean;
}