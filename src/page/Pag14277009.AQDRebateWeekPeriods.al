page 14277009 "AQD Rebate Week Periods"
{
    Caption = 'Rebate Week Periods';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AQD Rebate Week Periods";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Date"; Rec."AQDStart Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("End Date"; Rec."AQDEnd Date")
                {
                    ApplicationArea = All;
                }
                field("Period Type"; Rec."AQDPeriod Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Closed; Rec.AQDClosed)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.AQDName)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Create weekly Periods")
            {
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CreateRebatePeriods: Report "AQD Reb. Week Periods Mgt";
                    "Integer": Record "Integer";
                begin
                    //SBC 05-12-2022
                    CreateRebatePeriods.Run;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

