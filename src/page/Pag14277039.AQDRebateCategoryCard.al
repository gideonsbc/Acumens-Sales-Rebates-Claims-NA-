page 14277039 "AQD Rebate Item Category Card"
{
    ApplicationArea = All;
    Caption = 'Rebate Category Card';
    PageType = Card;
    SourceTable = "AQD Rebate Item Category";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code for the item category.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the item category.';
                }
                field(Rebatable; Rec.Rebatable)
                {
                    ToolTip = 'Specifies the value of the Rebatable field.', Comment = '%';
                }
                field("Category Type"; Rec."Category Type")
                {
                    Editable = Rec.Rebatable;
                    ToolTip = 'Specifies the value of the Category Type field.', Comment = '%';
                }
            }
            part("AQD Item Rebate Category Subpage"; "AQD Rebate Category Subpage")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Rebate Category Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }
}
