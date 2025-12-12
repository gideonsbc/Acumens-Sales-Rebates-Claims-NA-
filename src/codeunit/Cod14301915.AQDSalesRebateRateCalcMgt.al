codeunit 14301915 "AQD Sales Rebate Rate Calc Mgt"
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
        Case BillToCustomer."AQD CustRbt Calculation Date" OF
            BillToCustomer."AQD CustRbt Calculation Date"::" ",
            BillToCustomer."AQD CustRbt Calculation Date"::"Shipment Date":
                DocumentDate := CustomerRebateDetailsLocIn."Posting Date";
            BillToCustomer."AQD CustRbt Calculation Date"::"Rebate Order Date":
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
        CalcBestSalesRebateRate(CustomerRebateDetailsLocIn, TempSalesRebatesRate);

        CustomerRebateDetailsLocIn."Rebate Type" := TempSalesRebatesRate."Rebate Type";
        CustomerRebateDetailsLocIn."Rebate %" := TempSalesRebatesRate."Rebate %";
        CustomerRebateDetailsLocIn."Rebate Per Unit" := TempSalesRebatesRate."Rebate Per Unit";
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
        ItemCategories: Record "Item Category";
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
        //SalesRebatesRate.SETRANGE("Starting Date", 0D, DocumentDate);
        SalesRebatesRate.SETFILTER("Starting Date", '%1|<=%2', 0D, DocumentDate);
        SalesRebatesRate.SETRANGE(Blocked, false);
        SalesRebatesRate.SetRange("Rebate Program Code", CustomerRebateDetailsLocIn."Rebate Program Code");
        SalesRebatesRate.SETFILTER("Territory Code", '%1|%2', CustomerRebateDetailsLocIn."Territory Code", '');

        CASE CustomerRebateDetailsLocIn."Entity Type" OF
            CustomerRebateDetailsLocIn."Entity Type"::Customer:
                BEGIN
                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"All Customers");
                    SalesRebatesRate.SetRange("Entity No.");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::Customer);
                    SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Bill-To Customer No.");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    IF LocalCust.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.") THEN BEGIN
                        IF LocalCust."AQD Customer Rebate Category" <> '' then begin
                            SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Customer Category");
                            SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', LocalCust."AQD Customer Rebate Category");
                            CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
                        end;
                    END;

                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"All Customers");
                    SalesRebatesRate.SetRange("Entity No.");
                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Rebate Category");
                    SalesRebatesRate.SetFilter("No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Rebate Item Category Code");
                    SalesRebatesRate.SetRange("Variant Code");
                    SalesRebatesRate.SetRange("Unit of Measure Code");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::Customer);
                    SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Bill-To Customer No.");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    IF LocalCust.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.") THEN BEGIN
                        IF LocalCust."AQD Customer Rebate Category" <> '' then begin
                            SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Customer Category");
                            SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', LocalCust."AQD Customer Rebate Category");
                            CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
                        end;
                    END;
                END;
            CustomerRebateDetailsLocIn."Entity Type"::Employee:
                BEGIN
                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Employee Commission");
                    SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Entity No.");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Rebate Category");
                    SalesRebatesRate.SetFilter("No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Rebate Item Category Code");
                    SalesRebatesRate.SetRange("Variant Code");
                    SalesRebatesRate.SetRange("Unit of Measure Code");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
                END;
            CustomerRebateDetailsLocIn."Entity Type"::Vendor:
                BEGIN
                    SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Vendor Commission");
                    SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Entity No.");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);

                    SalesRebatesRate.SetRange("Line Type", SalesRebatesRate."Line Type"::"Rebate Category");
                    SalesRebatesRate.SetFilter("No.", '%1|%2', ' ', CustomerRebateDetailsLocIn."Rebate Item Category Code");
                    SalesRebatesRate.SetRange("Variant Code");
                    SalesRebatesRate.SetRange("Unit of Measure Code");
                    CopyCustomerSalesRebateToCustomerSalesRebate(SalesRebatesRate, TempSalesRebatesRate);
                END;
        END;
    END;

    procedure CalcBestSalesRebateRate(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details"; var CustomerSalesRebateRate: Record "AQD Sales Rebates Rate")
    var
        BestCustomerSalesRebate: Record "AQD Sales Rebates Rate";
        ItemRec: Record Item;
        CustomerRec: Record Customer;
        BestSalesRebateFound: Boolean;
        FoundSalesRebate: Boolean;
        SalesQty: Decimal;
        SalesAmount: Decimal;
    begin
        SalesQty := 0;
        SalesAmount := 0;

        FoundSalesRebate := CustomerSalesRebateRate.FindFirst();
        IF FoundSalesRebate THEN BEGIN
            REPEAT
                // IF IsInMinQty(CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                //     CASE TRUE OF
                //         ((BestCustomerSalesRebate."Variant Code" = '') OR (CustomerSalesRebateRate."Variant Code" <> '')):
                //             BEGIN
                //                 BestCustomerSalesRebate := CustomerSalesRebateRate;
                //                 BestSalesRebateFound := TRUE;
                //             END;
                //     END;
                // END;
                CASE CustomerSalesRebateRate."Entity Type" OF
                    CustomerSalesRebateRate."Entity Type"::Customer,
                    CustomerSalesRebateRate."Entity Type"::"Employee Commission",
                    CustomerSalesRebateRate."Entity Type"::"Vendor Commission":
                        BEGIN
                            ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                            ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                            ItemRec.SetFilter("Date Filter", '%1..%2',
                                CustomerSalesRebateRate."Starting Date",
                                CustomerSalesRebateRate."Ending Date");
                            ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                            SalesQty := ItemRec."AQD Cust Rbt Sales (Qty.)";
                            SalesAmount := ItemRec."AQD Cust Rbt Sales (LCY)";
                            Case TRUE of
                                (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                    BEGIN
                                        IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") AND
                                           (SalesAmount >= CustomerSalesRebateRate."Minimum Amount")
                                        THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" = 0):
                                    BEGIN
                                        IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                    BEGIN
                                        IF (SalesAmount >= CustomerSalesRebateRate."Minimum Amount") THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" = 0):
                                    BEGIN
                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                        BestSalesRebateFound := TRUE;
                                    END;
                            End;
                        END;
                    CustomerSalesRebateRate."Entity Type"::"Customer Category":
                        BEGIN
                            CustomerRec.RESET;
                            CustomerRec.SetRange("AQD Customer Rebate Category", CustomerSalesRebateRate."No.");
                            IF CustomerRec.FINDFIRST THEN BEGIN
                                REPEAT
                                    ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                    ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRec."No.");
                                    ItemRec.SetFilter("Date Filter", '%1..%2',
                                        CustomerSalesRebateRate."Starting Date",
                                        CustomerSalesRebateRate."Ending Date");
                                    ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                    SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                    SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                UNTIL CustomerRec.NEXT = 0;
                            END;

                            Case TRUE of
                                (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                    BEGIN
                                        IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") AND
                                           (SalesAmount >= CustomerSalesRebateRate."Minimum Amount")
                                        THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" <> 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" = 0):
                                    BEGIN
                                        IF (SalesQty >= CustomerSalesRebateRate."Minimum Quantity") THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" <> 0):
                                    BEGIN
                                        IF (SalesAmount >= CustomerSalesRebateRate."Minimum Amount") THEN BEGIN
                                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                                            BestSalesRebateFound := TRUE;
                                        END;
                                    END;
                                (CustomerSalesRebateRate."Minimum Quantity" = 0) AND
                                (CustomerSalesRebateRate."Minimum Amount" = 0):
                                    BEGIN
                                        BestCustomerSalesRebate := CustomerSalesRebateRate;
                                        BestSalesRebateFound := TRUE;
                                    END;
                            End;
                        END;
                    CustomerSalesRebateRate."Entity Type"::"All Customers":
                        BEGIN
                            BestCustomerSalesRebate := CustomerSalesRebateRate;
                            BestSalesRebateFound := TRUE;
                        END;
                END;
            UNTIL CustomerSalesRebateRate.NEXT = 0;
            CustomerRebateDetailsLocIn.Ineligible := NOT BestSalesRebateFound;
            // Below assignment is to allow to insert record
            IF CustomerRebateDetailsLocIn.Ineligible THEN
                BestCustomerSalesRebate."Rebate Type" := BestCustomerSalesRebate."Rebate Type"::"Per Quantity";
        END;
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