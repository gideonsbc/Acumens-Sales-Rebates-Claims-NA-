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
