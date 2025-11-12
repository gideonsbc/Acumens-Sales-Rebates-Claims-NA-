page 14301917 "AQD Customer Rebate User Setup"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate User Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate User Setup";
    UsageCategory = Administration;
    ObsoleteState = Pending;
    ObsoleteReason = 'Move to Cashflow App';
    ObsoleteTag = '25.1023.0.6';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field("Rebate Role"; Rec."Rebate Role")
                {
                    ApplicationArea = All;
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code Filter"; Rec."Salesperson Code Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Filter"; Rec."Global Dimension 1 Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Filter"; Rec."Global Dimension 2 Filter")
                {
                    ApplicationArea = All;
                }
                field("State Filter"; Rec."State Filter")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

