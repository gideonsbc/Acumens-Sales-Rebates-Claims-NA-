page 14301912 "AQD CustRebateItemCategoryCard"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Category Card';
    PageType = Card;
    SourceTable = "AQD Cust Rebate Item Category";

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
            part("AQD Item Rebate Category Subpage"; "AQD CustRebateCategory Subpage")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Rebate Category Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }
}
