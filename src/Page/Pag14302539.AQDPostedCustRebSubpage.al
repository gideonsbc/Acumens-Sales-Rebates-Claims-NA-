page 14302539 "AQD Posted Cust Reb Subpage"
{
    ApplicationArea = All;
    Caption = 'Posted Sales Rebate Subpage';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "AQD Posted Cust Rebate Line";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                    Visible = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';

                    trigger OnDrillDown()
                    var
                        RebateMgtEventsFunctions: Codeunit "AQD CustRbtMgt EventsFunctions";
                    begin
                        clear(RebateMgtEventsFunctions);
                        RebateMgtEventsFunctions.ShowPostedDocument(Rec."Document Type", Rec."Document No.");
                    end;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill-To Customer Name"; Rec."Bill-To Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    Visible = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                    Visible = false;
                }
                field("Rebate Order Date"; Rec."Rebate Order Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Rebate Order Date field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Customer Invoice No."; Rec."Customer Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Invoice No. field.', Comment = '%';
                }
                field("Customer Cr. Memo No."; Rec."Customer Cr. Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Cr. Memo No. field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("Vendor Commission"; Rec."Vendor Commission")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Commission field.', Comment = '%';
                }
                field("Employee Commission"; Rec."Employee Commission")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Employee Commission field.', Comment = '%';
                }
                field("Off-Invoice Rebate"; Rec."Off-Invoice Rebate")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Ineligible; Rec.Ineligible)
                {
                    ApplicationArea = All;
                    Caption = 'Ineligible';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ineligible field.', Comment = '%';
                }
                field(Exclude; Rec."Do Not Credit")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Exclude field.', Comment = '%';
                }
                field("Rebate Status"; Rec."Customer Rebate Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rebate Amount Changed By"; Rec."Rebate Amount Changed By")
                {
                    ApplicationArea = All;
                    Caption = 'Changed By:';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Rebate Amount Changed By field.', Comment = '%';
                }
                field("Cust Rebate Amt(Item Charge)"; Rec."Cust Rebate Amt(Item Charge)")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebate Amt(Item Charge)';
                    Editable = false;
                    Visible = false;
                }
                field("Customer Rebate Amt (GL)"; Rec."Customer Rebate Amt (GL)")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebate Amt (GL)';
                    Editable = false;
                    Visible = false;
                }
                field("Rebate Amount Changed DateTime"; Rec."Rebate Amount Changed DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'Changed DateTime:';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Rebate Amount Changed DateTime field.', Comment = '%';
                }
            }
        }
    }
}