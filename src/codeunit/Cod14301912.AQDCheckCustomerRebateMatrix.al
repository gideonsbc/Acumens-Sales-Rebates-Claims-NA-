codeunit 14301912 "AQD ChkCustItemRbt Matrix Mgt"
{

    trigger OnRun()
    begin
    end;

    procedure IsBillToCustomerEligibleForRebate(var CustItemRebateMatrix: Record "AQD Cust Item Rebate Tiers"; CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; PostingDate: Date; RebateCode: Code[10]): Boolean
    var
        LocalCustomer: Record Customer;
        ItemCard: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        IsHandled: Boolean;
        RebateCategoryCode: Code[20];
        IsCustomerEligible: Boolean;
    begin
        IsCustomerEligible := FALSE;
        RebateSetup.GET;

        IF NOT RebateSetup."Use Cust Rebate Tiers" then
            EXIT(TRUE);

        CustItemRebateMatrix.RESET;
        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                begin
                    ItemCard.GET(DocumentLine_No);
                    RebateCategoryCode := ItemCard."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::Item);
                end;
        END;
        CustItemRebateMatrix.SetFilter("No.", '%1|%2', ' ', DocumentLine_No);
        CustItemRebateMatrix.SetRange("Rebate Program Code", RebateCode);
        CustItemRebateMatrix.SETRANGE(Blocked, false);

        CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::Customer);
        CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', CustomerNo);
        IF CustItemRebateMatrix.FindFirst() THEN begin
            IsCustomerEligible := CheckCustomerItemRebateEligibility(CustomerNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    CustItemRebateMatrix,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsCustomerEligible);
        end;

        IF LocalCustomer.GET(CustomerNo) THEN BEGIN
            IF LocalCustomer."AQD Cust Rebate Category Code" <> '' then begin
                CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"Customer Category");
                CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', LocalCustomer."AQD Cust Rebate Category Code");
                IF CustItemRebateMatrix.FindFirst() THEN begin
                    IsCustomerEligible := CheckCustomerItemRebateEligibility(CustomerNo,
                                            DocumentLine_Type,
                                            DocumentLine_No,
                                            CustItemRebateMatrix,
                                            PostingDate,
                                            RebateCode);

                    EXIT(IsCustomerEligible);
                end;
            end;
        END;

        CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"All Customers");
        CustItemRebateMatrix.SetRange("Customer No.");
        IF CustItemRebateMatrix.FindFirst() THEN begin
            IsCustomerEligible := CheckCustomerItemRebateEligibility(
                                    CustomerNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    CustItemRebateMatrix,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsCustomerEligible);
        end;

        CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::Customer);
        CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', CustomerNo);
        IF CustItemRebateMatrix.FindFirst() THEN begin
            IsCustomerEligible := CheckCustomerItemRebateEligibility(CustomerNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    CustItemRebateMatrix,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsCustomerEligible);
        end;

        IF LocalCustomer.GET(CustomerNo) THEN BEGIN
            IF LocalCustomer."AQD Cust Rebate Category Code" <> '' then begin
                CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"Customer Category");
                CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', LocalCustomer."AQD Cust Rebate Category Code");
                IF CustItemRebateMatrix.FindFirst() THEN begin
                    IsCustomerEligible := CheckCustomerItemRebateEligibility(CustomerNo,
                                            DocumentLine_Type,
                                            DocumentLine_No,
                                            CustItemRebateMatrix,
                                            PostingDate,
                                            RebateCode);
                    EXIT(IsCustomerEligible);
                end;
            end;
        END;

        CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"All Customers");
        CustItemRebateMatrix.SetRange("Customer No.");
        CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::"Rebate Category");
        CustItemRebateMatrix.SetFilter("No.", '%1|%2', ' ', RebateCategoryCode);
        IF CustItemRebateMatrix.FindFirst() THEN begin
            IsCustomerEligible := CheckCustomerItemRebateEligibility(CustomerNo,
                                    DocumentLine_Type,
                                    DocumentLine_No,
                                    CustItemRebateMatrix,
                                    PostingDate,
                                    RebateCode);
            EXIT(IsCustomerEligible);
        end;

        EXIT(TRUE);
    END;

    local procedure CopyCustomerSalesRebateToCustomerSalesRebate(var FromCustItemRebateMatrix: Record "AQD Cust Item Rebate Tiers"; var ToCustItemRebateMatrix: Record "AQD Cust Item Rebate Tiers" temporary)
    begin
        IF FromCustItemRebateMatrix.FINDSET THEN
            REPEAT
                ToCustItemRebateMatrix := FromCustItemRebateMatrix;
                ToCustItemRebateMatrix.INSERT;
            UNTIL FromCustItemRebateMatrix.NEXT = 0;
    END;

    local procedure CheckCustomerItemRebateEligibility(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; var CustItemRebateMatrix: Record "AQD Cust Item Rebate Tiers"; PostingDate: Date; RebateCode: Code[10]): Boolean
    var
        LocalItem: Record Item;
        LocalItemLedgerEntry: Record "Item Ledger Entry";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        IsEligible: Boolean;
        FirstReceiptDateCriteria: Date;
        LocaltotalRebateCategorySalesQty: Decimal;
        LocaltotalRebateCategorySalesLCY: Decimal;
        LocaltotalRebateCategorySalesQtyYTD: Decimal;
        LocaltotalRebateCategorySalesLCYYTD: Decimal;
        LocalEligiblePeriodAfterFirstShpt: Boolean;
        StartDate: Date;
    begin
        LocaltotalRebateCategorySalesQty := 0;
        LocaltotalRebateCategorySalesLCY := 0;
        LocaltotalRebateCategorySalesQtyYTD := 0;
        LocaltotalRebateCategorySalesLCYYTD := 0;
        LocalEligiblePeriodAfterFirstShpt := FALSE;

        StartDate := DMY2Date(01, 01, Date2DMY(Today, 3));

        IsEligible := TRUE;
        RebateSetup.GET;
        if not RebateSetup."Use Cust Rebate Tiers" then
            EXIT(TRUE);

        CLEAR(LocalItem);

        CASE CustItemRebateMatrix."Line Type" OF
            CustItemRebateMatrix."Line Type"::Item:
                BEGIN
                    LocalItem.GET(DocumentLine_No);
                    LocalItem.CalcFields("Sales (Qty.)", "Sales (LCY)");

                    //IF (CustItemRebateMatrix."Sales Quantity Threshold" <> 0) AND
                    IF (CustItemRebateMatrix."Sales Quantity Threshold" > LocalItem."Sales (Qty.)") THEN
                        IsEligible := FALSE;

                    //IF (CustItemRebateMatrix."Sales Amount Threshold" <> 0) AND
                    IF (CustItemRebateMatrix."Sales Amount Threshold" > LocalItem."Sales (LCY)") THEN
                        IsEligible := FALSE;

                    LocalItem.SetFilter("Date Filter", '%1..%2', StartDate, Today);
                    LocalItem.CalcFields("Sales (Qty.)", "Sales (LCY)");
                    IF (CustItemRebateMatrix."Sales Quantity Threshold (YTD)" > LocalItem."Sales (Qty.)") THEN
                        IsEligible := FALSE;

                    IF (CustItemRebateMatrix."Sales Amount Threshold (YTD)" > LocalItem."Sales (LCY)") THEN
                        IsEligible := FALSE;

                    IF (FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt) <> '') THEN BEGIN
                        FirstReceiptDateCriteria := CalcDate('-' + FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt), PostingDate);

                        LocalItemLedgerEntry.RESET;
                        LocalItemLedgerEntry.SetRange("Entry Type", LocalItemLedgerEntry."Entry Type"::Sale);
                        LocalItemLedgerEntry.SETFILTER("Document Type", '%1|%2',
                            LocalItemLedgerEntry."Document Type"::"Sales Shipment",
                            LocalItemLedgerEntry."Document Type"::"Sales Invoice");
                        LocalItemLedgerEntry.SETRANGE("Item No.", DocumentLine_No);
                        LocalItemLedgerEntry.SETRANGE("Source Type", LocalItemLedgerEntry."Source Type"::Customer);
                        LocalItemLedgerEntry.SETRANGE("Source No.", CustomerNo);
                        LocalItemLedgerEntry.SETFILTER("Posting Date", '<=%1', FirstReceiptDateCriteria);
                        IF NOT LocalItemLedgerEntry.FindFirst() THEN
                            IsEligible := FALSE;
                    END;
                END;
            CustItemRebateMatrix."Line Type"::"Rebate Category":
                BEGIN
                    LocalItem.RESET;
                    LocalItem.SETRANGE("AQD Cust Rebate Category Code", CustItemRebateMatrix."No.");
                    LocalItem.SetRange("AQD Customer Rebate Enabled", TRUE);
                    IF LocalItem.FindFirst() THEN begin
                        REPEAT
                            LocalItem.CalcFields("Sales (Qty.)", "Sales (LCY)");
                            LocaltotalRebateCategorySalesQty += LocalItem."Sales (Qty.)";
                            LocaltotalRebateCategorySalesLCY += LocalItem."Sales (LCY)";

                            LocalItem.SetFilter("Date Filter", '%1..%2', StartDate, Today);
                            LocalItem.CalcFields("Sales (Qty.)", "Sales (LCY)");
                            LocaltotalRebateCategorySalesQtyYTD += LocalItem."Sales (Qty.)";
                            LocaltotalRebateCategorySalesLCYYTD += LocalItem."Sales (LCY)";

                            IF (FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt) <> '') AND
                               (NOT LocalEligiblePeriodAfterFirstShpt)
                            THEN BEGIN
                                FirstReceiptDateCriteria := CalcDate('-' + FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt), PostingDate);

                                LocalItemLedgerEntry.RESET;
                                LocalItemLedgerEntry.SetRange("Entry Type", LocalItemLedgerEntry."Entry Type"::Sale);
                                LocalItemLedgerEntry.SETFILTER("Document Type", '%1|%2',
                                    LocalItemLedgerEntry."Document Type"::"Sales Shipment",
                                    LocalItemLedgerEntry."Document Type"::"Sales Invoice");
                                LocalItemLedgerEntry.SETRANGE("Item No.", DocumentLine_No);
                                LocalItemLedgerEntry.SETRANGE("Source Type", LocalItemLedgerEntry."Source Type"::Customer);
                                LocalItemLedgerEntry.SETRANGE("Source No.", CustomerNo);
                                LocalItemLedgerEntry.SETFILTER("Posting Date", '<=%1', FirstReceiptDateCriteria);
                                IF LocalItemLedgerEntry.FindFirst() THEN
                                    LocalEligiblePeriodAfterFirstShpt := TRUE
                            END;
                        UNTIL LocalItem.Next() = 0;

                        IF (FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt) <> '') THEN
                            IsEligible := LocalEligiblePeriodAfterFirstShpt;

                        IF CustItemRebateMatrix."Sales Quantity Threshold" > LocaltotalRebateCategorySalesQty THEN
                            IsEligible := FALSE;

                        IF CustItemRebateMatrix."Sales Amount Threshold" > LocaltotalRebateCategorySalesLCY THEN
                            IsEligible := FALSE;

                        IF CustItemRebateMatrix."Sales Quantity Threshold (YTD)" > LocaltotalRebateCategorySalesQtyYTD THEN
                            IsEligible := FALSE;

                        IF CustItemRebateMatrix."Sales Amount Threshold (YTD)" > LocaltotalRebateCategorySalesLCYYTD THEN
                            IsEligible := FALSE;
                    END;
                END;
        END;
        EXIT(IsEligible);
    end;
}