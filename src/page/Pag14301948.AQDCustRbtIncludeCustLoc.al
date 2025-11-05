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
                field("Ship-To Code"; Rec."Ship-To Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."Location Type" = Rec."Location Type"::"Ship-To Address";
                    Enabled = Rec."Location Type" = Rec."Location Type"::"Ship-To Address";
                    ToolTip = 'Specifies the value of the ShiP-To Code field.', Comment = '%';
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
