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

            trigger OnPostDataItem()
            begin
                Clear(SummaryArray);
                SummaryArray[1] := RespCenter;
                SummaryArray[2] := Location;
                SummaryArray[3] := ShortDim1;
                SummaryArray[4] := ShortDim2;
                SummaryArray[7] := ByTerritoryCode;

                RebateCalculationMgt.GenerateCustomerRebates(Customer, SummaryArray, false, ShptRcptNo, InvCrMemoNo, CalledFromGenerateCustomerRebate, ProcessCatchUpRebate, RebateProgramCodeFilter, BrokerVendorNo, Window, Text50001);

                if GuiAllowed then
                    Window.Close;

                CreatedCustomerRebate.RESET;
                CreatedCustomerRebate.DeleteAll();
            end;

            trigger OnPreDataItem()
            begin
                IF BillToCustomerNo <> '' THEN
                    Customer.SetRange("No.", BillToCustomerNo);

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
        if ProcessCatchUpRebate then
            if Customer.GETFILTER("Date Filter") = '' then
                Error('Date Filter must have a value. It cannot be zero or empty.');

        CustomerRebateSetup.GET;
        IF Customer.GETFILTER("Date Filter") <> '' THEN BEGIN
            StartPostingDate := Customer.GetRangeMin("Date Filter");
            EndPostingDate := Customer.GetRangeMax("Date Filter");
        END ELSE begin
            StartPostingDate := CustomerRebateSetup."Customer Rebate Start Date";
            EndPostingDate := DMY2Date(31, 12, Date2DMY(WorkDate(), 3));
        end;
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
        RebateProgramCodeFilter: Code[100];
        BrokerVendorNo: Code[100];
}