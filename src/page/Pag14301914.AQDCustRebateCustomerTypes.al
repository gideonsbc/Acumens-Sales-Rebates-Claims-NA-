page 14301914 "AQD Cust Rebate Customer Types"
{
    ApplicationArea = All;
    Caption = 'Rebate Customer Types';
    DelayedInsert = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "AQD CustRbt RebateCustomerType";
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
                    ShowMandatory = TRUE;
                    ToolTip = 'Specifies the code for the Rebate Customer Type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the Rebate Customer Type.';
                }
            }
        }
    }

    procedure SetSelection(var RebateCustomerType: Record "AQD CustRbt RebateCustomerType")
    begin
        CurrPage.SetSelectionFilter(RebateCustomerType);
    end;

    procedure GetSelectionFilterForItem(var RebateCustomerType: Record "AQD CustRbt RebateCustomerType"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RebateCustomerType);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateCustomerType.FieldNo("Code")));
    end;

    procedure GetSelectionFilter(): Text
    var
        RebateCustomerType: Record "AQD CustRbt RebateCustomerType";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        CurrPage.SetSelectionFilter(RebateCustomerType);
        RecRef.GetTable(RebateCustomerType);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateCustomerType.FieldNo(Code)));
    end;
}