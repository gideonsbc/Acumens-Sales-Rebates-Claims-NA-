page 14301954 "AQD Customer Rebate Preview"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Preview';
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Header";
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }

                field("Rebate-To Customer No."; Rec."Rebate-To Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies the value of the Rebate-To Customer No. field.', Comment = '%';
                }
                field("Rebate-to Name"; Rec."Rebate-to Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("AQD Calculation Date"; Rec."AQD Calculation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Calculation Date';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Rebate Amount';
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.';
                }
                field("Vendor Commission"; Rec."Vendor Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of theVendor Commission Amount field.';
                }
                field("Employee Commission"; Rec."Employee Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Employee Commission field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field.', Comment = '%';
                }
            }
            part("AQD Customer Rebate Details"; "AQD Customer Rebate Details")
            {
                Caption = 'Document Lines';
                ApplicationArea = All;
                SubPageLink = "Rebate No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}