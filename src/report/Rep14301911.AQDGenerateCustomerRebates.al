report 14301911 "AQD Generate Customer Rebates"
{
    Caption = 'Generate Customer Rebates';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("AQD Enroll for Cust Rebate" = CONST(true));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then
                    Window.Update(1, "No.");

                Clear(RebateCalculationMgt);
                RebateCalculationMgt.CalculateRebate(Customer, false);
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                if GuiAllowed then
                    Window.Open(Text50001);
            end;
        }
    }

    requestpage
    {
        Caption = 'Calculate Customer Rebate';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
        Text50001: Label 'Calculating Rebate for Customer No. #1########';
        Window: Dialog;
}

