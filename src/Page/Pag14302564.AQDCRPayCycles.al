page 14302564 "AQD CR Pay Cycles"
{
    ApplicationArea = All;
    Caption = 'Pay Cycles';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "AQD CR Pay Cycle";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cycle Code"; Rec."Cycle Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pay cycle the period belongs to.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first posting date covered by the pay cycle.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last posting date covered by the pay cycle.';
                }
                field("Commission Payable Date"; Rec."Commission Payable Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date commissions for the period become payable.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GeneratePayCycles)
            {
                ApplicationArea = All;
                Caption = 'Generate Pay Cycles';
                Image = CreateYear;
                RunObject = report "AQD CR Generate Pay Cycles";
                ToolTip = 'Generate pay cycle periods for a number of periods.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(GeneratePayCycles_Promoted; GeneratePayCycles) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        PayCycle: Record "AQD CR Pay Cycle";
    begin
        PayCycle.InitDefaultCycleCode();
    end;
}
