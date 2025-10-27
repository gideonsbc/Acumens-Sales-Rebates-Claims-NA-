codeunit 14277012 "AQD Sales Rebate Calc. Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        TempSalesRebates: Record "AQD Sales Rebates Setup" temporary;
        Item: Record Item;
        BillToCustomerNo: Code[20];
        //CustomerPriceGroup: Code[10];
        ItemNo: Code[20];
        VariantCode: Code[10];
        UnitofMeasureCode: Code[10];
        PostingDate: Date;
        Qty: Decimal;
        QtyPerUOM: Decimal;

    procedure FindSalesLineRebate(var RebateEntryIn: Record "AQD Rebate Entry")
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        IsHandled: Boolean;
        Item: Record Item;
    begin
        CASE RebateEntryIn."Document Type" OF
            RebateEntryIn."Document Type"::Invoice:
                BEGIN
                    SalesInvLine.GET(RebateEntryIn."Document No.", RebateEntryIn."Document Line No.");
                    SalesInvLine.TESTFIELD("Qty. per Unit of Measure");

                    SetUoM(ABS(SalesInvLine.Quantity), SalesInvLine."Qty. per Unit of Measure");
                    Item.GET(SalesInvLine."No.");

                    BillToCustomerNo := SalesInvLine."Bill-to Customer No.";
                    PostingDate := SalesInvLine."Posting Date";
                    //CustomerPriceGroup := SalesInvLineIn."Customer Price Group";
                    ItemNo := SalesInvLine."No.";
                    VariantCode := SalesInvLine."Variant Code";
                    UnitofMeasureCode := SalesInvLine."Unit of Measure Code";
                END;
            RebateEntryIn."Document Type"::"Credit Memo":
                BEGIN
                    SalesCrMemoLine.GET(RebateEntryIn."Document No.", RebateEntryIn."Document Line No.");
                    SalesCrMemoLine.TESTFIELD("Qty. per Unit of Measure");

                    SetUoM(ABS(SalesCrMemoLine.Quantity), SalesCrMemoLine."Qty. per Unit of Measure");
                    Item.GET(SalesCrMemoLine."No.");

                    BillToCustomerNo := SalesCrMemoLine."Bill-to Customer No.";
                    PostingDate := SalesCrMemoLine."Posting Date";
                    //CustomerPriceGroup := SalesCrMemoLine."Customer Price Group";
                    ItemNo := SalesCrMemoLine."No.";
                    VariantCode := SalesCrMemoLine."Variant Code";
                    UnitofMeasureCode := SalesCrMemoLine."Unit of Measure Code";
                END;
        END;

        SalesRebateExists(BillToCustomerNo, RebateEntryIn."Rebate Item Category Code", ItemNo, VariantCode, UnitofMeasureCode, PostingDate);
        CalcBestRebate(TempSalesRebates);

        RebateEntryIn."Rebate Type" := TempSalesRebates."Rebate Type";
        RebateEntryIn."Rebate %" := TempSalesRebates."Rebate %";
        RebateEntryIn."Rebate Per Quantity" := TempSalesRebates."Rebate Per Quantity";
    end;

    procedure SalesRebateExists(BillToCustomerNoIn: Code[20]; CustomerPriceGroupIn: Code[10]; ItemNoIn: Code[20]; VariantCodeIn: Code[10]; UnitofMeasureCodeIn: Code[10]; PostingDateIn: Date): Boolean
    var
        IsHandled: Boolean;
    begin
        FindSalesRebate(TempSalesRebates, BillToCustomerNoIn, CustomerPriceGroupIn, ItemNoIn, VariantCodeIn, UnitofMeasureCodeIn, PostingDateIn);
        EXIT(TempSalesRebates.FINDFIRST);
    end;

    procedure FindSalesRebate(var ToSalesRebateSetup: Record "AQD Sales Rebates Setup" temporary; CustNo: Code[20]; CustPriceGrCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; StartingDate: Date)
    var
        FromSalesRebate: Record "AQD Sales Rebates Setup";
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
    begin
        ToSalesRebateSetup.RESET;
        IF ToSalesRebateSetup.ISTEMPORARY THEN
            ToSalesRebateSetup.DELETEALL;

        FromSalesRebate.SETRANGE("No.", ItemNo);
        FromSalesRebate.SETFILTER("Variant Code", '%1|%2', VariantCode, '');
        FromSalesRebate.SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
        IF UOM <> '' THEN
            FromSalesRebate.SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
        FromSalesRebate.SETRANGE("Starting Date", 0D, StartingDate);
        FromSalesRebate.SETRANGE("Customer Type", FromSalesRebate."Customer Type"::"All Customers");
        FromSalesRebate.SETRANGE("Customer No.");
        CopySalesRebateToSalesRebate(FromSalesRebate, ToSalesRebateSetup);

        IF CustNo <> '' THEN BEGIN
            FromSalesRebate.SETRANGE("Customer Type", FromSalesRebate."Customer Type"::Customer);
            FromSalesRebate.SETRANGE("Customer No.", CustNo);
            CopySalesRebateToSalesRebate(FromSalesRebate, ToSalesRebateSetup);
        END;

        IF CustPriceGrCode <> '' THEN BEGIN
            FromSalesRebate.SETRANGE("Customer Type", FromSalesRebate."Customer Type"::"Customer Type");
            FromSalesRebate.SETRANGE("Customer No.", CustPriceGrCode);
            CopySalesRebateToSalesRebate(FromSalesRebate, ToSalesRebateSetup);
        END;
    END;

    procedure CalcBestRebate(var SalesRebatesSetup: Record "AQD Sales Rebates Setup")
    var
        BestSalesRebateSetup: Record "AQD Sales Rebates Setup";
        BestSalesRebateFound: Boolean;
        FoundSalesRebate: Boolean;
    begin
        FoundSalesRebate := SalesRebatesSetup.FINDSET;
        IF FoundSalesRebate THEN
            REPEAT
                IF IsInMinQty(SalesRebatesSetup."Unit of Measure Code", SalesRebatesSetup."Minimum Quantity") THEN BEGIN
                    CASE TRUE OF
                        ((BestSalesRebateSetup."Variant Code" = '') OR (SalesRebatesSetup."Variant Code" <> '')):
                            BEGIN
                                BestSalesRebateSetup := SalesRebatesSetup;
                                BestSalesRebateFound := TRUE;
                            END;
                    END;
                END;
            UNTIL SalesRebatesSetup.NEXT = 0;
        SalesRebatesSetup := BestSalesRebateSetup;
    end;

    local procedure CopySalesRebateToSalesRebate(var FromSalesRebateSetup: Record "AQD Sales Rebates Setup"; var ToSalesRebateSetup: Record "AQD Sales Rebates Setup" temporary)
    begin
        IF FromSalesRebateSetup.FINDSET THEN
            REPEAT
                ToSalesRebateSetup := FromSalesRebateSetup;
                ToSalesRebateSetup.INSERT;
            UNTIL FromSalesRebateSetup.NEXT = 0;
    end;

    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;
}