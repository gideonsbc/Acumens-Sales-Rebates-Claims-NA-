page 14277008 "AQD Rebate Role Center"
{
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Rebate Role Center', Comment = '{Dependency=Match,"ProfileDescription_ORDERPROCESSOR"}';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part("AQD Rebate Cues"; "AQD Rebate Cues")
            {
                Caption = 'Rebate Activities';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Reporting)
        {
        }
        area(Embedding)
        {
            action(Items)
            {
                Caption = 'Items';
                ApplicationArea = All;
                Image = Item;
                RunObject = Page "Item List";
            }
            action("G/L Accounts")
            {
                Caption = 'G/L Accounts';
                ApplicationArea = All;
                Image = GL;
                RunObject = Page "G/L Account List";
            }
            action(Resources)
            {
                Caption = 'Resources';
                ApplicationArea = All;
                Image = Resource;
                RunObject = Page "Resource List";
            }
            action("Item Charges")
            {
                Caption = 'Item Charges';
                ApplicationArea = All;
                Image = ItemCosts;
                RunObject = Page "Item Charges";
            }
            action("Fixed Assets")
            {
                Caption = 'Fixed Assets';
                ApplicationArea = All;
                Image = FixedAssets;
                RunObject = Page "Fixed Asset List";
            }
            action(Vendors)
            {
                Caption = 'Vendors';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "Vendor List";
            }
            action(Customers)
            {
                Caption = 'Customers';
                ApplicationArea = All;
                Image = Customer;
                RunObject = Page "Customer List";
            }
            action("Sales Orders")
            {
                Caption = 'Sales Orders';
                ApplicationArea = All;
                Image = SalesInvoice;
                RunObject = Page "Sales Order List";
            }
            action("Sales Return Orders")
            {
                Caption = 'Sales Return Orders';
                ApplicationArea = All;
                Image = SalesCreditMemo;
                RunObject = Page "Sales Return Order List";
            }
            action("AQD Rebate Customer Types")
            {
                Caption = 'Rebate Customer Types';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Customer Types";
            }
            action("AQD Rebate Cust Type Eligib")
            {
                Caption = 'Rebate Customer Type Eligibility';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Cust Type Eligib";
            }
            action("AQD CustItem Rebate Eligib")
            {
                Caption = 'Customer Item Rebate Eligibility';
                ApplicationArea = All;
                Image = PurchaseCreditMemo;
                RunObject = Page "AQD CustItem Rebate Eligib";
            }
            action("Rebate Document Entries")
            {
                Caption = 'Rebate Document Entries';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Document Entry";
            }
            action("Rebate Entries")
            {
                Caption = 'Rebate Entries';
                ApplicationArea = All;
                Image = SelectEntries;
                RunObject = Page "AQD Rebate Entries";
            }
            action("Rebate Register")
            {
                Caption = 'Rebate Register';
                ApplicationArea = All;
                Image = Register;
                RunObject = Page "AQD Rebate Register";
            }
            action("AQD Item Rebate Categories")
            {
                Caption = 'Item Rebate Categories';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "AQD Rebate Item Categories";
            }
            action("Rebate Program Codes")
            {
                ApplicationArea = All;
                Caption = 'Rebate Program Codes';
                RunObject = page "AQD Rebate Program Codes";
            }
            action("AQD Rebate Vendor Types")
            {
                Caption = 'Rebate Vendor Types';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Vendor Types";
            }
            action("AQD Rebate Vendor Type Eligibility")
            {
                Caption = 'Rebate Vendor Type Eligibility';
                ApplicationArea = All;
                Image = PurchaseCreditMemo;
                RunObject = Page "AQD Rebate Vendor Type Eligib";
            }
            action("AQD VendItem Rebate Eligib")
            {
                Caption = 'Vendor Item Rebate Eligibility';
                ApplicationArea = All;
                Image = PurchaseCreditMemo;
                RunObject = Page "AQD VendItem Rebate Eligib";
            }
            action("Purchase Orders")
            {
                Caption = 'Purchase Orders';
                ApplicationArea = All;
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Order List";
            }
            action("Purchase Invoices")
            {
                Caption = 'Purchase Invoices';
                ApplicationArea = All;
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Invoices";
            }
            action("Purhchase Return Orders")
            {
                Caption = 'Purhchase Return Orders';
                ApplicationArea = All;
                Image = PurchaseCreditMemo;
                RunObject = Page "Purchase Return Order List";
            }
            action("Purchase Credit Memos")
            {
                Caption = 'Purchase Credit Memos';
                ApplicationArea = All;
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Credit Memos";
            }
            action("Vendor Rebate Batches")
            {
                ApplicationArea = All;
                Caption = 'Vendor Rebate Batches';
                RunObject = page "AQD Vendor Rebate Batches";
            }
            action("Vendor Rebates")
            {
                ApplicationArea = All;
                Caption = 'Vendor Rebates';
                RunObject = page "AQD Vendor Rebates";
            }
            action("Posted Vendor Rebate Batches")
            {
                ApplicationArea = All;
                Caption = 'Posted Vendor Rebate Batches';
                RunObject = page "AQD PostedVendorRebate Batches";
            }
            action("Posted Vendor Rebates")
            {
                ApplicationArea = All;
                Caption = 'Posted Vendor Rebates';
                RunObject = page "AQD Posted Vendor Rebates";
            }
        }
        area(sections)
        {
            group(PostedDocuments)
            {
                Caption = 'Posted Documents';
                action("Posted Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action("Posted Purchase Receipts")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Open the list of posted purchase Receipts.';
                }
                action("Posted Purchase Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase invoices.';
                }
                action("Posted Purchase Return Shipments")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ToolTip = 'Open the list of posted purchase Return Shipments.';
                }
                action("Posted Purchase Credit Memos")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
            }
            group("Customer Rebate")
            {
                Caption = 'Customer Rebate';
                action(GenerateRebateLines)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Customer Rebates';
                    Image = CalculateSalesTax;
                    RunObject = Report "AQD Generate Rebate Lines";
                }
                action(RebateDocumentEntries)
                {
                    Caption = 'Rebate Document Entries';
                    ApplicationArea = All;
                    Image = CampaignEntries;
                    RunObject = Page "AQD Rebate Document Entry";
                }
                action(RebateEntries)
                {
                    Caption = 'Rebate Entries';
                    ApplicationArea = All;
                    Image = SelectEntries;
                    RunObject = Page "AQD Rebate Entries";
                }
                action(RebateJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Journal';
                    Image = ConsumptionJournal;
                    RunObject = Page "AQD Rebate Journal";
                }
                action(RebatePurchaseJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Purchase Journal';
                    Image = Purchase;
                    RunObject = Page "AQD Rebate Purch. Journal";
                }
                action(RebatePaymentJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Payment Journal';
                    Image = PaymentJournal;
                    RunObject = Page "AQD Rebate Payment Journal";
                }
                action(RebateSalesJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Sales Journal';
                    Image = Sales;
                    RunObject = Page "AQD Rebate Sales Journal";
                }
                action(RebateRegister)
                {
                    Caption = 'Rebate Register';
                    ApplicationArea = All;
                    Image = Register;
                    RunObject = Page "AQD Rebate Register";
                }
            }
            group("Vendor Rebate")
            {
                Caption = 'Vendor Rebate';
                action("AQD Item Rebate Categories2")
                {
                    Caption = 'Item Rebate Categories';
                    ApplicationArea = All;
                    Image = Vendor;
                    RunObject = Page "AQD Rebate Item Categories";
                }
                action("Item Rebate Program Codes2")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Program Codes';
                    RunObject = page "AQD Rebate Program Codes";
                }
                action("AQD Rebate Item Ledger Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Item Ledger Entries';
                    RunObject = page "AQD Rebate Item Ledger Entries";
                }
                action(GenerateVendorRebates)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Vendor Rebates';
                    Image = Reconcile;
                    RunObject = Report "AQD Generate Vendor Rebs";
                }
                action(VendorRebates)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Rebates';
                    RunObject = page "AQD Vendor Rebates";
                }
                action(VendorRebateDetails)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Rebate Details';
                    RunObject = page "AQD Vendor Rebate Details";
                    Visible = false;
                }
                action("Vendor Rebate Comments")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Rebate Comments';
                    RunObject = page "AQD Vendor Rebate Comments";
                    Visible = false;
                }
                action(PostedVendorRebates)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Vendor Rebates';
                    RunObject = page "AQD Posted Vendor Rebates";
                }
                action(PostedVendorRebateDetails)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Vendor Rebate Details';
                    RunObject = page "AQD Posted Vend Rebate Details";
                    Visible = false;
                }
                action("Posted Vendor Rebate Comments")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Vendor Rebate Comments';
                    RunObject = page "AQD Posted Ven Reb Comment";
                    Visible = false;
                }
            }
        }
        area(Creation)
        {
            action("Generate Rebate Lines")
            {
                ApplicationArea = All;
                Caption = 'Generate Customer Rebates';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Generate Rebate Lines";
            }
            action("Generate Vendor Rebates")
            {
                ApplicationArea = All;
                Caption = 'Generate Vendor Rebates';
                Image = Reconcile;
                RunObject = Report "AQD Generate Vendor Rebs";
            }
            group(Journals)
            {
                action("Rebate Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Journal';
                    Image = ConsumptionJournal;
                    RunObject = Page "AQD Rebate Journal";
                }
                action("Rebate Purchase Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Purchase Journal';
                    Image = Purchase;
                    RunObject = Page "AQD Rebate Purch. Journal";
                }
                action("Rebate Payment Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Payment Journal';
                    Image = PaymentJournal;
                    RunObject = Page "AQD Rebate Payment Journal";
                }
                action("Rebate Sales Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Sales Journal';
                    Image = Sales;
                    RunObject = Page "AQD Rebate Sales Journal";
                }
            }
            group(Reports)
            {
                Image = Report;
                action("AQD Vendor Rebate Forecast")
                {
                    Caption = 'Vendor Rebate Forecast';
                    ApplicationArea = All;
                    Image = Report2;
                    RunObject = Report "AQD Vendor Rebate Forecast";
                }
                action("AQD Inventory - Customer Sales")
                {
                    Caption = 'Rebate Inventory Customer Sales';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD Inventory - Customer Sales";
                }
                action("Inventory Valuation")
                {
                    Caption = 'Inventory Valuation';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "Inventory Valuation";
                }
                action("AQD Update Rebate Vendor Type")
                {
                    Caption = 'Update Rebate Vendor Type';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD Udt Rebate Vendor Type";
                }
                action("AQD Udt Rebate Customer Type")
                {
                    Caption = 'Update Rebate Customer Type';
                    ApplicationArea = All;
                    Image = CustomerGroup;
                    RunObject = Report "AQD Udt Rebate Vendor Type";
                }
            }
        }
        area(Processing)
        {
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                action("Acumens Rebate Setup")
                {
                    Caption = 'Acumens Claims & Rebates Setup';
                    ApplicationArea = All;
                    Image = CostAccountingSetup;
                    RunObject = Page "AQD Acumens Rebate Setup";
                }
                action("Rebate User Setup")
                {
                    Caption = 'Rebate User Setup';
                    ApplicationArea = All;
                    Image = UserSetup;
                    RunObject = Page "AQD Rebate User Setup";
                }
                action("Rebate Week Periods")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Week Periods';
                    Image = PeriodEntries;
                    RunObject = Page "AQD Rebate Week Periods";
                }
                action("Rebate Month Periods")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Month Periods';
                    Image = PeriodEntries;
                    RunObject = Page "AQD Rebate Month Period";
                }
                action("Sales Rebates Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebates Setup';
                    Image = Setup;
                    RunObject = Page "AQD Sales Rebates Setup";
                }
                action("Purchase Rebate Rates")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Rebate Rates';
                    Image = Setup;
                    RunObject = Page "AQD Vendor Rebate Rates";
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Archived RebateRegister")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Register';
                    Image = Register;
                    RunObject = Page "AQD Rebate Register";
                }
                action(PostedVendorRebatesHistory)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Vendor Rebates';
                    RunObject = page "AQD Posted Vendor Rebates";
                }
            }
        }
    }
}

