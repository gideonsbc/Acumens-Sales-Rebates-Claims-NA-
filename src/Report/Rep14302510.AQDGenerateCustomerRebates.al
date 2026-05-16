report 14302510 "AQD Generate Customer Rebates"
{
    Caption = 'Generate and Post Customer Rebates';
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
                CurrentCount += 1;
                IF CurrentCount = TotalCount then
                    LastRecord := TRUE;

                if GuiAllowed then
                    Window.Update(1, "No.");

                Clear(DateArray);
                CustomerRebateSetup.GET;
                IF Customer.GETFILTER("Date Filter") <> '' THEN BEGIN
                    StartPostingDate := Customer.GetRangeMin("Date Filter");
                    EndPostingDate := Customer.GetRangeMax("Date Filter");
                END ELSE begin
                    StartPostingDate := CustomerRebateSetup."Customer Rebate Start Date";
                    //EndPostingDate := DMY2Date(31, 12, Date2DMY(TODAY, 3));
                    //EndPostingDate := Today;
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
                SummaryArray[7] := ByTerritoryCode;

                Clear(RebateCalculationMgt);
                RebateCalculationMgt.CalculateRebate(Customer, DateArray, SummaryArray, false, ShptRcptNo, InvCrMemoNo, CalledFromGenerateCustomerRebate, LastRecord, ProcessCatchUpRebate, RebateProgramCodeFilter, BrokerVendorNo);
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    Window.Close;
                CreatedCustomerRebate.RESET;
                CreatedCustomerRebate.DeleteAll();
            end;

            trigger OnPreDataItem()
            begin
                IF BillToCustomerNo <> '' THEN
                    Customer.SetRange("No.", BillToCustomerNo);

                TotalCount := Customer.COUNT;
                CurrentCount := 0;

                if GuiAllowed then
                    Window.Open(Text50001);

                CreatedCustomerRebate.RESET;
                CreatedCustomerRebate.DeleteAll();
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
                    field(ByTerritoryCode; ByTerritoryCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Territory Code';
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
                group("Catchup Rebate Processing")
                {
                    Caption = 'Catchup Rebate Processing';
                    field("ProcessCatchUpRebate"; ProcessCatchUpRebate)
                    {
                        Caption = 'Process CatchUp Rebate';
                    }
                    field(RebateProgramCode; RebateProgramCodeFilter)
                    {
                        Caption = 'Rebate Program Code Filter';
                        Editable = ProcessCatchUpRebate;
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            RebateProgramCodes: Page "AQD Cust Rebate Program Codes";
                        begin
                            RebateProgramCodes.LOOKUPMODE := TRUE;
                            IF RebateProgramCodes.RUNMODAL = ACTION::LookupOK THEN
                                Text := RebateProgramCodes.GetSelectionFilter
                            ELSE
                                EXIT(false);
                            EXIT(true);
                        end;
                    }
                    field(VendorNo; BrokerVendorNo)
                    {
                        Caption = 'Vendor No. Filter';
                        Editable = ProcessCatchUpRebate;
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Vendors: Page "Vendor List";
                        begin
                            Vendors.LOOKUPMODE := TRUE;
                            IF Vendors.RUNMODAL = ACTION::LookupOK THEN
                                Text := Vendors.GetSelectionFilter
                            ELSE
                                EXIT(false);
                            EXIT(true);
                        end;
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

        if ProcessCatchUpRebate then
            if RebateProgramCodeFilter = '' then
                Error('Please select the Rebate Program Code filter before proceeding.');

    end;

    procedure SetShptRcptNoAndInvCrMemoNo(BillToCustomerNoIn: Code[20]; ShptRcptNoIn: Code[20]; InvCrMemoNoIn: Code[20]; CalledFromGenerateVendorRebateIn: Boolean)
    begin
        BillToCustomerNo := BillToCustomerNoIn;
        ShptRcptNo := ShptRcptNoIn;
        InvCrMemoNo := InvCrMemoNoIn;
        CalledFromGenerateCustomerRebate := CalledFromGenerateVendorRebateIn;
    end;

    var
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        CreatedCustomerRebate: Record "AQD Created Customer Rebate";
        RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
        Text50001: Label 'Calculating Rebate for Customer No. #1########';
        Window: Dialog;
        Location: Boolean;
        ShortDim1: Boolean;
        ShortDim2: Boolean;
        // SellToCust: Boolean;
        // BillToCust: Boolean;
        RespCenter: Boolean;
        ByTerritoryCode: Boolean;
        SummaryArray: array[7] of Boolean;
        StartPostingDate: Date;
        EndPostingDate: Date;
        DateArray: array[2] of Date;
        ShptRcptNo: Code[20];
        InvCrMemoNo: Code[20];
        BillToCustomerNo: Code[20];
        TotalCount: Integer;
        CurrentCount: Integer;
        LastRecord: Boolean;
        CalledFromGenerateCustomerRebate: Boolean;
        ProcessCatchUpRebate: Boolean;
        RebateProgramCodeFilter: Code[20];
        BrokerVendorNo: Code[20];
}