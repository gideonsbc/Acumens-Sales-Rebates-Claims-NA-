report 14302613 "AQD Sales History POD"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'Sales History POD';
    Caption = 'Sales History POD';
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './src/Layout/Rep14302613.AQDSalesHistoryPOD.rdlc';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Vendor No.", "Search Description", "Location Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Item_TABLECAPTION__________ItemFilter; Item.TableCaption + ': ' + ItemFilter)
            {
            }
            column(STRSUBSTNO_Text000_DateRange_1__DateRange_2__1_; StrSubstNo(Text000, DateRange[1], DateRange[2] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_2__DateRange_3__1_; StrSubstNo(Text000, DateRange[2], DateRange[3] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_3__DateRange_4__1_; StrSubstNo(Text000, DateRange[3], DateRange[4] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_4__DateRange_5__1_; StrSubstNo(Text000, DateRange[4], DateRange[5] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_5__DateRange_6__1_; StrSubstNo(Text000, DateRange[5], DateRange[6] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_6__DateRange_7__1_; StrSubstNo(Text000, DateRange[6], DateRange[7] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_7__DateRange_8__1_; StrSubstNo(Text000, DateRange[7], DateRange[8] - 1))
            {
            }
            column(STRSUBSTNO_Text000_DateRange_8__DateRange_9__1_; StrSubstNo(Text000, DateRange[8], DateRange[9] - 1))
            {
            }
            column(Item__No__; "No.")
            {
            }
            column(Item_Description; Description)
            {
            }
            column(Item__Base_Unit_of_Measure_; "Base Unit of Measure")
            {
            }
            column(QuantitySold_1_; QuantitySold[1])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_2_; QuantitySold[2])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_3_; QuantitySold[3])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_4_; QuantitySold[4])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_5_; QuantitySold[5])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_6_; QuantitySold[6])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_7_; QuantitySold[7])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_8_; QuantitySold[8])
            {
                DecimalPlaces = 0 : 5;
            }
            column(PODAmount_1_; PODAmount[1])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_2_; PODAmount[2])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_3_; PODAmount[3])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_4_; PODAmount[4])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_5_; PODAmount[5])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_6_; PODAmount[6])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_7_; PODAmount[7])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_8_; PODAmount[8])
            {
                DecimalPlaces = 2 : 2;
            }
            column(LastDirectCostByLocation; LastDirectCostByLocation)
            {
            }
            column(ContractPrice; ContractPrice)
            {
            }
            column(PODAmount_7__Control1000000021; PODAmount[7])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_8__Control1000000022; PODAmount[8])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_6__Control1000000023; PODAmount[6])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_5__Control1000000024; PODAmount[5])
            {
                DecimalPlaces = 2 : 2;
            }
            column(PODAmount_4__Control1000000025; PODAmount[4])
            {
                DecimalPlaces = 2 : 2;
            }
            column(QuantitySold_4__Control1000000026; QuantitySold[4])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_5__Control1000000027; QuantitySold[5])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_6__Control1000000028; QuantitySold[6])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_7__Control1000000029; QuantitySold[7])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_8__Control1000000030; QuantitySold[8])
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantitySold_3__Control1000000031; QuantitySold[3])
            {
                DecimalPlaces = 0 : 5;
            }
            column(PODAmount_3__Control1000000032; PODAmount[3])
            {
                DecimalPlaces = 2 : 2;
            }
            column(QuantitySold_2__Control1000000040; QuantitySold[2])
            {
                DecimalPlaces = 0 : 5;
            }
            column(PODAmount_2__Control1000000041; PODAmount[2])
            {
                DecimalPlaces = 2 : 2;
            }
            column(QuantitySold_1__Control1000000042; QuantitySold[1])
            {
                DecimalPlaces = 0 : 5;
            }
            column(PODAmount_1__Control1000000043; PODAmount[1])
            {
                DecimalPlaces = 2 : 2;
            }
            column(Sales_HistoryCaption; Sales_HistoryCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Items_with_no_sales_during_these_time_periods_are_not_included_Caption; Items_with_no_sales_during_these_time_periods_are_not_included_CaptionLbl)
            {
            }
            column(Item__No__Caption; FieldCaption("No."))
            {
            }
            column(POD_RefundCaption; POD_RefundCaptionLbl)
            {
            }
            column(POD_RefundCaption_Control1000000000; POD_RefundCaption_Control1000000000Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000009; POD_RefundCaption_Control1000000009Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000011; POD_RefundCaption_Control1000000011Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000012; POD_RefundCaption_Control1000000012Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000013; POD_RefundCaption_Control1000000013Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000014; POD_RefundCaption_Control1000000014Lbl)
            {
            }
            column(POD_RefundCaption_Control1000000015; POD_RefundCaption_Control1000000015Lbl)
            {
            }
            column(Item__Base_Unit_of_Measure_Caption; Item__Base_Unit_of_Measure_CaptionLbl)
            {
            }
            column(Qty_SoldCaption; Qty_SoldCaptionLbl)
            {
            }
            column(Last_Direct_CostCaption; Last_Direct_CostCaptionLbl)
            {
            }
            column(ContractPriceCaption; ContractPriceCaptionLbl)
            {
            }
            column(Refund_Amount__Caption; Refund_Amount__CaptionLbl)
            {
            }
            column(Total_Caption; Total_CaptionLbl)
            {
            }
            column(Qty_SoldCaption_Control1000000045; Qty_SoldCaption_Control1000000045Lbl)
            {
            }
            column(Refund_Amount__Caption_Control1000000046; Refund_Amount__Caption_Control1000000046Lbl)
            {
            }
            column(OnlyItemsWithSales_; OnlyItemsWithSales)
            {
            }

            trigger OnAfterGetRecord()
            begin
                PrintLine := false;
                Clear(QuantitySold);
                Clear("$Sold");
                Clear("Profit%");
                Clear(QuantitySoldPRYR);

                ContractPrice := "AQD Contract Price";

                FoundLastDirectCost := false;
                LastDirectCostByLocation := 0;
                PurchInvLine.Reset();
                PurchInvLine.SetCurrentKey("Posting Date");
                PurchInvLine.Ascending(false);
                PurchInvLine.SetRange("Posting Date", 0D, MonthEndDate);
                PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                PurchInvLine.SetRange("No.", "No.");
                PurchInvLine.SetFilter(Quantity, '<>0');

                if PurchInvLine.FindSet() then
                    repeat

                        if (Item.GetFilter("Location Filter") = 'CA') or
                           (Item.GetFilter("Location Filter") = 'LA') or
                           (ContractType = ContractType::"Contract Price CA")
                        then begin
                            if SKU.Get('CA', Item."No.", '') then begin
                                LastDirectCostByLocation := SKU."Last Direct Cost";
                                if PurchInvLine."Direct Unit Cost" <> 0 then begin
                                    LastDirectCostByLocation := PurchInvLine."Direct Unit Cost";
                                    FoundLastDirectCost := true;
                                end;
                            end;
                        end;

                        if (Item.GetFilter("Location Filter") = 'AZ') or
                           (ContractType = ContractType::"Contract Price AZ")
                        then begin
                            if SKU.Get('AZ', Item."No.", '') then begin
                                LastDirectCostByLocation := SKU."Last Direct Cost";
                                if PurchInvLine."Direct Unit Cost" <> 0 then begin
                                    LastDirectCostByLocation := PurchInvLine."Direct Unit Cost";
                                    FoundLastDirectCost := true;
                                end;
                            end;
                        end;

                    until (PurchInvLine.Next() = 0) or FoundLastDirectCost;

                ContractPrice := "AQD Contract Price";

                Clear(PODAmount);
                for i := 1 to ArrayLen(QuantitySold) do begin
                    SetRange("Date Filter", DateRange[i], DateRange[i + 1] - 1);
                    CalcFields("Sales (Qty.)", "Sales (LCY)", "COGS (LCY)");
                    if "Sales (Qty.)" <> 0 then begin
                        QuantitySold[i] := "Sales (Qty.)";
                        "$Sold"[i] := "Sales (LCY)";
                        Profit := "Sales (LCY)" - "COGS (LCY)";
                        if "Sales (LCY)" <> 0 then begin
                            "Profit%"[i] := Round(Profit / "Sales (LCY)" * 100, 0.1);
                            PrintLine := true;
                        end else
                            "Profit%"[i] := 0;
                        SetRange("Date Filter", PriorYRMin[i], PriorYRMax[i]);
                        CalcFields("Sales (Qty.)");
                        QuantitySoldPRYR[i] := "Sales (Qty.)";
                        if ContractPrice <> 0 then
                            PODAmount[i] := QuantitySold[i] * (LastDirectCostByLocation - ContractPrice);
                    end;
                end;

                if (not PrintLine) and (OnlyItemsWithSales) then
                    CurrReport.Skip;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrevMonthEndDate; PrevMonthEndDate)
                    {
                        Caption = 'Direct Cost As of';
                        ApplicationArea = All;
                    }
                    field("DateRange[1]"; DateRange[1])
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                    }
                    field(TimeDivision; TimeDivision)
                    {
                        Caption = 'Length of Period (eg 1M,2W,29D)';
                        ApplicationArea = All;
                    }
                    field(OnlyItemsWithSales; OnlyItemsWithSales)
                    {
                        Caption = 'Only Items with Sales';
                        ApplicationArea = All;
                    }
                    field(ContractType; ContractType)
                    {
                        Caption = 'Contract Price Type';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if DateRange[1] = 0D then
                DateRange[1] := WorkDate;
            if TimeDivision = '' then
                TimeDivision := '1M';

            if PrevMonthEndDate = 0D then begin
                PrevMonthEndDate := CalcDate('CM', Today);
                PrevMonthEndDate := CalcDate('-1M', PrevMonthEndDate);
                PrevMonthEndDate := CalcDate('CM', PrevMonthEndDate);
            end;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        ItemFilter := Item.GetFilters;
        for i := 2 to ArrayLen(DateRange) do
            DateRange[i] := CalcDate(TimeDivision, DateRange[i - 1]);
        for i := 1 to ArrayLen(PriorYRMin) do begin
            PriorYRMin[i] := CalcDate('<-1Y>', DateRange[i]);
            PriorYRMax[i] := CalcDate('<-1Y>', DateRange[i + 1]) - 1;
        end;

        MonthEndDate := CalcDate('CM', PrevMonthEndDate);

        ReportExecutionStartTime := TIME;
    end;

    trigger OnPostReport()
    begin
        ReportExecutionEndTime := TIME;
        IF GUIALLOWED THEN
            MESSAGE('Start Time %1\End Time %2', ReportExecutionStartTime, ReportExecutionEndTime);
    end;

    var
        CompanyInformation: Record "Company Information";
        OnlyItemsWithSales: Boolean;
        TimeDivision: Code[10];
        ItemFilter: Text[1000];
        DateRange: array[9] of Date;
        PriorYRMin: array[8] of Date;
        PriorYRMax: array[8] of Date;
        QuantitySold: array[8] of Decimal;
        "$Sold": array[8] of Decimal;
        "Profit%": array[8] of Decimal;
        QuantitySoldPRYR: array[8] of Decimal;
        Profit: Decimal;
        i: Integer;
        PrintLine: Boolean;
        Text000: Label '%1 thru %2';
        PODAmount: array[8] of Decimal;
        ContractType: Option "Contract Price CA","Contract Price AZ";
        ContractPrice: Decimal;
        LastDirectCostByLocation: Decimal;
        SKU: Record "Stockkeeping Unit";
        PrevMonthEndDate: Date;
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        FoundLastDirectCost: Boolean;
        MonthEndDate: Date;
        Sales_HistoryCaptionLbl: Label 'Sales History';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Items_with_no_sales_during_these_time_periods_are_not_included_CaptionLbl: Label 'Items with no sales during these time periods are not included.';
        POD_RefundCaptionLbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000000Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000009Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000011Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000012Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000013Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000014Lbl: Label 'POD Refund';
        POD_RefundCaption_Control1000000015Lbl: Label 'POD Refund';
        Item__Base_Unit_of_Measure_CaptionLbl: Label 'Unit of Measure:';
        Qty_SoldCaptionLbl: Label 'Qty Sold';
        Last_Direct_CostCaptionLbl: Label 'Last Direct Cost';
        ContractPriceCaptionLbl: Label 'Contract Price';
        Refund_Amount__CaptionLbl: Label 'Refund Amount $';
        Total_CaptionLbl: Label 'Total:';
        Qty_SoldCaption_Control1000000045Lbl: Label 'Qty Sold';
        Refund_Amount__Caption_Control1000000046Lbl: Label 'Refund Amount $';
        ReportExecutionStartTime: Time;
        ReportExecutionEndTime: Time;
}

