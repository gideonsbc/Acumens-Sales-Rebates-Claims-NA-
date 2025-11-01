codeunit 14301915 "AQD ChkCustItemRbt Matrix Mgt"
{

    trigger OnRun()
    begin
    end;

    procedure IsBillToCustomerEligibleForRebate(var CustItemRebateMatrix: Record "AQD Cust Item Rebate Matrix"; CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; PostingDate: Date; RebateCode: Code[10]): Boolean
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

        IF NOT RebateSetup."Use Cust Rebate Criteria" then
            EXIT(TRUE);

        CustItemRebateMatrix.RESET;
        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                begin
                    ItemCard.GET(DocumentLine_No);
                    RebateCategoryCode := ItemCard."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::Item);
                end;
            DocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(DocumentLine_No);
                    RebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::Resource);
                END;
            DocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(DocumentLine_No);
                    RebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::"G/L Account");
                END;
            DocumentLine_Type::"Charge (Item)":
                BEGIN
                    ItemCharge.GET(DocumentLine_No);
                    RebateCategoryCode := ItemCharge."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::"Charge (Item)");
                END;
            DocumentLine_Type::"Fixed Asset":
                BEGIN
                    FixedAsset.GET(DocumentLine_No);
                    RebateCategoryCode := FixedAsset."AQD Cust Rebate Category Code";
                    CustItemRebateMatrix.SetRange("Line Type", CustItemRebateMatrix."Line Type"::"Fixed Asset");
                END;
        END;
        CustItemRebateMatrix.SetFilter("No.", '%1|%2', ' ', DocumentLine_No);
        CustItemRebateMatrix.SetRange("Rebate Program Code", RebateCode);
        CustItemRebateMatrix.SETRANGE(Blocked, false);

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
            IF LocalCustomer."AQD Rebate Customer Type" <> '' then begin
                CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"Customer Type");
                CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', LocalCustomer."AQD Rebate Customer Type");
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
            IF LocalCustomer."AQD Rebate Customer Type" <> '' then begin
                CustItemRebateMatrix.SetRange("Customer Type", CustItemRebateMatrix."Customer Type"::"Customer Type");
                CustItemRebateMatrix.SetFilter("Customer No.", '%1|%2', ' ', LocalCustomer."AQD Rebate Customer Type");
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

        EXIT(TRUE);
    END;

    local procedure CopyCustomerSalesRebateToCustomerSalesRebate(var FromCustItemRebateMatrix: Record "AQD Cust Item Rebate Matrix"; var ToCustItemRebateMatrix: Record "AQD Cust Item Rebate Matrix" temporary)
    begin
        IF FromCustItemRebateMatrix.FINDSET THEN
            REPEAT
                ToCustItemRebateMatrix := FromCustItemRebateMatrix;
                ToCustItemRebateMatrix.INSERT;
            UNTIL FromCustItemRebateMatrix.NEXT = 0;
    END;

    local procedure CheckCustomerItemRebateEligibility(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; var CustItemRebateMatrix: Record "AQD Cust Item Rebate Matrix"; PostingDate: Date; RebateCode: Code[10]): Boolean
    var
        LocalItem: Record Item;
        LocalItemLedgerEntry: Record "Item Ledger Entry";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        IsEligible: Boolean;
        FirstReceiptDateCriteria: Date;
    begin
        IsEligible := FALSE;
        RebateSetup.GET;
        if not RebateSetup."Use Cust Rebate Criteria" then
            EXIT(TRUE);

        CASE DocumentLine_Type OF
            DocumentLine_Type::Item:
                begin
                    LocalItem.GET(DocumentLine_No);
                    LocalItem.CalcFields("Sales (Qty.)", "Sales (LCY)");

                    IF (CustItemRebateMatrix."Sales Quantity Threshold" <> 0) AND
                        (CustItemRebateMatrix."Sales Quantity Threshold" < LocalItem."Sales (Qty.)")
                    THEN
                        IsEligible := true;

                    IF (CustItemRebateMatrix."Sales Amount Threshold" <> 0) AND
                        (CustItemRebateMatrix."Sales Amount Threshold" < LocalItem."Sales (LCY)")
                    THEN
                        IsEligible := TRUE;

                    IF (FORMAT(CustItemRebateMatrix.EligiblePeriodAfterFirstShpt) <> '')
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
                            IsEligible := TRUE
                        ELSE
                            IsEligible := FALSE;
                    END;
                END;
            // Currently Not Implement for other Types
            DocumentLine_Type::Resource:
                BEGIN
                END;
            DocumentLine_Type::"G/L Account":
                BEGIN
                END;
            DocumentLine_Type::"Charge (Item)":
                BEGIN
                END;
            DocumentLine_Type::"Fixed Asset":
                BEGIN
                END;
        END;
        EXIT(IsEligible);
    end;

    var
        CustItemRebateMatrix: Record "AQD Cust Item Rebate Matrix" temporary;
}