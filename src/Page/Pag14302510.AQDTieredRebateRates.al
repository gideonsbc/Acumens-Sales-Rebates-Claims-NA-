
page 14302510 "AQD Tiered Rebate Rates"
{
    ApplicationArea = All;
    Caption = 'AQD Tiered Rebate Rates';
    PageType = List;
    SourceTable = "AQD Tiered Rebate Rates";
    UsageCategory = Lists;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Basis; Rec.Basis)
                {
                    ToolTip = 'Specifies the value of the Basis field.', Comment = '%';
                }
                field("Lower Limit %"; Rec."Lower Limit")
                {
                    ToolTip = 'Specifies the value of the Lower Limit (%) field.', Comment = '%';
                }
                field("Upper Limit %"; Rec."Upper Limit")
                {
                    ToolTip = 'Specifies the value of the Upper Limit (%) field.', Comment = '%';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ToolTip = 'Specifies the value of the Rebate % field.', Comment = '%';
                }
            }
        }
    }
}
