page 14301936 "AQD Customer Rebate Comments"
{
    Caption = 'Customer Rebate Comments';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AQD Customer Rebate Comments";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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