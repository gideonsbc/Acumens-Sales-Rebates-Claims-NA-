page 14301937 "AQD Posted Customer Rebates"
{
    Caption = 'Posted Customer Rebate Documents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    SourceTable = "AQD Posted Cust Rebate Header";
    CardPageId = "AQD Posted Customer Rebates";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Buy-from Vendor No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor No. field.', Comment = '%';
                }
                field("Buy-from Vendor Name"; Rec."Sell-To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor Name field.', Comment = '%';
                }
                field("Pay-to Vendor No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pay-to Vendor No. field.', Comment = '%';
                }
                field("Pay-to Name"; Rec."Bill-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Description field.', Comment = '%';
                }
                field("Rebate Status"; Rec."Customer Rebate Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.', Comment = '%';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field.', Comment = '%';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            // Not Required For Now. Not Delete
            // action("Create Purchase Journal")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Create Purchase Journal';
            //     Image = CreateDocument;

            //     trigger OnAction()
            //     var
            //         VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
            //     begin
            //         clear(VendorRebatePost);
            //         VendorRebatePost.CreateVendorRebatePurchJournal(Rec);
            //         CurrPage.UPDATE(false);
            //     end;
            // }
            action("Create Purchase Document")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Document';
                Image = CreateDocument;

                trigger OnAction()
                var
                    CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
                begin
                    //clear(VendorRebatePost);
                    //VendorRebatePost.CreatePurchaseDocument(Rec, TRUE);
                    //CurrPage.UPDATE(false);
                end;
            }
            action("Vendor Rebate Details")
            {
                ApplicationArea = All;
                Caption = 'Vendor Rebate Details';
                Image = Report;
                trigger OnAction()
                var
                //VendorRebateDetails: Report "AQD Customer Rebate Details";
                begin
                    //Clear(VendorRebateDetails);
                    Rec.SetRange("No.", Rec."No.");
                    //VendorRebateDetails.SetTableView(Rec);
                    //VendorRebateDetails.Run();
                end;
            }
        }
        area(Navigation)
        {
            // action("AQD Rebate Purchase Journal")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Rebate Purchase Journal';
            //     Image = OpenJournal;
            //     RunObject = Page "AQD Rebate Purch. Journal";
            //     ToolTip = 'Open the Rebate Purchase Journal.';
            // }
            action("Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Purchase Invoices';
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Purchase Invoices.';
            }
            action("Purchase Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Purchase Credit Memos';
                Image = PurchaseCreditMemo;
                RunObject = Page "Purchase Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Purchase Credit Memos.';
            }
            action("Posted Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Posted Purchase Invoices';
                Image = PostDocument;
                RunObject = Page "Posted Purchase Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Purchase Invoices.';
            }
            action("Posted Purchase Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Posted Purchase Credit Memos';
                Image = PostedCreditMemo;
                RunObject = Page "Posted Purchase Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Purchase Credit Memos.';
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Rebates';
                // actionref(CreatePurchaseJournal_Promoted; "Create Purchase Journal")
                // {
                // }
                actionref(CreatePurchaseDocument_Promoted; "Create Purchase Document")
                {
                }
                actionref(Vendor_Rebate_Details_Promoted; "Vendor Rebate Details")
                {
                }
                // actionref(RebatePurchaseJournal_Promoted; "AQD Rebate Purchase Journal")
                // {
                // }
                actionref(PurchaseInvoices_Promoted; "Purchase Invoices")
                {
                }
                actionref(PurchaseCreditMemos_Promoted; "Purchase Credit Memos")
                {
                }
                actionref(PostedPurchaseInvoices_Promoted; "Posted Purchase Invoices")
                {
                }
                actionref(PostedPurchaseCreditMemos_Promoted; "Posted Purchase Credit Memos")
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CustomerRebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if CustomerRebateUserSetup."Rebate Role" = CustomerRebateUserSetup."Rebate Role"::Salesperson then
            CustomerRebateUserSetup.TestField("Salesperson Code Filter");
        if CustomerRebateUserSetup."Salesperson Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code", CustomerRebateUserSetup."Salesperson Code Filter");
        if CustomerRebateUserSetup."Global Dimension 1 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", CustomerRebateUserSetup."Global Dimension 1 Filter");
        if CustomerRebateUserSetup."Global Dimension 2 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", CustomerRebateUserSetup."Global Dimension 2 Filter");
        if CustomerRebateUserSetup."Location Filter" <> '' then
            Rec.SetFilter("Location Code", CustomerRebateUserSetup."Location Filter");
        if CustomerRebateUserSetup."State Filter" <> '' then
            Rec.SetFilter(State, CustomerRebateUserSetup."State Filter");
        Rec.FilterGroup(0);
    end;

    var
        CustomerRebateUserSetup: Record "AQD Customer Rebate User Setup";
}