page 14301914 "AQD Rebate Customer Categories"
{
    ApplicationArea = All;
    Caption = 'Rebate Customer Categories';
    DelayedInsert = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "AQD Rebate Customer Category";
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
                field("Rebate Customer No"; Rec."Rebate Customer No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Customer No. for Rebate.';
                }
                field("Rebate Customer Name"; Rec."Rebate Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Customer Name for Rebate.';
                }
            }
        }
    }

    procedure SetSelection(var RebateCustomerType: Record "AQD Rebate Customer Category")
    begin
        CurrPage.SetSelectionFilter(RebateCustomerType);
    end;

    procedure GetSelectionFilterForItem(var RebateCustomerType: Record "AQD Rebate Customer Category"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RebateCustomerType);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateCustomerType.FieldNo("Code")));
    end;

    procedure GetSelectionFilter(): Text
    var
        RebateCustomerType: Record "AQD Rebate Customer Category";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        CurrPage.SetSelectionFilter(RebateCustomerType);
        RecRef.GetTable(RebateCustomerType);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, RebateCustomerType.FieldNo(Code)));
    end;

    var
        Text0000: Label '%1 and %2 must not be same.';
}