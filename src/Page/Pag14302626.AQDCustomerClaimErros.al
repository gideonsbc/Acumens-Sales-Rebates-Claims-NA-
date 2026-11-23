page 14302626 "AQD Customer Claim Errors"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    ApplicationArea = All;
    Caption = 'Customer Claim Errors';
    DeleteAllowed = false;
    Editable = FALSE;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AQD Customer Claim Errors";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Claim No."; Rec."Claim No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim No. field.', Comment = '%';
                }
                field("Claim Line No."; Rec."Claim Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim Line No. field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mandatory field.', Comment = '%';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Type field.', Comment = '%';
                }
                field("Error Date Time"; Rec."Error Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Date Time field.', Comment = '%';
                }
            }
        }
    }
}