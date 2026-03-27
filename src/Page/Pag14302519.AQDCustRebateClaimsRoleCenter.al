page 14302519 "AQD Cust Rebate And Claims RC"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate & Claims Role Center', Comment = '';
    UsageCategory = Tasks;
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
            // action("Fixed Assets")
            // {
            //     Caption = 'Fixed Assets';
            //     ApplicationArea = All;
            //     Image = FixedAssets;
            //     RunObject = Page "Fixed Asset List";
            // }
            action(Customers)
            {
                Caption = 'Customers';
                ApplicationArea = All;
                Image = Customer;
                RunObject = Page "Customer List";
            }
            action(Vendors)
            {
                Caption = 'Vendors';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "Vendor List";
            }
            action(Employees)
            {
                Caption = 'Employees';
                ApplicationArea = All;
                Image = Employee;
                RunObject = Page "Employee List";
            }
            // action(AQDCustRbtIncludeCustomerLocations)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Include Customer Locations';
            //     Image = Customer;
            //     RunObject = Page "AQD Cust Rbt Include Cust Loc";
            // }
            // action(AQDCustRbtExcludeCustomerLocations)
            // {
            //     Caption = 'Exclude Customer Locations';
            //     ApplicationArea = All;
            //     Image = Customer;
            //     RunObject = Page "AQD Cust Rbt Exclude Cust Loc";
            // }
            action("Customer Rebate Program Codes")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Program Codes';
                RunObject = page "AQD Cust Rebate Program Codes";
            }
            action("AQD CR Item Categories")
            {
                Caption = 'Item Categories';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "Item Categories";
            }
            action("AQD Rebate Customer Categories")
            {
                Caption = 'Rebate Customer Categories';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Customer Categories";
            }
            // action("AQD Rebate Cust Type Eligib")
            // {
            //     Caption = 'Rebate Customer Type Eligibility';
            //     ApplicationArea = All;
            //     Image = CampaignEntries;
            //     RunObject = Page "AQD Rebate Cust Type Eligib";
            // }
            action(ClaimProgramCodes)
            {
                Caption = 'Claim Program Codes';
                ApplicationArea = All;
                Image = Entries;
                RunObject = Page "AQD Cust Claim Program Code";
            }
            action(ClaimServiceCodes)
            {
                Caption = 'Claim Service Codes';
                ApplicationArea = All;
                Image = Entries;
                RunObject = Page "AQD Claim Service Codes";
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
            action("Purchase Credit Memos")
            {
                Caption = 'Purchase Credit Memos';
                ApplicationArea = All;
                Image = SalesCreditMemo;
                RunObject = Page "Purchase Credit Memos";
            }
            action("Customer Rebate Batches")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Batches';
                RunObject = page "AQD Customer Rebate Batches";
            }
            action("Customer Rebates")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebates';
                RunObject = page "AQD Customer Rebates Documents";
            }
            action("AQD Full Price Cust Claim List")
            {
                ApplicationArea = All;
                Caption = 'Full Price Customer Claims';
                RunObject = page "AQD Full Price Cust Claim List";
            }
            action("AQD PriceMatch Cust Claim List")
            {
                ApplicationArea = All;
                Caption = 'Price Match Customer Claims';
                RunObject = page "AQD PriceMatch Cust Claim List";
            }
            action("Customer Contract Prices")
            {
                ApplicationArea = All;
                Caption = 'Customer Contract Prices';
                RunObject = page "AQD Customer Contract Prices";
            }
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
                action("Posted Purchase Credit Memo")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Credit Memos';
                    Image = PostedCreditMemo;
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted Purchase credit memos.';
                }
            }
        }
        area(Creation)
        {
            action("Generate Customer Rebate")
            {
                ApplicationArea = All;
                Caption = 'Generate and Post Customer Rebates';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Generate Customer Rebates";
            }
            action("Post Customer Rebate Batches")
            {
                ApplicationArea = All;
                Caption = 'Post Customer Rebate Batches';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Post Cust Rebate Batches";
                Visible = false;
            }
            action("Generate Customer Full Claim Claims")
            {
                ApplicationArea = All;
                Caption = 'Create Customer Full Price Claims';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Create CustFullPriceClaims";
            }
            action("Generate Customer Price Match Claims")
            {
                ApplicationArea = All;
                Caption = 'Create Customer Price Match Claims';
                Image = CalculateSalesTax;
                RunObject = Report "AQD Create CustPriceMatchClaim";
            }
            group(Journals)
            {
                // action("Customer Rebate Journal")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Customer Rebate Journal';
                //     Image = ConsumptionJournal;
                //     RunObject = Page "AQD Customer Rebate Journal";
                // }
                // action("Rebate Purchase Journal")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Rebate Purchase Journal';
                //     Image = Purchase;
                //     RunObject = Page "AQD Rebate Purch. Journal";
                // }
                // action("Rebate Payment Journal")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Rebate Payment Journal';
                //     Image = PaymentJournal;
                //     RunObject = Page "AQD Rebate Payment Journal";
                // }
                // action("Rebate Sales Journal")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Rebate Sales Journal';
                //     Image = Sales;
                //     RunObject = Page "AQD Rebate Sales Journal";
                // }
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
                action("AQD POD Cust/Item Sales New")
                {
                    Caption = 'POD Customer/Item Sales';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD POD Cust/Item Sales New";
                    Visible = false;
                }
                action("AQD Sales History POD")
                {
                    Caption = 'Sales History POD';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD Sales History POD";
                    Visible = false;
                }
                action("AQD Sales History POD New")
                {
                    Caption = 'Sales History POD';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD Sales History POD New";
                }
                action("AQD POD Cust/Item Sales New 2")
                {
                    Caption = 'POD Customer/Item Sales';
                    ApplicationArea = All;
                    Image = InventoryCalculation;
                    RunObject = Report "AQD POD Cust/Item Sales New 2";
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
            group(CustomerRebateSetup)
            {
                Caption = 'Customer Rebate Setup';
                Image = Setup;
                action("Acumens Customer Rebates Claims Setup")
                {
                    Caption = 'Acumens Customer Rebates & Claims Setup';
                    ApplicationArea = All;
                    Image = CostAccountingSetup;
                    RunObject = Page "AQD Acumens CustRbtClaim Setup";
                }
                action("Acumens Rebate Setup")
                {
                    Caption = 'Acumens Customer Rebates & Claims Setup';
                    ApplicationArea = All;
                    Image = CostAccountingSetup;
                    RunObject = Page "AQD Acumens CustRbtClaim Setup";
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with Acumens Customer Rebates Claims Setup';
                }
                action("User Setup")
                {
                    Caption = 'User Setup';
                    ApplicationArea = All;
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                }
                action("Customer Rebate Program Codes2")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebate Program Codes';
                    RunObject = page "AQD Cust Rebate Program Codes";
                    Image = Customer;
                }
                action("AQD CR Item Categories2")
                {
                    Caption = 'Item Categories';
                    ApplicationArea = All;
                    Image = Vendor;
                    RunObject = Page "Item Categories";
                }
                action("AQD Rebate Customer Categories2")
                {
                    Caption = 'Rebate Customer Categories';
                    ApplicationArea = All;
                    Image = CampaignEntries;
                    RunObject = Page "AQD Rebate Customer Categories";
                }
                action("Customer Rebates Rates")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebates Rates';
                    Image = Setup;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
                }
            }
            group(CustomerClaimSetup)
            {
                Caption = 'Claim Setup';
                Image = Setup;
                action("Acumens Customer Rebates Claims Setup2")
                {
                    Caption = 'Acumens Customer Rebates & Claims Setup';
                    ApplicationArea = All;
                    Image = CostAccountingSetup;
                    RunObject = Page "AQD Acumens CustRbtClaim Setup";
                }
                action("AQD Customer Claim Vendors")
                {
                    Caption = 'Claim Vendors';
                    ApplicationArea = All;
                    Image = UserSetup;
                    RunObject = Page "AQD Customer Claim Vendors";
                }
                action(ClaimProgramCodes2)
                {
                    Caption = 'Claim Program Codes';
                    ApplicationArea = All;
                    Image = Entries;
                    RunObject = Page "AQD Cust Claim Program Code";
                }
                action(ClaimServiceCodes2)
                {
                    Caption = 'Claim Service Codes';
                    ApplicationArea = All;
                    Image = Entries;
                    RunObject = Page "AQD Claim Service Codes";
                }
            }

            group(History)
            {
                Caption = 'History';

                action("Item Ledger Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Item Ledger Entries';
                    RunObject = page "Item Ledger Entries";
                    Image = ItemLedger;
                }
                action("AQD CustRbt Drop Shpt Info")
                {
                    ApplicationArea = All;
                    Caption = 'Drop Shipment Information';
                    RunObject = page "AQD Drop Shipment Information";
                    Image = History;
                }
                action("Posted Customer Rebate Batches")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Customer Rebate Batches';
                    RunObject = page "AQD Posted Cust Rebate Batches";
                    Image = PostedCreditMemo;
                }
                action("Posted Customer Rebates")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Customer Rebates';
                    RunObject = page "AQD Posted Customer Rebates";
                    Image = PostedCreditMemo;
                }
                action("AQD Posted CustRbtDetail List")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Customer Rebate Details';
                    RunObject = page "AQD Posted CustRbtDetail List";
                    Image = PostedCreditMemo;
                }
                action("AQD Completed Full Price Cust Claim List2")
                {
                    ApplicationArea = All;
                    Caption = 'Completed Full Price Customer Claims';
                    Image = CreditMemo;
                    RunObject = page AQDCmpltedFullPriceCustClmList;
                }
                action("AQD Completed PriceMatch Cust Claim List2")
                {
                    ApplicationArea = All;
                    Caption = 'Completed Price Match Customer Claims';
                    Image = CreditMemo;
                    RunObject = page "AQD CmpltdPriceMthCustClmList";
                }
            }
        }
    }
}

