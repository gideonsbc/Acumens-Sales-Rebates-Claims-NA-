page 14302631 "AQD Claim Service Codes"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    ApplicationArea = All;
    DataCaptionFields = "Service Code", Description;
    Editable = true;
    PageType = List;
    SourceTable = "AQD Claim Service Codes";
    UsageCategory = None;
    Caption = 'Claim Service Codes';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Service Code"; Rec."Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("ERS Indicator"; Rec."ERS Indicator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ERS Indicator field.';
                }
                field("Dealer Location Indicator"; Rec."Dealer Location Indicator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dealer Location Indicator field.';
                }
                field("Fleet Location Indicator"; Rec."Fleet Location Indicator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fleet Location Indicator field.';
                }
                field("Time Required"; Rec."Time Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Required field.';
                }
            }
        }
    }
}