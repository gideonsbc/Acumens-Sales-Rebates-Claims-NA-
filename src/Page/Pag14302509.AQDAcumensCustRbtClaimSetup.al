page 14302509 "AQD Acumens CustRbtClaim Setup"
{
    ApplicationArea = All;
    Caption = 'Acumens Customer Rebates & Claims Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "AQD Acumens CustRbtClaim Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Customer Rebate")
            {
                Caption = 'Customer Rebate';
                Editable = AllowToEdit;

                group(RebateEnabled)
                {
                    Caption = 'Rebate Enabled';
                    field("Item Rebate Enabled"; Rec."Item Rebate Enabled")
                    {
                        ApplicationArea = All;
                        Caption = 'Item';
                    }
                    field("Resource Rebate Enabled"; Rec."Resource Rebate Enabled")
                    {
                        ApplicationArea = All;
                        Caption = 'Resource';
                    }
                    field("G/L Account Rebate Enabled"; Rec."G/L Account Rebate Enabled")
                    {
                        ApplicationArea = All;
                        Caption = 'G/L Account';
                    }
                }
                field("Customer Rebate Source Code"; Rec."Customer Rebate Source Code")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Calculation Start Date';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Duplicate Field';
                    ObsoleteTag = 'Discontined from 25.1023.0.7';
                    Visible = FALSE;
                }
                field("Customer Rebate Start Date"; Rec."Customer Rebate Start Date")
                {
                    ApplicationArea = All;
                    Caption = 'Calculation Start Date';
                }
                field("Rebate Calc Start Invoice No."; Rec."Rebate Calc Start Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Calc Start CM No."; Rec."Rebate Calc Start CM No.")
                {
                    ApplicationArea = All;
                }
                field("Exclude Credit Memo"; Rec."Exclude Credit Memo")
                {
                    ApplicationArea = All;
                }
                field("Pay Customer Rebate On"; Rec."Post Customer Rebates for")
                {
                    ApplicationArea = All;
                    Visible = FALSE;
                }
                field("Rebate Payable AC"; Rec."Rebate Payable AC")
                {
                    ApplicationArea = All;
                }
                field("Post Rebates by Bill-To Cust"; Rec."Post Rebates by Bill-To Cust")
                {
                    ApplicationArea = All;
                }
                field("Auto Process Customer Rebates"; Rec."Auto Process Customer Rebates")
                {
                    ApplicationArea = All;
                }
                field("Min GP% for Customer Rebate"; Rec."Min GP% for Customer Rebate")
                {
                    ApplicationArea = All;
                }
                group(DefaultSetup)
                {
                    Caption = 'Default Setup';

                    // field("Default Rebate Posting Type"; Rec."Default Rebate Posting Type")
                    // {
                    //     ApplicationArea = All;
                    // }
                    field("Bill-To Rebate Customer"; Rec."Bill-To Rebate Customer")
                    {
                        ApplicationArea = All;
                    }
                    FIELD("Default Rebate Customer No"; Rec."Default Rebate Customer No")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Bill-To Customer No.';
                        Editable = Rec."Bill-To Rebate Customer" = Rec."Bill-To Rebate Customer"::"Customer Card Setup";
                        Enabled = Rec."Bill-To Rebate Customer" = Rec."Bill-To Rebate Customer"::"Customer Card Setup";
                    }
                    field("Default Setup Rebate Type"; Rec."Default Setup Rebate Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Setup Rebate Type';
                    }
                    field("Default Rebate Code"; Rec."Default Rebate Program Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Program Code';
                    }
                    field("Sales Item Charge No."; Rec."Sales Item Charge No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Item Charge No.';
                        Visible = false;
                    }
                }
                group("Rebate Sales Journal")
                {
                    Caption = 'Rebate Sales Journal';
                    field("Sales Journal Template Name"; Rec."Sales Journal Template Name")
                    {
                        Caption = 'Journal Template Name';
                        ApplicationArea = All;
                    }
                    field("Sales Journal Batch Name"; Rec."Sales Journal Batch Name")
                    {
                        Caption = 'Journal Batch Name';
                        ApplicationArea = All;
                    }
                }
            }
            group("Customer Claim")
            {
                Caption = 'Customer Claim';
                Editable = AllowToEdit;

                field("Item Claim Enabled"; Rec."Item Claim Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Claim Enabled field.', Comment = '%';
                }
                field("Resource Claim Enabled"; Rec."Resource Claim Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resource Claim Enabled field.', Comment = '%';
                }
                field("G/L Account Claim Enabled"; Rec."G/L Account Claim Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account Claim Enabled field.', Comment = '%';
                }

                group(ClaimFullPrice)
                {
                    Caption = 'Full Price Claim';
                    Editable = AllowToEdit;
                    field("Claim No. is Order No."; Rec."Claim No. is Order No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim No. is Order No. field.', Comment = '%';
                    }
                    field("Create Claim On"; Rec."Create Claim On")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create Claim On field.', Comment = '%';
                    }
                    field("Insert Comment Lines on Claim"; Rec."Insert Comment Lines on Claim")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Insert Comment Lines on Claim field.', Comment = '%';
                    }
                    field("Full Price Default Pyt Method"; Rec."Full Price Default Pyt Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Full Price Claim Default Payment Method Code field.', Comment = '%';
                    }
                    Field(PostCreditMemoOnOrderInvoicing; Rec.PostCreditMemoOnOrderInvoicing)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Post Credit Memo On Order Invoicing field.', Comment = '%';
                    }
                    FIELD(AllowToPostOrdAfterClaimApprov; Rec.AllowToPostOrdAfterClaimApprov)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Allow to Post Order After Claim Approval field.', Comment = '%';
                    }
                    field("Claims G/L Account"; Rec."Full Price Claims G/L Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claims G/L Account field.', Comment = '%';
                    }
                    field("Claim Delivery Commission Acct"; Rec."Claim Delivery Commission Acct")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Delivery Commission Acct field.', Comment = '%';
                    }
                    field("Claim Discount Account"; Rec."Claim Discount G/L Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Discount Account field.', Comment = '%';
                    }
                    FIELD("Claim Variance G/L Account"; Rec."Claim Variance G/L Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Variance G/L Account field.', Comment = '%';
                    }
                }
                group(ClaimPriceMatch)
                {
                    Caption = 'Price Match Claim';
                    Editable = AllowToEdit;

                    field("Price Match Default Pyt Method"; Rec."Price Match Default Pyt Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Default Payment Method Code for Price Match Sales Invoice field.', Comment = '%';
                    }
                    field("Price Match Create Claim On"; Rec."Price Match Create Claim On")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Create Claim On field.', Comment = '%';
                    }
                    field("Price Match ClaimServCode Mand"; Rec."Price Match ClaimServCode Mand")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Claim Service Code field.', Comment = '%';
                    }
                    field("Price Match ClaimProgCode Mand"; Rec."Price Match ClaimProgCode Mand")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Claim Program Code field.', Comment = '%';
                    }
                    field("Price Match Always CreCostDiff"; Rec."Price Match Always CreCostDiff")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Always Create Cost Difference Line field.', Comment = '%';
                    }
                    field("Price Match Always CreCommLine"; Rec."Price Match Always CreCommLine")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Always Create Delivery Commission Line field.', Comment = '%';
                    }
                    field("Price Match Claims G/L Account"; Rec."Price Match Claims G/L Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Claims G/L Account field.', Comment = '%';
                    }
                    field("PriceMatch ClmCostDiff G/LAcct"; Rec."PriceMatch ClmCostDiff G/LAcct")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Claims Cost Difference G/L Account field.', Comment = '%';
                    }
                    field("Price Match Claim DelComm Acct"; Rec."Price Match Claim DelComm Acct")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Claims Delivery Commission G/L Account field.', Comment = '%';
                    }
                    field("Price Match Claim Disc G/LAcct"; Rec."Price Match Claim Disc G/LAcct")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Claims Discount G/L Account field.', Comment = '%';
                    }
                    field("Price Match Claim Vari G/LAcct"; Rec."Price Match Claim Vari G/LAcct")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of Price Match Claims Variance G/L Account field.', Comment = '%';
                    }
                }
            }
            group("Number Series")
            {
                Caption = 'Number Series';
                Editable = AllowToEdit;
                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Customer Rebate';

                    field("Customer Rebate Nos"; Rec."Customer Rebate Document Nos")
                    {
                        ApplicationArea = All;
                        ShowMandatory = TRUE;
                    }
                }
                Group("AQD AcumensCustomerClaim")
                {
                    Caption = 'Customer Claim';
                    field("Full Price Claim Nos."; Rec."Full Price Claim Nos.")
                    {
                        ApplicationArea = All;
                    }
                    field("Price Match Claim Nos."; Rec."Price Match Claim Nos.")
                    {
                        ApplicationArea = All;
                    }
                    field("Supplementary Invoice Nos."; Rec."Supplementary Invoice Nos.")
                    {
                        ApplicationArea = All;
                    }
                    field("Claim Purchase Cr Memo Nos."; Rec."Claim Purchase Cr Memo Nos.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(EditAction)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                trigger OnAction()
                begin
                    AllowToEdit := TRUE;
                    CurrPage.Update(false);
                end;
            }
            action("Get Default Setups")
            {
                ApplicationArea = All;
                Caption = 'Get Default Setups';
                Image = GetEntries;
                Visible = false;
                trigger OnAction()
                begin
                    Message('To Be Implemented');
                end;
            }
            action(DeleteDefaultSetupsAction)
            {
                Caption = 'Delete Default Setups';
                Image = DeleteAllBreakpoints;
                ApplicationArea = All;
                ToolTip = 'Executes the Delete Default Setups action.';
                trigger OnAction()
                begin
                    DeleteDefaultSetups();
                end;
            }
            action(ResetNoSeriesAction)
            {
                Caption = 'Reset Number Series';
                Image = ResetStatus;
                ToolTip = 'Resets All ASM Number series on the setup';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    ResetNoSeries();
                end;
            }
            action("Old Invoice & Credit Memo Non-Rebatable")
            {
                ApplicationArea = All;
                Caption = 'Old Invoice & Credit Memo Non-Rebatable';
                Image = OrderList;
                Visible = FALSE;
                trigger OnAction()
                var
                    RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
                begin
                    Clear(RebateCalculationMgt);
                    RebateCalculationMgt.UpdateOldDocumentsNonRebateEnable();
                    CurrPage.Update();
                end;
            }
            action("User Setup")
            {
                ApplicationArea = All;
                Caption = 'User Setup';
                Image = UserSetup;
                RunObject = Page "User Setup";
            }
            action("Customer Rebate Program Codes")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Program Codes';
                RunObject = page "AQD Cust Rebate Program Codes";
                Image = Customer;
            }
            action("Item Categories")
            {
                Caption = 'Item Categories';
                ApplicationArea = All;
                Image = Vendor;
                RunObject = Page "Item Categories";
            }
            action("Rebate Customer Categories")
            {
                Caption = 'Rebate Customer Categories';
                ApplicationArea = All;
                Image = CampaignEntries;
                RunObject = Page "AQD Rebate Customer Categories";
            }
            action("Sales Rebates Rates")
            {
                ApplicationArea = All;
                Caption = 'Sales Rebates Rates';
                Image = Setup;
                RunObject = Page "AQD CustRbt SalesRebates Setup";
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                Caption = 'HOME';
                actionref(Edit_Home; EditAction) { }
                actionref(DeleteDefaultSetupsAction_Home; DeleteDefaultSetupsAction) { }
                actionref(ResetNoSeriesAction_Home; ResetNoSeriesAction) { }
                actionref(OldInvoice_Home; "Old Invoice & Credit Memo Non-Rebatable") { }
                actionref(UserSetup_Home; "User Setup") { }
                actionref(CustomerRebateProgramCodes_Home; "Customer Rebate Program Codes") { }
                actionref(ItemCategories_Home; "Item Categories") { }
                actionref(RebateCustomerCategories_Home; "Rebate Customer Categories") { }
                actionref(SalesRebatesRates_Home; "Sales Rebates Rates") { }
            }
        }
    }

    trigger OnOpenPage()
    var
        SourceCodeRec: Record "Source Code";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        IF NOT SourceCodeRec.GET('RBTSALES') THEN BEGIN
            SourceCodeRec.Init();
            SourceCodeRec.Code := 'RBTSALES';
            SourceCodeRec.Description := 'Customer Rebate';
            SourceCodeRec.Insert();
        END;

        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init();
            Rec."Customer Rebate Source Code" := 'RBTSALES';
            Rec."Post Customer Rebates for" := Rec."Post Customer Rebates for"::"All Invoices";
            Rec."Rebate Payable Ac" := Rec."Rebate Payable Ac"::Customer;
            Rec."Auto Process Customer Rebates" := TRUE;
            Rec."Default Rebate Posting Type" := Rec."Default Rebate Posting Type"::Expense;

            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Sales);
            if GenJournalTemplate.FindFirst() then begin
                Rec."Sales Journal Template Name" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Customer Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name
                ELSE begin
                    IF NOT GenJournalBatch.GET(GenJournalTemplate.Name, 'CUSTREBATE') THEN BEGIN
                        GenJournalBatch.Init();
                        GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
                        GenJournalBatch.Name := 'CUSTREBATE';
                        GenJournalBatch.Description := 'Sales Rebate Batch';
                        GenJournalBatch."AQD Customer Rebate" := TRUE;
                        GenJournalBatch.Insert();
                        Rec."Sales Journal Batch Name" := GenJournalBatch.Name;
                    END ELSE begin
                        IF NOT GenJournalBatch."AQD Customer Rebate" THEN BEGIN
                            GenJournalBatch."AQD Customer Rebate" := TRUE;
                            GenJournalBatch.Modify();
                        END
                    end;
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name;
                end;
            end;
            Rec.Insert();
            InitializeDefaultSetups();
            AllowToEdit := FALSE;
        end;
    end;

    local procedure InitializeDefaultSetups()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLAccount: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        TaxGroup: Record "Tax Group";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchaseSetup: Record "Purchases & Payables Setup";
        CustomerRebateProgramCode: Record "AQD Cust Rebate Program Code";
        CustomerSalesRebateSetup: Record "AQD Sales Rebates Rate";
        LastGLAccountNo: CODE[20];
        CustomerRebatePayableGLAccount: Code[20];
        CustomerRebateExpenseGLAccount: Code[20];
        AmazonRebateExpenseGLAccount, ShopifyRebateExpenseGLAccount, WalmartRebateExpenseGLAccount, RoyaltyRebateExpenseGLAccount, CouponRebateExpenseGLAccount : Code[20];
        AmazonRebatePayableGLAccount, ShopifyRebatePayableGLAccount, WalmartRebatePayableGLAccount, RoyaltyRebatePayableGLAccount, CouponRebatePayableGLAccount : Code[20];
        Counter: Integer;
        ExitLoop: Boolean;
        LocalUserConfirmMsg: Label 'Do you want to initialize default setups?';
        AmazonVendor, ShopifyVendor, WalmartVendor, RoyaltyVendor, CouponVendor : Record Vendor;
        AmazonVendor2, ShopifyVendor2, WalmartVendor2, RoyaltyVendor2, CouponVendor2 : Record Vendor;
        AmazonVendorCode, ShopifyVendorCode, WalmartVendorCode, RoyaltyVendorCode, CouponVendorCode : Code[20];
        NoSeries: Codeunit "No. Series";
        PurchSetup: Record "Purchases & Payables Setup";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        VendorRec: Record Vendor;
    begin
        if Confirm(LocalUserConfirmMsg) then begin
            ResetNoSeries();

            SalesSetup.GET;
            PurchaseSetup.GET;
            Rec."Full Price Claim Nos." := 'FULL PRICE CLAIM';
            Rec."Price Match Claim Nos." := 'PRICE MATCH CLAIM';
            Rec."Create Claim On" := Rec."Create Claim On"::"Order Release";
            Rec."Claim Purchase Cr Memo Nos." := PurchaseSetup."Credit Memo Nos.";
            Rec."Supplementary Invoice Nos." := SalesSetup."Invoice Nos.";

            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Sales);
            if GenJournalTemplate.FindFirst() then begin
                Rec."Sales Journal Template Name" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Customer Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name
                ELSE begin
                    IF NOT GenJournalBatch.GET(GenJournalTemplate.Name, 'CUSTREBATE') THEN BEGIN
                        GenJournalBatch.Init();
                        GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
                        GenJournalBatch.Name := 'CUSTREBATE';
                        GenJournalBatch.Description := 'Sales Rebate Batch';
                        GenJournalBatch."AQD Customer Rebate" := TRUE;
                        GenJournalBatch.Insert();
                    END;
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name;
                end;
            end;
            Rec."Customer Rebate Document Nos" := 'CRB';
            IF SalesInvoiceHeader.FINDLAST THEN BEGIN
                Rec."Rebate Calc Start Invoice No." := SalesInvoiceHeader."No.";
                Rec."Customer Rebate Start Date" := SalesInvoiceHeader."Posting Date";
            END;
            IF SalesCrMemoHeader.FINDLAST THEN BEGIN
                Rec."Rebate Calc Start CM No." := SalesCrMemoHeader."No.";
                Rec."Customer Rebate Start Date" := SalesCrMemoHeader."Posting Date";
            END;

            IF Rec."Customer Rebate Start Date" <> 0D THEN
                Rec."Customer Rebate Start Date" := CalcDate('1D', Rec."Customer Rebate Start Date")
            ELSE
                Rec."Customer Rebate Start Date" := WorkDate();
            Rec.Modify(true);

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            IF GLAccount2.FindLast() THEN
                CustomerRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20160';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Customer Rebate Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount.INSERT;
                CustomerRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            IF GLAccount2.FindLast() THEN
                CustomerRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50415';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Customer Rebate Expense';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount.INSERT;
                CustomerRebateExpenseGLAccount := GLAccount."No.";
            END;


            //Expense Accounts
            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Amazon);
            IF GLAccount2.FindLast() THEN
                AmazonRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50435';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Amazon Commission';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Amazon;
                GLAccount.INSERT;
                AmazonRebateExpenseGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Shopify);
            IF GLAccount2.FindLast() THEN
                ShopifyRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50436';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Shopify Commission';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Shopify;
                GLAccount.INSERT;
                ShopifyRebateExpenseGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Walmart);
            IF GLAccount2.FindLast() THEN
                WalmartRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50437';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Walmart Commission';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Walmart;
                GLAccount.INSERT;
                WalmartRebateExpenseGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Royalty);
            IF GLAccount2.FindLast() THEN
                RoyaltyRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50438';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Royalty Commission';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Royalty;
                GLAccount.INSERT;
                RoyaltyRebateExpenseGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Coupon);
            IF GLAccount2.FindLast() THEN
                CouponRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '50439';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Coupon Accrual';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                GLAccount."Account Category" := GLAccount."Account Category"::Expense;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Expense;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Coupon;
                GLAccount.INSERT;
                CouponRebateExpenseGLAccount := GLAccount."No.";
            END;


            //Payable Accounts
            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Amazon);
            IF GLAccount2.FindLast() THEN
                AmazonRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20165';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Amazon Commission Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                GLAccount.Validate("Account Subcategory Entry No.", 11);
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Amazon;
                GLAccount.INSERT;
                AmazonRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Shopify);
            IF GLAccount2.FindLast() THEN
                ShopifyRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20166';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Shopify Commission Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                GLAccount.Validate("Account Subcategory Entry No.", 11);
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Shopify;
                GLAccount.INSERT;
                ShopifyRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Walmart);
            IF GLAccount2.FindLast() THEN
                WalmartRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20167';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Walmart Commission Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                GLAccount.Validate("Account Subcategory Entry No.", 11);
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Walmart;
                GLAccount.INSERT;
                WalmartRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Royalty);
            IF GLAccount2.FindLast() THEN
                RoyaltyRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20168';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Royalty Commission Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                GLAccount.Validate("Account Subcategory Entry No.", 11);
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Royalty;
                GLAccount.INSERT;
                RoyaltyRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/LAcct Type", GLAccount2."AQD Cust Rebate G/LAcct Type"::Payable);
            GLAccount2.SETRANGE("AQD Cust Rebate Acct Group", GLAccount2."AQD Cust Rebate Acct Group"::Coupon);
            IF GLAccount2.FindLast() THEN
                CouponRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                LastGLAccountNo := '20169';

                ExitLoop := FALSE;
                Counter := 1;

                GLAccount2.RESET;
                REPEAT
                    IF GLAccount2.GET(LastGLAccountNo) THEN
                        LastGLAccountNo := IncStr(LastGLAccountNo)
                    ELSE
                        ExitLoop := TRUE;
                    Counter += 1;
                UNTIL (Counter > 100) OR ExitLoop;

                GLAccount.INIT;
                GLAccount."No." := LastGLAccountNo;
                GLAccount.Name := 'Coupon Commission Payable';
                GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
                GLAccount."Account Category" := GLAccount."Account Category"::Liabilities;
                GLAccount."Direct Posting" := true;
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Both;
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                GLAccount.Validate("Account Subcategory Entry No.", 11);
                IF TaxGroup.GET('NONTAXABLE') THEN
                    GLAccount."Tax Group Code" := 'NONTAXABLE';
                GLAccount."AQD Cust Rebate G/LAcct Type" := GLAccount."AQD Cust Rebate G/LAcct Type"::Payable;
                GLAccount."AQD Cust Rebate Acct Group" := GLAccount."AQD Cust Rebate Acct Group"::Coupon;
                GLAccount.INSERT;
                CouponRebatePayableGLAccount := GLAccount."No.";
            END;


            //Vendors
            PurchSetup.Get();
            AmazonVendor.Reset();
            AmazonVendor.SetFilter(Name, '@*Amazon*');
            if AmazonVendor.FindFirst() then
                AmazonVendorCode := AmazonVendor."No."
            else begin
                AmazonVendor2.Init();
                AmazonVendor2.Validate("No.", NoSeries.GetNextNo(PurchSetup."Vendor Nos."));
                AmazonVendor2.Validate(Name, 'Amazon Commission Accruals');
                AmazonVendor2.Insert(true);
                AmazonVendorCode := AmazonVendor2."No.";
            end;

            ShopifyVendor.Reset();
            ShopifyVendor.SetFilter(Name, '@*Shopify*');
            if ShopifyVendor.FindFirst() then
                ShopifyVendorCode := ShopifyVendor."No."
            else begin
                ShopifyVendor2.Init();
                ShopifyVendor2.Validate("No.", NoSeries.GetNextNo(PurchSetup."Vendor Nos."));
                ShopifyVendor2.Validate(Name, 'Shopify Commission Accruals');
                ShopifyVendor2.Insert(true);
                ShopifyVendorCode := ShopifyVendor2."No.";
            end;

            WalmartVendor.Reset();
            WalmartVendor.SetFilter(Name, '@*Walmart*');
            if WalmartVendor.FindFirst() then
                WalmartVendorCode := WalmartVendor."No."
            else begin
                WalmartVendor2.Init();
                WalmartVendor2.Validate("No.", NoSeries.GetNextNo(PurchSetup."Vendor Nos."));
                WalmartVendor2.Validate(Name, 'Walmart Commission Accruals');
                WalmartVendor2.Insert(true);
                WalmartVendorCode := WalmartVendor2."No.";
            end;

            RoyaltyVendor.Reset();
            RoyaltyVendor.SetFilter(Name, '@*Royalty*');
            if RoyaltyVendor.FindFirst() then
                RoyaltyVendorCode := RoyaltyVendor."No."
            else begin
                RoyaltyVendor2.Init();
                RoyaltyVendor2.Validate("No.", NoSeries.GetNextNo(PurchSetup."Vendor Nos."));
                RoyaltyVendor2.Validate(Name, 'Royalty Commission Accruals');
                RoyaltyVendor2.Insert(true);
                RoyaltyVendorCode := RoyaltyVendor2."No.";
            end;

            CouponVendor.Reset();
            CouponVendor.SetFilter(Name, '@*Coupon*');
            if CouponVendor.FindFirst() then
                CouponVendorCode := CouponVendor."No."
            else begin
                CouponVendor2.Init();
                CouponVendor2.Validate("No.", NoSeries.GetNextNo(PurchSetup."Vendor Nos."));
                CouponVendor2.Validate(Name, 'Coupon Accruals');
                CouponVendor2.Insert(true);
                CouponVendorCode := CouponVendor2."No.";
            end;


            //General business Posting Group
            if not GenBusinessPostingGroup.Get('DOMESTIC') then begin
                GenBusinessPostingGroup.Init();
                GenBusinessPostingGroup.Code := 'DOMESTIC';
                GenBusinessPostingGroup.Description := 'Domestic customers and vendors';
                GenBusinessPostingGroup.Insert(true);
            end;


            //Vendor Posting Group
            if not VendorPostingGroup.Get('AMAZON') then begin
                VendorPostingGroup.Init();
                VendorPostingGroup.Code := 'AMAZON';
                VendorPostingGroup.Description := 'Amazon Commission';
                VendorPostingGroup.Validate("Payables Account", AmazonRebatePayableGLAccount);
                VendorPostingGroup.Insert(true);
            end;

            if not VendorPostingGroup.Get('SHOPIFY') then begin
                VendorPostingGroup.Init();
                VendorPostingGroup.Code := 'SHOPIFY';
                VendorPostingGroup.Description := 'Shopify Commission';
                VendorPostingGroup.Validate("Payables Account", ShopifyRebatePayableGLAccount);
                VendorPostingGroup.Insert(true);
            end;

            if not VendorPostingGroup.Get('WALMART') then begin
                VendorPostingGroup.Init();
                VendorPostingGroup.Code := 'WALMART';
                VendorPostingGroup.Description := 'Walmart Commission';
                VendorPostingGroup.Validate("Payables Account", WalmartRebatePayableGLAccount);
                VendorPostingGroup.Insert(true);
            end;

            if not VendorPostingGroup.Get('ROYALTY') then begin
                VendorPostingGroup.Init();
                VendorPostingGroup.Code := 'ROYALTY';
                VendorPostingGroup.Description := 'Royalty Commission';
                VendorPostingGroup.Validate("Payables Account", RoyaltyRebatePayableGLAccount);
                VendorPostingGroup.Insert(true);
            end;

            if not VendorPostingGroup.Get('COUPON') then begin
                VendorPostingGroup.Init();
                VendorPostingGroup.Code := 'COUPON';
                VendorPostingGroup.Description := 'Coupon Commission';
                VendorPostingGroup.Validate("Payables Account", CouponRebatePayableGLAccount);
                VendorPostingGroup.Insert(true);
            end;


            //Modify Vendors
            if VendorRec.Get(AmazonVendorCode) then begin
                VendorRec.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
                VendorRec.Validate("Vendor Posting Group", 'AMAZON');
                VendorRec.Modify(true);
            end;

            if VendorRec.Get(ShopifyVendorCode) then begin
                VendorRec.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
                VendorRec.Validate("Vendor Posting Group", 'SHOPIFY');
                VendorRec.Modify(true);
            end;

            if VendorRec.Get(WalmartVendorCode) then begin
                VendorRec.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
                VendorRec.Validate("Vendor Posting Group", 'WALMART');
                VendorRec.Modify(true);
            end;

            if VendorRec.Get(RoyaltyVendorCode) then begin
                VendorRec.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
                VendorRec.Validate("Vendor Posting Group", 'ROYALTY');
                VendorRec.Modify(true);
            end;

            if VendorRec.Get(CouponVendorCode) then begin
                VendorRec.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
                VendorRec.Validate("Vendor Posting Group", 'COUPON');
                VendorRec.Modify(true);
            end;


            //Customer Rebate Program Code
            IF NOT CustomerRebateProgramCode.GET('ALL-UNIT') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'ALL-UNIT';
                CustomerRebateProgramCode.Description := 'Rebate - All Customers';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::Percentage;
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 0;
                CustomerRebateProgramCode."Customer Default Rebate %" := 10;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::Customer;
                CustomerRebateProgramCode."Entity No." := '';
                CustomerRebateProgramCode."Rebate Expense AC" := CustomerRebateExpenseGLAccount;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('ALL-PCT') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'ALL-PCT';
                CustomerRebateProgramCode.Description := 'Rebate - All Customers';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::"Per Quantity";
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 20;
                CustomerRebateProgramCode."Customer Default Rebate %" := 0;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::Customer;
                CustomerRebateProgramCode."Entity No." := '';
                CustomerRebateProgramCode."Rebate Expense AC" := CustomerRebateExpenseGLAccount;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('AMAZON') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'AMAZON';
                CustomerRebateProgramCode.Description := 'Amazon Commission';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::Percentage;
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 0;
                CustomerRebateProgramCode."Customer Default Rebate %" := 5;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::"Vendor Commission";
                CustomerRebateProgramCode."Entity No." := AmazonVendorCode;
                CustomerRebateProgramCode."Rebate Expense AC" := AmazonRebateExpenseGLAccount;
                CustomerRebateProgramCode."Specific Sales" := true;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('SHOPIFY') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'SHOPIFY';
                CustomerRebateProgramCode.Description := 'Shopify Commission';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::Percentage;
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 0;
                CustomerRebateProgramCode."Customer Default Rebate %" := 5;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::"Vendor Commission";
                CustomerRebateProgramCode."Entity No." := ShopifyVendorCode;
                CustomerRebateProgramCode."Rebate Expense AC" := ShopifyRebateExpenseGLAccount;
                CustomerRebateProgramCode."Specific Sales" := true;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('WALMART') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'WALMART';
                CustomerRebateProgramCode.Description := 'Walmart Commission';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::Percentage;
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 0;
                CustomerRebateProgramCode."Customer Default Rebate %" := 5;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::"Vendor Commission";
                CustomerRebateProgramCode."Entity No." := WalmartVendorCode;
                CustomerRebateProgramCode."Rebate Expense AC" := WalmartRebateExpenseGLAccount;
                CustomerRebateProgramCode."Specific Sales" := true;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('ROYALTY') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'ROYALTY';
                CustomerRebateProgramCode.Description := 'Royalty Commission';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::"Per Quantity";
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 1;
                CustomerRebateProgramCode."Customer Default Rebate %" := 0;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::"Vendor Commission";
                CustomerRebateProgramCode."Entity No." := RoyaltyVendorCode;
                CustomerRebateProgramCode."Rebate Expense AC" := RoyaltyRebateExpenseGLAccount;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            IF NOT CustomerRebateProgramCode.GET('COUPON') THEN BEGIN
                CustomerRebateProgramCode.INIT;
                CustomerRebateProgramCode.Code := 'COUPON';
                CustomerRebateProgramCode.Description := 'Coupon Accrual';
                CustomerRebateProgramCode."Customer Rebate Posting Type" := CustomerRebateProgramCode."Customer Rebate Posting Type"::Expense;
                CustomerRebateProgramCode."Customer Default Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type"::Percentage;
                CustomerRebateProgramCode."Customer Def Rebate Per Unit" := 0;
                CustomerRebateProgramCode."Customer Default Rebate %" := 5;
                CustomerRebateProgramCode."Entity Type" := CustomerRebateProgramCode."Entity Type"::"Vendor Commission";
                CustomerRebateProgramCode."Entity No." := CouponVendorCode;
                CustomerRebateProgramCode."Rebate Expense AC" := CouponRebateExpenseGLAccount;
                CustomerRebateProgramCode."Specific Sales" := true;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::Customer);
            CustomerSalesRebateSetup.SETRANGE("Entity No.", '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'ALL-UNIT');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Rebate Program Code" := 'ALL-UNIT';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                IF CustomerRebateProgramCode.GET(CustomerSalesRebateSetup."Rebate Program Code") THEN BEGIN
                    CustomerSalesRebateSetup."Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type";
                    CustomerSalesRebateSetup."Rebate Per Unit" := CustomerRebateProgramCode."Customer Def Rebate Per Unit";
                    CustomerSalesRebateSetup."Rebate %" := CustomerRebateProgramCode."Customer Default Rebate %";
                END;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::Customer);
            CustomerSalesRebateSetup.SETRANGE("Entity No.", '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'ALL-PCT');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Rebate Program Code" := 'ALL-PCT';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                IF CustomerRebateProgramCode.GET(CustomerSalesRebateSetup."Rebate Program Code") THEN BEGIN
                    CustomerSalesRebateSetup."Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type";
                    CustomerSalesRebateSetup."Rebate Per Unit" := CustomerRebateProgramCode."Customer Def Rebate Per Unit";
                    CustomerSalesRebateSetup."Rebate %" := CustomerRebateProgramCode."Customer Default Rebate %";
                END;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Volume Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::Customer);
            CustomerSalesRebateSetup.SETRANGE("Entity No.", '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'ALL-UNIT');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Volume Rebate";
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Rebate Program Code" := 'ALL-UNIT';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                IF CustomerRebateProgramCode.GET(CustomerSalesRebateSetup."Rebate Program Code") THEN BEGIN
                    CustomerSalesRebateSetup."Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type";
                    CustomerSalesRebateSetup."Rebate Per Unit" := CustomerRebateProgramCode."Customer Def Rebate Per Unit";
                    CustomerSalesRebateSetup."Rebate %" := CustomerRebateProgramCode."Customer Default Rebate %";
                END;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Volume Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::Customer);
            CustomerSalesRebateSetup.SETRANGE("Entity No.", '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'ALL-PCT');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Volume Rebate";
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Entity Type" := CustomerSalesRebateSetup."Entity Type"::Customer;
                CustomerSalesRebateSetup."Entity No." := '';
                CustomerSalesRebateSetup."Rebate Program Code" := 'ALL-PCT';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                IF CustomerRebateProgramCode.GET(CustomerSalesRebateSetup."Rebate Program Code") THEN BEGIN
                    CustomerSalesRebateSetup."Rebate Type" := CustomerRebateProgramCode."Customer Default Rebate Type";
                    CustomerSalesRebateSetup."Rebate Per Unit" := CustomerRebateProgramCode."Customer Def Rebate Per Unit";
                    CustomerSalesRebateSetup."Rebate %" := CustomerRebateProgramCode."Customer Default Rebate %";
                END;
                CustomerSalesRebateSetup.Insert();
            END;

            //Sales Rebate Setup
            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::"Vendor Commission");
            CustomerSalesRebateSetup.SETFILTER("Entity No.", '<>%1', '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'AMAZON');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup.Validate("Rebate Program Code", 'AMAZON');
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::"Vendor Commission");
            CustomerSalesRebateSetup.SETFILTER("Entity No.", '<>%1', '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'SHOPIFY');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup.Validate("Rebate Program Code", 'SHOPIFY');
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::"Vendor Commission");
            CustomerSalesRebateSetup.SETFILTER("Entity No.", '<>%1', '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("No.", '');
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'WALMART');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup.Validate("Rebate Program Code", 'WALMART');
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::"Vendor Commission");
            CustomerSalesRebateSetup.SETFILTER("Entity No.", '<>%1', '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'ROYALTY');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup.Validate("Rebate Program Code", 'ROYALTY');
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup.Validate("No.", '1968-S');
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                CustomerSalesRebateSetup.Insert();
            END;

            CustomerSalesRebateSetup.RESET;
            CustomerSalesRebateSetup.SETRANGE("CustRbt Rate Type", CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate");
            CustomerSalesRebateSetup.SETRANGE("Entity Type", CustomerSalesRebateSetup."Entity Type"::"Vendor Commission");
            CustomerSalesRebateSetup.SETFILTER("Entity No.", '<>%1', '');
            CustomerSalesRebateSetup.SETRANGE("Territory Code", '');
            CustomerSalesRebateSetup.SETRANGE("Line Type", CustomerSalesRebateSetup."Line Type"::Item);
            CustomerSalesRebateSetup.SETRANGE("Variant Code", '');
            CustomerSalesRebateSetup.SETRANGE("Rebate Program Code", 'COUPON');
            CustomerSalesRebateSetup.SETRANGE("Starting Date", 0D);
            CustomerSalesRebateSetup.SETRANGE("Unit of Measure Code", '');
            CustomerSalesRebateSetup.SetRange("Minimum Quantity", 0);
            CustomerSalesRebateSetup.SetRange("Minimum Amount", 0);
            IF NOT CustomerSalesRebateSetup.FindFirst() THEN BEGIN
                CustomerSalesRebateSetup.Init();
                CustomerSalesRebateSetup."Entry No." := 0;
                CustomerSalesRebateSetup."CustRbt Rate Type" := CustomerSalesRebateSetup."CustRbt Rate Type"::"Simple Rebate";
                CustomerSalesRebateSetup.Validate("Rebate Program Code", 'COUPON');
                CustomerSalesRebateSetup."Territory Code" := '';
                CustomerSalesRebateSetup."Line Type" := CustomerSalesRebateSetup."Line Type"::Item;
                CustomerSalesRebateSetup."No." := '';
                CustomerSalesRebateSetup."Variant Code" := '';
                CustomerSalesRebateSetup."Starting Date" := 0D;
                CustomerSalesRebateSetup."Unit of Measure Code" := '';
                CustomerSalesRebateSetup."Minimum Quantity" := 0;
                CustomerSalesRebateSetup."Minimum Amount" := 0;
                CustomerSalesRebateSetup.Insert();
            END;

        END;
    END;

    local procedure ResetNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Reset();
        if not NoSeries.Get('CRB') then begin
            NoSeries.Init();
            NoSeries.Code := 'CRB';
            NoSeries.Description := 'Customer Rebate Nos';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            NoSeriesLine.Reset();
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'CRB';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CRB00001';
            if NoSeriesLine.Insert() then;
        end;

        NoSeries.Reset();
        IF NOT NoSeries.Get('FULL PRICE CLAIM') THEN BEGIN
            NoSeries.Init();
            NoSeries.Code := 'FULL PRICE CLAIM';
            NoSeries.Description := 'Full Price Customer Claim Nos';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            NoSeriesLine.Reset();
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'FULL PRICE CLAIM';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'FPC000001';
            IF NoSeriesLine.Insert() THEN;
        END;

        IF NOT NoSeries.Get('PRICE MATCH CLAIM') THEN BEGIN
            NoSeries.Init();
            NoSeries.Code := 'PRICE MATCH CLAIM';
            NoSeries.Description := 'Price Match Customer Claim Nos';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            NoSeriesLine.Reset();
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'PRICE MATCH CLAIM';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'PMC000001';
            IF NoSeriesLine.Insert() THEN;
        END;
    end;

    local procedure DeleteDefaultSetups()
    var
        LocalUserConfirmMsg: Label 'Please note that this action will delete all default settings. Do you want to continue?';
    begin
        if Confirm(LocalUserConfirmMsg) then
            Rec.Delete();
    end;

    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        AllowToEdit: Boolean;
}