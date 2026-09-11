report 14302516 "AQD Post Customer Rebates"
{
    ApplicationArea = All;
    Caption = 'Post Customer Rebates';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    Permissions = tabledata "AQD Customer Rebate Header" = RIMD,
        tabledata "AQD Customer Rebate Line" = RIMD,
        tabledata "AQD Customer Rebate Details" = RIMD,
        tabledata "AQD Customer Rebate Comments" = RIMD,
        tabledata "AQD Posted Cust Rebate Header" = RIMD,
        tabledata "AQD Posted Cust Rebate Line" = RIMD,
        tabledata "AQD Posted Cust Reb Details" = RIMD,
        tabledata "AQD Posted Cust Rebate Batch" = RIMD,
        tabledata "Sales Header" = RIMD,
        tabledata "Gen. Journal Line" = RIMD;

    dataset
    {
        dataitem(CustomerRebateHeader; "AQD Customer Rebate Header")
        {
            DataItemTableView = sorting("No.");

            trigger OnPreDataItem()
            begin
                RunBy := RunBy::"Auto Process Customer Rebate";
                SetRange(Preview, false);
                SetRange("AQD Last Processing Error Msg", '');
            end;

            trigger OnAfterGetRecord()
            begin
                ClearLastError();
                Clear(CustomerRebatePost);
                CustomerRebatePost.SetCustomerRebateParameters(RunBy, CustomerRebateHeader, false);

                if not CustomerRebatePost.Run() then begin
                    CustomerRebateHeader.Get(CustomerRebateHeader."No.");
                    CustomerRebateHeader."AQD Last Processing Error Msg" :=
                        CopyStr(GetLastErrorText(), 1, MaxStrLen(CustomerRebateHeader."AQD Last Processing Error Msg"));
                    CustomerRebateHeader.Modify();
                end;
            end;
        }
    }

    var
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        RunBy: Enum "AQD Customer Rebate Posting";
}