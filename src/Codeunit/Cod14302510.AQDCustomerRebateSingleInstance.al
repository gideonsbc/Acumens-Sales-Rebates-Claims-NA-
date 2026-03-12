codeunit 14302510 "AQD Cust Rebate SingleInstance"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CalledFromRebate: Boolean;
        ResultMessage: TEXT[250];

    procedure SetCalledFromRebate(CalledFromRebateIn: Boolean)
    begin
        CalledFromRebate := CalledFromRebateIn;
    end;

    procedure GetCalledFromRebate(var CalledFromRebateIn: Boolean)
    begin
        CalledFromRebateIn := CalledFromRebate;
    end;

    procedure SetCustomerRebateBatchResult(ResultMessageIn: text[250])
    begin
        ResultMessage := ResultMessageIn;
    end;

    procedure GetCustomerRebateBatchResult(var ResultMessageIn: text[250])
    begin
        ResultMessageIn := ResultMessage;
    end;
}