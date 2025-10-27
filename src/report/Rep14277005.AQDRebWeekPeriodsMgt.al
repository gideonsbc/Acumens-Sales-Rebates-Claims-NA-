report 14277005 "AQD Reb. Week Periods Mgt"
{
    Caption = 'Rebate Week Periods Mgt';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
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
                        Visible = false;
                        ApplicationArea = All;
                    }
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = All;
                    }
                    field("Period Type"; PeriodType)
                    {
                        ApplicationArea = All;
                    }
                    field("No. Of Periods"; NoOfPeriods)
                    {
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

    trigger OnPostReport()
    begin
        if NoOfPeriods = 0 then
            Error('Please select the number for periods');

        if StartDate = 0D then
            Error('Please select the start date');

        if PeriodType = PeriodType::" " then
            Error('Please Select the period type');

        // //SBCBR 6/29/2022 Handle Weekly Periods
        if PeriodType = PeriodType::"1 Week" then
            CreateWeekPeriods;
        if PeriodType = PeriodType::"2 Week" then
            CreateTwoWeekPeriods;
        if PeriodType = PeriodType::"3 Week" then
            CreateThreeWeekPeriods;
        if PeriodType = PeriodType::"4 Week" then
            CreateFourWeekPeriods;
        if PeriodType = PeriodType::"Bi-Monthly" then
            CreateBIMonthlyWeekPeriods;
    end;

    var
        EndDate: Date;
        Periodno: Integer;
        PeriodType: Option " ","1 Week","2 Week","3 Week","4 Week","Bi-Monthly";
        NoOfPeriods: Integer;
        StartDate: Date;
        PreviousPeriod: Date;
        PeriodOption: Option "Create Period","Close Old Period","Close current period";
        TaxPeriodStart: Date;

    local procedure CreateWeekPeriods()
    var
        EndingDate: Date;
        WeeklyCommisionPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
    begin
        WeeklyCommisionPeriod.Reset;
        if WeeklyCommisionPeriod.FindLast then begin
            NextPeriod := WeeklyCommisionPeriod."AQDEnd Date";
            PeriodStart := CalcDate('+1W', WeeklyCommisionPeriod."AQDEnd Date");
            TaxPeriodStart := CalcDate('-CW', PeriodStart);
        end else begin
            PeriodStart := CalcDate('-CW', StartDate);
            TaxPeriodStart := CalcDate('-1W', PeriodStart);
            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", PeriodStart);
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := PeriodStart;
                WeeklyCommisionPeriod."AQDStart Date" := TaxPeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(PeriodStart, 3)) + Text000 + Format(Date2DWY(PeriodStart, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"1 Week";
                WeeklyCommisionPeriod.Insert;
            end;
            NextPeriod := PeriodStart;
        end;

        repeat
            NextPeriod := CalcDate('+1W', NextPeriod);
            NextPeriod := CalcDate('+CW', NextPeriod);
            TaxPeriodStart := CalcDate('-CW', NextPeriod);
            Periodno += 1;
            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", NextPeriod);
            WeeklyCommisionPeriod.SetRange("AQDPeriod Type", WeeklyCommisionPeriod."AQDPeriod Type"::"1 Week");
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := NextPeriod;
                WeeklyCommisionPeriod."AQDStart Date" := TaxPeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"1 Week";
                WeeklyCommisionPeriod.Insert;

                if Periodno = NoOfPeriods then
                    PeriodEnd := NextPeriod;
            end;
        until PeriodEnd = NextPeriod;

        if PeriodEnd = NextPeriod then
            Message('Weekly Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;

    local procedure CreateTwoWeekPeriods()
    var
        EndingDate: Date;
        WeeklyCommisionPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
    begin
        PeriodStart := CalcDate('-CW', StartDate);
        NextPeriod := PeriodStart;

        PreviousPeriod := CalcDate('+1W', NextPeriod);

        repeat
            NextPeriod := CalcDate('+2W', NextPeriod);
            NextPeriod := CalcDate('+CW', NextPeriod);

            TaxPeriodStart := CalcDate('-2W', NextPeriod);
            TaxPeriodStart := CalcDate('-CW', TaxPeriodStart);
            Periodno += 1;

            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", NextPeriod);
            WeeklyCommisionPeriod.SetRange("AQDPeriod Type", WeeklyCommisionPeriod."AQDPeriod Type"::"2 Week");
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := NextPeriod;
                WeeklyCommisionPeriod."AQDStart Date" := TaxPeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(PreviousPeriod, 3)) + Text000 + Format(Date2DWY(PreviousPeriod, 2)) + ' - ' + Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"2 Week";
                WeeklyCommisionPeriod.Insert;

                PreviousPeriod := CalcDate('+2W', NextPeriod);

                if Periodno = NoOfPeriods then
                    PeriodEnd := NextPeriod;
            end;
        until PeriodEnd = NextPeriod;

        if PeriodEnd = NextPeriod then
            Message('Weekly Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;

    local procedure CreateThreeWeekPeriods()
    var
        EndingDate: Date;
        WeeklyCommisionPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
    begin
        PeriodStart := CalcDate('-CW', StartDate);
        NextPeriod := PeriodStart;

        PreviousPeriod := CalcDate('+1W', NextPeriod);

        repeat
            NextPeriod := CalcDate('+3W', NextPeriod);
            NextPeriod := CalcDate('+CW', NextPeriod);

            TaxPeriodStart := CalcDate('-3W', NextPeriod);
            TaxPeriodStart := CalcDate('-CW', TaxPeriodStart);

            Periodno += 1;

            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", NextPeriod);
            WeeklyCommisionPeriod.SetRange("AQDPeriod Type", WeeklyCommisionPeriod."AQDPeriod Type"::"3 Week");
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := NextPeriod;
                WeeklyCommisionPeriod."AQDStart Date" := TaxPeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(PreviousPeriod, 3)) + Text000 + Format(Date2DWY(PreviousPeriod, 2)) + ' - ' + Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"3 Week";
                WeeklyCommisionPeriod.Insert;

                PreviousPeriod := CalcDate('+1W', NextPeriod);

                if Periodno = NoOfPeriods then
                    PeriodEnd := NextPeriod;
            end;
        until PeriodEnd = NextPeriod;

        if PeriodEnd = NextPeriod then
            Message('Weekly Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;

    local procedure CreateFourWeekPeriods()
    var
        EndingDate: Date;
        WeeklyCommisionPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
    begin
        PeriodStart := CalcDate('-CW', StartDate);
        NextPeriod := PeriodStart;

        PreviousPeriod := NextPeriod;

        repeat

            NextPeriod := CalcDate('+4W', NextPeriod);
            NextPeriod := CalcDate('+CW', NextPeriod);

            TaxPeriodStart := CalcDate('-4W', NextPeriod);
            TaxPeriodStart := CalcDate('-CW', TaxPeriodStart);

            Periodno += 1;

            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", NextPeriod);
            WeeklyCommisionPeriod.SetRange("AQDPeriod Type", WeeklyCommisionPeriod."AQDPeriod Type"::"4 Week");
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := NextPeriod;
                WeeklyCommisionPeriod."AQDStart Date" := TaxPeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(PreviousPeriod, 3)) + Text000 + Format(Date2DWY(PreviousPeriod, 2)) + ' - ' + Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"4 Week";
                WeeklyCommisionPeriod.Insert;
                PreviousPeriod := CalcDate('+1W', NextPeriod);
                if Periodno = NoOfPeriods then
                    PeriodEnd := NextPeriod;
            end;
        until PeriodEnd = NextPeriod;

        if PeriodEnd = NextPeriod then
            Message('Weekly Periods %1..%2 successfully created', PeriodStart, PeriodEnd);
    end;

    local procedure CreateBIMonthlyWeekPeriods()
    var
        EndingDate: Date;
        WeeklyCommisionPeriod: Record "AQD Rebate Week Periods";
        Text000: Label ' Week ';
        PeriodStart: Date;
        PeriodEnd: Date;
        NextPeriod: Date;
    begin
        PeriodStart := CalcDate('-CM', StartDate);
        if StartDate - PeriodStart > 15 then begin
            PeriodStart := CalcDate('-CM + 15D', StartDate);
            EndDate := CalcDate('+CM', PeriodStart);
            //PreviousPeriod := CALCDATE('-CM+14D',PeriodStart);
            PreviousPeriod := PeriodStart;
            TaxPeriodStart := CalcDate('-CM', PeriodStart)
        end else begin
            EndDate := CalcDate('-CM + 14D', PeriodStart);
            PeriodStart := CalcDate('-CM', EndDate);
            // PreviousPeriod := CALCDATE('-CM + 15D',PeriodStart);
            PreviousPeriod := PeriodStart;
        end;

        NextPeriod := EndDate;

        repeat
            Periodno += 1;

            WeeklyCommisionPeriod.Reset;
            WeeklyCommisionPeriod.SetRange("AQDEnd Date", NextPeriod);
            WeeklyCommisionPeriod.SetRange("AQDPeriod Type", WeeklyCommisionPeriod."AQDPeriod Type"::"Bi-Monthly");
            if not WeeklyCommisionPeriod.FindFirst then begin
                WeeklyCommisionPeriod.Init;
                WeeklyCommisionPeriod."AQDEnd Date" := NextPeriod;
                WeeklyCommisionPeriod."AQDStart Date" := PeriodStart;
                WeeklyCommisionPeriod.AQDName := Format(Date2DWY(PeriodStart, 3)) + Text000 + Format(Date2DWY(PeriodStart, 2)) + ' - ' + Format(Date2DWY(NextPeriod, 3)) + Text000 + Format(Date2DWY(NextPeriod, 2));
                WeeklyCommisionPeriod."AQDPeriod Type" := WeeklyCommisionPeriod."AQDPeriod Type"::"Bi-Monthly";
                WeeklyCommisionPeriod.Insert;

                // PreviousPeriod := NextPeriod;
                if NextPeriod = CalcDate('-CM + 14D', NextPeriod) then begin
                    NextPeriod := CalcDate('+CM', NextPeriod);
                    //EndingDate := CALCDATE('+15D',NextPeriod);
                    PeriodStart := CalcDate('-CM + 15D', NextPeriod);
                end else begin
                    PeriodStart := CalcDate('+CM + 1D', NextPeriod);
                    NextPeriod := CalcDate('-CM + 14D', PeriodStart);
                end;
                // END;
                if Periodno = NoOfPeriods then
                    PeriodEnd := NextPeriod;
            end;
        until PeriodEnd = NextPeriod;

        if PeriodEnd = NextPeriod then
            Message('Weekly Periods %1..%2 successfully created', PreviousPeriod, PeriodEnd);
    end;
}

