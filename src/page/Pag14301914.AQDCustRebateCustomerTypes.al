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
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Customer Rebate Expense G/L Account No.';

                    trigger OnValidate()
                    BEGIN
                        IF (Rec."G/L Account No." <> '') AND
                           (Rec."G/L Account No." = Rec."Bal. G/ Account No.")
                        THEN
                            ERROR(Text0000, Rec."G/L Account No.", Rec."Bal. G/ Account No.");
                    END;
                }
                field("Bal. G/L Account No."; Rec."Bal. G/ Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Customer Rebate Expense Bal. G/L Account No.';

                    trigger OnValidate()
                    BEGIN
                        IF (Rec."Bal. G/ Account No." <> '') AND
                           (Rec."G/L Account No." = Rec."Bal. G/ Account No.")
                        THEN
                            ERROR(Text0000, Rec."G/L Account No.", Rec."Bal. G/ Account No.");
                    END;
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

    var
        Text0000: Label '%1 and %2 must not be same.';
}