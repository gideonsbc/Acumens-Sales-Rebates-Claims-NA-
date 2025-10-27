report 14277043 "AQD Vendor Rebate Forecast"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Forecast';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.") where("AQD Enroll for Rebate" = CONST(true));

            trigger OnPreDataItem()
            begin
                TempVendorForCastBuffer.Reset();
                if TempVendorForCastBuffer.IsTemporary then
                    TempVendorForCastBuffer.DeleteAll();

                if StartYear = 0 then
                    Error('Start year must not be blank');

                if PurchaseMultiplier = 0 then
                    Error('Purchase Multiplier must not be blank');

                StartYearStartingDate := DMY2Date(01, 01, StartYear);
                StartYearEndingDate := CalcDate('<CY>', StartYearStartingDate);

                OpenWindow(Text001);
            end;

            trigger OnAfterGetRecord()
            var
                RunningYear: Integer;
                StartDatesforThisPeriod: array[12] of Date;
                DataType: Option Actual,Forecast;
            begin
                VendorRebate.Reset();
                VendorRebate.SetCurrentKey("Posting Date");//Sort by Posting date

                //Filter based on Run By
                case RunBy of
                    RunBy::"Buy-From Vendor":
                        VendorRebate.SetRange("Buy-from Vendor No.", Vendor."No.");
                    RunBy::"Pay-To Vendor":
                        VendorRebate.SetRange("Pay-to Vendor No.", Vendor."No.");
                end;

                VendorRebate.SetFilter("Posting Date", '>=%1', StartYearStartingDate);//Filter by Rebate Posting Date
                if VendorRebate.FindFirst() then begin
                    repeat
                        VendorRebateLine.Reset();
                        VendorRebateLine.SetRange("Rebate No.", VendorRebate."No.");
                        //  VendorRebateLine.SetRange("Buy-from Vendor No.", VendorRebate."Buy-from Vendor No.");
                        if VendorRebateLine.FindFirst() then
                            repeat
                                UpdateWindow(1, VendorRebate."Pay-to Vendor No.");

                                RunningYear := Date2DMY(VendorRebate."Posting Date", 3);
                                GetMonthsforThisPeriod(RunningYear, StartDatesforThisPeriod);

                                //  VendorRebateLine.CalcFields("Vendor Rebate Amount");//is a flowfield

                                GenerateTempActualData(VendorRebateLine, StartDatesforThisPeriod, RunningYear, DataType::Actual);//Generate Actual Entries
                                GenerateDataforMissingYears(Vendor);

                                if (RunningYear > StartYear) or (Date2DMY(Today, 3) = StartYear) then
                                    GenerateTempForecastData(VendorRebateLine, StartDatesforThisPeriod, RunningYear, DataType::Forecast, False)//Generate Forecast Entries
                                else if (RunningYear = StartYear) and (Date2DMY(Today, 3) > StartYear) then begin
                                    GetMonthsforThisPeriod(RunningYear + 1, StartDatesforThisPeriod);
                                    GenerateTempForecastData(VendorRebateLine, StartDatesforThisPeriod, RunningYear, DataType::Forecast, True)//Generate Forecast Entries

                                end;


                            until VendorRebateLine.Next() = 0;
                    until VendorRebate.Next() = 0;


                end;

            end;

            trigger OnPostDataItem()
            var
                VendorNo: Code[20];
                ShowVendor: Boolean;
            begin
                RecordCount := 0;

                ExcelBuf.Reset();
                ExcelBuf.DeleteAll();
                ExcelBuf.CreateNewBook(SheetName);

                TempVendorForCastBuffer.Reset();
                TempVendorForCastBuffer.SetCurrentKey("Buy-from Vendor No.", Year);
                if TempVendorForCastBuffer.FindFirst() then
                    repeat
                        ShowVendor := false;
                        if TempVendorForCastBuffer."Buy-from Vendor No." <> VendorNo then begin
                            ShowVendor := true;
                            VendorNo := TempVendorForCastBuffer."Buy-from Vendor No.";
                        end;
                        UpdateWindow(2, 'Generating Excel: ' + TempVendorForCastBuffer."Buy-from Vendor No.");
                        InserttoExcel(TempVendorForCastBuffer, ShowVendor);
                        RecordCount += 1;
                    until TempVendorForCastBuffer.Next() = 0;

                CloseWindow();

                if RecordCount > 0 then
                    CreateExcelbook()
                else
                    Message('There was no Vendor Rebate records within the specified year');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(StartYear; StartYear)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Year';
                        BlankZero = true;
                        trigger OnValidate()
                        var
                            StartYeartxt: Text[4];
                        begin
                            StartYeartxt := Format(StartYear);
                            IsaValidateYear(StartYeartxt);
                            if StartYeartxt <> '' then
                                Evaluate(StartYear, StartYeartxt);
                        end;
                    }
                    field(PurchaseMultiplier; PurchaseMultiplier)
                    {
                        ApplicationArea = All;
                        Caption = 'Purchase Multiplier';
                        DecimalPlaces = 0 : 2;
                        BlankZero = true;
                    }
                    field(RunBy; RunBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Run By';
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction in [CloseAction::OK, CloseAction::LookupOK, CloseAction::Yes] then begin
                if StartYear = 0 then
                    Error('Start year must not be blank');

                if PurchaseMultiplier = 0 then
                    Error('Purchase Multiplier must not be blank');
            end;
        end;
    }

    var
        StartYear: Integer;
        PurchaseMultiplier: Decimal;
        RunBy: Option "Pay-To Vendor","Buy-From Vendor";
        StartYearStartingDate: Date;
        StartYearEndingDate: Date;
        VendorRebate: Record "AQD Posted Vend Rebate Header";
        VendorRebateLine: Record "AQD Posted Vend Rebate Line";
        TempVendorForCastBuffer: Record "Vendor Rebate Buffer" temporary;
        Window: Dialog;
        ExcelBuf: Record "Excel Buffer" temporary;
        SheetName: Label 'Forecast';
        FileHeaderInserted: Boolean;
        RecordCount: Integer;
        Text001: Label 'Calculating Forecast...\Vendor No: #1##\#2###';

    procedure IsaValidateYear(var Year: Text[4])
    var
        TestYear: Integer;
        i: Integer;
        TypeHelper: Codeunit "Type Helper";
    begin
        if Year <> '' then begin
            if (StrLen(Year) <> 4) and (StrLen(Year) <> 2) then
                Error(Year + ' is not a valid Year.');

            if (StrLen(Year) = 2) then
                Year := '20' + Year;//Allow user to enter the last two Numbers then autocomplete

            if not (CopyStr(Year, 1, 2) in ['19', '20']) then
                Error(Year + ' is not a valid Year.');

            if Not TypeHelper.IsNumeric(Year) then
                Error(Year + ' is not a valid number. The value must be an interger');

            if not Evaluate(TestYear, Year) then
                Error(Year + ' is not a valid number. The value must be an interger');
        end;
    end;

    procedure GetMonthsforThisPeriod(RunningYear: Integer; var StartDatesforThisPeriod: array[12] of Date)
    begin
        if RunningYear = 0 then
            Error('Posting date must not be blank on ' + VendorRebate.TableCaption);

        Clear(StartDatesforThisPeriod);

        StartDatesforThisPeriod[1] := DMY2Date(01, 01, RunningYear);//January
        StartDatesforThisPeriod[2] := DMY2Date(01, 02, RunningYear);//February
        StartDatesforThisPeriod[3] := DMY2Date(01, 03, RunningYear);//March
        StartDatesforThisPeriod[4] := DMY2Date(01, 04, RunningYear);//April
        StartDatesforThisPeriod[5] := DMY2Date(01, 05, RunningYear);//May
        StartDatesforThisPeriod[6] := DMY2Date(01, 06, RunningYear);//June
        StartDatesforThisPeriod[7] := DMY2Date(01, 07, RunningYear);//July
        StartDatesforThisPeriod[8] := DMY2Date(01, 08, RunningYear);//August
        StartDatesforThisPeriod[9] := DMY2Date(01, 09, RunningYear);//September
        StartDatesforThisPeriod[10] := DMY2Date(01, 10, RunningYear);//October
        StartDatesforThisPeriod[11] := DMY2Date(01, 11, RunningYear);//November
        StartDatesforThisPeriod[12] := DMY2Date(01, 12, RunningYear);//December
    end;

    local procedure GenerateTempActualData(var VendorRebateLine: Record "AQD Posted Vend Rebate Line"; var StartDatesforThisPeriod: array[12] of Date; var RunningYear: Integer; DataType: Option Actual,Forecast)
    var
        Vendor: Record Vendor;
    begin
        VendorRebateLine.CalcFields("Vendor Rebate Amount");//is a flowfield
        TempVendorForCastBuffer.Reset();
        TempVendorForCastBuffer.SetRange("Buy-from Vendor No.", VendorRebate."Buy-from Vendor No.");
        TempVendorForCastBuffer.SetRange(Year, RunningYear);
        TempVendorForCastBuffer.SetRange("Data Type", DataType);
        if not TempVendorForCastBuffer.FindFirst() then begin//insert
            TempVendorForCastBuffer.Reset();//remove filters
            TempVendorForCastBuffer.Init();
            TempVendorForCastBuffer.Year := RunningYear;
            TempVendorForCastBuffer."Data Type" := DataType;//Actual for Non Forecast lines
            TempVendorForCastBuffer."Buy-from Vendor No." := VendorRebate."Buy-from Vendor No.";
            if Vendor.get(VendorRebate."Buy-from Vendor No.") then
                TempVendorForCastBuffer."Buy-from Vendor Name" := Vendor.Name
            else
                TempVendorForCastBuffer."Buy-from Vendor Name" := VendorRebate."Buy-from Vendor Name";
            TempVendorForCastBuffer."Posting Date" := VendorRebate."Posting Date";//This is rebate posting date. Not document Posting Date
            TempVendorForCastBuffer."Pay-to Vendor No." := VendorRebate."Pay-to Vendor No.";
            TempVendorForCastBuffer."Pay-to Vendor Name" := VendorRebate."Pay-to Name";

            if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[1]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[1])) then//January
            begin
                TempVendorForCastBuffer."January Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."January Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[2]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[2])) then // February
            begin
                TempVendorForCastBuffer."February Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."February Rebate" := VendorRebateLine."Vendor Rebate Amount";

            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[3]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[3])) then //March
            begin
                TempVendorForCastBuffer."March Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."March Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[4]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[4])) then //March
            begin
                TempVendorForCastBuffer."April Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."April Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[5]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[5])) then //March
            begin
                TempVendorForCastBuffer."May Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."May Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[6]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[6])) then //March
            begin
                TempVendorForCastBuffer."June Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."June Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end
            else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[7]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[7])) then //March
            begin
                TempVendorForCastBuffer."July Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."July Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[8]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[8])) then //March
            begin
                TempVendorForCastBuffer."August Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."August Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[9]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[9])) then //March
            begin
                TempVendorForCastBuffer."September Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."September Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[10]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[10])) then //March
            begin
                TempVendorForCastBuffer."October Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."October Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[11]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[11])) then //March
            begin
                TempVendorForCastBuffer."November Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."November Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[12]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[12])) then //March
            begin
                TempVendorForCastBuffer."December Purchases" := VendorRebateLine.Amount;
                TempVendorForCastBuffer."December Rebate" := VendorRebateLine."Vendor Rebate Amount";
            end;

            TempVendorForCastBuffer.Insert();

        end else begin//modify
            if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[1]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[1])) then//January
              begin
                TempVendorForCastBuffer."January Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."January Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[2]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[2])) then // February
            begin
                TempVendorForCastBuffer."February Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."February Rebate" += VendorRebateLine."Vendor Rebate Amount";

            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[3]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[3])) then //March
            begin
                TempVendorForCastBuffer."March Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."March Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[4]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[4])) then //April
            begin
                TempVendorForCastBuffer."April Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."April Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[5]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[5])) then //May
            begin
                TempVendorForCastBuffer."May Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."May Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[6]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[6])) then //June
            begin
                TempVendorForCastBuffer."June Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."June Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end
            else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[7]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[7])) then //July
            begin
                TempVendorForCastBuffer."July Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."July Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[8]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[8])) then //August
            begin
                TempVendorForCastBuffer."August Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."August Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[9]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[9])) then //September
            begin
                TempVendorForCastBuffer."September Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."September Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[10]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[10])) then //October
            begin
                TempVendorForCastBuffer."October Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."October Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[11]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[11])) then //November
            begin
                TempVendorForCastBuffer."November Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."November Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end else if (VendorRebateLine."Posting Date" >= StartDatesforThisPeriod[12]) and (VendorRebateLine."Posting Date" <= CalcDate('CM', StartDatesforThisPeriod[12])) then //December
            begin
                TempVendorForCastBuffer."December Purchases" += VendorRebateLine.Amount;
                TempVendorForCastBuffer."December Rebate" += VendorRebateLine."Vendor Rebate Amount";
            end;

            TempVendorForCastBuffer.Modify();
        end;
    end;

    local procedure GenerateTempForecastData(var VendorRebateLine: Record "AQD Posted Vend Rebate Line"; var StartDatesforThisPeriod: array[12] of Date; var RunningYear: Integer; DataType: Option Actual,Forecast; UsePreviousYearData: Boolean)
    var
        TempVendorForCastBuffer_lv: Record "Vendor Rebate Buffer" temporary;
        Vendor: Record Vendor;
    begin
        TempVendorForCastBuffer.Reset();//Remove any filters from Main Temp Variable

        //>> Get Original Entry
        TempVendorForCastBuffer_lv.Reset();
        TempVendorForCastBuffer_lv.DeleteAll();
        TempVendorForCastBuffer_lv.Copy(TempVendorForCastBuffer, true);

        TempVendorForCastBuffer_lv.Reset();
        TempVendorForCastBuffer_lv.SetRange("Buy-from Vendor No.", VendorRebate."Buy-from Vendor No.");
        TempVendorForCastBuffer_lv.SetRange(Year, StartYear);
        TempVendorForCastBuffer_lv.SetRange("Data Type", TempVendorForCastBuffer_lv."Data Type"::Actual);
        if TempVendorForCastBuffer_lv.FindFirst() then begin//<< Get Original Entry   
            //insert its forecast                        
            TempVendorForCastBuffer.Reset();
            TempVendorForCastBuffer.SetRange("Buy-from Vendor No.", VendorRebate."Buy-from Vendor No.");
            if UsePreviousYearData then
                TempVendorForCastBuffer.SetRange(Year, RunningYear + 1)
            else
                TempVendorForCastBuffer.SetRange(Year, RunningYear);
            TempVendorForCastBuffer.SetRange("Data Type", DataType);
            if not TempVendorForCastBuffer.FindFirst() then begin//insert
                TempVendorForCastBuffer.Reset();//remove filters
                TempVendorForCastBuffer.Init();
                if UsePreviousYearData then
                    TempVendorForCastBuffer.Year := RunningYear + 1
                else
                    TempVendorForCastBuffer.Year := RunningYear;
                TempVendorForCastBuffer."Data Type" := DataType;
                TempVendorForCastBuffer."Buy-from Vendor No." := VendorRebate."Buy-from Vendor No.";
                if Vendor.get(VendorRebate."Buy-from Vendor No.") then
                    TempVendorForCastBuffer."Buy-from Vendor Name" := Vendor.Name
                else
                    TempVendorForCastBuffer."Buy-from Vendor Name" := VendorRebate."Buy-from Vendor Name";
                TempVendorForCastBuffer."Posting Date" := VendorRebate."Posting Date";//This is rebate posting date. Not document Posting Date
                TempVendorForCastBuffer."Pay-to Vendor No." := VendorRebate."Pay-to Vendor No.";
                TempVendorForCastBuffer."Pay-to Vendor Name" := VendorRebate."Pay-to Name";
                //January
                TempVendorForCastBuffer."January Purchases" := TempVendorForCastBuffer_lv."January Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."January Rebate" := TempVendorForCastBuffer_lv."January Rebate" * PurchaseMultiplier;

                //February
                TempVendorForCastBuffer."February Purchases" := TempVendorForCastBuffer_lv."February Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."February Rebate" := TempVendorForCastBuffer_lv."February Rebate" * PurchaseMultiplier;

                //March
                TempVendorForCastBuffer."March Purchases" := TempVendorForCastBuffer_lv."March Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."March Rebate" := TempVendorForCastBuffer_lv."March Rebate" * PurchaseMultiplier;

                //April
                TempVendorForCastBuffer."April Purchases" := TempVendorForCastBuffer_lv."April Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."April Rebate" := TempVendorForCastBuffer_lv."April Rebate" * PurchaseMultiplier;

                //May
                TempVendorForCastBuffer."May Purchases" := TempVendorForCastBuffer_lv."May Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."May Rebate" := TempVendorForCastBuffer_lv."May Rebate" * PurchaseMultiplier;

                //June
                TempVendorForCastBuffer."June Purchases" := TempVendorForCastBuffer_lv."June Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."June Rebate" := TempVendorForCastBuffer_lv."June Rebate" * PurchaseMultiplier;

                //July
                TempVendorForCastBuffer."July Purchases" := TempVendorForCastBuffer_lv."July Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."July Rebate" := TempVendorForCastBuffer_lv."July Rebate" * PurchaseMultiplier;

                //August
                TempVendorForCastBuffer."August Purchases" := TempVendorForCastBuffer_lv."August Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."August Rebate" := TempVendorForCastBuffer_lv."August Rebate" * PurchaseMultiplier;

                //September
                TempVendorForCastBuffer."September Purchases" := TempVendorForCastBuffer_lv."September Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."September Rebate" := TempVendorForCastBuffer_lv."September Rebate" * PurchaseMultiplier;

                //October
                TempVendorForCastBuffer."October Purchases" := TempVendorForCastBuffer_lv."October Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."October Rebate" := TempVendorForCastBuffer_lv."October Rebate" * PurchaseMultiplier;

                //November
                TempVendorForCastBuffer."November Purchases" := TempVendorForCastBuffer_lv."November Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."November Rebate" := TempVendorForCastBuffer_lv."November Rebate" * PurchaseMultiplier;

                //December
                TempVendorForCastBuffer."December Purchases" := TempVendorForCastBuffer_lv."December Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."December Rebate" := TempVendorForCastBuffer_lv."December Rebate" * PurchaseMultiplier;

                if not (TempVendorForCastBuffer.Year < Date2DMY(Today, 3)) then begin//Skip Forecast for previous years
                    if not TempVendorForCastBuffer.Insert() then
                        TempVendorForCastBuffer.Modify();
                end;


            end else begin//modify
                          //January
                TempVendorForCastBuffer."January Purchases" := TempVendorForCastBuffer_lv."January Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."January Rebate" := TempVendorForCastBuffer_lv."January Rebate" * PurchaseMultiplier;

                //February
                TempVendorForCastBuffer."February Purchases" := TempVendorForCastBuffer_lv."February Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."February Rebate" := TempVendorForCastBuffer_lv."February Rebate" * PurchaseMultiplier;

                //March
                TempVendorForCastBuffer."March Purchases" := TempVendorForCastBuffer_lv."March Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."March Rebate" := TempVendorForCastBuffer_lv."March Rebate" * PurchaseMultiplier;

                //April
                TempVendorForCastBuffer."April Purchases" := TempVendorForCastBuffer_lv."April Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."April Rebate" := TempVendorForCastBuffer_lv."April Rebate" * PurchaseMultiplier;

                //May
                TempVendorForCastBuffer."May Purchases" := TempVendorForCastBuffer_lv."May Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."May Rebate" := TempVendorForCastBuffer_lv."May Rebate" * PurchaseMultiplier;

                //June
                TempVendorForCastBuffer."June Purchases" := TempVendorForCastBuffer_lv."June Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."June Rebate" := TempVendorForCastBuffer_lv."June Rebate" * PurchaseMultiplier;

                //July
                TempVendorForCastBuffer."July Purchases" := TempVendorForCastBuffer_lv."July Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."July Rebate" := TempVendorForCastBuffer_lv."July Rebate" * PurchaseMultiplier;

                //August
                TempVendorForCastBuffer."August Purchases" := TempVendorForCastBuffer_lv."August Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."August Rebate" := TempVendorForCastBuffer_lv."August Rebate" * PurchaseMultiplier;

                //September
                TempVendorForCastBuffer."September Purchases" := TempVendorForCastBuffer_lv."September Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."September Rebate" := TempVendorForCastBuffer_lv."September Rebate" * PurchaseMultiplier;

                //October
                TempVendorForCastBuffer."October Purchases" := TempVendorForCastBuffer_lv."October Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."October Rebate" := TempVendorForCastBuffer_lv."October Rebate" * PurchaseMultiplier;

                //November
                TempVendorForCastBuffer."November Purchases" := TempVendorForCastBuffer_lv."November Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."November Rebate" := TempVendorForCastBuffer_lv."November Rebate" * PurchaseMultiplier;

                //December
                TempVendorForCastBuffer."December Purchases" := TempVendorForCastBuffer_lv."December Purchases" * PurchaseMultiplier;
                TempVendorForCastBuffer."December Rebate" := TempVendorForCastBuffer_lv."December Rebate" * PurchaseMultiplier;

                TempVendorForCastBuffer.Modify();
            end;
        end;//Get Original Entry
    end;

    local procedure GenerateDataforMissingYears(Vendor: Record Vendor)
    var
        MissingYear: Integer;
    begin
        //If missing for the starting years then insert blank actuals
        MissingYear := StartYear;
        if MissingYear < (Date2DMY(Today, 3)) then
            repeat
                TempVendorForCastBuffer.Reset();
                TempVendorForCastBuffer.SetRange("Buy-from Vendor No.", Vendor."No.");
                TempVendorForCastBuffer.SetRange(Year, MissingYear);
                TempVendorForCastBuffer.SetRange("Data Type", TempVendorForCastBuffer."Data Type"::Actual);
                if not TempVendorForCastBuffer.FindFirst() then begin//insert
                                                                     //
                    TempVendorForCastBuffer.Reset();//remove filters
                    TempVendorForCastBuffer.Init();
                    TempVendorForCastBuffer.Year := MissingYear;
                    TempVendorForCastBuffer."Data Type" := TempVendorForCastBuffer."Data Type"::Actual;//Actual for Non Forecast lines
                    TempVendorForCastBuffer."Buy-from Vendor No." := Vendor."No.";
                    TempVendorForCastBuffer."Buy-from Vendor Name" := Vendor.Name;
                    TempVendorForCastBuffer."Posting Date" := 0D;
                    TempVendorForCastBuffer."Pay-to Vendor No." := Vendor."No.";
                    TempVendorForCastBuffer."Pay-to Vendor Name" := Vendor.Name;

                    TempVendorForCastBuffer."January Purchases" := 0;
                    TempVendorForCastBuffer."January Rebate" := 0;
                    TempVendorForCastBuffer."February Purchases" := 0;
                    TempVendorForCastBuffer."February Rebate" := 0;
                    TempVendorForCastBuffer."March Purchases" := 0;
                    TempVendorForCastBuffer."March Rebate" := 0;
                    TempVendorForCastBuffer."April Purchases" := 0;
                    TempVendorForCastBuffer."April Rebate" := 0;
                    TempVendorForCastBuffer."May Purchases" := 0;
                    TempVendorForCastBuffer."May Rebate" := 0;
                    TempVendorForCastBuffer."June Purchases" := 0;
                    TempVendorForCastBuffer."June Rebate" := 0;
                    TempVendorForCastBuffer."July Purchases" := 0;
                    TempVendorForCastBuffer."July Rebate" := 0;
                    TempVendorForCastBuffer."August Purchases" := 0;
                    TempVendorForCastBuffer."August Rebate" := 0;
                    TempVendorForCastBuffer."September Purchases" := 0;
                    TempVendorForCastBuffer."September Rebate" := 0;
                    TempVendorForCastBuffer."October Purchases" := 0;
                    TempVendorForCastBuffer."October Rebate" := 0;
                    TempVendorForCastBuffer."November Purchases" := 0;
                    TempVendorForCastBuffer."November Rebate" := 0;
                    TempVendorForCastBuffer."December Purchases" := 0;
                    TempVendorForCastBuffer."December Rebate" := 0;
                    TempVendorForCastBuffer.Insert();
                    //
                end;
                MissingYear := MissingYear + 1;
            until MissingYear = (Date2DMY(Today, 3));
    end;

    local procedure OpenWindow(Message: Text[80])
    begin
        IF GUIALLOWED THEN
            Window.OPEN(Message);
    end;

    local procedure UpdateWindow(UpdateNumber: Integer; UpdateValue: Text[80])
    begin
        IF GUIALLOWED THEN
            Window.UPDATE(UpdateNumber, UpdateValue);
    end;

    LOCAL procedure CloseWindow()
    begin
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    procedure InserttoExcel(TempVendorForCastBuffer: Record "Vendor Rebate Buffer" temporary; ShowVendor: Boolean)
    begin
        ExcelBuf.SelectOrAddSheet(SheetName);
        MakeExcelDataHeader();

        ExcelBuf.NewRow;
        if ShowVendor then begin
            ExcelBuf.AddColumn(TempVendorForCastBuffer."Buy-from Vendor No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn(TempVendorForCastBuffer."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        end else begin
            ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        end;
        ExcelBuf.AddColumn(Format(TempVendorForCastBuffer.Year) + ' (' + Format(TempVendorForCastBuffer."Data Type") + ')', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."January Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."January Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."February Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."February Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."March Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."March Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."April Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."April Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."May Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."May Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."June Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."June Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."July Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."July Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."August Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."August Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."September Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."September Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."October Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."October Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."November Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."November Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."December Purchases", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Round(TempVendorForCastBuffer."December Rebate", 0.01), false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
    end;


    procedure MakeExcelDataHeader()
    begin
        if FileHeaderInserted then
            exit;

        FileHeaderInserted := true;

        MakeExcelInfo();

        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Vendor No.', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Vendor Name', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Year', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('January Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('January Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('February Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('February Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('March Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('March Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('April Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('April Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('May Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('May Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('June Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('June Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('July Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('July Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('August Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('August Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('September Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('September Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('October Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('October Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('November Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('November Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('December Purchases', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('December Rebate', false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
    end;

    local procedure MakeExcelInfo()
    var
        FilterString: Text;
    begin
        FilterString := 'Start Year: ' + Format(StartYear) + ' Purchase Multiplier: ' + Format(PurchaseMultiplier) + ' Run By: ' + Format(RunBy);
        ExcelBuf.SetUseInfoSheet();
        ExcelBuf.AddInfoColumn('Company Name', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyName, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('Report Name', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn('Vendor Rebate Forecast', false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('Report No.', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"AQD Vendor Rebate Forecast", false, false, false, false, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('User ID', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(UserId(), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('Date Time', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Today(), false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(Time(), false, false, false, false, '', ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('Filters', false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();

        ExcelBuf.ClearNewRow();

    end;

    procedure CreateExcelbook()
    begin
        ExcelBuf.WriteSheet('', CompanyName, UserId);
        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename('Vendor Rebate Forecast ' + DelChr(Format(CurrentDateTime), '=', '-|:|/|\|.|,'));
        ExcelBuf.OpenExcel();
    end;
}
