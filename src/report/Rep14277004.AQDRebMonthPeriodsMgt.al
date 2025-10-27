report 14277004 "AQD Reb. Month Periods Mgt"
{
    Caption = 'Rebate Month Periods Mgt';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 .. 2));

            trigger OnAfterGetRecord()
            begin
                if Integer.Number = 1 then begin
                    CreateMonthPeriods();
                end;

                if Integer.Number = 2 then
                    CreateWeeklyPeriods();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Filters)
                {
                    field("End Date"; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        EndDate: Date;
        PeriodOption: Option "Create Period","Close Old Period","Close current period";
        RebateSetup: Record "AQD Acumens Rebate Setup";

    local procedure CreateMonthPeriods()
    var
        EndingDate: Date;
        MonthComnPeriod: Record "AQD Rebate Month Period";
        Text000: Label '<Month Text>';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
        CommisionEntries: Record "AQD Rebate Document Entry";
        InitialPeriodStart: Date;
    begin
        InitialPeriodStart := 0D;

        MonthComnPeriod.Reset;
        if MonthComnPeriod.FindLast then begin
            NextPeriod := MonthComnPeriod."AQDEnding Date";
            PeriodStart := CalcDate('+1M', MonthComnPeriod."AQDEnding Date");
        end else begin
            CommisionEntries.Reset;
            CommisionEntries.SetCurrentKey("Document Posting Date");
            if CommisionEntries.FindFirst then
                InitialPeriodStart := CommisionEntries."Document Posting Date"
            else begin
                RebateSetup.Get();
                RebateSetup.TestField("Start Date");
                InitialPeriodStart := RebateSetup."Start Date";
            end;

            if InitialPeriodStart <> 0D then begin
                PeriodStart := CalcDate('+CM', InitialPeriodStart);
                MonthComnPeriod.Reset;
                MonthComnPeriod.SetRange("AQDEnding Date", PeriodStart);
                if not MonthComnPeriod.FindFirst then begin
                    MonthComnPeriod.Init;
                    MonthComnPeriod."AQDEnding Date" := PeriodStart;
                    MonthComnPeriod.AQDName := Format(Date2DMY(PeriodStart, 3)) + ' ' + Format(PeriodStart, 0, Text000);
                    MonthComnPeriod."AQDPeriod Type" := MonthComnPeriod."AQDPeriod Type"::Monthly;
                    MonthComnPeriod.Insert;
                end;
            end;
            NextPeriod := PeriodStart;
        end;


        EndingDate := CalcDate('+CM', EndDate);


        repeat
            NextPeriod := CalcDate('+1M', NextPeriod);
            NextPeriod := CalcDate('+CM', NextPeriod);
            MonthComnPeriod.Reset;
            MonthComnPeriod.SetRange("AQDEnding Date", NextPeriod);
            if not MonthComnPeriod.FindFirst then begin
                MonthComnPeriod.Init;
                MonthComnPeriod."AQDEnding Date" := NextPeriod;
                MonthComnPeriod.AQDName := Format(Date2DMY(NextPeriod, 3)) + ' ' + Format(NextPeriod, 0, Text000);
                MonthComnPeriod."AQDPeriod Type" := MonthComnPeriod."AQDPeriod Type"::Monthly;
                MonthComnPeriod.Insert;
            end;
        until (NextPeriod = EndingDate) or (NextPeriod > EndDate);

        PeriodEnd := EndingDate;
        Message('Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;

    local procedure CreateWeeklyPeriods()
    var
        EndingDate: Date;
        WeekMonthComnPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
        CommisionEntries: Record "AQD Rebate Document Entry";
    begin
        WeekMonthComnPeriod.Reset;
        if WeekMonthComnPeriod.FindLast then begin
            NextPeriod := WeekMonthComnPeriod."AQDEnd Date";
            PeriodStart := CalcDate('+1W', WeekMonthComnPeriod."AQDEnd Date");
        end
        else begin
            CommisionEntries.Reset;
            CommisionEntries.SetCurrentKey("Document Posting Date");
            if CommisionEntries.FindFirst then begin
                PeriodStart := CalcDate('+CW', CommisionEntries."Document Posting Date");
                WeekMonthComnPeriod.Reset;
                WeekMonthComnPeriod.SetRange("AQDEnd Date", PeriodStart);
                if not WeekMonthComnPeriod.FindFirst then begin
                    WeekMonthComnPeriod.Init;
                    WeekMonthComnPeriod."AQDEnd Date" := PeriodStart;
                    WeekMonthComnPeriod.AQDName := Format(Date2DWY(PeriodStart, 3)) + Text000 + Format(Date2DWY(PeriodStart, 2));
                    WeekMonthComnPeriod."AQDPeriod Type" := WeekMonthComnPeriod."AQDPeriod Type"::"1 Week";
                    WeekMonthComnPeriod.Insert;
                end;
            end;
            NextPeriod := PeriodStart;
        end;


        EndingDate := CalcDate('+CW', EndDate);

        repeat
            NextPeriod := CalcDate('+1W', NextPeriod);
            NextPeriod := CalcDate('+CW', NextPeriod);
            WeekMonthComnPeriod.Reset;
            WeekMonthComnPeriod.SetRange("AQDEnd Date", NextPeriod);
            if not WeekMonthComnPeriod.FindFirst then begin
                WeekMonthComnPeriod.Init;
                WeekMonthComnPeriod."AQDEnd Date" := NextPeriod;
                WeekMonthComnPeriod.AQDName := Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeekMonthComnPeriod."AQDPeriod Type" := WeekMonthComnPeriod."AQDPeriod Type"::"2 Week";
                WeekMonthComnPeriod.Insert;
            end;
        until NextPeriod = EndingDate;

        PeriodEnd := EndingDate;
        Message('Weekly Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;
}

