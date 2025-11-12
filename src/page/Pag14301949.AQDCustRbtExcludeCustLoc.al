namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301949 "AQD Cust Rbt Exclude Cust Loc"
{
    ApplicationArea = All;
    Caption = 'Exclude Customer Locations';
    PageType = List;
    SourceTable = "AQD Cust Rbt Exclude Cust Loc";
    UsageCategory = Lists;
    DelayedInsert = TRUE;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer Type"; Rec."Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Type field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Location Type"; Rec."Location Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                    ShowMandatory = TRUE;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    ShowMandatory = TRUE;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
            }
        }
    }
}
