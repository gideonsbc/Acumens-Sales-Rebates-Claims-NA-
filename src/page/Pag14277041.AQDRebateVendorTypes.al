page 14277041 "AQD Rebate Vendor Types"
{
    ApplicationArea = All;
    Caption = 'Rebate Vendor Types';
    DelayedInsert = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "AQD Rebate Vendor Type";
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
                    ApplicationArea = All;
                    NotBlank = TRUE;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code for the Vendor Rebate Category.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the Vendor Rebate Category.';
                }
            }
        }
    }
    procedure SetSelection(var RebateVendorType: Record "AQD Rebate Vendor Type")
    begin
        CurrPage.SetSelectionFilter(RebateVendorType);
    end;

    procedure GetSelectionFilterForItem(var RebateVendorType: Record "AQD Rebate Vendor Type"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RebateVendorType);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateVendorType.FieldNo("Code")));
    end;
}