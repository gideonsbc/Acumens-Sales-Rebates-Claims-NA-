codeunit 14302621 "AQD Sales Rebate Calc Preview"
{
    trigger OnRun()
    begin
    end;

    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCategory: Record "Item Category";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        RebateToCUstomer: Record Customer;
        SalesPerson: Record "Salesperson/Purchaser";
        SalesLine: Record "Sales Line";
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        TempRebateCategoryLines: Record "AQD Cust Rebate Category Lines" temporary;
        GlobalSalesRebateRate: Record "AQD Sales Rebates Rate New";
        LineRebatable: Boolean;
        GlobalRebateCategoryCode: Code[20];
        GlobalNextRebateProgramLineNo: Integer;
        RebateLineNo: Integer;
        RunBy: Enum "AQD Customer Rebate Posting";
        BillToNotRebatableError: Label 'The Bill-To Customer %1 is not enrolled for Customer Rebate. Please contact the Customer to enroll for Customer Rebate.';
        SalesRebateCalcMgt: Codeunit "AQD Sales Rebate Calc Mgt";
        SalesRebateRateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
        EntityType: Enum "AQD CR Rebate Entity Type";

    procedure CustomerRebateCalcPreview(var SalesHeaderIn: Record "Sales Header")
    var
        CustomerRebatePreview: Page "AQD Customer Rebate Preview";
    begin
        // Clear Vendor Rebate Tables
        CustomerRebateDetails.RESET;
        CustomerRebateDetails.SetRange("Rebate No.", SalesHeaderIn."No.");
        IF NOT CustomerRebateDetails.IsEmpty THEN
            CustomerRebateDetails.DeleteAll();

        CustomerRebateLine.RESET;
        CustomerRebateLine.SetRange("Rebate No.", SalesHeaderIn."No.");
        IF NOT CustomerRebateLine.IsEmpty THEN
            CustomerRebateLine.DeleteAll();

        IF CustomerRebateHeader.GET(SalesHeaderIn."No.") THEN
            CustomerRebateHeader.DELETE;

        CalculateCustomerRebate(SalesHeaderIn);
        COMMIT;

        clear(CustomerRebatePreview);
        CustomerRebatePreview.SetRecord(CustomerRebateHeader);
        CustomerRebatePreview.RunModal();

        // Clear Vendor Rebate Tables
        CustomerRebateDetails.RESET;
        CustomerRebateDetails.SetRange("Rebate No.", SalesHeaderIn."No.");
        IF NOT CustomerRebateDetails.IsEmpty THEN
            CustomerRebateDetails.DeleteAll();

        CustomerRebateLine.RESET;
        CustomerRebateLine.SetRange("Rebate No.", SalesHeaderIn."No.");
        IF NOT CustomerRebateLine.IsEmpty THEN
            CustomerRebateLine.DeleteAll();

        IF CustomerRebateHeader.GET(SalesHeaderIn."No.") THEN
            CustomerRebateHeader.DELETE;
    END;

    procedure CalculateCustomerRebate(var SalesHeaderIn: Record "Sales Header")
    var
        LocalCustomer: Record Customer;
        BatchPostCustomerRebate: Report "AQD Post Cust Rebate Batches";
        LocalCustomerType: Record "AQD Rebate Customer Category";
        CustomerRebatePostMgt: Codeunit "AQD Customer Rebate Post Mgt";
    BEGIN
        RebateSetup.Get;

        SalesHeaderIn.TestField("AQD Customer Rebate", false);

        SellToCustomer.GET(SalesHeaderIn."Sell-to Customer No.");
        BillToCustomer.GET(SalesHeaderIn."Bill-to Customer No.");

        IF NOT BillToCustomer."AQD Enroll for Cust Rebate" THEN
            ERROR(BillToNotRebatableError, BillToCustomer."No.");

        IF (RebateSetup."Bill-To Rebate Customer" = RebateSetup."Bill-To Rebate Customer"::"Customer Rebate Category Setup") THEN BEGIN
            BillToCustomer.TESTFIELD("AQD Cust Rebate Category");
            LocalCustomerType.GET(BillToCustomer."AQD Cust Rebate Category");
            LocalCustomerType.TESTFIELD("Rebate Customer No");
        END ELSE IF RebateSetup."Bill-To Rebate Customer" = RebateSetup."Bill-To Rebate Customer"::"Customer Card Setup" THEN
                BillToCustomer.TestField("AQD Cust Rebate Customer No.");

        IF SalesHeaderIn."Document Type" In
            [SalesHeaderIn."Document Type"::"Return Order",
            SalesHeaderIn."Document Type"::"Credit Memo"]
        THEN
            RebateSetup.TestField("Exclude Credit Memo", false);

        BuildCustomerRebatePreview(SalesHeaderIn);
    End;

    local procedure BuildCustomerRebatePreview(var SalesHeaderIn: Record "Sales Header")
    var
        RebateCustomerRec: Record Customer;
    begin
        GetRebateCustomerDetails(SalesHeaderIn);

        SalesLine.Reset;
        SalesLine.SetRange("Document No.", SalesHeaderIn."No.");
        SalesLine.SetFilter(Type, '%1|%2|%3',
          SalesLine.Type::Item,
          SalesLine.Type::"G/L Account",
          SalesLine.Type::Resource);
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter(Quantity, '<>0');
        OnAfterApplySalesLineFilter(SalesHeaderIn, SalesLine);

        BuildCustomerRebate(SalesHeaderIn);
    END;

    local procedure BuildCustomerRebate(var SalesHeaderIn: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
        RebateNo: Code[20];
        LocalEmpVenCustomerFilter: Record "AQD CR Vend Emp Customer Filt";
        LocalEmpVenTerritoryFilter: Record "AQD CR Vend Emp Territory Filt";
        LocalCustomerRebate: Boolean;
        LocalEmployeeRebate: Boolean;
        LocalRecordFound: Boolean;
        LocalVendorRebate: Boolean;
        LocalRebateEntigyType: Enum "AQD CR Rebate Entity Type";
        LocaSalesRebateRate: Record "AQD Sales Rebates Rate New";
        SeenPayees: Dictionary of [Code[20], Boolean];
    begin
        RebateLineNo := 10000;

        IsHandled := false;
        OnBeforeStartCalculatingCustomerRebate(SalesHeaderIn, IsHandled);
        if IsHandled then
            exit;

        //Document
        InsertCustomerRebateHeader(SalesHeaderIn);
        //Line
        InsertCustomerRebateLine(SalesHeaderIn);

        SalesLine.Reset;
        SalesLine.SetRange("Document No.", SalesHeaderIn."No.");
        SalesLine.SetFilter(Type, '%1|%2|%3',
          SalesLine.Type::Item,
          SalesLine.Type::"G/L Account",
          SalesLine.Type::Resource);
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter(Quantity, '<>0');
        OnAfterApplySalesLineFilter(SalesHeaderIn, SalesLine);
        IF SalesLine.FindFirst then begin
            REPEAT
                LineRebatable := IsLineRebateEnabled(
                                    SalesHeaderIn,
                                    SalesLine.Type,
                                    SalesLine."No.");

                LocalRebateEntigyType := LocalRebateEntigyType::Customer;
                InsertCustomerRebateDetail(SalesHeaderIn, SalesLine, LocalRebateEntigyType, SalesHeaderIn."Bill-to Customer No.");

                LocalRebateEntigyType := LocalRebateEntigyType::Vendor;
                Clear(SeenPayees);
                LocaSalesRebateRate.Reset();
                LocaSalesRebateRate.SetCurrentKey("Payee Type", "Payee No.");
                LocaSalesRebateRate.SetRange("Payee Type", LocaSalesRebateRate."Payee Type"::"Vendor Commission");
                LocaSalesRebateRate.SetFilter("Payee No.", '<>%1', '');
                if LocaSalesRebateRate.FindSet() then begin
                    repeat
                        if not SeenPayees.ContainsKey(LocaSalesRebateRate."Payee No.") then begin
                            SeenPayees.Add(LocaSalesRebateRate."Payee No.", true);

                            LocalVendorRebate := FALSE;
                            LocalRecordFound := FALSE;

                            LocalEmpVenTerritoryFilter.RESET;
                            LocalEmpVenTerritoryFilter.SetRange("Type", LocalEmpVenTerritoryFilter."Type"::Vendor);
                            LocalEmpVenTerritoryFilter.SetRange("No.", LocaSalesRebateRate."Payee No.");
                            IF LocalEmpVenTerritoryFilter.FINDFIRST THEN BEGIN
                                LocalRecordFound := TRUE;
                                LocalEmpVenTerritoryFilter.SETFILTER("Territory Code", '%1|%2', BillToCustomer."No.", '');
                                IF LocalEmpVenTerritoryFilter.FINDFIRST THEN
                                    LocalVendorRebate := TRUE;
                            END;

                            LocalEmpVenCustomerFilter.RESET;
                            LocalEmpVenCustomerFilter.SetRange("Type", LocalEmpVenCustomerFilter."Type"::Vendor);
                            LocalEmpVenCustomerFilter.SetRange("No.", LocaSalesRebateRate."Payee No.");
                            IF LocalEmpVenCustomerFilter.FINDFIRST THEN BEGIN
                                LocalRecordFound := TRUE;
                                LocalEmpVenCustomerFilter.SETFILTER("Customer No.", '%1|%2', BillToCustomer."No.", '');
                                IF LocalEmpVenCustomerFilter.FINDFIRST THEN
                                    LocalVendorRebate := TRUE;
                            END;

                            IF NOT LocalRecordFound THEN
                                LocalVendorRebate := TRUE;

                            IF LocalVendorRebate THEN
                                InsertCustomerRebateDetail(SalesHeaderIn, SalesLine, LocalRebateEntigyType, LocaSalesRebateRate."Payee No.");
                        end;
                    until LocaSalesRebateRate.Next() = 0;
                end;

                LocalRebateEntigyType := LocalRebateEntigyType::Employee;
                Clear(SeenPayees);
                LocaSalesRebateRate.Reset();
                LocaSalesRebateRate.SetRange("Payee Type", LocaSalesRebateRate."Payee Type"::"Employee Commission");
                LocaSalesRebateRate.SetFilter("Payee No.", '<>%1', '');
                if LocaSalesRebateRate.FindSet() then begin
                    repeat
                        if not SeenPayees.ContainsKey(LocaSalesRebateRate."Payee No.") then begin
                            SeenPayees.Add(LocaSalesRebateRate."Payee No.", true);

                            LocalEmployeeRebate := FALSE;
                            LocalRecordFound := FALSE;

                            LocalEmpVenTerritoryFilter.RESET;
                            LocalEmpVenTerritoryFilter.SetRange("Type", LocalEmpVenTerritoryFilter."Type"::Employee);
                            LocalEmpVenTerritoryFilter.SetRange("No.", LocaSalesRebateRate."Payee No.");
                            IF LocalEmpVenTerritoryFilter.FINDFIRST THEN BEGIN
                                LocalRecordFound := TRUE;
                                LocalEmpVenTerritoryFilter.SETFILTER("Territory Code", '%1|%2', BillToCustomer."Territory Code", '');
                                IF LocalEmpVenTerritoryFilter.FINDFIRST THEN
                                    LocalEmployeeRebate := TRUE;
                            END;

                            LocalEmpVenCustomerFilter.RESET;
                            LocalEmpVenCustomerFilter.SetRange("Type", LocalEmpVenCustomerFilter."Type"::Employee);
                            LocalEmpVenCustomerFilter.SetRange("No.", LocaSalesRebateRate."Payee No.");
                            IF LocalEmpVenCustomerFilter.FINDFIRST THEN BEGIN
                                LocalRecordFound := TRUE;
                                LocalEmpVenCustomerFilter.SETFILTER("Customer No.", '%1|%2', BillToCustomer."No.", '');
                                IF LocalEmpVenCustomerFilter.FINDFIRST THEN
                                    LocalEmployeeRebate := TRUE;
                            END;

                            IF NOT LocalRecordFound THEN
                                LocalEmployeeRebate := TRUE;

                            IF LocalEmployeeRebate THEN
                                InsertCustomerRebateDetail(SalesHeaderIn, SalesLine, LocalRebateEntigyType, LocaSalesRebateRate."Payee No.");
                        end;
                    until LocaSalesRebateRate.Next() = 0;
                end;

            UNTIL SalesLine.Next = 0;
        END;
    END;

    local procedure IsRebataEnabledLineExist(SalesHeaderIn: Record "Sales Header"): Boolean
    var
        LocalSalesLine: Record "Sales Line";
        IsHandled: Boolean;
        LineRebatable: Boolean;
    begin
        LineRebatable := false;

        LocalSalesLine.Reset;
        LocalSalesLine.SetRange("Document Type", SalesHeaderIn."Document Type");
        LocalSalesLine.SetRange("Document No.", SalesHeaderIn."No.");
        LocalSalesLine.SetFilter(Type, '%1|%2|%3',
          LocalSalesLine.Type::Item,
          LocalSalesLine.Type::Resource,
          LocalSalesLine.Type::"G/L Account");
        LocalSalesLine.SetFilter("No.", '<>%1', '');
        LocalSalesLine.SetFilter(Quantity, '<>%1', 0);
        OnAfterApplySalesLineFilter(SalesHeaderIn, LocalSalesLine);
        if LocalSalesLine.FindFirst then begin
            Repeat
                IsHandled := false;
                OnBeforeFindRebateRate(SalesHeaderIn, SalesLine, IsHandled);
                if not IsHandled then
                    LineRebatable := IsLineRebateEnabled(SalesHeaderIn,
                                                         LocalSalesLine.Type,
                                                         LocalSalesLine."No.");
            Until (LocalSalesLine.Next = 0) OR LineRebatable;
            EXIT(LineRebatable);
        end;
        exit(false);
    end;

    local procedure IsLineRebateEnabled(SalesHeaderIn: Record "Sales Header"; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]): Boolean
    var
        Item: Record Item;
        Location: Record Location;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixedAsset: Record "Fixed Asset";
        ItemCategory: Record "Item Category";
        LocalRebateCategoryCode: Code[20];
        IsHandled: Boolean;
        IsRebateEnabled: Boolean;
    begin
        IsRebateEnabled := FALSE;
        IsHandled := false;
        OnBeforeCheckLineRebateEnabled(SalesHeaderIn, IsRebateEnabled, IsHandled);
        IF IsHandled THEN
            EXIT;

        TempRebateCategoryLines.RESET;
        IF TempRebateCategoryLines.IsTemporary THEN
            TempRebateCategoryLines.DeleteAll();

        GlobalNextRebateProgramLineNo := 10000;

        IsRebateEnabled := FALSE;

        GetCustomerRebateCategoryLines(BillToCustomer."No.", DocumentLine_Type, DocumentLine_No, SalesHeaderIn."Posting Date", IsRebateEnabled);
        GetCustomerTypeRebateCategoryLines(BillToCustomer."No.", DocumentLine_Type, DocumentLine_No, SalesHeaderIn."Posting Date", IsRebateEnabled);
        GetEmployeeRebateCategoryLines(BillToCustomer."No.", DocumentLine_Type, DocumentLine_No, SalesHeaderIn."Posting Date", IsRebateEnabled);
        GetVendorRebateCategoryLines(BillToCustomer."No.", DocumentLine_Type, DocumentLine_No, SalesHeaderIn."Posting Date", IsRebateEnabled);

        IF IsRebateEnabled then begin
            TempRebateCategoryLines.RESET;
            IF NOT TempRebateCategoryLines.FindFirst() THEN begin
                TempRebateCategoryLines."Line No." := 10000;
                TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
                TempRebateCategoryLines."Entity Type" := TempRebateCategoryLines."Entity Type"::Customer;
                TempRebateCategoryLines.INSERT;
            END;
        end;
        OnAfterCheckLineRebateEnabled(SalesHeaderIn, IsRebateEnabled);
        EXIT(IsRebateEnabled);
    end;

    local procedure GetCustomerRebateCategoryLines(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20];
                                                                                                PostingDate: Date; var IsRebateEnabled: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        GlobalSalesRebateRate.RESET;
        GlobalSalesRebateRate.SetRange("Customer Type", GlobalSalesRebateRate."Customer Type"::Customer);
        GlobalSalesRebateRate.SetRange("Payee Type", GlobalSalesRebateRate."Payee Type"::CustomerRebate);

        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Item);

                    Item.GET(DocumentLine_No);
                    IsRebateEnabled := Item."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"G/L Account");

                    GLAccount.GET(DocumentLine_No);
                    IsRebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::Resource:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Resource);

                    Resource.GET(DocumentLine_No);
                    IsRebateEnabled := Resource."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                end;
            else begin
                IsHandled := FALSE;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebateEnabled, IsHandled);
                IF IsHandled THEN
                    EXIT(IsRebateEnabled);
            end;
        END;

        //GlobalSalesRebateRate.SetFilter("No.", '%1|%2', DocumentLine_No, '');
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsLineMatch(DocumentLine_Type, DocumentLine_No, GlobalSalesRebateRate."No. Filter") then
                    if SalesRebateCalcMgt.IsCustomerMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate."Customer No. Filter") then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Item Attribute");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.AttributeMatches(GlobalSalesRebateRate."Item Attribute Name",
                                                                      GlobalSalesRebateRate."Item Attribute Value Filter",
                                                                      SalesRebateCalcMgt.GetItemAttributeValues(DocumentLine_No))
                           then
                    if SalesRebateCalcMgt.IsCustomerMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate."Customer No. Filter") then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Rebate Category");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsItemTypeMatchCategory(GlobalRebateCategoryCode,
                                                                               SalesRebateRateCalcMgt.BuildItemCategoryCodeFilter(GlobalSalesRebateRate."No. Filter"))
                           then
                    if SalesRebateCalcMgt.IsCustomerMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate."Customer No. Filter") then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

    END;

    local procedure GetCustomerTypeRebateCategoryLines(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; PostingDate: Date; var IsRebateEnabled: Boolean): Boolean
    var
        IsMatchNoFilter: Boolean;
    begin

        GlobalSalesRebateRate.RESET;
        GlobalSalesRebateRate.SetFilter("Customer Type", '%1|%2|%3|%4', GlobalSalesRebateRate."Customer Type"::"Customer Category", GlobalSalesRebateRate."Customer Type"::"Customer Posting Group", GlobalSalesRebateRate."Customer Type"::"Corporate Affiliation level", GlobalSalesRebateRate."Customer Type"::"GPO Membership level");
        GlobalSalesRebateRate.SetRange("Payee Type", GlobalSalesRebateRate."Payee Type"::CustomerRebate);

        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Item);

                    Item.GET(DocumentLine_No);
                    GlobalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"G/L Account");

                    GLAccount.GET(DocumentLine_No);
                    GlobalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::Resource:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Resource);

                    Resource.GET(DocumentLine_No);
                    GlobalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                end;
        END;

        //GlobalSalesRebateRate.SetFilter("No.", '%1|%2', DocumentLine_No, '');
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsLineMatch(DocumentLine_Type, DocumentLine_No, GlobalSalesRebateRate."No. Filter") then
                    if SalesRebateCalcMgt.IsCustomerTypeMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate) then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Item Attribute");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.AttributeMatches(GlobalSalesRebateRate."Item Attribute Name",
                                                                      GlobalSalesRebateRate."Item Attribute Value Filter",
                                                                      SalesRebateCalcMgt.GetItemAttributeValues(DocumentLine_No))
                           then
                    if SalesRebateCalcMgt.IsCustomerTypeMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate) then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Rebate Category");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsItemTypeMatchCategory(GlobalRebateCategoryCode,
                                                                               SalesRebateRateCalcMgt.BuildItemCategoryCodeFilter(GlobalSalesRebateRate."No. Filter"))
                           then
                    if SalesRebateCalcMgt.IsCustomerTypeMatchCustomerNoFilter(CustomerNo, GlobalSalesRebateRate) then
                        InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Customer);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

    END;

    local procedure GetEmployeeRebateCategoryLines(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20];
                                                                                                PostingDate: Date; var IsRebateEnabled: Boolean): Boolean
    var
        IsHandled: Boolean;
        IsMatchNoFilter: Boolean;
    begin
        IsHandled := false;

        GlobalSalesRebateRate.RESET;
        GlobalSalesRebateRate.SetRange("Payee Type", GlobalSalesRebateRate."Payee Type"::"Employee Commission");
        GlobalSalesRebateRate.SetRange("Payee No.");

        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Item);

                    Item.GET(DocumentLine_No);
                    IsRebateEnabled := Item."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"G/L Account");

                    GLAccount.GET(DocumentLine_No);
                    IsRebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::Resource:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Resource);

                    Resource.GET(DocumentLine_No);
                    IsRebateEnabled := Resource."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                end;
            else begin
                IsHandled := FALSE;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebateEnabled, IsHandled);
                IF IsHandled THEN
                    EXIT(IsRebateEnabled);
            end;
        END;

        //GlobalSalesRebateRate.SetFilter("No.", '%1|%2', DocumentLine_No, '');
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsLineMatch(DocumentLine_Type, DocumentLine_No, GlobalSalesRebateRate."No. Filter") then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Employee);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Item Attribute");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.AttributeMatches(GlobalSalesRebateRate."Item Attribute Name",
                                                                      GlobalSalesRebateRate."Item Attribute Value Filter",
                                                                      SalesRebateCalcMgt.GetItemAttributeValues(DocumentLine_No))
                           then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Employee);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Rebate Category");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsItemTypeMatchCategory(GlobalRebateCategoryCode,
                                                                            SalesRebateRateCalcMgt.BuildItemCategoryCodeFilter(GlobalSalesRebateRate."No. Filter"))
                        then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Employee);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

    END;

    local procedure GetVendorRebateCategoryLines(CustomerNo: Code[20]; DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20];
                                                                                              PostingDate: Date; var IsRebateEnabled: Boolean): Boolean
    var
        IsHandled: Boolean;
        IsMatchNoFilter: Boolean;
    begin
        IsHandled := false;

        GlobalSalesRebateRate.RESET;
        GlobalSalesRebateRate.SetRange("Payee Type", GlobalSalesRebateRate."Payee Type"::"Vendor Commission");
        GlobalSalesRebateRate.SetRange("Payee No.");

        case DocumentLine_Type of
            DocumentLine_Type::Item:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Item);

                    Item.GET(DocumentLine_No);
                    IsRebateEnabled := Item."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::"G/L Account":
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"G/L Account");

                    GLAccount.GET(DocumentLine_No);
                    IsRebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                end;
            DocumentLine_Type::Resource:
                begin
                    GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::Resource);

                    Resource.GET(DocumentLine_No);
                    IsRebateEnabled := Resource."AQD Customer Rebate Enabled";
                    GlobalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                end;
            else begin
                IsHandled := FALSE;
                OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type, DocumentLine_No, IsRebateEnabled, IsHandled);
                IF IsHandled THEN
                    EXIT(IsRebateEnabled);
            end;
        END;

        //GlobalSalesRebateRate.SetFilter("No.", '%1|%2', DocumentLine_No, '');
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsLineMatch(DocumentLine_Type, DocumentLine_No, GlobalSalesRebateRate."No. Filter") then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Vendor);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Item Attribute");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.AttributeMatches(GlobalSalesRebateRate."Item Attribute Name",
                                                                       GlobalSalesRebateRate."Item Attribute Value Filter",
                                                                       SalesRebateCalcMgt.GetItemAttributeValues(DocumentLine_No))
                            then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Vendor);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

        GlobalSalesRebateRate.SetRange("Line Type", GlobalSalesRebateRate."Line Type"::"Rebate Category");
        IF GlobalSalesRebateRate.FindFirst() THEN BEGIN
            REPEAT
                if SalesRebateCalcMgt.IsItemTypeMatchCategory(GlobalRebateCategoryCode,
                                                                            SalesRebateRateCalcMgt.BuildItemCategoryCodeFilter(GlobalSalesRebateRate."No. Filter"))
                        then
                    InsertTempRebateCategoryLine(GlobalSalesRebateRate, CustomerNo, EntityType::Vendor);
            UNTIL GlobalSalesRebateRate.Next() = 0;
        END;

    END;

    local procedure InsertTempRebateCategoryLine(GlobalSalesRebateRate: Record "AQD Sales Rebates Rate New"; CustomerNo: Code[20]; EntityType: Enum "AQD CR Rebate Entity Type")
    begin
        TempRebateCategoryLines.Reset();
        TempRebateCategoryLines.SetRange("Rebate Program Code", GlobalSalesRebateRate."Program Code");
        TempRebateCategoryLines.SetRange("Entity Type", EntityType);

        if not TempRebateCategoryLines.FindFirst() then begin
            TempRebateCategoryLines.Init();
            TempRebateCategoryLines."Rebate Category Code" := GlobalRebateCategoryCode;
            TempRebateCategoryLines."Line No." := GlobalNextRebateProgramLineNo;
            TempRebateCategoryLines."Rebate Program Code" := GlobalSalesRebateRate."Program Code";
            TempRebateCategoryLines."Entity Type" := EntityType;
            TempRebateCategoryLines."Line Type" := GlobalSalesRebateRate."Line Type";
            OnBeforeInsertTempRebateCategoryLines(TempRebateCategoryLines, GlobalSalesRebateRate, CustomerNo);
            TempRebateCategoryLines.Insert();
            GlobalNextRebateProgramLineNo += 10000;
        end;
    end;


    local procedure InsertCustomerRebateHeader(SalesHeaderIn: Record "Sales Header")
    var
        RebateCustomerRec: Record Customer;
        CustomerRebateType: Record "AQD Rebate Customer Category";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitRebateHeader(SalesHeaderIn, IsHandled);
        IF IsHandled then
            EXIT;

        Clear(CustomerRebateHeader);

        CASE RebateSetup."Bill-To Rebate Customer" OF
            RebateSetup."Bill-To Rebate Customer"::"Customer Card Setup":
                BEGIN
                    BillToCustomer.TESTFIELD("AQD Cust Rebate Customer No.");
                    RebateCustomerRec.Get(BillToCustomer."AQD Cust Rebate Customer No.");
                END;
            RebateSetup."Bill-To Rebate Customer"::"Customer Rebate Category Setup":
                BEGIN
                    BillToCustomer.TESTFIELD("AQD Cust Rebate Category");
                    CustomerRebateType.GET(BillToCustomer."AQD Cust Rebate Category");
                    RebateCustomerRec.GET(CustomerRebateType."Rebate Customer No");
                END;
        END;

        CustomerRebateHeader.Init;
        CustomerRebateHeader."No." := SalesHeaderIn."No.";
        CustomerRebateHeader."Rebate Pay-To Customer No." := RebateCustomerRec."No.";
        CustomerRebateHeader."Rebate-to Name" := RebateCustomerRec.Name;
        CustomerRebateHeader."Rebate-To Name 2" := RebateCustomerRec."Name 2";
        CustomerRebateHeader."Rebate-To Address" := RebateCustomerRec.Address;
        CustomerRebateHeader."Rebate-To Address 2" := RebateCustomerRec."Address 2";
        CustomerRebateHeader."Rebate-To City" := RebateCustomerRec.City;
        CustomerRebateHeader."Rebate-To Contact" := RebateCustomerRec.Contact;
        CustomerRebateHeader."Rebate-To Post Code" := RebateCustomerRec."Post Code";
        CustomerRebateHeader."Rebate-To County" := RebateCustomerRec.County;
        CustomerRebateHeader."Rebate-To Country/Region Code" := RebateCustomerRec."Country/Region Code";
        CustomerRebateHeader."Salesperson Code" := SalesHeaderIn."Salesperson Code";
        CustomerRebateHeader."External Document No." := SalesHeaderIn."External Document No.";
        CustomerRebateHeader.State := SalesHeaderIn."Ship-to County";
        CustomerRebateHeader."Responsibility Center" := SalesHeaderIn."Responsibility Center";
        CustomerRebateHeader."Location Code" := SalesHeaderIn."Location Code";
        CustomerRebateHeader."Shortcut Dimension 1 Code" := SalesHeaderIn."Shortcut Dimension 1 Code";
        CustomerRebateHeader."Shortcut Dimension 2 Code" := SalesHeaderIn."Shortcut Dimension 2 Code";
        CustomerRebateHeader."Territory Code" := BillToCustomer."Territory Code";
        CustomerRebateHeader."Posting Date" := SalesHeaderIn."Posting Date";
        CustomerRebateHeader."Document Date" := Today;
        CustomerRebateHeader."Created By" := UserId;
        CustomerRebateHeader."Created Date" := Today;
        CustomerRebateHeader."AQD Calculation Date" := BillToCustomer."AQD CustRbt Calculation Date";
        CustomerRebateHeader.Preview := true;
        IsHandled := FALSE;
        OnBeforeInsertRebateHeader(SalesHeaderIn, CustomerRebateHeader, IsHandled);
        IF NOT IsHandled THEN
            CustomerRebateHeader.Insert;
        OnAfterInsertRebateHeader(SalesHeaderIn, CustomerRebateHeader);
    end;

    local procedure InsertCustomerRebateLine(SalesHeaderIn: Record "Sales Header")
    var
        LocalCustomerRebateLine: Record "AQD Customer Rebate Line";
        IsHandled: Boolean;
        CustMgtEvent: Codeunit "AQD CustRbtMgt EventsFunctions";
    begin
        IsHandled := false;
        OnBeforeInitCustomerRebateLine(SalesHeaderIn, IsHandled);
        if IsHandled then
            exit;

        LocalCustomerRebateLine.Reset();
        LocalCustomerRebateLine.SetRange("Rebate No.", SalesHeaderIn."No.");
        if LocalCustomerRebateLine.FindLast() then
            RebateLineNo := LocalCustomerRebateLine."Line No." + 10000
        else
            RebateLineNo := 10000;

        SalesHeaderIn.CalcFields(Amount, "Amount Including VAT");

        CustomerRebateLine.Init;
        CustomerRebateLine."Rebate No." := SalesHeaderIn."No.";
        CustomerRebateLine."Cust Rebate Program Code" := SalesHeaderIn."AQD Cust Rebate Program Code";
        CustomerRebateLine."Marketplace Code" := SalesHeaderIn."AQD Marketplace Code";
        CustomerRebateLine."Off-Invoice Rebate" := CustMgtEvent.OffInvoiceRebateAmountPreview(SalesHeaderIn);
        CustomerRebateLine."Line No." := RebateLineNo;
        CASE SalesHeaderIn."Document Type" OF
            SalesHeaderIn."Document Type"::Order:
                CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::"Unposted Order";
            SalesHeaderIn."Document Type"::Invoice:
                CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::"Unposted Invoice";
            SalesHeaderIn."Document Type"::"Return Order":
                CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::"Unposted Return Order";
            SalesHeaderIn."Document Type"::"Credit Memo":
                CustomerRebateLine."Document Type" := CustomerRebateLine."Document Type"::"Unposted Credit Memo";
        END;
        CustomerRebateLine."Document No." := SalesHeaderIn."No.";
        CustomerRebateLine."Order No." := SalesHeaderIn."No.";
        CustomerRebateLine.Description := SalesHeaderIn."Posting Description";
        CustomerRebateLine."Order Date" := SalesHeaderIn."Order Date";
        CustomerRebateLine."Rebate Order Date" := SalesHeaderIn."AQD Customer Rebate Order Date";
        CustomerRebateLine."Posting Date" := SalesHeaderIn."Posting Date";
        CustomerRebateLine."External Document No." := SalesHeaderIn."External Document No.";
        CustomerRebateLine.Amount := SalesHeaderIn.Amount;
        CustomerRebateLine."Amount Including VAT" := SalesHeaderIn."Amount Including VAT";
        CustomerRebateLine."Salesperson Code" := SalesHeaderIn."Salesperson Code";
        CustomerRebateLine."Responsibility Center" := SalesHeaderIn."Responsibility Center";
        CustomerRebateLine."Location Code" := SalesHeaderIn."Location Code";
        CustomerRebateLine."Territory Code" := BillToCustomer."Territory Code";
        CustomerRebateLine."Currency Code" := SalesHeaderIn."Currency Code";
        CustomerRebateLine."Shortcut Dimension 1 Code" := SalesHeaderIn."Shortcut Dimension 1 Code";
        CustomerRebateLine."Shortcut Dimension 2 Code" := SalesHeaderIn."Shortcut Dimension 2 Code";
        CustomerRebateLine."Sell-To Customer No." := SalesHeaderIn."Sell-To Customer No.";
        CustomerRebateLine."Sell-To Customer Name" := SalesHeaderIn."Sell-To Customer Name";
        CustomerRebateLine."Bill-To Customer No." := SalesHeaderIn."Bill-To Customer No.";
        CustomerRebateLine."Bill-To Customer Name" := SalesHeaderIn."Bill-To Name";
        CustomerRebateLine."Rebate Pay-To Customer No." := CustomerRebateHeader."Rebate Pay-To Customer No.";
        CustomerRebateLine.Preview := TRUE;
        IsHandled := FALSE;
        OnBeforeInsertRebateLine(CustomerRebateLine, IsHandled);
        IF NOT IsHandled THEN
            CustomerRebateLine.Insert;
        OnAfterInsertRebateLine(CustomerRebateLine);
    END;

    local procedure InsertCustomerRebateDetail(SalesHeaderIn: Record "Sales Header"; SalesLineIn: Record "Sales Line"; RebateEntigyType: Enum "AQD CR Rebate Entity Type"; EntityNo: Code[20])
    var
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        Location: Record Location;
        LocalDocumentLine_Type: Enum "Purchase Line Type";
        LocalDocumentLine_No: Code[20];
        LineNo: Integer;
        IsHandled: Boolean;
        PostingDate: Date;
        CustomerRebateDetailsLoc: Record "AQD Customer Rebate Details";
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
        TempReturnReceiptLine: Record "Return Receipt Line" temporary;
        RebateProgramCodeRec: Record "AQD Cust Rebate Program Code";
        LocalRebateCategoryCode: Code[20];
        IsRebateEnabled: Boolean;
    begin
        Clear(CustomerRebateDetails);
        LineNo := 1;

        IsHandled := false;
        OnBeforeInitRebateDetail(SalesHeaderIn, SalesLineIn, IsHandled);
        if IsHandled then
            exit;

        PostingDate := SalesHeaderIn."Posting Date";
        LocalDocumentLine_Type := SalesLineIn.Type;
        LocalDocumentLine_No := SalesLineIn."No.";

        CASE LocalDocumentLine_Type OF
            LocalDocumentLine_Type::Item:
                BEGIN
                    Item.GET(LocalDocumentLine_No);
                    IsRebateEnabled := Item."AQD Customer Rebate Enabled";
                    LocalRebateCategoryCode := Item."AQD Cust Rebate Category Code";
                END;
            LocalDocumentLine_Type::"G/L Account":
                BEGIN
                    GLAccount.GET(LocalDocumentLine_No);
                    IsRebateEnabled := GLAccount."AQD Customer Rebate Enabled";
                    LocalRebateCategoryCode := GLAccount."AQD Cust Rebate Category Code";
                END;
            LocalDocumentLine_Type::Resource:
                BEGIN
                    Resource.GET(LocalDocumentLine_No);
                    IsRebateEnabled := Resource."AQD Customer Rebate Enabled";
                    LocalRebateCategoryCode := Resource."AQD Cust Rebate Category Code";
                END;
        END;

        CustomerRebateDetailsLoc.Reset();
        CustomerRebateDetailsLoc.SetRange("Rebate No.", SalesHeaderIn."No.");
        CustomerRebateDetailsLoc.SetRange("Rebate Line No.", RebateLineNo);
        if CustomerRebateDetailsLoc.FindLast() then
            LineNo := CustomerRebateDetailsLoc."Line No." + 10000
        else
            LineNo := 10000;

        TempRebateCategoryLines.RESET;
        TempRebateCategoryLines.SetRange("Rebate Category Code", LocalRebateCategoryCode);
        IF TempRebateCategoryLines.FindFirst() THEN begin
            repeat
                IF RebateProgramCodeRec.GET(TempRebateCategoryLines."Rebate Program Code") THEN
                    TempRebateCategoryLines."AQD Cust Rebate Posting Type" := RebateProgramCodeRec."Customer Rebate Posting Type";
                IF TempRebateCategoryLines."AQD Cust Rebate Posting Type" = TempRebateCategoryLines."AQD Cust Rebate Posting Type"::" " THEN
                    TempRebateCategoryLines."AQD Cust Rebate Posting Type" := TempRebateCategoryLines."AQD Cust Rebate Posting Type"::Expense;
                TempRebateCategoryLines.Modify();
            until TempRebateCategoryLines.Next() = 0;
        END ELSE BEGIN
            TempRebateCategoryLines.INIT;
            TempRebateCategoryLines."Rebate Category Code" := LocalRebateCategoryCode;
            TempRebateCategoryLines."Line No." := 10000;
            TempRebateCategoryLines."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
            TempRebateCategoryLines."AQD Cust Rebate Posting Type" := RebateSetup."Default Rebate Posting Type";
            TempRebateCategoryLines.Insert();
        END;

        TempRebateCategoryLines.RESET;
        TempRebateCategoryLines.SetRange("Entity Type", RebateEntigyType);
        IF TempRebateCategoryLines.FindFirst() THEN BEGIN
            Repeat
                CustomerRebateDetails.INIT;
                CustomerRebateDetails."Rebate No." := SalesHeaderIn."No.";
                CustomerRebateDetails."Rebate Line No." := RebateLineNo;
                CustomerRebateDetails."Line No." := LineNo;
                Case SalesHeaderIn."Document Type" OF
                    SalesHeaderIn."Document Type"::Order:
                        CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::"Unposted Order";
                    SalesHeaderIn."Document Type"::Invoice:
                        CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::"Unposted Invoice";
                    SalesHeaderIn."Document Type"::"Return Order":
                        CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::"Unposted Return Order";
                    SalesHeaderIn."Document Type"::"Credit Memo":
                        CustomerRebateDetails."Document Type" := CustomerRebateDetails."Document Type"::"Unposted Credit Memo";
                END;
                CustomerRebateDetails."Document No." := SalesLineIn."Document No.";
                CustomerRebateDetails."Document Line No." := SalesLineIn."Line No.";
                CustomerRebateDetails."Entity Type" := TempRebateCategoryLines."Entity Type";
                CustomerRebateDetails."Entity No." := EntityNo;
                case SalesLineIn.Type of
                    SalesLineIn.Type::"G/L Account":
                        CustomerRebateDetails.Type := CustomerRebateDetails.Type::"G/L Account";
                    SalesLineIn.Type::Item:
                        CustomerRebateDetails.Type := CustomerRebateDetails.Type::Item;
                    SalesLineIn.Type::Resource:
                        CustomerRebateDetails.Type := CustomerRebateDetails.Type::Resource;
                end;
                CustomerRebateDetails."No." := SalesLineIn."No.";
                CustomerRebateDetails.Description := SalesLineIn.Description;
                CustomerRebateDetails.Quantity := SalesLineIn.Quantity;
                CustomerRebateDetails."Unit Cost" := SalesLineIn."Unit Cost";
                CustomerRebateDetails."Unit Price" := SalesLineIn."Unit Price";
                CustomerRebateDetails.Amount := SalesLineIn.Amount;
                CustomerRebateDetails."Amount Including VAT" := SalesLineIn."Amount Including VAT";
                CustomerRebateDetails."Rebate Type" := CustomerRebateDetails."Rebate Type"::" ";
                CustomerRebateDetails."Rebate %" := 0;
                CustomerRebateDetails."Rebate Per Unit" := 0;
                CustomerRebateDetails."Salesperson Code" := SalesHeaderIn."Salesperson Code";
                CustomerRebateDetails."Responsibility Center" := SalesLineIn."Responsibility Center";
                CustomerRebateDetails."Location Code" := SalesLineIn."Location Code";
                CustomerRebateDetails."Territory Code" := BillToCustomer."Territory Code";
                CustomerRebateDetails."Shortcut Dimension 1 Code" := SalesLineIn."Shortcut Dimension 1 Code";
                CustomerRebateDetails."Shortcut Dimension 2 Code" := SalesLineIn."Shortcut Dimension 2 Code";
                CustomerRebateDetails.State := SalesHeaderIn."Ship-to County";
                CustomerRebateDetails."Sell-To Customer No." := CustomerRebateLine."Sell-To Customer No.";
                CustomerRebateDetails."Bill-To Customer No." := CustomerRebateLine."Bill-To Customer No.";
                CustomerRebateDetails."Rebate Pay-To Customer No." := CustomerRebateLine."Rebate Pay-To Customer No.";

                //Add special Rebate Program code
                CustomerRebateDetails."Header Rebate Program Code" := SalesHeaderIn."AQD Cust Rebate Program Code";
                CustomerRebateDetails."Header Marketplace Code" := SalesHeaderIn."AQD Marketplace Code";
                CustomerRebateDetails."Marketplace Code" := TempRebateCategoryLines."Marketplace Code";
                CustomerRebateDetails."Payment Terms Code" := SalesHeaderIn."Payment Terms Code";
                CustomerRebateDetails."Line Type" := TempRebateCategoryLines."Line Type";

                // Calculate and Vendor Rebate Amount
                CustomerRebateDetails."Rebate Item Category Code" := TempRebateCategoryLines."Rebate Category Code";
                CustomerRebateDetails."Rebate Program Code" := TempRebateCategoryLines."Rebate Program Code";
                CustomerRebateDetails."Posting Date" := CustomerRebateLine."Posting Date";
                CustomerRebateDetails."Rebate Order Date" := CustomerRebateLine."Rebate Order Date";
                CustomerRebateDetails.Preview := TRUE;

                GetRebateCategoryCode(CustomerRebateDetails);
                GetSalesRebateDetails(CustomerRebateDetails);
                CustomerRebateDetails."Profit %" := CalculateProfitPercentage(CustomerRebateDetails);
                CalculateRebateAmount(CustomerRebateDetails);

                CustomerRebateDetails."Calculated Line Rebate Amount" := CustomerRebateDetails."Customer Rebate Amount";
                CustomerRebateDetails."Do Not Credit" := false;
                CustomerRebateDetails."AQD Use Cust Rebate Setup From" := TempRebateCategoryLines."AQD Use Rebate Setup From";
                CustomerRebateDetails."AQD Cust Rebate Posting Type" := TempRebateCategoryLines."AQD Cust Rebate Posting Type";
                IF CustomerRebateDetails."Rebate Type" <> CustomerRebateDetails."Rebate Type"::" " then begin
                    IsHandled := FALSE;
                    OnBeforeInsertRebateDetail(CustomerRebateDetails, IsHandled);
                    IF NOT IsHandled then begin
                        CustomerRebateDetails.Insert();
                        LineNo += 10000;
                    end;
                    OnAfterInsertRebateDetail(CustomerRebateDetails);
                end;
            Until (TempRebateCategoryLines.Next() = 0);
        END;
    END;

    local procedure GetRebateCategoryCode(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        LocalResource: Record Resource;
        LocalItem: Record Item;
        LocalGLAccount: Record "G/L Account";
        LocalFixesAsset: Record "Fixed Asset";
        LocalItemCharge: Record "Item Charge";
    begin
        case CustomerRebateDetailsLocIn.Type OF
            CustomerRebateDetailsLocIn.Type::Item:
                begin
                    IF LocalItem.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalItem."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::Resource:
                begin
                    IF LocalResource.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalResource."AQD Cust Rebate Category Code";
                end;
            CustomerRebateDetailsLocIn.Type::"G/L Account":
                begin
                    IF LocalGLAccount.GET(CustomerRebateDetailsLocIn."No.") then
                        CustomerRebateDetailsLocIn."Rebate Item Category Code" := LocalGLAccount."AQD Cust Rebate Category Code";
                end;
        end;
    end;

    local procedure GetSalesRebateDetails(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    var
        SalesRebateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
        IsHandled: Boolean;
    begin
        OnBeforeGetSalesRebateDetail(CustomerRebateDetailsLocIn, IsHandled);
        IF IsHandled THEN
            EXIT;

        SalesRebateCalcMgt.FindSalesLineRebateRate(CustomerRebateDetailsLocIn, false, 0D, 0D);

        OnAfterGetSalesRebateDetail(CustomerRebateDetailsLocIn);
    end;

    local procedure CalculateRebateAmount(var CustomerRebateDetailsIn: Record "AQD Customer Rebate Details")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateRebateAmount(CustomerRebateDetailsIn, IsHandled);
        if IsHandled then
            exit;

        IF NOT LineRebatable THEN BEGIN
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Unit" := 0;
            CustomerRebateDetailsIn.Ineligible := TRUE;
            EXIT; // Exit to avoid calculation
        END;

        IF CustomerRebateDetailsIn.Ineligible THEN BEGIN
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Unit" := 0;
            EXIT; // Exit to avoid calculation
        END;

        if (RebateSetup."Min GP% for Customer Rebate" <> 0) and
           (RebateSetup."Min GP% for Customer Rebate" > Abs(CustomerRebateDetailsIn."Profit %"))
        then begin
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Unit" := 0;
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            exit;
        end;

        if (CustomerRebateDetailsIn."Document Type" = CustomerRebateDetailsIn."Document Type"::Invoice) and
           (CustomerRebateDetailsIn."Profit %" < 0)
        then begin
            CustomerRebateDetailsIn."Rebate %" := 0;
            CustomerRebateDetailsIn."Rebate Per Unit" := 0;
            CustomerRebateDetailsIn."Customer Rebate Amount" := 0;
            exit;
        end;

        case CustomerRebateDetailsIn."Rebate Type" of
            CustomerRebateDetailsIn."Rebate Type"::"Per Unit":
                begin
                    CustomerRebateDetailsIn."Customer Rebate Amount" := Round(CustomerRebateDetailsIn."Rebate Per Unit" * CustomerRebateDetailsIn.Quantity, 0.01);
                    CustomerRebateDetailsIn."Rebate %" := 0;
                end;
            CustomerRebateDetailsIn."Rebate Type"::Percentage:
                begin
                    CustomerRebateDetailsIn."Customer Rebate Amount" := Round((CustomerRebateDetailsIn."Rebate %" / 100) * CustomerRebateDetailsIn.Amount, 0.01);
                    CustomerRebateDetailsIn."Rebate Per Unit" := 0;
                end;
            else
                CustomerRebateDetailsIn."Customer Rebate Amount" := Round(CustomerRebateDetailsIn."Rebate Per Unit" * CustomerRebateDetailsIn.Quantity, 0.01);
        end;
    end;

    local procedure CalculateProfitPercentage(var CustomerRebateDetailsVar: Record "AQD Customer Rebate Details"): Decimal
    var
        ProfitPer: Decimal;
    begin
        ProfitPer := 0;
        CustomerRebateDetailsVar."Profit Amount" := Round(CustomerRebateDetailsVar.Quantity * (CustomerRebateDetailsVar."Unit Price" - CustomerRebateDetailsVar."Unit Cost"), 0.01);
        if CustomerRebateDetailsVar."Unit Price" <> 0 then
            ProfitPer := Round((CustomerRebateDetailsVar."Unit Price" - CustomerRebateDetailsVar."Unit Cost") / CustomerRebateDetailsVar."Unit Price" * 100, 0.01);
        if CustomerRebateDetailsVar."Document Type" = CustomerRebateDetailsVar."Document Type"::"Credit Memo" then begin
            CustomerRebateDetailsVar."Profit Amount" := -1 * CustomerRebateDetailsVar."Profit Amount";
            ProfitPer := ProfitPer * -1;
        end;
        exit(ProfitPer);
    end;

    local procedure GetRebateCustomerDetails(var SalesHeaderIn: RECORD "Sales Header")
    var
        LocalCustomerRebateType: Record "AQD Rebate Customer Category";
    begin
        CASE RebateSetup."Bill-To Rebate Customer" OF
            RebateSetup."Bill-To Rebate Customer"::"Customer Card Setup":
                BEGIN
                    BillToCustomer.TESTFIELD("AQD Cust Rebate Customer No.");
                    RebateToCUstomer.Get(BillToCustomer."AQD Cust Rebate Customer No.");
                END;
            RebateSetup."Bill-To Rebate Customer"::"Customer Rebate Category Setup":
                BEGIN
                    BillToCustomer.TestField("AQD Cust Rebate Category");
                    LocalCustomerRebateType.GET(BillToCustomer."AQD Cust Rebate Category");
                    RebateToCUstomer.Get(LocalCustomerRebateType."Rebate Customer No");
                END;
        END;
    END;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplySalesLineFilter(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateRebateAmount(var CustomerRebateDetails: Record "AQD Customer Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRebateHeader(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateHeader(SalesHeader: Record "Sales Header"; var CustomerRebateHeader: Record "AQD Customer Rebate Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateHeader(SalesHeader: Record "Sales Header"; var CustomerRebateHeader: Record "AQD Customer Rebate Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitCustomerRebateLine(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateLine(var CustomerRebateLine: Record "AQD Customer Rebate Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateLine(var CustomerRebateLine: Record "AQD Customer Rebate Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRebateDetail(SalesHeader: Record "Sales Header"; SalesLineIn: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRebateDetail(var CustomerRebateDetails: Record "AQD Customer Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRebateDetail(var CustomerRebateDetails: Record "AQD Customer Rebate Details")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRebateAmount(var CustomerRebateDetails: Record "AQD Customer Rebate Details")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCalculatingCustomerRebate(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetRebateRateForOtherTypes(DocumentLine_Type: Enum "Sales Line Type"; DocumentLine_No: Code[20]; var IsRebateEnabled: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitCustomerRebateEntry(DocumentType: Option " ",Invoice,"Credit Memo"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Invoice Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindRebateRate(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesRebateDetail(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesRebateDetail(var CustomerRebateDetailsLocIn: Record "AQD Customer Rebate Details")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLineRebateEnabled(SalesHeader: Record "Sales Header"; var IsRebateEnabled: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckLineRebateEnabled(SalesHeaderIn: Record "Sales Header"; var IsRebateEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetFilterTempRebateCategoryLines(var TempRebateCategoryLines: Record "AQD Cust Rebate Category Lines" temporary; SalesHeaderIn: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempRebateCategoryLines(var TempRebateCategoryLines: Record "AQD Cust Rebate Category Lines" temporary; GlobalSalesRebateRate: Record "AQD Sales Rebates Rate New"; CustomerNo: Code[20])
    begin
    end;
}