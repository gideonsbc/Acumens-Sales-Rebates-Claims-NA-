page 14277007 "AQD Rebate Month Period"
{
    Caption = 'Rebate Month Period';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AQD Rebate Month Period";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Ending Date"; Rec."AQDEnding Date")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.AQDName)
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
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Create Periods")
            {
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CreateRebatePeriods: Report "AQD Reb. Month Periods Mgt";
                    "Integer": Record "Integer";
                begin
                    //SBC 05-12-2022
                    Integer.SetRange(Number, 1);
                    CreateRebatePeriods.SetTableView(Integer);
                    CreateRebatePeriods.Run;
                    CurrPage.Update;
                end;
            }
        }
    }
}

