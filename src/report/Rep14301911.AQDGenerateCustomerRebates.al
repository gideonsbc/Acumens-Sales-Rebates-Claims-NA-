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
            RequestFilterFields = "No.", "Date Filter";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then
                    Window.Update(1, "No.");

                Clear(DateArray);
                DateArray[1] := Customer.GetRangeMin("Date Filter");
                DateArray[2] := Customer.GetRangeMax("Date Filter");

                //Summary
                Clear(SummaryArray);
                SummaryArray[1] := SellToCust;
                SummaryArray[2] := RespCenter;
                SummaryArray[3] := Location;
                SummaryArray[4] := ShortDim1;
                SummaryArray[5] := ShortDim2;

                Clear(RebateCalculationMgt);
                RebateCalculationMgt.CalculateRebate(Customer, DateArray, SummaryArray, false);
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
            area(Content)
            {
                group("Create Rebate Summary By")
                {
                    Caption = 'Create Rebate Summary By';
                    field(SellToCust; SellToCust)
                    {
                        ApplicationArea = All;
                        Caption = 'Sell-To Customer No.';
                    }
                    field(RespCenter; RespCenter)
                    {
                        ApplicationArea = All;
                        Caption = 'Responsibility Center';
                    }
                    field(Location; Location)
                    {
                        ApplicationArea = All;
                        Caption = 'Location Code';
                    }
                    field(ShortDim1; ShortDim1)
                    {
                        ApplicationArea = All;
                        CaptionClass = '1,2,1';
                        Caption = 'Shortcut Dimension 1 Code';
                    }
                    field(ShortDim2; ShortDim2)
                    {
                        ApplicationArea = All;
                        CaptionClass = '1,2,2';
                        Caption = 'Shortcut Dimension 2 Code';
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
        RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
        Text50001: Label 'Calculating Rebate for Customer No. #1########';
        Window: Dialog;
        Location: Boolean;
        ShortDim1: Boolean;
        ShortDim2: Boolean;
        SellToCust: Boolean;
        RespCenter: Boolean;
        SummaryArray: array[5] of Boolean;
        StartPostingDate: Date;
        EndPostingDate: Date;
        DateArray: array[2] of Date;
}

