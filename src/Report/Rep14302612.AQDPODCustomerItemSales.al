report 14302612 "AQD POD Cust/Item Sales New"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'POD Customer/Item Sales';
    Caption = 'POD Customer/Item Sales';
    DefaultLayout = RDLC;
    Permissions = TableData "Sales Invoice Header" = rim, TableData "Sales Invoice Line" = rim;
    RDLCLayout = './src/Layout/Rep14302612.AQDPODCustomerItemSalesNew.rdlc';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            column(CompanyAddress_3; CompanyAddress[3])
            {
            }
            column(CompanyAddress_2; CompanyAddress[2])
            {
            }
            column(CompanyAddress_1; CompanyAddress[1])
            {
            }
            column(CompanyInformation_Picture; CompanyInformation.Picture)
            {
            }
            column(CompanyInformation_Phone_No; CompanyInformation."Phone No.")
            {
            }
            column(CompanyInformation_Fax_No; CompanyInformation."Fax No.")
            {
            }
            column(PeriodText; PeriodText)
            {
            }
            column(For_Period_PeriodText; 'For Period: ' + PeriodText)
            {
            }
            column(FilterString; FilterString)
            {
            }
            column(Customer_TABLECAPTION_FilterString; Customer.TableCaption + ':  ' + FilterString)
            {
            }
            column(Customer_Customer_Name; Customer.Name)
            {
            }
            column(Customer_Customer_No; Customer."No.")
            {
            }
            column(PODAmount; PODAmount)
            {
            }
            column(Total_for_Customer_Name; 'Total for ' + Customer.Name)
            {
            }
            column(Document_DateCaption; Document_DateCaptionLbl)
            {
            }
            column(Page_Caption; Page_CaptionLbl)
            {
            }
            column(Item_SalesCaption; Item_SalesCaptionLbl)
            {
            }
            column(Phone_No_Caption; Phone_No_CaptionLbl)
            {
            }
            column(Fax_No_Caption; Fax_No_CaptionLbl)
            {
            }
            column(Item_No_Caption; Item_No_CaptionLbl)
            {
            }
            column(Item_Extended_Description_Caption; Item_Extended_Description_CaptionLbl)
            {
            }
            column(Quantity_Base_Caption; Quantity_Base_CaptionLbl)
            {
            }
            column(Contract_PriceCaption; Contract_PriceCaptionLbl)
            {
            }
            column(POD_RefundCaption; POD_RefundCaptionLbl)
            {
            }
            column(Last_Direct_CostCaption; Last_Direct_CostCaptionLbl)
            {
            }
            column(InvoiceNoLbl; InvoiceNoLbl)
            { }
            column(PostingDateLbl; PostingDateLbl)
            { }
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemTableView = WHERE(Type = CONST(Item), Quantity = FILTER(<> 0));
                column(Sales_Invoice_Line_Quantity_Base; "Sales Invoice Line"."Quantity (Base)")
                {
                }
                column(Sales_Invoice_Line_No; "No.")
                {
                }
                column(Sales_Invoice_Line_Item_Extended_Description; Item.Description)
                {
                }
                column(Sales_Invoice_Line_PODAmount; PODAmount)
                {
                }
                column(Sales_Invoice_Line_ContractPrice; ContractPrice)
                {
                }
                column(Sales_Invoice_Line_SKUCost; SKUCost)
                {
                }
                column(Sales_Invoice_Line_Document_No; "Document No.")
                {
                }
                column(Sales_Invoice_Line_Line_No; "Line No.")
                {
                }
                column(PrintDetail; PrintDetail)
                {
                }
                column(Document_No; "Document No.")
                { }
                column(PostingDate; PostingDate)
                {
                }
                trigger OnAfterGetRecord()
                var
                    PrintLine: Boolean;
                begin
                    OnRecordCount += 1;

                    SalesInvHeader.Get("Sales Invoice Line"."Document No.");
                    PostingDate := SalesInvHeader."Posting Date";
                    if LinkNewPODCustomer then
                        if "AQD POD Customer" = '' then
                            UpdatePODCustomer;

                    if (("AQD POD Customer" = '') and ("Sell-to Customer No." <> Customer."No.")) then
                        CurrReport.Skip;

                    if not Item.Get("No.") then
                        Clear(Item);

                    ContractPrice := Item."AQD Contract Price";
                    ItemSKU.Get("Location Code", "No.", '');

                    if PrevItemNo <> "No." then begin
                        SKUCost := 0;
                        GetLastInvoiceCost("Location Code");
                    end;

                    PODAmount := 0;
                    if ContractPrice <> 0 then
                        PODAmount := "Quantity (Base)" * (SKUCost - ContractPrice);
                    SumPODAmount += PODAmount;
                    PrevItemNo := "No.";

                    if PrintToExcel then begin
                        if (LastSalesInvoiceLineNo <> '') and (LastSalesInvoiceLineNo <> "No.") then begin
                            ExcelBuf.NewRow;
                            IF PrintDetail then BEGIN
                                ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            END ELSE begin
                                ExcelBuf.AddColumn(LastSalesInvoiceLineNo, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn(LastSalesInvoiceLineExtDesc, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            end;
                            ExcelBuf.AddColumn(LastSKUCost, false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(QuantityTotal, false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(LastContractPrice, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmountTotal, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                            if PrintDetail then
                                ExcelBuf.NewRow;
                        end;
                        if PrintDetail then begin
                            ExcelBuf.NewRow;
                            ExcelBuf.AddColumn("No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            ExcelBuf.AddColumn(Item.Description, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            ExcelBuf.AddColumn(SKUCost, false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn("Quantity (Base)", false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(ContractPrice, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmount, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                        end;
                    end;

                    if (LastSalesInvoiceLineNo <> "No.") then begin
                        QuantityTotal := 0;
                        PODAmountTotal := 0;
                    end;
                    QuantityTotal += "Quantity (Base)";
                    PODAmountTotal += PODAmount;
                    LastSalesInvoiceLineNo := "No.";
                    LastSalesInvoiceLineExtDesc := Item.Description;
                    LastSKUCost := SKUCost;
                    LastContractPrice := ContractPrice;
                END;

                trigger OnPostDataItem()
                begin
                    IF PrintToExcel THEN BEGIN
                        IF OnRecordCount > 0 THEN BEGIN
                            ExcelBuf.NewRow;
                            IF PrintDetail then BEGIN
                                ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            END ELSE begin
                                ExcelBuf.AddColumn(LastSalesInvoiceLineNo, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn(LastSalesInvoiceLineExtDesc, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                            end;
                            ExcelBuf.AddColumn(LastSKUCost, false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(QuantityTotal, false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(LastContractPrice, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmountTotal, false, '', false, false, false, '@', ExcelBuf."Cell Type"::Number);
                        END;

                        ExcelBuf.NewRow;
                        ExcelBuf.AddColumn('Total for ' + Customer.Name, FALSE, '', true, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn(SumPODAmount, FALSE, '', TRUE, FALSE, FALSE, '@', ExcelBuf."Cell Type"::Number);
                    END;
                end;

                trigger OnPreDataItem()
                begin
                    SetCurrentKey(Type, "No.", "AQD POD Customer", "Posting Date");
                    if ItemNoFilter <> '' then
                        SetFilter("No.", ItemNoFilter);

                    SetFilter("AQD POD Customer", '%1|%2', Customer."No.", '');

                    if PostDateFilter <> '' then
                        SetFilter("Posting Date", PostDateFilter);

                    IF NOT FindFirst() then
                        CurrReport.Break();

                    TotalRecordCount := "Sales Invoice Line".Count;
                    OnRecordCount := 0;
                    LastSalesInvoiceLineNo := '';
                end;
            }
            trigger OnPreDataItem()
            begin
                if SourceNoFilter <> '' then
                    SetFilter("No.", SourceNoFilter);

                // Store the filter to pass to the layout
                FilterString := Customer.GetFilters();
                OpenWindow(WindowText000);
            end;

            trigger OnAfterGetRecord()
            begin
                UpdateWindow(1, Customer."No.");
                if PrintToExcel then begin
                    ExcelBuf.NewRow;
                    ExcelBuf.NewRow;
                    ExcelBuf.AddColumn(Customer."No.", false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(Customer.Name, false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
                end;
                SumPODAmount := 0;
            end;

            trigger OnPostDataItem()
            begin
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
                        ApplicationArea = All;
                        Caption = 'Direct Cost As of';
                    }
                    field(PostDateFilter; PostDateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date Filter';
                        trigger OnValidate()
                        begin
                            SalesInvoice.SETFILTER("Posting Date", PostDateFilter);
                            PostDateFilter := SalesInvoice.GETFILTER("Posting Date");
                        end;
                    }
                    field(PrintDetail; PrintDetail)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Detail';
                    }
                    field(ContractType; ContractType)
                    {
                        ApplicationArea = All;
                        Caption = 'Contract Price Type';
                    }
                    field(CostOption; CostOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Option';
                    }
                    field(LinkNewPODCustomer; LinkNewPODCustomer)
                    {
                        ApplicationArea = All;
                        Caption = 'Link New POD Customer';
                    }
                    field(PrintToExcel; PrintToExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Print To Excel';
                    }
                    field(SourceNoFilter; SourceNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No. Filter';

                        trigger OnAssistEdit()
                        begin
                            Clear(SelelctCustPage);
                            SelelctCustPage.SetSourceNoFilter(SourceNoFilter);
                            SelelctCustPage.RunModal();
                            SourceNoFilter := SelelctCustPage.GetSelectedCustomers();
                        end;
                    }
                    field(ItemNoFilter; ItemNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Item No. Filter';

                        trigger OnAssistEdit()
                        begin
                            Clear(SelectItemPage);
                            SelectItemPage.SetItemNoFilter(ItemNoFilter);
                            SelectItemPage.RunModal();
                            ItemNoFilter := SelectItemPage.GetSelectedItems();
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
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
    trigger OnPostReport()
    begin
        CloseWindow();
        if PrintToExcel then begin
            ExcelBuf.SetColumnWidth('A', 30);
            ExcelBuf.SetColumnWidth('B', 78);
            ExcelBuf.SetColumnWidth('C', 25);
            ExcelBuf.SetColumnWidth('D', 25);
            ExcelBuf.SetColumnWidth('E', 25);
            ExcelBuf.SetColumnWidth('F', 25);

            CreateExcelbook;
        end;

        ReportExecutionEndTime := TIME;
        IF GUIALLOWED THEN
            MESSAGE('Start Time %1\End Time %2', ReportExecutionStartTime, ReportExecutionEndTime);
    end;

    trigger OnPreReport()
    begin

        PeriodText := PostDateFilter;
        CompanyInformation.Get;
        if SourceNoFilter <> '' then
            FilterString := SourceNoFilter;

        CompanyInformation.CalcFields(Picture);
        FormatAddress.Company(CompanyAddress, CompanyInformation);

        MonthEndDate := CalcDate('CM', PrevMonthEndDate);

        ReportExecutionStartTime := TIME;

        if PrintToExcel then begin
            MakeExcelInfo;

            if (PeriodText <> '') then begin
                ExcelBuf.NewRow;
                ExcelBuf.AddColumn('For Period: ' + PeriodText, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
            end;

            if (FilterString <> '') then begin
                ExcelBuf.NewRow;
                ExcelBuf.AddColumn(Customer.TableCaption + ':  ' + FilterString, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
            end;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.AddColumn('Item No.', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Item Description', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Last Direct Cost', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Quantity (Base)', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Contract Price', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('POD Refund', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        end;
    end;

    var
        CompanyInformation: Record "Company Information";
        SalesInvoice: Record "Sales Invoice Header";
        FilterString: Text;
        PeriodText: Text[30];
        PrintDetail: Boolean;
        PostDateFilter: Text[1000];
        FormatAddress: Codeunit "Format Address";
        CompanyAddress: array[8] of Text[60];
        Item: Record Item;
        ContractPrice: Decimal;
        PODAmount: Decimal;
        SumPODAmount: Decimal;
        ContractType: Option "Contract Price CA","Contract Price AZ";
        ItemSKU: Record "Stockkeeping Unit";
        PrevMonthEndDate: Date;
        SKUCost: Decimal;
        MonthEndDate: Date;
        PrevItemNo: Code[20];
        SalesInvHeader: Record "Sales Invoice Header";
        CostOption: Option "Last Direct Cost","Invoices from AZ","Invoices from CA";
        ExcelBuf: Record "Excel Buffer" temporary;
        Text000: Label 'Company Name';
        Text001: Label 'Report No.';
        Text002: Label 'POD Customer/Item Sales';
        Text003: Label 'Report Name';
        Text004: Label 'User ID';
        Text005: Label 'Date / Time';
        Text006: Label 'Direct Cost As of';
        Text007: Label 'Posting Date Filter';
        Text008: Label 'Contract Price Type';
        Text009: Label 'Cost Option';
        Text010: Label 'Cost Option';
        PrintToExcel: Boolean;
        Text101: Label 'Data';
        Text102: Label 'POD Customer/Item Sales New';
        SalesInvLine: Record "Sales Invoice Line";
        GF3No: Code[20];
        LastSalesInvoiceLineNo: Code[20];
        QuantityTotal: Decimal;
        PODAmountTotal: Decimal;
        LastSalesInvoiceLineExtDesc: Text[130];
        LastSKUCost: Decimal;
        LastContractPrice: Decimal;
        SalesPrice: Record "Sales Price";
        LinkNewPODCustomer: Boolean;
        Document_DateCaptionLbl: Label 'Document Date';
        Page_CaptionLbl: Label 'Page:';
        Item_SalesCaptionLbl: Label 'Item Sales';
        Phone_No_CaptionLbl: Label 'Phone No:';
        Fax_No_CaptionLbl: Label 'Fax No:';
        Item_No_CaptionLbl: Label 'Item No.';
        Item_Extended_Description_CaptionLbl: Label 'Item Description';
        Quantity_Base_CaptionLbl: Label 'Quantity (Base)';
        Contract_PriceCaptionLbl: Label 'Contract Price';
        POD_RefundCaptionLbl: Label 'POD Refund';
        Last_Direct_CostCaptionLbl: Label 'Last Direct Cost';
        PostingDate: Date;
        InvoiceNoLbl: Label 'Invoice No.';
        PostingDateLbl: Label 'Posting Date';
        Window: Dialog;
        WindowText000: Label 'Processing Customer No. #1##########';
        TotalRecordCount: Integer;
        OnRecordCount: Integer;
        ReportExecutionStartTime: Time;
        ReportExecutionEndTime: Time;
        SelelctCustPage: page "AQD Select Customers";
        SelectItemPage: Page "AQD Select Items";
        SelectShipToCodesPage: Page "AQD Select Ship-To Codes";
        ItemNoFilter: Text;
        SourceNoFilter: Text;
        ShipToCodeFilter: Text;

    procedure GetLastInvoiceCost(statecode: Code[10])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        FoundLastDirectCost: Boolean;
    begin
        FoundLastDirectCost := false;
        SKUCost := 0;

        PurchInvLine.SetCurrentKey("Posting Date");
        PurchInvLine.Ascending(false);
        PurchInvLine.SetRange("Posting Date", 0D, MonthEndDate);
        PurchInvLine.SetRange("No.", "Sales Invoice Line"."No.");
        PurchInvLine.SetFilter(Quantity, '<>0');

        if statecode = 'CA' then begin
            if ItemSKU.Get('CA', Item."No.", "Sales Invoice Line"."Variant Code") then begin
                PurchInvLine.SetFilter("Location Code", '%1|%2|%3', 'CA', 'LA', 'DS');
                if PurchInvLine.FindSet() then
                    repeat
                        if PurchInvLine."Direct Unit Cost" <> 0 then begin
                            SKUCost := PurchInvLine."Direct Unit Cost";
                            FoundLastDirectCost := true;
                        end;
                    until (PurchInvLine.Next() = 0) or FoundLastDirectCost;
            end;
        end;

        if not FoundLastDirectCost and (statecode = 'AZ') then begin
            if ItemSKU.Get('AZ', Item."No.", "Sales Invoice Line"."Variant Code") then begin
                PurchInvLine.SetFilter("Location Code", '%1|%2', 'AZ', 'DS');
                if PurchInvLine.FindSet() then
                    repeat
                        if PurchInvLine."Direct Unit Cost" <> 0 then begin
                            SKUCost := PurchInvLine."Direct Unit Cost";
                            FoundLastDirectCost := true;
                        end;
                    until (PurchInvLine.Next() = 0) or FoundLastDirectCost;
            end;
        end;
    end;

    local procedure MakeExcelInfo()
    begin
        ExcelBuf.SetUseInfoSheet;
        ExcelBuf.AddInfoColumn(Format(Text000), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyInformation.Name, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text001), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"AQD POD Cust/Item Sales New", false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text003), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Format(Text002), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text004), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text005), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Today, false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(Time, false, false, false, false, '', ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text006), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(PrevMonthEndDate, false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text007), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(PostDateFilter, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text008), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Format(ContractType), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text010), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Format(CostOption), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.ClearNewRow;
        MakeExcelDataHeader;
    end;

    local procedure CreateExcelbook()
    begin
        ExcelBuf.CreateNewBook('Data');
        ExcelBuf.SetColumnWidth('A', 30);
        ExcelBuf.SetColumnWidth('B', 78);
        ExcelBuf.SetColumnWidth('C', 25);
        ExcelBuf.SetColumnWidth('D', 25);
        ExcelBuf.SetColumnWidth('E', 25);
        ExcelBuf.SetColumnWidth('F', 25);
        ExcelBuf.WriteSheet(Text102, CompanyName(), UserId());
        ExcelBuf.SetColumnWidth('A', 28);
        ExcelBuf.SetColumnWidth('B', 28);
        ExcelBuf.SetColumnWidth('C', 10);

        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename('PODCustomer_Item_Sales_New');
        ExcelBuf.OpenExcel();
    end;

    procedure MakeExcelDataHeader()
    begin
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Item Sales', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Document Date', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Today, false, '', false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[1], false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[2], false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[3], false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Phone No', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(CompanyInformation."Phone No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Fax No', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(CompanyInformation."Fax No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
    end;

    procedure UpdatePODCustomer()
    begin
        SalesPrice.SetRange(SalesPrice."Sales Code", SalesInvHeader."Sell-to Customer No.");
        SalesPrice.SetFilter("AQD POD Customer", '<>%1', '');
        if SalesPrice.FindFirst then begin
            "Sales Invoice Line"."AQD POD Customer" := SalesPrice."AQD POD Customer";
            "Sales Invoice Line".Modify;
        end;
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
}