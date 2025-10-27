page 14277043 "AQD Vendor Rebate Rates"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Rates';
    DataCaptionExpression = PageCaptionText;
    DelayedInsert = true;
    PageType = List;
    //SaveValues = true;
    SourceTable = "AQD Vendor Rebate Rate";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(VendTypeFilterCtrl; VendorTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Type Filter';
                    ToolTip = 'Specifies a filter for which Purchase Rebates to display.';
                    trigger OnValidate()
                    begin
                        VendNoFilter := '';
                        VendNoFilterOnAfterValidate();
                    end;
                }
                field(VendNoFilterCtrl; VendNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No. Filter';
                    ToolTip = 'Specifies a filter for which purchase prices display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RebateVendorTypes: Record "AQD Rebate Vendor Type";
                        VendList: Page "Vendor List";
                        RebateVendorTypesPage: Page "AQD Rebate Vendor Types";
                    begin
                        case VendorTypeFilter OF
                            VendorTypeFilter::Vendor:
                                begin
                                    VendList.LookupMode := true;
                                    if VendList.RunModal() = ACTION::LookupOK then
                                        Text := VendList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            VendorTypeFilter::"Vendor Type":
                                begin
                                    IF RebateVendorTypesPage.RunModal() = Action::LookupOK then
                                        Text := RebateVendorTypesPage.GetSelectionFilterForItem(RebateVendorTypes)
                                    else
                                        exit(false);
                                end;
                        end;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        VendNoFilterOnAfterValidate();
                    end;
                }
                field(ItemTypeFIlterCtrl; ItemTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Type Filter';
                    ToolTip = 'Specifies a filter for which Purchase Rebates to display.';
                    trigger OnValidate()
                    begin
                        ItemNoFilter := '';
                        ItemNoFilterOnAfterValidate();
                    end;
                }
                field(ItemNoFIlterCtrl; ItemNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No. Filter';
                    ToolTip = 'Specifies a filter for which purchase Rebates to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RebateItemCategories: Record "AQD Rebate Item Category";
                        ItemList: Page "Item List";
                        ResourceList: Page "Resource List";
                        GLAccountList: Page "G/L Account List";
                        FixedAssetList: Page "Fixed Asset List";
                        ItemChargeList: Page "Item Charges";
                        ItemCharge: Record "Item Charge";
                        RebateItemCateghoriesPage: Page "AQD Rebate Item Categories";
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
                                    clear(RebateItemCateghoriesPage);
                                    RebateItemCateghoriesPage.LookupMode := true;
                                    if RebateItemCateghoriesPage.RunModal() = ACTION::LookupOK then
                                        Text := RebateItemCateghoriesPage.GetSelectionFilterForItem(RebateItemCategories)
                                    else
                                        exit(false);

                                end;
                        End;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoFilterOnAfterValidate();
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date Filter';
                    ToolTip = 'Specifies a filter for which purchase Rebates to display.';

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
                ShowCaption = false;
                field("Vendor Type"; Rec."Vendor Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the vendor type who offers the Purchase Rebate on the item.';

                    trigger OnValidate()
                    begin
                        IF Rec."Vendor Type" <> xRec."Vendor Type" then
                            Rec."Vendor No." := '';
                    end;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = Rec."Vendor Type" <> Rec."Vendor Type"::All;
                    Enabled = Rec."Vendor Type" <> Rec."Vendor Type"::All;
                    ToolTip = 'Specifies the number of the vendor who offers the Purchase Rebate on the item.';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Type that the purchase Rebate applies to.';
                }
                field("Item No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item that the purchase Rebate applies to.';
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
                    ToolTip = 'Specifies the the purchase Rebate Program Code applies to Line Item.';
                    ShowMandatory = TRUE;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in Rebates or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum quantity of the item that you must buy from the vendor in order to get the purchase rebate.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date from which the purchase rebate is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date to which the purchase rebate is valid.';
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

    trigger OnOpenPage()
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        IsOnMobile := ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Phone;

        GetRecFilters();
        SetRecFilters();
        IsLookupMode := CurrPage.LookupMode;

        RebateSetup.GET;
        SetCaption();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
    begin
        RebateSetup.GET;
        CASE RebateSetup."Default Setup Rebate Type" of
            RebateSetup."Default Setup Rebate Type"::Item:
                Rec."Line Type" := Rec."Line Type"::Item;
            RebateSetup."Default Setup Rebate Type"::"Rebate Category":
                Rec."Line Type" := Rec."Line Type"::"Rebate Category";
        END;
        Rec."Rebate Program Code" := RebateSetup."Default Rebate Program Code";
    end;

    var
        Vend: Record Vendor;
        VendNoFilter: Text;
        ItemNoFilter: Text;
        ItemTypeFilter: Enum "AQD Item Rebate Type Filter";
        VendorTypeFilter: Enum "AQD Vendor Rebate Type Filter";
        StartingDateFilter: Text[30];
        NoDataWithinFilterErr: Label 'There is no %1 within the filter %2.', Comment = '%1: Field(Code), %2: GetFilter(Code)';
        MultipleVendorsSelectedErr: Label 'More than one vendor uses these purchase prices. To copy prices, the Vendor No. Filter field must contain one vendor only.';
        IsLookupMode: Boolean;
        PageCaptionText: Text;
        IsOnMobile: Boolean;

    local procedure GetRecFilters()
    begin
        if Rec.GetFilters() <> '' then begin
            VendNoFilter := Rec.GetFilter("Vendor No.");
            ItemNoFilter := Rec.GetFilter("No.");
            Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
        end;
    end;

    procedure SetRecFilters()
    begin
        case VendorTypeFilter OF
            VendorTypeFilter::" ":
                BEGIN
                    Rec.SetRange("Vendor Type");
                END;
            VendorTypeFilter::Vendor:
                BEGIN
                    CheckFilters(DATABASE::Vendor, VendNoFilter);
                    Rec.SetRange("Vendor Type", Rec."Vendor Type"::Vendor);
                END;
            VendorTypeFilter::"Vendor Type":
                begin
                    CheckFilters(DATABASE::"AQD Rebate Vendor Type", VendNoFilter);
                    Rec.SetRange("Vendor Type", Rec."Vendor Type"::"Vendor Type");
                end;
            VendorTypeFilter::All:
                begin
                    VendNoFilter := '';
                    Rec.SetRange("Vendor Type", Rec."Vendor Type"::All);
                end;
        end;
        if VendNoFilter <> '' then
            Rec.SetFilter("Vendor No.", VendNoFilter)
        else
            Rec.SetRange("Vendor No.");

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
                    CheckFilters(DATABASE::"AQD Rebate Item Category", ItemNoFilter);
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

        CurrPage.Update(false);
    end;

    local procedure SetCaption()
    begin
        if IsOnMobile then
            PageCaptionText := ''
        else
            PageCaptionText := GetFilterDescription();
    end;

    local procedure GetFilterDescription(): Text
    var
        LocalItem: Record Item;
        LocalResource: Record Resource;
        LocalItemCharge: Record "Item Charge";
        LocalFixedAsset: Record "Fixed Asset";
        LocalGLAccount: Record "G/L Account";
        LocalItemCategory: Record "Item Category";
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[250];
        Description: Text;
    begin
        GetRecFilters();

        if ItemNoFilter <> '' then
            SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);

        SourceTableName := '';
        case ItemTypeFilter of
            ItemTypeFilter::Item:
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::Item);
                    LocalItem."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItem."No."));
                    if LocalItem.FindFIRST then begin
                        Description := LocalItem.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::Resource:
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::Resource);
                    LocalResource."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalResource."No."));
                    if LocalResource.FindFIRST then begin
                        Description := LocalResource.Name;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"G/L Account":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::"G/L Account");
                    LocalGLAccount."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalGLAccount."No."));
                    if LocalGLAccount.FindFIRST then begin
                        Description := LocalGLAccount.Name;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"Charge (Item)":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::"Item Charge");
                    LocalItemCharge."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItemCharge."No."));
                    if LocalItemCharge.FindFIRST then begin
                        Description := LocalItemCharge.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"Fixed Asset":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::"Fixed Asset");
                    LocalFixedAsset."No." := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalFixedAsset."No."));
                    if LocalFixedAsset.FindFIRST then begin
                        Description := LocalFixedAsset.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
            ItemTypeFilter::"Rebate Category":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, Database::"Item Category");
                    LocalItemCategory.Code := CopyStr(ItemNoFilter, 1, MaxStrLen(LocalItemCategory.Code));
                    if LocalItemCategory.FindFIRST then begin
                        Description := LocalItemCategory.Description;
                        exit(StrSubstNo('%1 %2 %3 %4 ', SourceTableName, FORMAT(ItemTypeFilter), ItemNoFilter, Description));
                    end else
                        EXIT('');
                end;
        END;

        if Vend.Get(CopyStr(VendNoFilter, 1, MaxStrLen(Vend."No."))) then
            Description := Vend.Name;

        exit(StrSubstNo('%1 %2 %3 %4 ', VendNoFilter, Description, SourceTableName, ItemNoFilter));
    end;

    local procedure VendNoFilterOnAfterValidate()
    var
        Item: Record Item;
    begin
        if Item.Get(Rec."No.") then
            CurrPage.SaveRecord();
        SetRecFilters();
        SetCaption();
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
        SetCaption();
    end;

    local procedure VendorNoFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
        SetCaption();
    end;

    procedure CheckFilters(TableNo: Integer; FilterTxt: Text)
    var
        FilterRecordRef: RecordRef;
        FilterFieldRef: FieldRef;
    begin
        if FilterTxt = '' then
            exit;
        Clear(FilterRecordRef);
        Clear(FilterFieldRef);
        FilterRecordRef.Open(TableNo);
        FilterFieldRef := FilterRecordRef.Field(1);
        FilterFieldRef.SetFilter(FilterTxt);
        if FilterRecordRef.IsEmpty() then
            Error(NoDataWithinFilterErr, FilterRecordRef.Caption, FilterTxt);
    end;

    procedure GetSelectionFilter(var VendorRebateRates: Record "AQD Vendor Rebate Rate")
    begin
        CurrPage.SetSelectionFilter(VendorRebateRates);
    end;
}