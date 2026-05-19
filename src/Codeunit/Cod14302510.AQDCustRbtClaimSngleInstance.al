codeunit 14302510 "AQD CustRbtClaim SngleInstance"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CalledFromRebate: Boolean;
        CalledFromSalesOrderPosting: Boolean;
        ResultMessage: TEXT[250];
        SuppressConfirm: Boolean;

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

    procedure SetCustomerClaimBatchResult(ResultMessageIn: text[250])
    begin
        ResultMessage := ResultMessageIn;
    end;

    procedure GetCustomerClaimBatchResult(var ResultMessageIn: text[250])
    begin
        ResultMessageIn := ResultMessage;
    end;

    procedure SetCalledFromSalesOrderPosting(CalledFromSalesOrderPostingIn: Boolean)
    begin
        CalledFromSalesOrderPosting := CalledFromSalesOrderPostingIn;
    end;

    procedure GetCalledFromSalesOrderPosting(var CalledFromSalesOrderPostingIn: Boolean)
    begin
        CalledFromSalesOrderPostingIn := CalledFromSalesOrderPosting;
    end;

    procedure SetSuppressConfirm(SuppressConfirmIn: Boolean)
    begin
        SuppressConfirm := SuppressConfirmIn;
    end;

    procedure GetConfirmSuppressed(): Boolean
    begin
        exit(SuppressConfirm);
    end;
}