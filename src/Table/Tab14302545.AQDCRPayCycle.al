table 14302545 "AQD CR Pay Cycle"
{
    Caption = 'Pay Cycle';
    DataClassification = CustomerContent;
    LookupPageId = "AQD CR Pay Cycles";
    DrillDownPageId = "AQD CR Pay Cycles";

    fields
    {
        field(1; "Cycle Code"; Code[20])
        {
            Caption = 'Cycle Code';
            NotBlank = true;
        }
        field(2; "Start Date"; Date)
        {
            Caption = 'Start Date';
            NotBlank = true;
        }
        field(3; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(4; "Commission Payable Date"; Date)
        {
            Caption = 'Commission Payable Date';
        }
    }

    keys
    {
        key(Key1; "Cycle Code", "Start Date")
        {
            Clustered = true;
        }
        key(Key2; "Cycle Code", "End Date")
        {
        }
    }

    trigger OnInsert()
    begin
        CheckPeriod();
    end;

    trigger OnModify()
    begin
        CheckPeriod();
    end;

    trigger OnRename()
    begin
        CheckPeriod();
    end;

    local procedure CheckPeriod()
    var
        PayCycle: Record "AQD CR Pay Cycle";
        EndBeforeStartErr: Label '%1 must not be before %2.', Comment = '%1 = End Date, %2 = Start Date';
        OverlapErr: Label 'Pay cycle %1..%2 overlaps the existing %3 pay cycle %4..%5.', Comment = '%1 = Start Date, %2 = End Date, %3 = Cycle Code, %4 = Existing Start Date, %5 = Existing End Date';
    begin
        TestField("End Date");
        TestField("Commission Payable Date");
        if "End Date" < "Start Date" then
            Error(EndBeforeStartErr, FieldCaption("End Date"), FieldCaption("Start Date"));

        PayCycle.SetRange("Cycle Code", "Cycle Code");
        PayCycle.SetRange("Start Date", 0D, "End Date");
        PayCycle.SetFilter("End Date", '%1..', "Start Date");
        if PayCycle.FindSet() then
            repeat
                if not IsSameRecord(PayCycle) then
                    Error(OverlapErr, "Start Date", "End Date", "Cycle Code", PayCycle."Start Date", PayCycle."End Date");
            until PayCycle.Next() = 0;
    end;

    local procedure IsSameRecord(PayCycle: Record "AQD CR Pay Cycle"): Boolean
    begin
        if PayCycle."Start Date" = "Start Date" then
            exit(true);
        exit((PayCycle."Cycle Code" = xRec."Cycle Code") and (PayCycle."Start Date" = xRec."Start Date"));
    end;

    procedure GetCommissionPayableDate(CycleCode: Code[20]; PostingDate: Date): Date
    var
        PayCycleNotFoundErr: Label 'No %1 pay cycle covers posting date %2. Generate the pay cycles with the Generate Pay Cycles batch job.', Comment = '%1 = Cycle Code, %2 = Posting Date';
    begin
        Reset();
        SetRange("Cycle Code", CycleCode);
        SetRange("Start Date", 0D, PostingDate);
        SetFilter("End Date", '%1..', PostingDate);
        if not FindLast() then
            Error(PayCycleNotFoundErr, CycleCode, PostingDate);
        exit("Commission Payable Date");
    end;

    procedure GetNextStartDate(CycleCode: Code[20]): Date
    begin
        Reset();
        SetCurrentKey("Cycle Code", "End Date");
        SetRange("Cycle Code", CycleCode);
        if FindLast() then
            exit("End Date" + 1);
        exit(0D);
    end;

    // BIWEEKLY: 14-day periods, End Date = Start Date + 2W - 1D
    procedure CalcEndDate(StartDate: Date): Date
    begin
        exit(CalcDate(PeriodLengthTxt, StartDate) - 1);
    end;

    procedure GetPeriodLength(): Text
    begin
        exit(PeriodLengthTxt);
    end;

    // Keeps the End Date to Commission Payable Date gap of the latest earlier cycle, otherwise the Friday after the period ends (End Date + 5D)
    procedure SuggestPayDate(CycleCode: Code[20]; EndDate: Date): Date
    begin
        Reset();
        SetCurrentKey("Cycle Code", "End Date");
        SetRange("Cycle Code", CycleCode);
        SetFilter("End Date", '..%1', EndDate - 1);
        if FindLast() then
            exit(EndDate + ("Commission Payable Date" - "End Date"));
        exit(CalcDate(PayDateOffsetTxt, EndDate));
    end;

    // Inserts consecutive cycles from StartDate; each Commission Payable Date is one period after the previous one. Returns the last End Date.
    procedure GenerateCycles(CycleCode: Code[20]; StartDate: Date; PayDate: Date; NoOfPeriods: Integer): Date
    var
        PayCycle: Record "AQD CR Pay Cycle";
        PeriodStart: Date;
        PeriodEnd: Date;
        PeriodPayDate: Date;
        i: Integer;
    begin
        PeriodStart := StartDate;
        PeriodPayDate := PayDate;
        for i := 1 to NoOfPeriods do begin
            PeriodEnd := CalcEndDate(PeriodStart);

            PayCycle.Init();
            PayCycle."Cycle Code" := CycleCode;
            PayCycle."Start Date" := PeriodStart;
            PayCycle."End Date" := PeriodEnd;
            PayCycle."Commission Payable Date" := PeriodPayDate;
            PayCycle.Insert(true);

            PeriodStart := PeriodEnd + 1;
            PeriodPayDate := CalcDate(PeriodLengthTxt, PeriodPayDate);
        end;
        exit(PeriodEnd);
    end;

    procedure GetDefaultCycleCode(): Code[20]
    begin
        exit(DefaultCycleCodeTxt);
    end;

    procedure InitDefaultCycleCode()
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        InsertDefaultCycles();

        if not RebateSetup.WritePermission() then
            exit;
        if RebateSetup.Get() then
            if RebateSetup."Default Pay Cycle Code" = '' then begin
                RebateSetup."Default Pay Cycle Code" := DefaultCycleCodeTxt;
                RebateSetup.Modify();
            end;
    end;

    local procedure InsertDefaultCycles()
    var
        PayCycle: Record "AQD CR Pay Cycle";
    begin
        if not PayCycle.WritePermission() then
            exit;
        PayCycle.SetRange("Cycle Code", DefaultCycleCodeTxt);
        if not PayCycle.IsEmpty() then
            exit;
    end;

    var
        DefaultCycleCodeTxt: Label 'BIWEEKLY', Locked = true;
        PeriodLengthTxt: Label '<2W>', Locked = true;
        PayDateOffsetTxt: Label '<5D>', Locked = true;
}
