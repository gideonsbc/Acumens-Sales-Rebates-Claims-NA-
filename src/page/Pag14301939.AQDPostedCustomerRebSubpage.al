page 14301939 "AQD Posted Cust Reb Subpage"
{
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Subpage';
    Editable = false;
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
                    //VendorRebatFunEvents: Codeunit "AQD Vendor RebateMgtEventsFuns";
                    begin
                        //clear(VendorRebatFunEvents);
                        //VendorRebatFunEvents.ShowPostedDocument(Rec."Document Type", Rec."Document No.");
                    end;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
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
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Invoice No. field.', Comment = '%';
                    Visible = VendorInvoiceCrMemoNo;
                }
                field("Vendor Cr. Memo No."; Rec."Vendor Cr. Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Cr. Memo No. field.', Comment = '%';
                    Visible = VendorInvoiceCrMemoNo;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount';
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
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field(Exclude; Rec.Exclude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exclude field.', Comment = '%';
                }
                field("Rebate Status"; Rec."Rebate Status")
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
                    Caption = 'Customer Rebate Amt(Item Charge)';
                    Editable = false;
                    Visible = false;
                }
                field("Customer Rebate Amt (GL)"; Rec."Customer Rebate Amt (GL)")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Amt (GL)';
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