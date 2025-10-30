page 14301911 "AQD Cust RebateItem Categories"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Item Categories';
    CardPageId = "AQD CustRebateItemCategoryCard";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "AQD Cust Rebate Item Category";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the code for the item category.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the item category.';
                }
                field("Category Type"; Rec."Category Type")
                {
                    Editable = Rec."Rebate Enabled";
                    ToolTip = 'Specifies the value of the Category Type field.', Comment = '%';
                }
                field("Rebate Enabled"; Rec."Rebate Enabled")
                {
                    ToolTip = 'Specifies the value of the Rebatable field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Copy Item Categories")
            {
                ApplicationArea = All;
                Caption = 'Copy Item Categories';
                Image = CopyDocument;
                trigger OnAction()
                var
                    ItemCategory: Record "Item Category";
                    RebateItemCategory: Record "AQD Cust Rebate Item Category";
                    UserConfirm: Label 'Do you want to copy Item Categories?';
                begin
                    IF NOT Confirm(UserConfirm) then
                        EXIT;

                    ItemCategory.RESET;
                    IF ItemCategory.FindFirst() THEN begin
                        repeat
                            if NOT RebateItemCategory.GET(ItemCategory.Code) then BEGIN
                                RebateItemCategory.Init();
                                RebateItemCategory.Code := ItemCategory.Code;
                                RebateItemCategory.Description := ItemCategory.Description;
                                RebateItemCategory."Category Type" := RebateItemCategory."Category Type"::Item;
                                RebateItemCategory.Insert();
                            END;
                        until ItemCategory.Next() = 0;
                    end;
                end;
            }
        }
    }
    protected var
        ItemCategoryManagement: Codeunit "Item Category Management";
        StyleTxt: Text;

    procedure SetSelection(var RebateItemCategory: Record "AQD Cust Rebate Item Category")
    begin
        CurrPage.SetSelectionFilter(RebateItemCategory);
    end;

    procedure GetSelectionFilterForItem(var RebateItemCategory: Record "AQD Cust Rebate Item Category"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RebateItemCategory);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateItemCategory.FieldNo("Code")));
    end;

}

