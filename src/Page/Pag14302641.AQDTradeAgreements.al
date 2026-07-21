page 14302641 "AQD Trade Agreements"
{
    ApplicationArea = All;
    Caption = 'Trade Agreements';
    PageType = List;
    SourceTable = "AQD Trade Agreement";
    UsageCategory = Lists;
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to the base app';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}
