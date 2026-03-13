page 14302611 "AQD Customer Claim Vendors"
{
    ApplicationArea = All;
    Caption = 'Claim Vendors';
    DelayedInsert = true;
    Editable = TRUE;
    PageType = List;
    SourceTable = "AQD Customer Claim Vendors";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;

                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field.', Comment = '%';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name field.', Comment = '%';
                }
                field("Bill-to Name 2"; Rec."Bill-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name 2 field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Address field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Address 2 field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to City"; Rec."Bill-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to City field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Country/Region Code field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to County"; Rec."Bill-to County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to County field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Name field.', Comment = '%';
                }
                field("Vendor Name 2"; Rec."Vendor Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Name 2 field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor Address"; Rec."Vendor Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Address field.', Comment = '%';
                }
                field("Vendor Address 2"; Rec."Vendor Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Address 2 field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor City"; Rec."Vendor City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor City field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor Country/Region Code"; Rec."Vendor Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Country/Region Code field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor County"; Rec."Vendor County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor County field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Vendor Post Code"; Rec."Vendor Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Post Code field.', Comment = '%';
                    Visible = FALSE;
                }
                field("AQM Claim Type"; Rec."Claim Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the AQM Claim Type field.', Comment = '%';
                }
            }
        }
    }
}