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
    CardPageId = "AQD Posted Customer Rebate Doc";

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
                field("Rebate-To Customer No."; Rec."Rebate-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate-To Customer No. field.', Comment = '%';
                }
                field("Rebate-To Customer Name"; Rec."Rebate-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate-To Customer Name field.', Comment = '%';
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
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Create Sales Document")
            {
                ApplicationArea = All;
                Caption = 'Create Sales Document';
                Image = CreateDocument;

                trigger OnAction()
                var
                    CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
                begin
                    clear(CustomerRebatePost);
                    CustomerRebatePost.CreateSalesFromPostedRebateDocument(Rec, TRUE);
                    CurrPage.UPDATE(false);
                end;
            }
            action("Customer Rebate Details")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Details';
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
            action("Sales Invoices")
            {
                ApplicationArea = All;
                Caption = 'Sales Invoices';
                Image = SalesInvoice;
                RunObject = Page "Sales Invoice List";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Sales Invoices.';
            }
            action("Sales Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Sales Credit Memos';
                Image = PurchaseCreditMemo;
                RunObject = Page "Sales Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Sales Credit Memos.';
            }
            action("Posted Sales Invoices")
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Invoices';
                Image = PostDocument;
                RunObject = Page "Posted Sales Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Sales Invoices.';
            }
            action("Posted Sales Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Credit Memos';
                Image = PostedCreditMemo;
                RunObject = Page "Posted Sales Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Sales Credit Memos.';
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Rebates';
                actionref(CreateSalesDocument_Promoted; "Create Sales Document")
                {
                }
                actionref(Customer_Rebate_Details_Promoted; "Customer Rebate Details")
                {
                }
                actionref(SalesInvoices_Promoted; "Sales Invoices")
                {
                }
                actionref(SalesCreditMemos_Promoted; "Sales Credit Memos")
                {
                }
                actionref(PostedSalesInvoices_Promoted; "Posted Sales Invoices")
                {
                }
                actionref(PostedSalesCreditMemos_Promoted; "Posted Sales Credit Memos")
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CustomerRebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if CustomerRebateUserSetup."AQD Cust Rbt Rebate Role" = CustomerRebateUserSetup."AQD Cust Rbt Rebate Role"::Salesperson then
            CustomerRebateUserSetup.TestField("AQD Cust Rbt SP Code Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt SP Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code", CustomerRebateUserSetup."AQD Cust Rbt SP Code Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt GlobalDim1Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", CustomerRebateUserSetup."AQD Cust Rbt GlobalDim1Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt GlobalDim2Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", CustomerRebateUserSetup."AQD Cust Rbt GlobalDim2Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt Location Filter" <> '' then
            Rec.SetFilter("Location Code", CustomerRebateUserSetup."AQD Cust Rbt Location Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt State Filter" <> '' then
            Rec.SetFilter(State, CustomerRebateUserSetup."AQD Cust Rbt State Filter");
        Rec.FilterGroup(0);
    end;

    var
        CustomerRebateUserSetup: Record "User Setup";
}