page 14277042 "AQD Rebate Program Codes"
{
    ApplicationArea = All;
    Caption = 'Rebate Program Codes';
    PageType = List;
    SourceTable = "AQD Rebate Program Code";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Rebate Program Code to attach to the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of what the code stands for.';
                }
                field("Rebate Posting Type"; Rec."Rebate Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Rebate Posting Type.';
                }
                field("Vendor Default Rebate Type"; Rec."Vendor Default Rebate Type")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Type';
                }
                field("Vendor Default Rebate %"; Rec."Vendor Default Rebate %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Default Rebate %';
                    Editable = Rec."Vendor Default Rebate Type" = Rec."Vendor Default Rebate Type"::Percentage;
                    Enabled = Rec."Vendor Default Rebate Type" = Rec."Vendor Default Rebate Type"::Percentage;
                }
                field("Vendor Def Rebate Per Quantity"; Rec."Vendor Def Rebate Per Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Per Quantity';
                    Editable = Rec."Vendor Default Rebate Type" = Rec."Vendor Default Rebate Type"::"Per Quantity";
                    Enabled = Rec."Vendor Default Rebate Type" = Rec."Vendor Default Rebate Type"::"Per Quantity";
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    actions
    {
    }
}