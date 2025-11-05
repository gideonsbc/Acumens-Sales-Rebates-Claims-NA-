page 14301916 "AQD CustRbt SalesRebates Setup"
{
    ApplicationArea = All;
    Caption = 'Sales Rebates Setup';
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
                        RebateCustomerTypeList: Page "AQD Cust Rebate Customer Types";
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
                            CustomerTypeFilter::"Customer Type":
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
                        CustItemRebateCategories: Record "AQD Cust Rebate Item Category";
                        ItemCharge: Record "Item Charge";
                        ItemList: Page "Item List";
                        ResourceList: Page "Resource List";
                        GLAccountList: Page "G/L Account List";
                        FixedAssetList: Page "Fixed Asset List";
                        ItemChargeList: Page "Item Charges";
                        CustItemRebateCateghoriesPage: Page "AQD Cust RebateItem Categories";
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
                            ItemTypeFilter::"Fixed Asset":
                                begin
                                    FixedAssetList.LookupMode := true;
                                    if FixedAssetList.RunModal() = ACTION::LookupOK then
                                        Text := FixedAssetList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            ItemTypeFilter::"Charge (Item)":
                                begin
                                    ItemChargeList.LookupMode := true;
                                    if ItemChargeList.RunModal() = ACTION::LookupOK then begin
                                        ItemChargeList.GetRecord(ItemCharge);
                                        Text := ItemCharge."No.";
                                    end else
                                        exit(false);
                                end;
                            ItemTypeFilter::"Rebate Category":
                                begin
                                    clear(CustItemRebateCateghoriesPage);
                                    CustItemRebateCateghoriesPage.LookupMode := true;
                                    if CustItemRebateCateghoriesPage.RunModal() = ACTION::LookupOK then
                                        Text := CustItemRebateCateghoriesPage.GetSelectionFilterForItem(CustItemRebateCategories)
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
                field("Customer Type"; Rec."Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = SalesTypeControlEditable;
                    ToolTip = 'Specifies the Customer Type, which defines whether the Rebate is for an individual, group, all customers.';

                    trigger OnValidate()
                    begin
                        CustomerNoControlEditable := SetCustomerNoEditable(Rec."Customer Type");
                        IF Rec."Customer Type" <> xRec."Customer Type" then
                            Rec."Customer No." := '';
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = CustomerNoControlEditable;
                    ToolTip = 'Specifies the Customer No. that belongs to the Customer Type.';
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
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the the Sales Rebate Program Code applies to Line Item.';
                    ShowMandatory = TRUE;
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
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum sales quantity required to warrant the sales rebate.';
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
                field("Rebate Per Quantity"; Rec."Rebate Per Quantity")
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
                Promoted = true;
                PromotedCategory = Process;
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
                Promoted = true;
                PromotedCategory = Process;
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
    end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // begin
    //     RebateSetup.GET;
    //     CASE RebateSetup."Default Setup Rebate Type" of
    //         RebateSetup."Default Setup Rebate Type"::Item:
    //             Rec."Line Type" := Rec."Line Type"::Item;
    //         RebateSetup."Default Setup Rebate Type"::"Rebate Category":
    //             Rec."Line Type" := Rec."Line Type"::"Rebate Category";
    //     END;
    //     Rec."Rebate Code" := RebateSetup."Default Rebate Code";
    // end;


    var
        Cust: Record Customer;
        RebateCustomerType: Record "AQD CustRbt RebateCustomerType";
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

        CustomerNoFilter := Rec.GetFilter("Customer No.");
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
                CustomerTypeFilter::"Customer Type":
                    begin
                        Rec.SetRange("Customer Type", Rec."Customer Type"::"Customer Type");
                        CheckFilters(DATABASE::"AQD CustRbt RebateCustomerType", CustomerNoFilter);
                    end;
                CustomerTypeFilter::"All Customers":
                    begin
                        CustomerNoFilter := '';
                        Rec.SetRange("Customer Type", Rec."Customer Type"::"All Customers");
                    end;
            End;
        end else
            Rec.SetRange("Customer Type");

        if CustomerTypeFilter in [CustomerTypeFilter::"All Customers", CustomerTypeFilter::" "] then begin
            CustomerNoFilterEnable := false;
            CustomerNoFilter := '';
        end;

        if CustomerNoFilter <> '' then
            Rec.SetFilter("Customer No.", CustomerNoFilter)
        else
            Rec.SetRange("Customer No.");

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
            ItemTypeFilter::"Fixed Asset":
                BEGIN
                    CheckFilters(DATABASE::"Fixed Asset", ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::"Fixed Asset");
                END;
            ItemTypeFilter::"G/L Account":
                BEGIN
                    CheckFilters(DATABASE::"G/L Account", ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::"G/L Account");
                END;
            ItemTypeFilter::"Charge (Item)":
                BEGIN
                    CheckFilters(DATABASE::"Item Charge", ItemNoFilter);
                    Rec.SetRange("Line Type", Rec."Line Type"::"Charge (Item)");
                END;
            ItemTypeFilter::"Rebate Category":
                BEGIN
                    CheckFilters(DATABASE::"AQD Cust Rebate Item Category", ItemNoFilter);
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
            ItemTypeFilter::"Charge (Item)":
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"Item Charge");
                    LocalItemCharge."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItemCharge."No."));
                    if LocalItemCharge.FindFIRST then begin
                        Description := LocalItemCharge.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"Fixed Asset":
                begin
                    SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"Fixed Asset");
                    LocalFixedAsset."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalFixedAsset."No."));
                    if LocalFixedAsset.FindFIRST then begin
                        Description := LocalFixedAsset.Description;
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
                exit(CustomerTypeFilter::Customer);
            Format(Rec."Customer Type"::"Customer Type"):
                exit(CustomerTypeFilter::"Customer Type");
            Format(Rec."Customer Type"::"All Customers"):
                exit(CustomerTypeFilter::"All Customers");
        end;
    end;

    local procedure SetCustomerNoEditable(CustomerTypeInput: Enum "AQD Cust Rebate Customer Type"): Boolean
    begin
        exit(CustomerTypeInput <> CustomerTypeInput::"All Customers");
    end;

    local procedure SetEditableFields()
    begin
        SalesTypeControlEditable := Rec.GetFilter("Customer Type") = '';
        CustomerNoControlEditable :=
          CustomerNoControlEditable and (Rec.GetFilter("Customer No.") = '');
    end;

    local procedure FilterLines()
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddTable(Rec.TableCaption, DATABASE::"Sales Price");

        FilterPageBuilder.SetView(Rec.TableCaption, Rec.GetView());
        if Rec.GetFilter("Customer Type") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Customer Type"));
        if Rec.GetFilter("Customer No.") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Customer No."));
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

