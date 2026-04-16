report 14302615 "AQD POD Cust/Item Sales New 2"
{
    AdditionalSearchTerms = 'POD Customer/Item Sales';
    ApplicationArea = All;
    Caption = 'POD Customer/Item Sales';
    DefaultLayout = RDLC;
    Permissions = TableData "Sales Invoice Header" = rim, TableData "Sales Invoice Line" = rim;
    RDLCLayout = './src/Layout/Rep14302615.AQDPODCustomerItemSalesNew2.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyInformation_Picture; CompanyInformation.Picture)
            {
            }
            column(CompanyInformation_PhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyInformation_Fax_No; CompanyInformation."Fax No.")
            {
            }
            column(ForPeriod_PeriodText; 'For Period: ' + PeriodText)
            {
            }
            column(Customer_TABLECAPTION_FilterString; Customer.TABLECAPTION + ':  ' + FilterString)
            {
            }
            column(Customer_Customer_Name; Customer.Name)
            {
            }
            column(Customer_Customer_No; Customer."No.")
            {
            }
            column(Customer_PODAmount; PODAmount)
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
            column(Item_Extended_Description_Caption; Item_Extended_Description_Control34CaptionLbl)
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
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemTableView = WHERE(Type = CONST(Item),
                                          Quantity = FILTER(<> 0));
                RequestFilterFields = "No.";
                column(Sales_Invoice_Line_Quantity_Base; "Sales Invoice Line"."Quantity (Base)")
                {
                }
                column(Sales_Invoice_Line_No; "No.")
                {
                }
                column(Item_Extended_Description; Item.Description)
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
                trigger OnAfterGetRecord()
                var
                    PrintLine: Boolean;
                begin
                    SalesInvHeader.GET("Sales Invoice Line"."Document No.");
                    IF LinkNewPODCustomer THEN
                        IF "AQD POD Customer" = '' THEN
                            UpdatePODCustomer;

                    IF (("AQD POD Customer" = '') AND ("Sell-to Customer No." <> Customer."No.")) THEN
                        CurrReport.SKIP;

                    IF NOT Item.GET("No.") THEN
                        CLEAR(Item);

                    ContractPrice := 0;
                    CASE ContractType OF
                        ContractType::"Contract Price CA":
                            BEGIN
                                IF CustomerContractPrices.GET("Sales Invoice Line"."No.", Customer."No.") THEN
                                    ContractPrice := CustomerContractPrices."Contract Price CA";
                                ItemSKU.GET("Location Code", "No.", '');
                            END;
                        ContractType::"Contract Price AZ":
                            BEGIN
                                IF CustomerContractPrices.GET("Sales Invoice Line"."No.", Customer."No.") THEN
                                    ContractPrice := CustomerContractPrices."Contract Price AZ";
                                ItemSKU.GET('AZ', "No.", '');
                            END;
                    END;

                    IF PrevItemNo <> "No." THEN BEGIN
                        SKUCost := 0;
                        CASE CostOption OF
                            CostOption::"Invoices from AZ":
                                GetLastInvoiceCost('AZ');
                            CostOption::"Invoices from CA":
                                GetLastInvoiceCost('CA');
                            CostOption::"Last Direct Cost":
                                SKUCost := ItemSKU."Last Direct Cost";
                        END;
                    END;

                    PODAmount := 0;
                    IF ContractPrice <> 0 THEN
                        PODAmount := "Quantity (Base)" * (SKUCost - ContractPrice);
                    SumPODAmount += PODAmount;

                    PrevItemNo := "No.";

                    IF PrintToExcel THEN BEGIN
                        IF (LastSalesInvoiceLineNo <> "No.") AND (LastSalesInvoiceLineNo <> '') THEN BEGIN
                            ExcelBuf.NewRow;
                            IF PrintDetail then BEGIN
                                ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            END ELSE begin
                                IF ExportVendorCrossRefNo THEN
                                    ExcelBuf.AddColumn(GetVendirCrossRefNo(LastSalesInvoiceLineNo), FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text)
                                ELSE
                                    ExcelBuf.AddColumn(LastSalesInvoiceLineNo, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn(LastSalesInvoiceLineExtDesc, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            end;
                            ExcelBuf.AddColumn(LastSKUCost, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(QuantityTotal, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(LastContractPrice, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmountTotal, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            if PrintDetail then
                                ExcelBuf.NewRow;
                        END;
                        IF PrintDetail THEN begin
                            ExcelBuf.NewRow;
                            IF ExportVendorCrossRefNo THEN
                                ExcelBuf.AddColumn(GetVendirCrossRefNo("No."), FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text)
                            ELSE
                                ExcelBuf.AddColumn("No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            ExcelBuf.AddColumn(Item.Description, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            ExcelBuf.AddColumn(SKUCost, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn("Quantity (Base)", FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(ContractPrice, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmount, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                        end;
                    end;

                    IF (LastSalesInvoiceLineNo <> "No.") THEN BEGIN
                        QuantityTotal := 0;
                        PODAmountTotal := 0;
                    END;
                    QuantityTotal += "Quantity (Base)";
                    PODAmountTotal += PODAmount;
                    LastSalesInvoiceLineNo := "No.";
                    LastSalesInvoiceLineExtDesc := Item.Description;
                    LastSKUCost := SKUCost;
                    LastContractPrice := ContractPrice;
                end;

                trigger OnPostDataItem()
                begin
                    IF PrintToExcel THEN BEGIN
                        IF OnRecordCount > 0 THEN BEGIN
                            IF PrintDetail then BEGIN
                                ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            END ELSE begin
                                IF ExportVendorCrossRefNo THEN
                                    ExcelBuf.AddColumn(GetVendirCrossRefNo(LastSalesInvoiceLineNo), FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text)
                                ELSE
                                    ExcelBuf.AddColumn(LastSalesInvoiceLineNo, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                                ExcelBuf.AddColumn(LastSalesInvoiceLineExtDesc, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                            end;
                            ExcelBuf.AddColumn(LastSKUCost, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(QuantityTotal, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(LastContractPrice, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                            ExcelBuf.AddColumn(PODAmountTotal, FALSE, '', FALSE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                        END;

                        ExcelBuf.NewRow;
                        ExcelBuf.AddColumn('Total for ' + Customer.Name, FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
                        ExcelBuf.AddColumn(SumPODAmount, FALSE, '', TRUE, FALSE, FALSE, '#,##0.00', ExcelBuf."Cell Type"::Number);
                        CreateSheet(Text101);
                    END;
                end;

                trigger OnPreDataItem()
                begin
                    SetCurrentKey(Type, "No.", "AQD POD Customer", "Posting Date");

                    CurrReport.CREATETOTALS(PODAmount, "Sales Invoice Line"."Quantity (Base)");
                    SETFILTER("AQD POD Customer", '=%1|%2', Customer."No.", '');
                    IF PostDateFilter <> '' THEN
                        SETFILTER("Posting Date", PostDateFilter);

                    CurrReport.CREATETOTALS(PODAmount, "Sales Invoice Line"."Quantity (Base)");

                    IF NOT FindFirst() THEN
                        CurrReport.Break();

                    TotalRecordCount := "Sales Invoice Line".Count;
                    OnRecordCount := 0;
                    LastSalesInvoiceLineNo := '';
                end;
            }
            trigger OnPreDataItem()
            begin
                OpenWindow(WindowText000);
            end;

            trigger OnAfterGetRecord()
            begin
                UpdateWindow(1, Customer."No."); //update after getting sales invoice header
                if PrintToExcel then begin
                    ExcelBuf.NewRow;
                    ExcelBuf.AddColumn(Customer."No.", false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(Customer.Name, false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.NewRow;
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
                group(Group)
                {
                    field("Direct Cost As Of"; PrevMonthEndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Direct Cost As Of';
                    }
                    field("Posting Date Filter"; PostDateFilter)
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
                    field(ExportVendorCrossRefNo; ExportVendorCrossRefNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Vendor Cross Ref No.';
                    }
                    field("Cross Ref Vendor No"; CrossRefVendorNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Cross Ref Vendor No';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            VendorList: Page "Vendor List";
                        begin
                            VendorList.LookupMode(true);
                            if VendorList.RunModal() = Action::LookupOK then begin
                                Text += VendorList.GetSelectionFilter();
                                exit(true);
                            end else
                                exit(false);
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
            IF PrevMonthEndDate = 0D THEN BEGIN
                PrevMonthEndDate := CALCDATE('CM', TODAY);
                PrevMonthEndDate := CALCDATE('-1M', PrevMonthEndDate);
                PrevMonthEndDate := CALCDATE('CM', PrevMonthEndDate);
            END;
        end;
    }

    labels
    {
    }
    trigger OnInitReport()
    begin
        CrossRefVendorNo := '00-PACTIV';
    end;

    trigger OnPostReport()
    begin
        CloseWindow();
        IF PrintToExcel THEN BEGIN
            ExcelBuf.DELETEALL();
            CreateExcelbook();
        END;
    end;

    trigger OnPreReport()
    begin

        PeriodText := PostDateFilter;
        CompanyInformation.GET;
        FilterString := Customer.GETFILTERS;
        CompanyInformation.CALCFIELDS(Picture);
        FormatAddress.Company(CompanyAddress, CompanyInformation);

        MonthEndDate := CALCDATE('CM', PrevMonthEndDate);

        IF NOT PrintToExcel THEN
            ExportVendorCrossRefNo := FALSE;

        IF PrintToExcel THEN BEGIN
            ExcelBuf.DELETEALL();
            ExcelBuf.CreateNewBook(Text101);
            ExcelBuf.SetColumnWidth('A', 50);
            ExcelBuf.SetColumnWidth('B', 78);
            ExcelBuf.SetColumnWidth('C', 14);
            ExcelBuf.SetColumnWidth('D', 14);
            ExcelBuf.SetColumnWidth('E', 14);
            ExcelBuf.SetColumnWidth('F', 12);
            ExcelBuf.SetColumnWidth('G', 12);
            MakeExcelInfo;
            ExcelBuf.WriteSheet('', COMPANYNAME, USERID);
            IF (PeriodText <> '') THEN BEGIN
                ExcelBuf.NewRow;
                ExcelBuf.AddColumn('For Period: ' + PeriodText, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            END;

            IF (FilterString <> '') THEN BEGIN
                ExcelBuf.NewRow;
                ExcelBuf.AddColumn(Customer.TABLECAPTION + ':  ' + FilterString, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            END;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            ExcelBuf.NewRow;
            IF ExportVendorCrossRefNo THEN
                ExcelBuf.AddColumn('Vendor Cross Ref No.', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text)
            ELSE
                ExcelBuf.AddColumn('Item No.', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Item Description', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Last Direct Cost', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Quantity (Base)', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('Contract Price', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
            ExcelBuf.AddColumn('POD Refund', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        END;
    end;

    var
        CompanyInformation: Record "Company Information";
        SalesInvoice: Record "Sales Invoice Header";
        FilterString: Text[1000];
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
        TQuantityTotal: Decimal;
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
        Item_Extended_Description_Control34CaptionLbl: Label 'Item Description';
        Quantity_Base_CaptionLbl: Label 'Quantity (Base)';
        Contract_PriceCaptionLbl: Label 'Contract Price';
        POD_RefundCaptionLbl: Label 'POD Refund';
        Last_Direct_CostCaptionLbl: Label 'Last Direct Cost';
        ExportVendorCrossRefNo: Boolean;
        CrossRefVendorNo: Code[20];
        CustomerContractPrices: Record "AQD Customer Contract Prices";
        RowNo: Integer;
        Text103: Label 'Export Vendor Cross Ref No';
        Text104: Label 'Cross Ref Vendor No';
        Window: Dialog;
        WindowText000: Label 'Processing Customer No. #1##########';
        OnRecordCount: Integer;
        TotalRecordCount: Integer;

    procedure GetLastInvoiceCost(statecode: Code[10])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        FoundLastDirectCost: Boolean;
    begin

        FoundLastDirectCost := FALSE;
        SKUCost := 0;

        PurchInvHeader.SETCURRENTKEY("Posting Date");
        PurchInvHeader.ASCENDING(FALSE);
        PurchInvHeader.SETRANGE("Posting Date", 0D, MonthEndDate);
        IF PurchInvHeader.FIND('-') THEN
            REPEAT
                PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
                PurchInvLine.SETRANGE("No.", "Sales Invoice Line"."No.");

                IF statecode = 'CA' THEN
                    IF ItemSKU.GET('CA', Item."No.", "Sales Invoice Line"."Variant Code") THEN BEGIN
                        PurchInvLine.SETFILTER("Location Code", '%1|%2|%3', 'CA', 'LA', 'DS');
                        PurchInvLine.SETFILTER(Quantity, '<>0');
                        IF PurchInvLine.FINDLAST THEN
                            IF PurchInvLine."Direct Unit Cost" <> 0 THEN BEGIN
                                SKUCost := PurchInvLine."Direct Unit Cost";
                                FoundLastDirectCost := TRUE;
                            END;
                    END;
                IF statecode = 'AZ' THEN
                    IF ItemSKU.GET('AZ', Item."No.", "Sales Invoice Line"."Variant Code") THEN BEGIN
                        PurchInvLine.SETFILTER("Location Code", '%1|%2', 'AZ', 'DS');
                        IF PurchInvLine.FIND('+') THEN
                            IF PurchInvLine."Direct Unit Cost" <> 0 THEN BEGIN
                                SKUCost := PurchInvLine."Direct Unit Cost";
                                FoundLastDirectCost := TRUE;
                            END;
                    END;

            UNTIL (PurchInvHeader.NEXT = 0) OR FoundLastDirectCost;
    end;

    local procedure MakeExcelInfo()
    begin
        ExcelBuf.SetUseInfoSheet;
        ExcelBuf.AddInfoColumn(FORMAT(Text000), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyInformation.Name, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text001), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"AQD POD Cust/Item Sales New 2", FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);//
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text003), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FORMAT(Text002), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text004), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(USERID, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text005), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(TODAY, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(TIME, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text006), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(PrevMonthEndDate, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text007), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(PostDateFilter, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text008), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FORMAT(ContractType), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text010), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FORMAT(CostOption), FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text103), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(ExportVendorCrossRefNo, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text104), FALSE, TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CrossRefVendorNo, FALSE, FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.ClearNewRow;
        MakeExcelDataHeader;
    end;

    local procedure CreateExcelbook()
    begin
        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename(Text102);
        ExcelBuf.OpenExcel();
    end;

    procedure MakeExcelDataHeader()
    begin
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Item Sales', FALSE, '', true, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', TRUE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Document Date', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(TODAY, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[1], FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[2], FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(CompanyAddress[3], FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Phone No', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(CompanyInformation."Phone No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn('Fax No', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(CompanyInformation."Fax No.", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
    end;

    procedure UpdatePODCustomer()
    begin
        SalesPrice.SETRANGE(SalesPrice."Sales Code", SalesInvHeader."Sell-to Customer No.");
        SalesPrice.SETFILTER("AQD POD Customer", '<>%1', '');
        IF SalesPrice.FINDFIRST THEN BEGIN
            "Sales Invoice Line"."AQD POD Customer" := SalesPrice."AQD POD Customer";
            "Sales Invoice Line".MODIFY;
        END;
        Commit;
    end;

    procedure GetVendirCrossRefNo(ItemNo: Code[20]): Code[20];
    VAR
        ItemCrossReference: Record "Item Reference";
        Item: Record Item;
    BEGIN
        IF NOT Item.GET(ItemNo) THEN
            EXIT;

        ItemCrossReference.SETRANGE(ItemCrossReference."Item No.", ItemNo);
        ItemCrossReference.SETRANGE(ItemCrossReference."Reference Type", ItemCrossReference."Reference Type"::Vendor);
        ItemCrossReference.SETRANGE(ItemCrossReference."Reference Type No.", CrossRefVendorNo);
        IF ItemCrossReference.FINDFIRST THEN
            EXIT(ItemCrossReference."Reference No.")
        ELSE
            EXIT('');
    END;

    procedure CreateSheet(SheetName: Text[250])
    begin
        SheetName := DELCHR(SheetName, '=', '/');
        SheetName := DELCHR(SheetName, '=', '*');
        SheetName := DELCHR(SheetName, '=', '{');
        SheetName := DELCHR(SheetName, '=', '}');
        SheetName := COPYSTR(SheetName, 1, 31);
        ExcelBuf.SelectOrAddSheet(SheetName);
        ExcelBuf.WriteSheet('', COMPANYNAME, USERID);
        ExcelBuf.SetColumnWidth('A', 28);
        ExcelBuf.SetColumnWidth('B', 28);
        ExcelBuf.SetColumnWidth('C', 10);
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