page 14301935 "AQD Customer Rebate Subpage"
{
    Caption = 'Customer Rebate Documents Subpage';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AQD Customer Rebate Line";
    RefreshOnActivate = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';

                    trigger OnDrillDown()
                    var
                        RebatMgtEventsFunctions: Codeunit "AQD CustRbtMgt EventsFunctions";
                    begin
                        clear(RebatMgtEventsFunctions);
                        RebatMgtEventsFunctions.ShowPostedDocument(Rec."Document Type", Rec."Document No.");
                    end;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    Visible = false;
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Rebate Order Date"; Rec."Rebate Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Order Date field.', Comment = '%';
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field(Exclude; Rec."Do Not Credit")
                {
                    ApplicationArea = All;
                    Caption = 'Excluded';
                    ToolTip = 'Specifies the value of the Exclude field.', Comment = '%';
                }
                field("Rebate Amount Changed By"; Rec."Rebate Amount Changed By")
                {
                    ApplicationArea = All;
                    Caption = 'Changed By';
                    ToolTip = 'Specifies the value of the Rebate Amount Changed By field.', Comment = '%';
                }
                field("Rebate Amount Changed DateTime"; Rec."Rebate Amount Changed DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'Changed DateTime';
                    ToolTip = 'Specifies the value of the Rebate Amount Changed DateTime field.', Comment = '%';
                }
            }
        }
    }

    local procedure ShowVendorInvoiceCrMemoNo()
    var
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        VendorInvoiceCrMemoNo := FALSE;
        RebateSetup.GET;
        CASE RebateSetup."Calculate Cust Rebate using" of
            RebateSetup."Calculate Cust Rebate using"::"Posted Invoice and Cr Memo":
                VendorInvoiceCrMemoNo := TRUE;
            RebateSetup."Calculate Cust Rebate using"::"Posted Shipment and Return Receipt":
                VendorInvoiceCrMemoNo := FALSE;
        END;
    end;

    var
        VendorInvoiceCrMemoNo: Boolean;
}