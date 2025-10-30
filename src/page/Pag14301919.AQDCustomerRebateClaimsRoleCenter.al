page 14301919 "AQD Cust Rebate & Claims RC"
{
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Customer Rebate & Claims Role Center', Comment = '';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part("AQD Customer Rebate Cues"; "AQD Customer Rebate Cues")
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
            action("Sales Invoices")
            {
                Caption = 'Sales Invoices';
                ApplicationArea = All;
                Image = SalesInvoice;
                RunObject = Page "Sales Invoice List";
            }
            action("Sales Return Orders")
            {
                Caption = 'Sales Return Orders';
                ApplicationArea = All;
                Image = SalesCreditMemo;
                RunObject = Page "Sales Return Order List";
            }
            action("Sales Credit Memos")
            {
                Caption = 'Sales Credit Memos';
                ApplicationArea = All;
                Image = SalesCreditMemo;
                RunObject = Page "Sales Credit Memos";
            }

            action("AQD Rebate Customer Types")
            {
                Caption = 'Rebate Customer Types';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Customer Types";
            }
            // action("AQD Rebate Cust Type Eligib")
            // {
            //     Caption = 'Rebate Customer Type Eligibility';
            //     ApplicationArea = All;
            //     Image = CampaignEntries;
            //     RunObject = Page "AQD Rebate Cust Type Eligib";
            // }
            action("AQD CustItem Rebate Matrix")
            {
                Caption = 'Customer Item Rebate Matrix';
                ApplicationArea = All;
                Image = PurchaseCreditMemo;
                RunObject = Page "AQD Rebate Customer Types";
            }
            action("Rebate Document Entries")
            {
                Caption = 'Customer Rebate Document Entries';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Cust Rebate Doc Entries";
            }
            action("Customer Rebate Register")
            {
                Caption = 'Customer Rebate Register';
                ApplicationArea = All;
                Image = Register;
                RunObject = Page "AQD Customer Rebate Register";
            }
            action("AQD Customer Rebate Item Categories")
            {
                Caption = 'Customer Item Rebate Categories';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "AQD Cust RebateItem Categories";
            }
            action("Customer Rebate Program Codes")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Program Codes';
                RunObject = page "AQD Cust Rebate Program Codes";
            }

            action("Customer Rebate Batches")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Batches';
                RunObject = page "AQD Customer Rebate Batches";
            }
            // action("Customer Rebates")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Customer Rebates';
            //     RunObject = page "AQD Customer Rebates";
            // }
        }
        area(sections)
        {
            group(PostedDocuments)
            {
                Caption = 'Posted Documents';
                action("Posted Sales Shipments")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Shipments';
                    Image = SalesShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'Open the list of posted sales Shipments.';
                }
                action("Posted Sales Invoices")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Return Receipts")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Return Receipts';
                    Image = PostedOrder;
                    RunObject = Page "Posted Return Receipts";
                    ToolTip = 'Open the list of posted Sales Return Receipts.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
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
                    RunObject = Report "AQD Generate Customer Rebates";
                }
                action(RebateDocumentEntries)
                {
                    Caption = 'Customer Rebate Document Entries';
                    ApplicationArea = All;
                    Image = CampaignEntries;
                    RunObject = Page "AQD Cust Rebate Doc Entries";
                }
                action(RebateEntries)
                {
                    Caption = 'Customer Rebate Entries';
                    ApplicationArea = All;
                    Image = SelectEntries;
                    RunObject = Page "AQD Customer Rebate Entries";
                }
                action(RebateJournal)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Journal';
                    Image = ConsumptionJournal;
                    RunObject = Page "AQD Customer Rebate Journal";
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
                action(CustomerRebateRegister)
                {
                    Caption = 'Customer Rebate Register';
                    ApplicationArea = All;
                    Image = Register;
                    RunObject = Page "AQD Customer Rebate Register";
                }
            }
        }
        area(Creation)
        {
            action("Generate Customer Rebate")
            {
                ApplicationArea = All;
                Caption = 'Generate Customer Rebates';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Generate Customer Rebates";
            }
            group(Journals)
            {
                action("Customer Rebate Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Journal';
                    Image = ConsumptionJournal;
                    RunObject = Page "AQD Customer Rebate Journal";
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
                // action("AQD Udt Rebate Customer Type")
                // {
                //     Caption = 'Update Rebate Customer Type';
                //     ApplicationArea = All;
                //     Image = CustomerGroup;
                //     RunObject = Report "AQD Udt Rebate Customer Type";
                // }
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
                    RunObject = Page "AQD Acumens CustRbtClaim Setup";
                }
                action("Rebate User Setup")
                {
                    Caption = 'Customer Rebate User Setup';
                    ApplicationArea = All;
                    Image = UserSetup;
                    RunObject = Page "AQD Customer Rebate User Setup";
                }
                action("Sales Rebates Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebates Setup';
                    Image = Setup;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Archived RebateRegister")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Register';
                    Image = Register;
                    RunObject = Page "AQD Customer Rebate Register";
                }
                action("Posted Customer Rebate Batches")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Customer Rebate Batches';
                    RunObject = page "AQD Posted Cust Rebate Batches";
                }
                // action("Posted Customer Rebates")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Posted Customer Rebates';
                //     RunObject = page "AQD Posted Cust Rebates";
                // }

            }
        }
    }
}

