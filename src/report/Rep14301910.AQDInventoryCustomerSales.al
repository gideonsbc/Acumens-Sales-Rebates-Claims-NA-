report 14301910 "AQD Inventory - Customer Sales"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/layout/Rep14277006.AQDInventoryCustomerSales.rdl';
    ApplicationArea = All;
    Caption = 'Rebate Inventory Customer Sales';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ReportHeader; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(0));
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PeriodText; PeriodText)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(ItemLedgEntryFilter; ItemLedgEntryFilter)
            {
            }
        }
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "No. 2", "Search Description", "Assembly BOM", "Inventory Posting Group";
            column(No_Item; "No.")
            {
            }
            column(Description_Item; Description)
            {
            }
            column(BaseUnitofMeasure_Item; "Base Unit of Measure")
            {
                IncludeCaption = true;
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = field("No."), "Variant Code" = field("Variant Filter"), "Location Code" = field("Location Filter"), "Global Dimension 1 Code" = field("Global Dimension 1 Filter"), "Global Dimension 2 Code" = field("Global Dimension 2 Filter");
                DataItemTableView = sorting("Item No.", "Source No.", "Posting Date", "Source Type") where("Source Type" = const(Customer));
                RequestFilterFields = "Posting Date", "Source No.";
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                    column(SourceNo_ItemLedgEntry; TempValueEntryBuf."Source No.")
                    {
                    }
                    column(CustName; GetCustName(TempValueEntryBuf."Source No."))
                    {
                    }
                    column(InvQty_ItemLedgEntry; -TempValueEntryBuf."Invoiced Quantity")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(SalesAmtActual_ItemLedgEntry; TempValueEntryBuf."Sales Amount (Actual)")
                    {
                        AutoFormatType = 1;
                    }
                    column(Profit_ItemLedgEntry; TempValueEntryBuf."Sales Amount (Expected)")
                    {
                        AutoFormatType = 1;
                    }
                    column(DiscountAmount; -TempValueEntryBuf."Purchase Amount (Expected)")
                    {
                        AutoFormatType = 1;
                    }
                    column(PurchaseRebateAmount; TempValueEntryBuf."Expected Cost Posted to G/L")
                    {
                        AutoFormatType = 1;
                    }
                    column(SalesRebateAmount; TempValueEntryBuf."Cost Posted to G/L")
                    {
                        AutoFormatType = 1;
                    }
                    column(CostAmount; TempValueEntryBuf."Cost Amount (Actual)")
                    {
                        AutoFormatType = 1;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not TempValueEntryBuf.FindSet() then
                                CurrReport.Break();
                        end else
                            if TempValueEntryBuf.Next() = 0 then
                                CurrReport.Break();
                    end;

                    trigger OnPostDataItem()
                    begin
                        TempValueEntryBuf.DeleteAll();
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempValueEntryBuf.Reset();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if IsNewGroup() then
                        AddReportLine(ValueEntryBuf);

                    IncrLineAmounts(ValueEntryBuf, "Item Ledger Entry");

                    if IsLastEntry() then
                        AddReportLine(ValueEntryBuf);
                end;

                trigger OnPreDataItem()
                begin
                    LastItemLedgEntryNo := GetLastItemLedgerEntryNo("Item Ledger Entry");
                    Clear(ValueEntryBuf);
                    ReportLineNo := 0;
                end;
            }
        }
    }

    requestpage
    {
        AboutTitle = 'About Inventory Customer Sales';
        AboutText = 'Analyse your customer sales per item to understand sales trends, optimise inventory management and improve marketing efforts. Assess the relationship between discounts, sales amount and volume of sales for each customer/item combination in the given period.';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        ReportTitle = 'Inventory - Customer Sales';
        Page = 'Page';
        CustomerNo = 'Customer No.';
        Name = 'Name';
        InvoicedQty = 'Invoiced Quantity';
        Amount = 'Sales Amount';
        Cost = 'Cost Amount';
        DiscountAmt = 'Discount Amount';
        Profit = 'Profit';
        ProfitPct = 'Profit %';
        Total = 'Total';
        PurchRebateLbl = 'Purchase Rebate';
        SalesRebateLbl = 'Sales Rebate';
    }

    trigger OnPreReport()
    begin
        ItemFilter := GetTableFilters(Item.TableCaption(), Item.GetFilters);
        ItemLedgEntryFilter := GetTableFilters("Item Ledger Entry".TableCaption(), "Item Ledger Entry".GetFilters);
        PeriodText := StrSubstNo(PeriodInfoTxt, "Item Ledger Entry".GetFilter("Posting Date"));
    end;

    var
        ValueEntryBuf: Record "Value Entry";
        TempValueEntryBuf: Record "Value Entry" temporary;
        PeriodText: Text;
        ItemFilter: Text;
        ItemLedgEntryFilter: Text;
        LastItemLedgEntryNo: Integer;
        ReportLineNo: Integer;

        PeriodInfoTxt: Label 'Period: %1', Comment = '%1 - period name';
        TableFiltersTxt: Label '%1: %2', Locked = true;

    local procedure CalcDiscountAmount(ItemLedgerEntryNo: Integer): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.CalcSums("Discount Amount");
        exit(ValueEntry."Discount Amount");
    end;

    local procedure GetLastItemLedgerEntryNo(var ItemLedgerEntry: Record "Item Ledger Entry"): Integer
    var
        LastItemLedgerEntry: Record "Item Ledger Entry";
    begin
        LastItemLedgerEntry.Copy(ItemLedgerEntry);
        if LastItemLedgerEntry.FindLast() then
            exit(LastItemLedgerEntry."Entry No.");
        exit(0);
    end;

    local procedure IncrLineAmounts(var ValueEntryBuf2: Record "Value Entry"; CurrItemLedgerEntry: Record "Item Ledger Entry")
    var
        Profit: Decimal;
        DiscountAmount: Decimal;
        CalculatedPurchaseRebate: Decimal;
        AppliedCostAmount: Decimal;
    begin
        CurrItemLedgerEntry.CalcFields("Sales Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
        Profit := CurrItemLedgerEntry."Sales Amount (Actual)" +
                  CurrItemLedgerEntry."Cost Amount (Actual)" +
                  CurrItemLedgerEntry."Cost Amount (Non-Invtbl.)" +
                  CurrItemLedgerEntry."AQD Cust Rebate Amount";
        DiscountAmount := CalcDiscountAmount(CurrItemLedgerEntry."Entry No.");
        CalcAppliedPurchaseAmounts(CurrItemLedgerEntry."Entry No.", CalculatedPurchaseRebate, AppliedCostAmount);

        if ValueEntryBuf2."Item No." = '' then begin
            ValueEntryBuf2.Init();
            ValueEntryBuf2."Item No." := CurrItemLedgerEntry."Item No.";
            ValueEntryBuf2."Source No." := CurrItemLedgerEntry."Source No.";
        end;
        ValueEntryBuf2."Invoiced Quantity" += CurrItemLedgerEntry."Invoiced Quantity";
        ValueEntryBuf2."Sales Amount (Actual)" += CurrItemLedgerEntry."Sales Amount (Actual)";
        ValueEntryBuf2."Sales Amount (Expected)" += Profit;
        ValueEntryBuf2."Purchase Amount (Expected)" += DiscountAmount;
        ValueEntryBuf2."Cost Posted to G/L" += CurrItemLedgerEntry."AQD Cust Rebate Amount";
        ValueEntryBuf2."Expected Cost Posted to G/L" += CalculatedPurchaseRebate;
        //ValueEntryBuf2."Cost Amount (Actual)" := AppliedCostAmount;
        ValueEntryBuf2."Cost Amount (Actual)" := CurrItemLedgerEntry."Cost Amount (Actual)" +
                                                 CurrItemLedgerEntry."Cost Amount (Non-Invtbl.)"; // - CalculatedPurchaseRebate;
    end;

    local procedure AddReportLine(var ValueEntryBuf2: Record "Value Entry")
    begin
        TempValueEntryBuf := ValueEntryBuf2;
        ReportLineNo += 1;
        TempValueEntryBuf."Entry No." := ReportLineNo;
        TempValueEntryBuf.Insert();
        Clear(ValueEntryBuf2);
    end;

    local procedure IsNewGroup(): Boolean
    begin
        exit(("Item Ledger Entry"."Source No." <> ValueEntryBuf."Source No.") and (ValueEntryBuf."Source No." <> ''));
    end;

    local procedure IsLastEntry(): Boolean
    begin
        exit("Item Ledger Entry"."Entry No." = LastItemLedgEntryNo);
    end;

    local procedure GetCustName(CustNo: Code[20]): Text[100]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustNo) then
            exit(Customer.Name);
        exit('');
    end;

    local procedure GetTableFilters(TableName: Text; Filters: Text): Text
    begin
        if Filters <> '' then
            exit(StrSubstNo(TableFiltersTxt, TableName, Filters));
        exit('');
    end;

    local procedure CalcAppliedPurchaseAmounts(ItemLedgerEntryNo: Integer; var CalculatedPurchaseRebate: Decimal; var AppliedCostAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ItemCharge: Record "Item Charge";
        AppliedEntries: Codeunit "Show Applied Entries";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemLedger_lv: Record "Item Ledger Entry";
        RebateSingelInstance: Codeunit "AQD Cust Rebate SingleInstance";
    begin
        CalculatedPurchaseRebate := 0;
        AppliedCostAmount := 0;
        if TempItemLedgerEntry.IsTemporary then
            TempItemLedgerEntry.DeleteAll();

        RebateSingelInstance.SetCalledFromRebate(TRUE);

        ItemLedger_lv.get(ItemLedgerEntryNo);
        AppliedEntries.FindAppliedEntries(ItemLedger_lv, TempItemLedgerEntry);

        RebateSingelInstance.SetCalledFromRebate(FALSE);

        TempItemLedgerEntry.Reset();
        if TempItemLedgerEntry.IsEmpty then
            exit;

        if TempItemLedgerEntry.FindFirst() then
            repeat
                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Item Charge No.");
                ValueEntry.SetRange("Item Ledger Entry No.", TempItemLedgerEntry."Entry No.");
                ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
                if ValueEntry.FindFirst() then
                    repeat
                        if ItemCharge.Get(ValueEntry."Item Charge No.") then begin
                            //if ItemCharge."AQD Customer Rebate" then begin
                            if ValueEntry."Valued Quantity" <> 0 then
                                CalculatedPurchaseRebate += (ValueEntry."Cost Amount (Actual)" / ValueEntry."Valued Quantity") * ItemLedger_lv.Quantity;

                            AppliedCostAmount += ValueEntry."Cost Amount (Actual)";
                        end;
                    until ValueEntry.Next() = 0;
            until TempItemLedgerEntry.Next() = 0;
        //    exit(TempPurchRebateAmnt);
    end;
}

