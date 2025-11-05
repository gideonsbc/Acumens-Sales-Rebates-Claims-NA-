report 14301917 "AQD Post Cust Rebate Batches"
{
    ApplicationArea = All;
    Caption = 'Batch Post Customer Rebates';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("AQD Customer Rebate Batch"; "AQD Customer Rebate Batch")
        {
            RequestFilterFields = "BatchID";
            RequestFilterHeading = 'Customer Rebate Batch';

            trigger OnPreDataItem()
            var
            BEGIN
                "AQD Customer Rebate Batch".SetCurrentKey(BatchID);

                RunBy := RunBy::"Customer Rebate Batch";

                CLEAR(CustomerRebatePostMgt);
                CustomerRebatePostMgt.SetCustomerRebateBatchParameters(RunBy, "AQD Customer Rebate Batch", FALSE);
                CustomerRebatePostMgt.Run();
                CurrReport.Break();
            END;
        }
    }
    var
        CustomerRebatePostMgt: Codeunit "AQD Customer Rebate Post Mgt";
        RunBy: Enum "AQD Customer Rebate Posting";
}