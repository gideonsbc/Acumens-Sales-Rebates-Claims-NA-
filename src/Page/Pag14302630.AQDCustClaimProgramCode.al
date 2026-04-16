page 14302630 "AQD Cust Claim Program Code"
{
    ApplicationArea = All;
    Caption = 'Claim Program Codes';
    PageType = List;
    SourceTable = "AQD Cust Claim Program Code";
    UsageCategory = Lists;

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