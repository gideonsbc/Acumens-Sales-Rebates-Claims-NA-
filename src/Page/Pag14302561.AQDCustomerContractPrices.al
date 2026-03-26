page 14302561 "AQD Customer Contract Prices"
{
    ApplicationArea = All;
    Caption = 'Customer Contract Prices';
    PageType = List;
    SourceTable = "AQD Customer Contract Prices";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1000000000)
            {
                ShowCaption = false;
                field("Item No"; Rec."Item No")
                {
                    ApplicationArea = All;
                }
                field("Customer No"; Rec."Customer No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Contract Price CA"; Rec."Contract Price CA")
                {
                    ApplicationArea = All;
                }
                field("Contract Price AZ"; Rec."Contract Price AZ")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}