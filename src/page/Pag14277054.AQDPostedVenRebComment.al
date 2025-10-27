page 14277054 "AQD Posted Ven Reb Comment"
{
    Caption = 'Posted Vendor Rebate Comments';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AQD Posted Ven Reb Comment";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Rebate No."; Rec."Rebate No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate No. field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field.', Comment = '%';
                }
            }
        }
    }
}