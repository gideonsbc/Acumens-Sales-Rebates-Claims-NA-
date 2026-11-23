page 14302630 "AQD Cust Claim Program Code"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    ApplicationArea = All;
    Caption = 'Claim Program Codes';
    PageType = List;
    SourceTable = "AQD Cust Claim Program Code";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Claim Vendor No."; Rec."Claim Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim Vendor No. field.', Comment = '%';
                }
                field("Claim Vendor Name"; Rec."Claim Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim Vendor Name field.', Comment = '%';
                }
            }
        }
    }
}