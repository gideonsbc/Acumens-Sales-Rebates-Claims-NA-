codeunit 14301916 "AQD Sales Rebate Rate Calc Mgt"
{

    trigger OnRun()
    begin
    end;

    procedure FindSalesLineRebateRate(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        IsHandled: Boolean;
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesShptLine: Record "Sales Shipment Line";
        ReturnReceiptLine: Record "Return Receipt Line";
    begin
        TempSalesRebatesRate.RESET;
        IF TempSalesRebatesRate.IsTemporary THEN
            TempSalesRebatesRate.DeleteAll();

        BillToCustomer.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.");
        Case BillToCustomer."AQD Calculation Date" OF
            BillToCustomer."AQD Calculation Date"::" ",
            BillToCustomer."AQD Calculation Date"::"Shipment Date":
                DocumentDate := CustomerRebateDetailsLocIn."Posting Date";
            BillToCustomer."AQD Calculation Date"::"Rebate Order Date":
                DocumentDate := CustomerRebateDetailsLocIn."Rebate Order Date";
        END;

        Case CustomerRebateDetailsLocIn."Document Type" OF
            CustomerRebateDetailsLocIn."Document Type"::Invoice:
                begin
                    SalesInvLine.GET(CustomerRebateDetailsLocIn."Document No.", CustomerRebateDetailsLocIn."Document Line No.");
                    SalesInvLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(SalesInvLine."Unit of Measure Code",
                           ABS(CustomerRebateDetailsLocIn.Quantity),
                           SalesInvLine."Qty. per Unit of Measure");
                    UOM := SalesInvLine."Unit of Measure Code";
                end;
            CustomerRebateDetailsLocIn."Document Type"::"Credit Memo":
                BEGIN
                    SalesCrMemoLine.GET(CustomerRebateDetailsLocIn."Document No.", CustomerRebateDetailsLocIn."Document Line No.");
                    SalesCrMemoLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(SalesCrMemoLine."Unit of Measure Code",
                           ABS(CustomerRebateDetailsLocIn.Quantity),
                           SalesCrMemoLine."Qty. per Unit of Measure");

                    UOM := SalesCrMemoLine."Unit of Measure Code";
                END;
            CustomerRebateDetailsLocIn."Document Type"::Shipment:
                begin
                    SalesShptLine.GET(CustomerRebateDetailsLocIn."Document No.", CustomerRebateDetailsLocIn."Document Line No.");
                    SalesShptLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(SalesShptLine."Unit of Measure Code",
                           ABS(CustomerRebateDetailsLocIn.Quantity),
                           SalesShptLine."Qty. per Unit of Measure");
                    UOM := SalesShptLine."Unit of Measure Code";
                end;
            CustomerRebateDetailsLocIn."Document Type"::"Return Receipt":
                BEGIN
                    ReturnReceiptLine.GET(CustomerRebateDetailsLocIn."Document No.", CustomerRebateDetailsLocIn."Document Line No.");
                    ReturnReceiptLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(ReturnReceiptLine."Unit of Measure Code",
                           ABS(CustomerRebateDetailsLocIn.Quantity),
                           ReturnReceiptLine."Qty. per Unit of Measure");
                    UOM := ReturnReceiptLine."Unit of Measure Code";
                END;
        End;

        Cust.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.");
        SalesLineRebateExists(CustomerRebateDetailsLocIn);
        CalcBestSalesRebateRate(TempSalesRebatesRate);

        CustomerRebateDetailsLocIn."Rebate Type" := TempSalesRebatesRate."Rebate Type";
        CustomerRebateDetailsLocIn."Rebate %" := TempSalesRebatesRate."Rebate %";
        CustomerRebateDetailsLocIn."Rebate Per Quantity" := TempSalesRebatesRate."Rebate Per Quantity";
    END;

    procedure SalesLineRebateExists(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details"): Boolean;
    var
        IsHandled: Boolean;
    begin
        FindSalesRebateRate(CustomerRebateDetailsLocIn);
        EXIT(TempSalesRebatesRate.FINDFIRST);
    end;

    procedure FindSalesRebateRate(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        SalesRebatesRate: Record "AQD Sales Rebates Rate";
        LocalCust: Record Customer;
        ItemCard: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        CustomerRebateItemCategories: Record "AQD Cust Rebate Item Category";
        RebateCategoryCodeFilter: Code[50];
    begin
        TempSalesRebatesRate.RESET;
        IF TempSalesRebatesRate.ISTEMPORARY THEN
            TempSalesRebatesRate.DELETEALL;

        SalesRebatesRate.RESET;
        CASE CustomerRebateDetailsLocIn.Type OF
            CustomerRebateDetailsLocIn.Type::Item:
                begin
                    ItemCard.GET(CustomerRebateDetailsLocIn."No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::Item);
                end;
            CustomerRebateDetailsLocIn.Type::Resource:
                BEGIN
                    Resource.GET(CustomerRebateDetailsLocIn."No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::Resource);
                END;
            CustomerRebateDetailsLocIn.Type::"G/L Account":
                BEGIN
                    GLAccount.GET(CustomerRebateDetailsLocIn."No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"G/L Account");
                END;
            CustomerRebateDetailsLocIn.Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(CustomerRebateDetailsLocIn."No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Charge (Item)");
                END;
            CustomerRebateDetailsLocIn.TYPE::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(CustomerRebateDetailsLocIn."No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Fixed Asset");
                END;
        END;
        SalesRebatesRate.SetFilter("No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."No.");
        SalesRebatesRate.SETFILTER("Variant Code", '%1|%2', '', '');
        SalesRebatesRate.SETFILTER("Ending Date", '%1|>=%2', 0D, DocumentDate);
        IF UOM <> '' THEN
            SalesRebatesRate.SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
        SalesRebatesRate.SETRANGE("Starting Date", 0D, DocumentDate);
        SalesRebatesRate.SETRANGE(Blocked, false);
        SalesRebatesRate.SetRange("Rebate Program Code", CustomerRebateDetailsLocIn."Rebate Program Code");
        SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::"All Customers");
        SalesRebatesRate.SetRange("Customer No.");
        CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

        SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::Customer);
        SalesRebatesRate.SetFilter("Customer No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Bill-To Customer No.");
        CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

        IF LocalCust.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.") THEN BEGIN
            IF LocalCust."AQD Rebate Customer Type" <> '' then begin
                SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::"Customer Type");
                SalesRebatesRate.SetFilter("Customer No.", '%1|%2', ' ', LocalCust."AQD Rebate Customer Type");
                CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
            end;
        END;

        SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::"All Customers");
        SalesRebatesRate.SetRange("Customer No.");
        SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Rebate Category");
        SalesRebatesRate.SetFilter("No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Rebate Item Category Code");
        SalesRebatesRate.SetRange("Variant Code");
        SalesRebatesRate.SetRange("Unit of Measure Code");
        CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

        SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::Customer);
        SalesRebatesRate.SetFilter("Customer No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Bill-To Customer No.");
        CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

        IF LocalCust.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.") THEN BEGIN
            IF LocalCust."AQD Rebate Customer Type" <> '' then begin
                SalesRebatesRate.SetRange("Customer Type", SalesRebatesRate."Customer Type"::"Customer Type");
                SalesRebatesRate.SetFilter("Customer No.", '%1|%2', ' ', LocalCust."AQD Rebate Customer Type");
                CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
            end;
        END;
    END;

    procedure CalcBestSalesRebateRate(var CustomerSalesRebateRate: Record "AQD Sales Rebates Rate")
    var
        BestCustomerSalesRebate: Record "AQD Sales Rebates Rate";
        BestSalesRebateFound: Boolean;
        FoundSalesRebate: Boolean;
    begin
        FoundSalesRebate := CustomerSalesRebateRate.FINDSET;
        IF FoundSalesRebate THEN
            REPEAT
                IF IsInMinQty(CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                    CASE TRUE OF
                        ((BestCustomerSalesRebate."Variant Code" = '') OR (CustomerSalesRebateRate."Variant Code" <> '')):
                            BEGIN
                                BestCustomerSalesRebate := CustomerSalesRebateRate;
                                BestSalesRebateFound := TRUE;
                            END;
                    END;
                END;
            UNTIL CustomerSalesRebateRate.NEXT = 0;
        TempSalesRebatesRate := BestCustomerSalesRebate;
    end;

    local procedure CopyCustomerSalesRebateToCustomerSalesRebate(var FromCustomerSalesRebateRate: Record "AQD Sales Rebates Rate"; var ToCustomerSalesRebateRate: Record "AQD Sales Rebates Rate" temporary)
    begin
        IF FromCustomerSalesRebateRate.FINDSET THEN
            REPEAT
                ToCustomerSalesRebateRate := FromCustomerSalesRebateRate;
                ToCustomerSalesRebateRate.INSERT;
            UNTIL FromCustomerSalesRebateRate.NEXT = 0;
    end;

    LOCAL procedure SetUoM(UnitofMeasureCode2: Code[10]; Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        UnitofMeasureCode := UnitofMeasureCode2;
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure IsInMinQty(MinQty: Decimal): Boolean
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;

    var
        TempSalesRebatesRate: Record "AQD Sales Rebates Rate" temporary;
        //Item: Record Item;
        Cust: Record Customer;
        BillToCustomer: Record Customer;
        UnitofMeasureCode: Code[10];
        DocumentDate: Date;
        Qty: decimal;
        QtyPerUOM: Decimal;
        UOM: Code[10];
}