report 14277041 "AQD Generate Vendor Rebs"
{
    Caption = 'Generate Vendor Rebates';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("AQD Enroll for Rebate" = CONST(true));
            RequestFilterFields = "No.", "Date Filter";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then
                    Window.Update(1, "No.");

                Clear(RebateCalculationMgt);

                Clear(DateArray);
                DateArray[1] := StartPostingDate;
                DateArray[2] := EndPostingDate;
                //Summary
                Clear(SummaryArray);
                SummaryArray[1] := BuyFrom;
                SummaryArray[2] := RespCenter;
                SummaryArray[3] := Location;
                SummaryArray[4] := ShortDim1;
                SummaryArray[5] := ShortDim2;

                RebateCalculationMgt.CalculateRebate(Vendor, DateArray, SummaryArray);
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
        Caption = 'Calculate Rebate';

        layout
        {
            area(Content)
            {
                group("Create Rebate Summary By")
                {
                    Caption = 'Create Rebate Summary By';
                    field(BuyFrom; BuyFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Buy-From Vendor No.';
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
    }

    trigger OnPreReport()
    begin
        StartPostingDate := Vendor.GetRangeMin("Date Filter");
        EndPostingDate := Vendor.GetRangeMax("Date Filter");
    end;

    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
        RebateCalculationMgt: Codeunit "AQD Vendor Rebate Calc. Mgt";
        Text50001: Label 'Vendor No. #1########';
        Text70931: Label 'Please Select Vendor';
        Text70932: Label 'Please Fill in Start Posting Date and End Posting Date';
        Window: Dialog;
        Location: Boolean;
        ShortDim1: Boolean;
        ShortDim2: Boolean;
        BuyFrom: Boolean;
        RespCenter: Boolean;
        SummaryArray: array[5] of Boolean;
        StartPostingDate: Date;
        EndPostingDate: Date;
        DateArray: array[2] of Date;
}

