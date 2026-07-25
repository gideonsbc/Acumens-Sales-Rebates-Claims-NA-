page 14302516 "AQD CustRbt SalesRebates Setup"
{
    ApplicationArea = All;
    Caption = 'Sales Rebates & Commission Rates';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "AQD Sales Rebates Rate";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CustomerTypeFilter; CustomerTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Type Filter';
                    ToolTip = 'Specifies a filter for which sales Rebates to display.';

                    trigger OnValidate()
                    begin
                        CustomerNoFilter := '';
                        SalesTypeFilterOnAfterValidate;
                    end;
                }
                field(CustomerNoFilter; CustomerNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Customer No. Filter';
                    Enabled = CustomerNoFilterEnable;
                    ToolTip = 'Specifies a filter for which sales rebate to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        RebateCustomerTypeList: Page "AQD Rebate Customer Categories";
                    begin
                        IF CustomerTypeFilter = CustomerTypeFilter::"All Customers" THEN
                            EXIT;

                        CASE CustomerTypeFilter OF
                            CustomerTypeFilter::Customer:
                                BEGIN
                                    CustList.LOOKUPMODE := TRUE;
                                    IF CustList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := CustList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            CustomerTypeFilter::"Customer Category":
                                BEGIN
                                    RebateCustomerTypeList.LOOKUPMODE := TRUE;
                                    IF RebateCustomerTypeList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := RebateCustomerTypeList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        CustomerNoFilterOnAfterValidate;
                    end;
                }
                field(ItemTypeFIlterCtrl; ItemTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Type Filter';
                    ToolTip = 'Specifies a filter for which Sales Rebates to display.';
                    trigger OnValidate()
                    begin
                        ItemNoFilter := '';
                        ItemNoFilterOnAfterValidate();
                    end;
                }
                field(ItemNoFilterCtrl; ItemNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No. Filter';
                    ToolTip = 'Specifies a filter for which sales rebates to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemCategories: Record "Item Category";
                        ItemCharge: Record "Item Charge";
                        ItemList: Page "Item List";
                        ResourceList: Page "Resource List";
                        GLAccountList: Page "G/L Account List";
                        FixedAssetList: Page "Fixed Asset List";
                        ItemChargeList: Page "Item Charges";
                        ItemCateghoriesPage: Page "Item Categories";
                    begin
                        Case ItemTypeFilter of
                            ItemTypeFilter::Item:
                                begin
                                    ItemList.LookupMode := true;
                                    if ItemList.RunModal() = ACTION::LookupOK then
                                        Text := ItemList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            ItemTypeFilter::Resource:
                                begin
                                    ResourceList.LookupMode := true;
                                    if ResourceList.RunModal() = ACTION::LookupOK then
                                        Text := ResourceList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            ItemTypeFilter::"G/L Account":
                                begin
                                    GLAccountList.LookupMode := true;
                                    if GLAccountList.RunModal() = ACTION::LookupOK then
                                        Text := GLAccountList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            ItemTypeFilter::"Rebate Category":
                                begin
                                    clear(ItemCateghoriesPage);
                                    ItemCateghoriesPage.LookupMode := true;
                                    if ItemCateghoriesPage.RunModal() = ACTION::LookupOK then
                                        Text := ItemCateghoriesPage.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                        End;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoFilterOnAfterValidate;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date Filter';
                    ToolTip = 'Specifies a filter for which sales rebates to display.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(StartingDateFilter);
                        StartingDateFilterOnAfterValid();
                    end;
                }
            }
            repeater(Control1)
            {
                field("CustRbt Rate Type"; Rec."CustRbt Rate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the the Customer Rebate Type applies to Line Item.';
                    ShowMandatory = TRUE;
                    QuickEntry = TRUE;
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the the Sales Rebate Program Code applies to Line Item.';
                    ShowMandatory = TRUE;
                    QuickEntry = TRUE;
                }
                field("Payee Type"; Rec."Payee Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payee Type field.', Comment = '%';
                }
                field("Payee No."; Rec."Payee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payee No. field.', Comment = '%';
                }
                field("Customer Type"; Rec."Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = SalesTypeControlEditable;
                    ToolTip = 'Specifies the Customer Type, which defines whether the Rebate is for an individual, group, all customers.';

                    trigger OnValidate()
                    begin
                        CustomerNoControlEditable := SetCustomerNoEditable(Rec."Customer Type");
                    end;
                }
                field("Customer No. Filter"; Rec."Customer No. Filter")
                {
                    ApplicationArea = All;
                    trigger onlookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        RebateCustomerTypeList: Page "AQD Rebate Customer Categories";
                    begin
                        CASE Rec."Customer Type" OF
                            Rec."Customer Type"::Customer:
                                BEGIN
                                    CustList.LOOKUPMODE := TRUE;
                                    IF CustList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := CustList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            Rec."Customer Type"::"Customer Category":
                                BEGIN
                                    RebateCustomerTypeList.LOOKUPMODE := TRUE;
                                    IF RebateCustomerTypeList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := RebateCustomerTypeList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;
                }
                Field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Territory Code that belongs to the Entity Type.';
                }
                field("AQD Trade Agreement"; Rec."AQD Trade Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Agreement field.';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Type of the item for which the Sales Rebate is valid.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item for which the Sales Rebate is valid.';
                }
                field("No. Filter"; Rec."No. Filter")
                {
                    ApplicationArea = All;
                    Editable = Rec."No." = '';
                    trigger onlookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        GLList: Page "G/L Account List";
                        ResourceList: Page "Resource List";
                        ItemCategories: Page "Item Categories";
                    begin
                        CASE Rec."Line Type" OF
                            Rec."Line Type"::Item:
                                BEGIN
                                    ItemList.LOOKUPMODE := TRUE;
                                    IF ItemList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            Rec."Line Type"::"G/L Account":
                                BEGIN
                                    GLList.LOOKUPMODE := TRUE;
                                    IF GLList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := GLList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            Rec."Line Type"::Resource:
                                BEGIN
                                    ResourceList.LOOKUPMODE := TRUE;
                                    IF ResourceList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ResourceList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            Rec."Line Type"::"Rebate Category":
                                BEGIN
                                    ItemCategories.LOOKUPMODE := TRUE;
                                    IF ItemCategories.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemCategories.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Rate Priority"; Rec."Rate Priority")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date from which the sales rebate is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calendar date when the sales rebate agreement ends.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the minimum sales quantity required to warrant the sales rebate.';
                }
                field("Minimum Amount"; Rec."Minimum Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the minimum Sales Amount required to warrant the sales rebate.';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                    Editable = Rec."Rebate Type" = Rec."Rebate Type"::Percentage;
                    Enabled = Rec."Rebate Type" = Rec."Rebate Type"::Percentage;
                }
                field("Rebate Per Quantity"; Rec."Rebate Per Unit")
                {
                    ApplicationArea = All;
                    Editable = Rec."Rebate Type" = Rec."Rebate Type"::"Per Quantity";
                    Enabled = Rec."Rebate Type" = Rec."Rebate Type"::"Per Quantity";
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Caption = 'Blocked';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SalesPricesFilter)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Filter';
                Image = "Filter";
                ToolTip = 'Apply the filter.';
                Visible = IsOnMobile;

                trigger OnAction()
                begin
                    FilterLines;
                end;
            }
            action(ClearFilter)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Clear Filter';
                Image = ClearFilter;
                ToolTip = 'Clear filter.';
                Visible = IsOnMobile;

                trigger OnAction()
                begin
                    Rec.RESET;
                    UpdateBasicRecFilters;
                    Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
                    SetEditableFields;
                end;
            }
            action(CopySalesRebateRates)
            {
                Caption = 'Copy Rebate Rates';
                trigger OnAction()
                var
                    FromSalesRebateSetup: Record "AQD Sales Rebates Rate";
                    DeleteSalesRebateSetup: Record "AQD Sales Rebates Rate";
                    ToSalesRebateSetup: Record "AQD Sales Rebates Rate";
                    TempRebateRateToCopy: Record "Drop Shpt. Post. Buffer"; //"Order No.", "Order Line No."
                    DeleteOldRates: Boolean;
                    StartDate: Date;
                    EndDate: Date;
                    CopiedRow: Integer;
                    DeletedRows: Integer;
                    UserConfirmMsg: Label 'Do you want to copy Sales Rebate Rates?';
                    UserCancelMsg: Label 'The process is cancelled.';
                    CompletionMsg: Label '%1 Sales Rebate Rates are copied.';
                    CompletionWithDeleteMsg: Label '%1 Sales Rebate Rates are copied.\\%2 Old Sales Rebate Rates are deleted.';
                    CustRbtUserInputPeriodPage: Page "AQD CustRbt User Input Period";
                BEGIN
                    CLEAR(CustRbtUserInputPeriodPage);
                    CustRbtUserInputPeriodPage.LookupMode(TRUE);
                    IF CustRbtUserInputPeriodPage.RUNMODAL = Action::LookupOK THEN
                        CustRbtUserInputPeriodPage.GetInputDate(StartDate, EndDate, DeleteOldRates)
                    ELSE BEGIN
                        Message(UserCancelMsg);
                        EXIT;
                    END;

                    FromSalesRebateSetup.Copy(Rec, FALSE);
                    IF FromSalesRebateSetup.FindFirst() THEN BEGIN
                        REPEAT
                            TempRebateRateToCopy.INIT;
                            TempRebateRateToCopy."Order No." := '';
                            TempRebateRateToCopy."Order Line No." := FromSalesRebateSetup."Entry No.";
                            TempRebateRateToCopy.INSERT;
                        UNTIL FromSalesRebateSetup.Next() = 0;
                    END;

                    TempRebateRateToCopy.RESET;
                    IF TempRebateRateToCopy.FINDFIRST THEN BEGIN
                        REPEAT
                            IF FromSalesRebateSetup.GET(TempRebateRateToCopy."Order Line No.") THEN BEGIN
                                ToSalesRebateSetup.INIT;
                                ToSalesRebateSetup := FromSalesRebateSetup;
                                ToSalesRebateSetup."Entry No." := 0;
                                ToSalesRebateSetup."Starting Date" := StartDate;
                                ToSalesRebateSetup."Ending Date" := EndDate;
                                IF ToSalesRebateSetup.Insert THEN BEGIN
                                    CopiedRow += 1;
                                    IF DeleteOldRates THEN BEGIN
                                        IF DeleteSalesRebateSetup.GET(FromSalesRebateSetup."Entry No.") THEN BEGIN
                                            DeletedRows += 1;
                                            DeleteSalesRebateSetup.Delete();
                                        END;
                                    END;
                                END;
                            END;
                        UNTIL TempRebateRateToCopy.Next() = 0;
                    END;
                    IF DeleteOldRates THEN
                        Message(StrSubstNo(CompletionWithDeleteMsg, CopiedRow, DeletedRows))
                    ELSE
                        Message(StrSubstNo(CompletionMsg, CopiedRow));
                END;
            }
        }
        area(Promoted)
        {
            actionref(SalesPricesFilter_Promoted; SalesPricesFilter) { }
            actionref(ClearFilter_Promoted; ClearFilter) { }
            actionref(CopySalesRebateRatesRef; CopySalesRebateRates) { }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CustomerNoControlEditable := SetCustomerNoEditable(Rec."Customer Type");
    end;

    trigger OnInit()
    begin
        CustomerNoFilterEnable := TRUE;
        CustomerNoControlEditable := TRUE;
        IsLookupMode := CurrPage.LOOKUPMODE;
    end;

    trigger OnOpenPage()
    begin
        IsOnMobile := ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Phone;
        GetRecFilters;
        SetRecFilters;
        IsLookupMode := CurrPage.LookupMode;

        RebateSetup.GET;
        SetCaption();

        Rec.SetCurrentKey("CustRbt Rate Type", "Customer Type", "Customer No. Filter", "Territory Code", "Line Type", "No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        RebateSetup.GET;
        CASE RebateSetup."Default Setup Rebate Type" of
            RebateSetup."Default Setup Rebate Type"::Item:
                Rec."Line Type" := Rec."Line Type"::Item;
            RebateSetup."Default Setup Rebate Type"::"Rebate Category":
                Rec."Line Type" := Rec."Line Type"::"Rebate Category";
        END;
        IF RebateSetup."Default Rebate Program Code" <> '' THEN
            Rec."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
    end;

    var
        Cust: Record Customer;
        RebateCustomerType: Record "AQD Rebate Customer Category";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        ClientTypeManagement: Codeunit "Client Type Management";
        CustomerTypeFilter: Enum "AQD Rebate Cust Type Filter";
        CustomerNoFilter: Text;
        ItemTypeFilter: Enum "AQD Item Rebate Type Filter";
        ItemNoFilter: Text;
        StartingDateFilter: Text[30];
        CurrencyCodeFilter: Text;
        Text000: Label 'All Customers';
        Text001: Label 'No %1 within the filter %2.';
        CustomerNoFilterEnable: Boolean;
        IsOnMobile: Boolean;
        IsLookupMode: Boolean;
        SalesTypeControlEditable: Boolean;
        CustomerNoControlEditable: Boolean;
        MultipleCustomersSelectedErr: Label 'More than one customer uses these sales rebates. To copy Rebates, the Sales Code Filter field must contain one customer only.';
        IncorrectSalesTypeToCopyPricesErr: Label 'To copy sales rebates, The Sales Type Filter field must contain Customer.';
        PageCaptionText: Text;

    local procedure SetCaption()
    begin
        if IsOnMobile then
            PageCaptionText := ''
        else
            PageCaptionText := GetFilterDescription();
    end;

    local procedure GetRecFilters()
    begin
        if Rec.GetFilters() <> '' then
            UpdateBasicRecFilters();

        Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
    end;

    local procedure UpdateBasicRecFilters()
    begin
        if Rec.GetFilter("Customer Type") <> '' then
            CustomerTypeFilter := GetSalesTypeFilter()
        else
            CustomerTypeFilter := CustomerTypeFilter::" ";

        CustomerNoFilter := Rec.GetFilter("Customer No. Filter");
        ItemNoFilter := Rec.GetFilter("No.");
    end;

    procedure SetRecFilters()
    begin
        CustomerNoFilterEnable := true;

        if CustomerTypeFilter <> CustomerTypeFilter::" " then begin
            Case CustomerTypeFilter OF
                CustomerTypeFilter::" ":
                    Rec.SetRange("Customer Type");
                CustomerTypeFilter::Customer:
                    begin
                        CheckFilters(DATABASE::Customer, CustomerNoFilter);
                        Rec.SetRange("Customer Type", Rec."Customer Type"::Customer);
                    end;
                CustomerTypeFilter::"Customer Category":
                    begin
                        CheckFilters(DATABASE::"AQD Rebate Customer Category", CustomerNoFilter);
                        Rec.SetRange("Customer Type", Rec."Customer Type"::"Customer Category");
                    end;
            // CustomerTypeFilter::"All Customers":
            //     begin
            //         CustomerNoFilter := '';
            //         Rec.SetRange("Entity Type", Rec."Entity Type"::"All Customers");
            //     end;
            // CustomerTypeFilter::"Employee Commission":
            //     begin
            //         CheckFilters(DATABASE::Employee, CustomerNoFilter);
            //         Rec.SetRange("Entity Type", Rec."Entity Type"::"Employee Commission");
            //     end;
            // CustomerTypeFilter::"Vendor Commission":
            //     begin
            //         CustomerNoFilter := '';
            //         CheckFilters(DATABASE::Vendor, CustomerNoFilter);
            //         Rec.SetRange("Entity Type", Rec."Entity Type"::"Vendor Commission");
            //     end;
            End;
        end else
            Rec.SetRange("Customer Type");

        if CustomerTypeFilter in [CustomerTypeFilter::"All Customers", CustomerTypeFilter::" "] then begin
            CustomerNoFilterEnable := false;
            CustomerNoFilter := '';
        end;

        if CustomerNoFilter <> '' then
            Rec.SetFilter("Customer No. Filter", CustomerNoFilter)
        else
            Rec.SetRange("Customer No. Filter");

        if StartingDateFilter <> '' then
            Rec.SetFilter("Starting Date", StartingDateFilter)
        else
            Rec.SetRange("Starting Date");

        case ItemTypeFilter of
            ItemTypeFilter::Item:
                BEGIN
                    CheckFilters(DATABASE::Item, ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::Item);
                END;
            ItemTypeFilter::Resource:
                begin
                    CheckFilters(DATABASE::Resource, ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::Resource);
                end;
            ItemTypeFilter::"G/L Account":
                BEGIN
                    CheckFilters(DATABASE::"G/L Account", ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::"G/L Account");
                END;
            ItemTypeFilter::"Rebate Category":
                BEGIN
                    CheckFilters(DATABASE::"Item Category", ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::"Rebate Category");
                END;
            ItemTypeFilter::" ":
                begin
                    ItemNoFilter := '';
                    Rec.SetRange("Line Type");
                END;
        end;

        if ItemNoFilter <> '' then
            Rec.SetFilter("No.", ItemNoFilter)
        else
            Rec.SetRange("No.");
        SetEditableFields();
        CurrPage.Update(false);
    end;

    local procedure GetCaption(): Text
    begin
        if IsOnMobile then
            PageCaptionText := ''
        else
            PageCaptionText := GetFilterDescription();

        EXIT(PageCaptionText);
    end;

    local procedure GetFilterDescription(): Text
    var
        ObjTranslation: Record "Object Translation";
        LocalItem: Record Item;
        LocalResource: Record Resource;
        LocalItemCharge: Record "Item Charge";
        LocalFixedAsset: Record "Fixed Asset";
        LocalGLAccount: Record "G/L Account";
        LocalItemCategory: Record "Item Category";
        SourceTableName: Text;
        SalesSrcTableName: Text;
        Description: Text;
    begin
        GetRecFilters;

        SourceTableName := '';
        IF ItemNoFilter <> '' THEN
            SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, 27);

        SourceTableName := '';
        case ItemTypeFilter of
            ItemTypeFilter::Item:
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Item);
                    LocalItem."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItem."No."));
                    if LocalItem.FindFIRST then begin
                        Description := LocalItem.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::Resource:
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Resource);
                    LocalResource."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalResource."No."));
                    if LocalResource.FindFIRST then begin
                        Description := LocalResource.Name;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"G/L Account":
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"G/L Account");
                    LocalGLAccount."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalGLAccount."No."));
                    if LocalGLAccount.FindFIRST then begin
                        Description := LocalGLAccount.Name;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"Rebate Category":
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"Item Category");
                    LocalItemCategory.Code := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItemCategory.Code));
                    if LocalItemCategory.FindFIRST then begin
                        Description := LocalItemCategory.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
        END;

        IF SalesSrcTableName = Text000 THEN
            EXIT(STRSUBSTNO('%1 %2 %3', SalesSrcTableName, SourceTableName, ItemNoFilter));

        EXIT(STRSUBSTNO('%1 %2 %3 %4 %5', SalesSrcTableName, CustomerNoFilter, Description, SourceTableName, ItemNoFilter));
    end;

    local procedure CheckFilters(TableNo: Integer; FilterTxt: Text)
    var
        FilterRecordRef: RecordRef;
        FilterFieldRef: FieldRef;
    begin
        IF FilterTxt = '' THEN
            EXIT;
        CLEAR(FilterRecordRef);
        CLEAR(FilterFieldRef);
        FilterRecordRef.OPEN(TableNo);
        FilterFieldRef := FilterRecordRef.FIELD(1);
        FilterFieldRef.SETFILTER(FilterTxt);
        IF FilterRecordRef.ISEMPTY THEN
            ERROR(Text001, FilterRecordRef.CAPTION, FilterTxt);
    end;

    local procedure CustomerNoFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure SalesTypeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        CustomerNoFilter := '';
        SetRecFilters;
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure GetSalesTypeFilter(): Integer
    begin
        case Rec.GetFilter("Customer Type") of
            Format(Rec."Customer Type"::Customer):
                exit(CustomerTypeFilter::Customer.AsInteger());
            Format(Rec."Customer Type"::"Customer Category"):
                exit(CustomerTypeFilter::"Customer Category".AsInteger());
        // Format(Rec."Entity Type"::"All Customers"):
        //     exit(CustomerTypeFilter::"All Customers".AsInteger());
        end;
        // case Rec.GetFilter("Payee Type") of
        //     Format(Rec."Payee Type"::"Employee Commission"):
        //         exit(CustomerTypeFilter::"Employee Commission".AsInteger());
        //     Format(Rec."Payee Type"::"Vendor Commission"):
        //         exit(CustomerTypeFilter::"Vendor Commission".AsInteger());
        // end;
    end;

    local procedure SetCustomerNoEditable(CustomerTypeInput: Enum "AQD Sales Rebate Customer Type"): Boolean
    begin
        //exit(CustomerTypeInput <> CustomerTypeInput::"All Customers");
    end;

    local procedure SetEditableFields()
    begin
        SalesTypeControlEditable := Rec.GetFilter("Customer Type") = '';
        CustomerNoControlEditable :=
          CustomerNoControlEditable and (Rec.GetFilter("Customer No. Filter") = '');
    end;

    local procedure FilterLines()
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddTable(Rec.TableCaption, DATABASE::"Sales Price");

        FilterPageBuilder.SetView(Rec.TableCaption, Rec.GetView());
        if Rec.GetFilter("Customer Type") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Customer Type"));
        if Rec.GetFilter("Customer No. Filter") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Customer No. Filter"));
        if Rec.GetFilter("No.") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("No."));
        if Rec.GetFilter("Starting Date") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Starting Date"));
        if FilterPageBuilder.RunModal() then
            Rec.SetView(FilterPageBuilder.GetView(Rec.TableCaption));

        UpdateBasicRecFilters();
        Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
        SetEditableFields();
    end;
}