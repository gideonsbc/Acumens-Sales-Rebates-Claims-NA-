namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301948 "AQD Cust Rbt Include Cust Loc"
{
    ApplicationArea = All;
    Caption = 'Include Customer Locations';
    PageType = List;
    SourceTable = "AQD Cust Rbt Include Cust Loc";
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