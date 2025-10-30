codeunit 14301920 "AQD Cust Rebate SingleInstance"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CalledFromRebate: Boolean;

    procedure SetCalledFromRebate(CalledFromRebateIn: Boolean)
    begin
        CalledFromRebate := CalledFromRebateIn;
    end;

    procedure GetCalledFromRebate(var CalledFromRebateIn: Boolean)
    begin
        CalledFromRebateIn := CalledFromRebate;
    end;
}

