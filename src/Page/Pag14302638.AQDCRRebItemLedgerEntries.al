page 14302638 "AQD CR Reb Item Ledger Entries"
{
    ApplicationArea = All;
    Caption = 'Rebate Item Ledger Entries';
    DeleteAllowed = FALSE;
    InsertAllowed = false;
    Editable = FALSE;
    PageType = List;
    SourceTable = "AQD CR Reb Item Ledger Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ToolTip = 'Specifies the value of the Order Line No. field.', Comment = '%';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("AQD Customer Rebate Order Date"; Rec."AQD Customer Rebate Order Date")
                {
                    ToolTip = 'Specifies the value of the Customer Rebate Order Date field.', Comment = '%';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Specifies the value of the Document Line No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Invoiced Quantity"; Rec."Invoiced Quantity")
                {
                    ToolTip = 'Specifies the value of the Invoiced Quantity field.', Comment = '%';
                }
                field(Positive; Rec.Positive)
                {
                    ToolTip = 'Specifies the value of the Positive field.', Comment = '%';
                }
                field(Correction; Rec.Correction)
                {
                    ToolTip = 'Specifies the value of the Correction field.', Comment = '%';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Specifies the value of the Item Category Code field.', Comment = '%';
                }
                // field("Drop Shipment"; Rec."Drop Shipment")
                // {
                //     ToolTip = 'Specifies the value of the Drop Shipment field.', Comment = '%';
                // }
                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Actual) field.', Comment = '%';
                }
                field("Cost Amount (Expected)"; Rec."Cost Amount (Expected)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Expected) field.', Comment = '%';
                }
                field("Cost Amount (Non-Invtbl.)"; Rec."Cost Amount (Non-Invtbl.)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Non-Invtbl.) field.', Comment = '%';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.', Comment = '%';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Source Type field.', Comment = '%';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.', Comment = '%';
                }
                field("Customer Cr. Memo No."; Rec."Customer Cr. Memo No.")
                {
                    ToolTip = 'Specifies the value of the Customer Cr. Memo No. field.', Comment = '%';
                }
                // field("Customer Order No."; Rec."Customer Order No.")
                // {
                //     ToolTip = 'Specifies the value of the Customer Order No. field.', Comment = '%';
                // }
                field("Customer Invoice No."; Rec."Customer Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Customer Invoice No. field.', Comment = '%';
                }
                // field("AQD Rebate Type"; Rec."AQD Rebate Type")
                // {
                //     ToolTip = 'Specifies the value of the Rebate Type field.', Comment = '%';
                // }
                // field("Rebate Per Quantity"; Rec."Rebate Per Quantity")
                // {
                //     ToolTip = 'Specifies the value of the Rebate Per Unit field.', Comment = '%';
                // }
                // field("AQD Rebate %"; Rec."AQD Rebate %")
                // {
                //     ToolTip = 'Specifies the value of the Rebate % field.', Comment = '%';
                // }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Rebate Amount field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        PostedRebateDetails: Record "AQD Posted Cust Reb Details";
                        PostedRebateDetailsPage: Page "AQD Posted CustRbtDetail List";
                    begin
                        if Rec."Customer Invoice No." <> '' then
                            PostedRebateDetails.SetRange("Document No.", Rec."Customer Invoice No.");
                        if Rec."Customer Cr. Memo No." <> '' then
                            PostedRebateDetails.SetRange("Document No.", Rec."Customer Cr. Memo No.");
                        PostedRebateDetails.SetRange("No.", Rec."Item No.");
                        PostedRebateDetails.SetRange("Document Line No.", Rec."Document Line No.");

                        PostedRebateDetailsPage.SetTableView(PostedRebateDetails);
                        PostedRebateDetailsPage.RunModal();
                    end;
                }
                field("Rebate Amount 2"; Rec."Rebate Amount 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Not in use';
                }
                field("AQD Rebate No"; Rec."AQD Rebate No")
                {
                    ToolTip = 'Specifies the value of the Rebate No. field.', Comment = '%';

                    trigger OnDrillDown()
                    var
                        PostedCustomerRebateHeader: Record "AQD Posted Cust Rebate Header";
                        CustomerRebateHeader: Record "AQD Customer Rebate Header";
                    begin
                        IF CustomerRebateHeader.GET(Rec."AQD Rebate No") THEN
                            PAGE.RUN(PAGE::"AQD Customer Rebate Document", CustomerRebateHeader)
                        ELSE IF PostedCustomerRebateHeader.GET(Rec."AQD Rebate No") THEN
                            PAGE.RUN(PAGE::"AQD Posted Customer Rebate Doc", PostedCustomerRebateHeader);
                    end;
                }
                // field("AQD Rebate Line No"; Rec."AQD Rebate Line No")
                // {
                //     ToolTip = 'Specifies the value of the Rebate Line No. field.', Comment = '%';
                // }
                // field("AQD Rebate Detail Line No."; Rec."AQD Rebate Detail Line No.")
                // {
                //     ToolTip = 'Specifies the value of the Rebate Detail Line No. field.', Comment = '%';
                // }
                field("AQD Rebate Status"; Rec."AQD Rebate Status")
                {
                    ToolTip = 'Specifies the value of the Rebate Status field.', Comment = '%';
                }
                // field("AQD Rebate Customer No"; Rec."AQD Rebate Customer No")
                // {
                //     ToolTip = 'Specifies the value of the Rebate Customer No. field.', Comment = '%';
                // }
                field("Document Posting Description"; Rec."Document Posting Description")
                {
                    ToolTip = 'Specifies the value of the Document Posting Description field.', Comment = '%';
                }
                field("AQD Sell-to Customer No."; Rec."AQD Sell-to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.', Comment = '%';
                }
                // field("AQD Pay-to Name"; Rec."AQD Pay-to Name")
                // {
                //     ToolTip = 'Specifies the value of the Pay-to Name field.', Comment = '%';
                // }
                // field("AQD Do Not Pay Rebate"; Rec."AQD Do Not Pay Rebate")
                // {
                //     ToolTip = 'Specifies the value of the Do Not Pay Rebate field.', Comment = '%';
                // }
                field("AQD Bill-to Customer No."; Rec."AQD Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field.', Comment = '%';
                }
                field("AQD Bill-to Customer Name"; Rec."AQD Bill-to Customer Name")
                {
                    ToolTip = 'Specifies the value of the Bill-to Customer Name field.', Comment = '%';
                }
                field("AQD Rebate Entry Created"; Rec."AQD Rebate Entry Created")
                {
                    ToolTip = 'Specifies the value of the Rebate Entry Created field.', Comment = '%';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.', Comment = '%';
                }
                field("AQD Rebate Last Changed By"; Rec."AQD Rebate Last Changed By")
                {
                    ToolTip = 'Specifies the value of the Last Changed By field.', Comment = '%';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                }
                field("Order Type"; Rec."Order Type")
                {
                    Visible = false;
                }
            }
        }
    }
}
