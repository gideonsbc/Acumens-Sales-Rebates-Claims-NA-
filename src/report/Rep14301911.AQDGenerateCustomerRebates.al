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
                CustomerRebateSetup.GET;
                IF Customer.GETFILTER("Date Filter") <> '' THEN BEGIN
                    StartPostingDate := Customer.GetRangeMin("Date Filter");
                    EndPostingDate := Customer.GetRangeMax("Date Filter");
                END ELSE begin
                    StartPostingDate := CustomerRebateSetup."Customer Rebate Start Date";
                    EndPostingDate := DMY2Date(31, 12, Date2DMY(TODAY, 3));
                end;
                DateArray[1] := StartPostingDate;
                DateArray[2] := EndPostingDate;

                //Summary
                Clear(SummaryArray);
                //SummaryArray[1] := SellToCust;
                // SummaryArray[2] := RespCenter;
                // SummaryArray[3] := Location;
                // SummaryArray[4] := ShortDim1;
                // SummaryArray[5] := ShortDim2;
                // SummaryArray[6] := BillToCust;

                SummaryArray[1] := RespCenter;
                SummaryArray[2] := Location;
                SummaryArray[3] := ShortDim1;
                SummaryArray[4] := ShortDim2;

                Clear(RebateCalculationMgt);
                RebateCalculationMgt.CalculateRebate(Customer, DateArray, SummaryArray, false, ShptRcptNo, InvCrMemoNo);
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
                    // field(SellToCust; SellToCust)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Sell-To Customer No.';
                    //     trigger OnValidate()
                    //     begin
                    //         BillToCust := SellToCust;
                    //     end;
                    // }
                    // field(BillToCust; BillToCust)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Bill-To Customer No.';
                    //     Editable = NOT SellToCust;
                    // }
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
    trigger OnPreReport()
    begin
        CustomerRebateSetup.GET;
        IF Customer.GETFILTER("Date Filter") <> '' THEN BEGIN
            StartPostingDate := Customer.GetRangeMin("Date Filter");
            EndPostingDate := Customer.GetRangeMax("Date Filter");
        END ELSE begin
            StartPostingDate := CustomerRebateSetup."Customer Rebate Start Date";
            EndPostingDate := DMY2Date(31, 12, Date2DMY(TODAY, 3));
        end;
    end;

    procedure SetShptRcptNoAndInvCrMemoNo(ShptRcptNoIn: Code[20]; InvCrMemoNoIn: Code[20])
    begin
        ShptRcptNo := ShptRcptNoIn;
        InvCrMemoNo := InvCrMemoNoIn;
    end;

    var
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
        Text50001: Label 'Calculating Rebate for Customer No. #1########';
        Window: Dialog;
        Location: Boolean;
        ShortDim1: Boolean;
        ShortDim2: Boolean;
        // SellToCust: Boolean;
        // BillToCust: Boolean;
        RespCenter: Boolean;
        SummaryArray: array[6] of Boolean;
        StartPostingDate: Date;
        EndPostingDate: Date;
        DateArray: array[2] of Date;
        ShptRcptNo: Code[20];
        InvCrMemoNo: Code[20];
}