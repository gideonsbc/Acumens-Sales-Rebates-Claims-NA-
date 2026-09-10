report 14302618 "AQD Collect Commissions"
{
    ApplicationArea = All;
    Caption = 'Generate & Post Commissions';
    ProcessingOnly = true;
    dataset
    {
        dataitem(SalesCommDocHeader; "AQD Sales Comm. Doc. Header")
        {
            RequestFilterFields = "No.", "Sell-To Customer No.";
            DataItemTableView = SORTING("No.") where(Processed = const(false), "Do Not Collect" = const(false));

            trigger OnAfterGetRecord()
            begin
                BilltoCustomerNo := SalesCommDocHeader."Bill-To Customer No.";

                Clear(GenerateCustomerRebate);
                GenerateCustomerRebate.SetShptRcptNoAndInvCrMemoNo(BilltoCustomerNo, '', SalesCommDocHeader."No.", TRUE);
                GenerateCustomerRebate.SetCommissionType(CommissionTypeIn::"Collect Commission");
                GenerateCustomerRebate.UseRequestPage(false);
                GenerateCustomerRebate.Run();
            end;
        }
    }

    var

        GenerateCustomerRebate: Report "AQD Generate Customer Rebates";
        CommissionTypeIn: Enum "AQD CR Commission Type";
        BilltoCustomerNo: Code[20];
}