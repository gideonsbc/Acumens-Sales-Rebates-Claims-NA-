codeunit 14302514 "AQD Sales Rebate Rate Calc Mgt"
{
    trigger OnRun()
    begin
    end;

    procedure FindSalesLineRebateRate(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesShptLine: Record "Sales Shipment Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        IsHandled: Boolean;
    begin
        TempSalesRebatesRate.RESET;
        IF TempSalesRebatesRate.IsTemporary THEN
            TempSalesRebatesRate.DeleteAll();

        BillToCustomer.GET(CustomerRebateDetailsLocIn."Bill-To Customer No.");
        // Case BillToCustomer."AQD CustRbt Calculation Date" OF
        //     BillToCustomer."AQD CustRbt Calculation Date"::" ",
        //     BillToCustomer."AQD CustRbt Calculation Date"::"Shipment Date":
        //         DocumentDate := CustomerRebateDetailsLocIn."Posting Date";
        //     BillToCustomer."AQD CustRbt Calculation Date"::"Rebate Order Date":
        //         DocumentDate := CustomerRebateDetailsLocIn."Rebate Order Date";
        // END;
        DocumentDate := CustomerRebateDetailsLocIn."Rebate Order Date";

        Case CustomerRebateDetailsLocIn."Document Type" OF
            CustomerRebateDetailsLocIn."Document Type"::"Unposted Order",
            CustomerRebateDetailsLocIn."Document Type"::"Unposted Invoice",
            CustomerRebateDetailsLocIn."Document Type"::"Unposted Return Order",
            CustomerRebateDetailsLocIn."Document Type"::"Unposted Credit Memo":
                begin
                    Case CustomerRebateDetailsLocIn."Document Type" of
                        CustomerRebateDetailsLocIn."Document Type"::"Unposted Order":
                            SalesLine.GET(SalesLine."Document Type"::Order,
                                          CustomerRebateDetailsLocIn."Document No.",
                                          CustomerRebateDetailsLocIn."Document Line No.");
                        CustomerRebateDetailsLocIn."Document Type"::"Unposted Invoice":
                            SalesLine.GET(SalesLine."Document Type"::Invoice,
                                          CustomerRebateDetailsLocIn."Document No.",
                                          CustomerRebateDetailsLocIn."Document Line No.");
                        CustomerRebateDetailsLocIn."Document Type"::"Unposted Return Order":
                            SalesLine.GET(SalesLine."Document Type"::"Return Order",
                                          CustomerRebateDetailsLocIn."Document No.",
                                          CustomerRebateDetailsLocIn."Document Line No.");
                        CustomerRebateDetailsLocIn."Document Type"::"Unposted Credit Memo":
                            SalesLine.GET(SalesLine."Document Type"::"Credit Memo",
                                          CustomerRebateDetailsLocIn."Document No.",
                                          CustomerRebateDetailsLocIn."Document Line No.");

                    End;
                    SalesLine.TESTFIELD("Qty. per Unit of Measure");
                    SetUoM(SalesLine."Unit of Measure Code",
                       ABS(CustomerRebateDetailsLocIn.Quantity),
                       SalesLine."Qty. per Unit of Measure");
                    UOM := SalesLine."Unit of Measure Code";
                end;
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

        IF NOT CustomerRebateDetailsLocIn.Ineligible THEN BEGIN
            CustomerRebateDetailsLocIn."CustRbt Rate Type" := TempSalesRebatesRate."CustRbt Rate Type";
            CustomerRebateDetailsLocIn."Rebate Type" := TempSalesRebatesRate."Rebate Type";
            CustomerRebateDetailsLocIn."Rebate %" := TempSalesRebatesRate."Rebate %";
            CustomerRebateDetailsLocIn."Rebate Per Unit" := TempSalesRebatesRate."Rebate Per Unit";
        END;
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
        LocalSalesRebatesRate: Record "AQD Sales Rebates Rate";
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
        OnSetSalesRebateRateFilter(SalesRebatesRate, CustomerRebateDetailsLocIn);

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
                        IF LocalCust."AQD Cust Rebate Category" <> '' then begin
                            SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Customer Category");
                            SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', LocalCust."AQD Cust Rebate Category");
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
                        IF LocalCust."AQD Cust Rebate Category" <> '' then begin
                            SalesRebatesRate.SetRange("Entity Type", SalesRebatesRate."Entity Type"::"Customer Category");
                            SalesRebatesRate.SetFilter("Entity No.", '%1|%2', ' ', LocalCust."AQD Cust Rebate Category");
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
        RebateDateFilter: text;
    begin
        FoundSalesRebate := CustomerSalesRebateRate.FindFirst();
        IF FoundSalesRebate THEN BEGIN
            REPEAT
                SalesQty := 0;
                SalesAmount := 0;

                IF CustomerSalesRebateRate."Starting Date" <> 0D THEN
                    RebateDateFilter := FORMAT(CustomerSalesRebateRate."Starting Date");

                IF (CustomerSalesRebateRate."Ending Date" <> 0D) THEN BEGIN
                    RebateDateFilter := RebateDateFilter + '..' + FORMAT(CustomerSalesRebateRate."Ending Date")
                END ELSE
                    IF RebateDateFilter <> '' THEN
                        RebateDateFilter := RebateDateFilter + '..';

                //IF CustomerRebateDetailsLocIn.Preview THEN begin
                //SalesQty += CustomerRebateDetailsLocIn.Quantity;
                //SalesAmount += CustomerRebateDetailsLocIn.Amount;
                //end;
                SalesQty := CustomerRebateDetailsLocIn.Quantity;
                SalesAmount := CustomerRebateDetailsLocIn.Amount;

                CASE CustomerSalesRebateRate."Entity Type" OF
                    CustomerSalesRebateRate."Entity Type"::Customer,
                    CustomerSalesRebateRate."Entity Type"::"Employee Commission",
                    CustomerSalesRebateRate."Entity Type"::"Vendor Commission":
                        BEGIN
                            IF CustomerSalesRebateRate."CustRbt Rate Type" = CustomerSalesRebateRate."CustRbt Rate Type"::"Volume Rebate" THEN BEGIN
                                Case CustomerSalesRebateRate."Line Type" OF
                                    CustomerSalesRebateRate."Line Type"::Item:
                                        BEGIN
                                            ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                            ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                            ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                            ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                            SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                            SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                        END;
                                    CustomerSalesRebateRate."Line Type"::"Rebate Category":
                                        BEGIN
                                            ItemRec.RESET;
                                            ItemRec.SETRANGE("AQD Cust Rebate Category Code", CustomerRebateDetailsLocIn."Rebate Item Category Code");
                                            IF ItemRec.FINDFIRST THEN BEGIN
                                                REPEAT
                                                    ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                    ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                    ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                    SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                    SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                UNTIL ItemRec.Next() = 0;
                                            END;
                                        END;
                                End;
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
                    CustomerSalesRebateRate."Entity Type"::"Customer Category":
                        BEGIN
                            CustomerRec.RESET;
                            CustomerRec.SetRange("AQD Cust Rebate Category", CustomerSalesRebateRate."No.");
                            IF CustomerRec.FINDFIRST THEN BEGIN
                                REPEAT
                                    Case CustomerSalesRebateRate."Line Type" OF
                                        CustomerSalesRebateRate."Line Type"::Item:
                                            BEGIN
                                                ItemRec.GET(CustomerRebateDetailsLocIn."No.");
                                                ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                            END;
                                        CustomerSalesRebateRate."Line Type"::"Rebate Category":
                                            BEGIN
                                                ItemRec.RESET;
                                                ItemRec.SETRANGE("AQD Cust Rebate Category Code", CustomerRebateDetailsLocIn."Rebate Item Category Code");
                                                IF ItemRec.FINDFIRST THEN BEGIN
                                                    REPEAT
                                                        ItemRec.SetFilter("AQD CustRbt Source No. Filter", CustomerRebateDetailsLocIn."Sell-To Customer No.");
                                                        ItemRec.SetFilter("Date Filter", RebateDateFilter);

                                                        ItemRec.CalcFields("AQD Cust Rbt Sales (Qty.)", "AQD Cust Rbt Sales (LCY)");
                                                        SalesQty += ItemRec."AQD Cust Rbt Sales (Qty.)";
                                                        SalesAmount += ItemRec."AQD Cust Rbt Sales (LCY)";
                                                    UNTIL ItemRec.Next() = 0;
                                                END;
                                            END;
                                    End;
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
        END;
        CustomerRebateDetailsLocIn.Ineligible := NOT BestSalesRebateFound;
        // Below assignment is to allow to insert record
        IF CustomerRebateDetailsLocIn.Ineligible THEN BEGIN
            BestCustomerSalesRebate."Rebate Type" := BestCustomerSalesRebate."Rebate Type"::"Per Quantity";
            IF CustomerRebateDetailsLocIn."Document Type" IN
                          [CustomerRebateDetailsLocIn."Document Type"::"Unposted Order",
                           CustomerRebateDetailsLocIn."Document Type"::"Unposted Invoice",
                           CustomerRebateDetailsLocIn."Document Type"::"Unposted Return Order",
                           CustomerRebateDetailsLocIn."Document Type"::"Unposted Credit Memo"]
                        THEN
                CustomerRebateDetailsLocIn.Description := 'No Rebate Rate Found';
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

    [IntegrationEvent(false, false)]
    local procedure OnSetSalesRebateRateFilter(var SalesRebatesRate: Record "AQD Sales Rebates Rate"; var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    begin
    end;

    var
        TempSalesRebatesRate: Record "AQD Sales Rebates Rate" temporary;
        Cust: Record Customer;
        BillToCustomer: Record Customer;
        UnitofMeasureCode: Code[10];
        DocumentDate: Date;
        Qty: decimal;
        QtyPerUOM: Decimal;
        UOM: Code[10];
}