page 14302515 "AQD Cust Rebate Program Codes"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Program Codes';
    PageType = List;
    SourceTable = "AQD Cust Rebate Program Code";
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
                // field("Customer Rebate Posting Type"; Rec."Customer Rebate Posting Type")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies a Customer Rebate Posting Type.';
                // }
                field("Customer Default Rebate Type"; Rec."Customer Default Rebate Type")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Type';
                }
                field("Cust Default Rebate %"; Rec."Customer Default Rebate %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Default Rebate %';
                    Editable = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::Percentage;
                    Enabled = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::Percentage;
                }
                field("Cust Def Rebate Per Unit"; Rec."Customer Def Rebate Per Unit")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Per Unit';
                    Editable = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::"Per Quantity";
                    Enabled = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::"Per Quantity";
                }
                field("Rebate Expense Type"; Rec."Rebate Expense Type")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Expense Type';
                }
                field("Rebate Expense AC"; Rec."Rebate Expense AC")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Expense A/C';
                    Editable = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    Enabled = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    ShowMandatory = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                }
                field("Rebate Payable AC"; Rec."Rebate Payable AC")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Payable A/C';
                    // Editable = ControlEditable;
                    // Enabled = ControlEditable;
                    // ShowMandatory = ControlEditable;
                    // Visible = ControlVisible;
                    //Editable = ControlEditable;
                    //Enabled = ControlEditable;
                    //ShowMandatory = ControlEditable;
                    //Visible = ControlVisible;
                    Editable = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    Enabled = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    ShowMandatory = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Used Customer Vendor Employee No.';
                    ObsoleteTag = 'Discontinued 25.1023.0.2';
                    Visible = false;
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    Caption = 'Entity Type';
                }
                field("Entity No."; Rec."Entity No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entity No.';
                }
                field("Specific Sales"; Rec."Specific Sales")
                {
                    ApplicationArea = All;
                    Caption = 'Specific Sales';
                    Visible = false;
                    ObsoleteState = Pending;
                }
                field("Specific Sales New"; Rec."Specific Sales New")
                {
                    ApplicationArea = All;
                    Caption = 'Specific Sales';
                }
                field("Marketplace Code"; Rec."Marketplace Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Marketplace Code field.', Comment = '%';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
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

    trigger OnOpenPage()
    BEGIN
        IF NOT CustomerRebateSetup.GET THEN
            CustomerRebateSetup.Init();

        ControlEditable := Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
        ControlVisible := CustomerRebateSetup."Rebate Payable Ac" = CustomerRebateSetup."Rebate Payable Ac"::"Rebate Payable AC";
    END;

    VAR
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        ControlEditable: Boolean;
        ControlVisible: Boolean;
}