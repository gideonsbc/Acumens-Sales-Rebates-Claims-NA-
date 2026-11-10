report 14302619 "AQD CR Generate Pay Cycles"
{
    ApplicationArea = All;
    Caption = 'Generate Pay Cycles';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(FrequencyField; CycleCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Frequency';
                        Editable = false;
                        ToolTip = 'Specifies the pay cycle code the periods are generated for.';
                    }
                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the first date of the first pay cycle. Choose the assist button to use the next available date after the existing pay cycles.';

                        trigger OnValidate()
                        begin
                            UpdateDates();
                        end;

                        trigger OnAssistEdit()
                        var
                            PayCycle: Record "AQD CR Pay Cycle";
                        begin
                            StartDate := PayCycle.GetNextStartDate(CycleCode);
                            if StartDate = 0D then
                                StartDate := WorkDate();
                            UpdateDates();
                        end;
                    }
                    field(EndDateField; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        Editable = false;
                        ToolTip = 'Specifies the last date of the first pay cycle, calculated from the Start Date and the period length of the frequency.';
                    }
                    field(PayDateField; PayDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Pay Date';
                        ToolTip = 'Specifies the Commission Payable Date of the first pay cycle. Later pay cycles keep the same distance between End Date and Pay Date. Choose the assist button to suggest the date from the pay-date pattern of the existing pay cycles.';

                        trigger OnAssistEdit()
                        var
                            PayCycle: Record "AQD CR Pay Cycle";
                        begin
                            if EndDate <> 0D then
                                PayDate := PayCycle.SuggestPayDate(CycleCode, EndDate);
                        end;
                    }
                    field(NoOfPeriodsField; NoOfPeriods)
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Periods';
                        MinValue = 1;
                        ToolTip = 'Specifies how many pay cycles to generate.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            PayCycle: Record "AQD CR Pay Cycle";
        begin
            InitCycleCode();
            if NoOfPeriods = 0 then
                NoOfPeriods := 260; // 10 years of biweekly cycles
            if StartDate = 0D then begin
                StartDate := PayCycle.GetNextStartDate(CycleCode);
                UpdateDates();
            end;
        end;
    }

    trigger OnPreReport()
    var
        PayCycle: Record "AQD CR Pay Cycle";
        LastEndDate: Date;
        PayDateBeforeStartErr: Label '%1 must not be before %2.', Comment = '%1 = Pay Date, %2 = Start Date';
        CreatedMsg: Label '%1 %2 pay cycles were created, from %3 to %4.', Comment = '%1 = No. of Periods, %2 = Cycle Code, %3 = First Start Date, %4 = Last End Date';
    begin
        InitCycleCode();
        if StartDate = 0D then
            Error(MissingValueErr, StartDateLbl);
        if PayDate = 0D then
            Error(MissingValueErr, PayDateLbl);
        if NoOfPeriods <= 0 then
            Error(MissingValueErr, NoOfPeriodsLbl);
        EndDate := PayCycle.CalcEndDate(StartDate);
        if PayDate < StartDate then
            Error(PayDateBeforeStartErr, PayDateLbl, StartDateLbl);

        LastEndDate := PayCycle.GenerateCycles(CycleCode, StartDate, PayDate, NoOfPeriods);

        if GuiAllowed() then
            Message(CreatedMsg, NoOfPeriods, CycleCode, StartDate, LastEndDate);
    end;

    local procedure InitCycleCode()
    var
        PayCycle: Record "AQD CR Pay Cycle";
    begin
        if CycleCode = '' then
            CycleCode := PayCycle.GetDefaultCycleCode();
    end;

    local procedure UpdateDates()
    var
        PayCycle: Record "AQD CR Pay Cycle";
    begin
        if StartDate = 0D then begin
            EndDate := 0D;
            PayDate := 0D;
            exit;
        end;
        EndDate := PayCycle.CalcEndDate(StartDate);
        PayDate := PayCycle.SuggestPayDate(CycleCode, EndDate);
    end;

    var
        CycleCode: Code[20];
        StartDate: Date;
        EndDate: Date;
        PayDate: Date;
        NoOfPeriods: Integer;
        MissingValueErr: Label 'You must specify %1.', Comment = '%1 = Field Caption';
        StartDateLbl: Label 'Start Date';
        PayDateLbl: Label 'Pay Date';
        NoOfPeriodsLbl: Label 'No. of Periods';
}
