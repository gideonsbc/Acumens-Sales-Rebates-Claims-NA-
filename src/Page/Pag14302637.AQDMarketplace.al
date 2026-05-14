page 14302637 "AQD Marketplace"
{
    Caption = 'Marketplace';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AQD Marketplace";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
            }
        }
    }

    procedure GetSelectionFilter(): Text
    var
        Marketplace: Record "AQD Marketplace";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(Marketplace);
        exit(SelectionFilterManagement.GetSelectionFilterForMarketplaceCode(Marketplace));
    end;
}