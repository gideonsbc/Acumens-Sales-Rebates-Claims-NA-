page 14302509 "AQD Acumens CustRbtClaim Setup"
{
    Caption = 'Acumens Customer Rebates & Claims Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "AQD Acumens CustRbtClaim Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Customer Rebate")
            {
                Caption = 'General';
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
                    Caption = 'Rebate Calculation Start Date';
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
            group("Number Series")
            {
                Caption = 'Number Series';
                Editable = AllowToEdit;

                field("Customer Rebate Nos"; Rec."Customer Rebate Document Nos")
                {
                    ApplicationArea = All;
                    ShowMandatory = TRUE;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1000000016; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control1000000017; Links)
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
        CustomerRebateProgramCode: Record "AQD Cust Rebate Program Code";
        CustomerSalesRebateSetup: Record "AQD Sales Rebates Rate";
        LastGLAccountNo: CODE[20];
        CustomerRebatePayableGLAccount: Code[20];
        CustomerRebateExpenseGLAccount: Code[20];
        Counter: Integer;
        ExitLoop: Boolean;
        LocalUserConfirmMsg: Label 'Do you want to initialize default setups?';
    begin
        if Confirm(LocalUserConfirmMsg) then begin
            ResetNoSeries();
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
            IF SalesInvoiceHeader.FINDLAST THEN
                Rec."Rebate Calc Start Invoice No." := SalesInvoiceHeader."No.";
            IF SalesCrMemoHeader.FINDLAST THEN
                Rec."Rebate Calc Start CM No." := SalesCrMemoHeader."No.";
            Rec.Modify(true);

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Balance Sheet");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Liabilities);
            GLAccount2.SETRANGE("AQD Cust Rebate G/L Account", TRUE);
            IF GLAccount2.FindLast() THEN
                CustomerRebatePayableGLAccount := GLAccount2."No."
            ELSE BEGIN
                GLAccount2.SETRANGE("AQD Cust Rebate G/L Account");
                IF GLAccount2.FINDLAST THEN
                    LastGLAccountNo := GLAccount2."No.";

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
                GLAccount."AQD Cust Rebate G/L Account" := TRUE;
                GLAccount.INSERT;
                CustomerRebatePayableGLAccount := GLAccount."No.";
            END;

            GLAccount2.RESET;
            GLAccount2.SETRANGE("Account Type", GLAccount2."Account Type"::Posting);
            GLAccount2.SETRANGE("Income/Balance", GLAccount2."Income/Balance"::"Income Statement");
            GLAccount2.SETRANGE("Account Category", GLAccount2."Account Category"::Expense);
            GLAccount2.SETRANGE("AQD Cust Rebate G/L Account", TRUE);
            IF GLAccount2.FindLast() THEN
                CustomerRebateExpenseGLAccount := GLAccount2."No."
            ELSE BEGIN
                GLAccount2.SETRANGE("AQD Cust Rebate G/L Account");
                IF GLAccount2.FINDLAST THEN
                    LastGLAccountNo := GLAccount2."No.";

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
                GLAccount."AQD Cust Rebate G/L Account" := TRUE;
                GLAccount.INSERT;
                CustomerRebateExpenseGLAccount := GLAccount."No.";
            END;

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
                CustomerRebateProgramCode."Rebate Payable AC" := CustomerRebatePayableGLAccount;
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
                CustomerRebateProgramCode."Rebate Payable AC" := CustomerRebatePayableGLAccount;
                CustomerRebateProgramCode.INSERT(TRUE);
            END;
            //"Entity Type", "Entity No.", "Territory Code", "Line Type", "No.", "Variant Code", 
            //"Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount"
            IF NOT CustomerSalesRebateSetup.GET(CustomerSalesRebateSetup."Entity Type"::Customer,
                '',
                '',
                CustomerSalesRebateSetup."Line Type"::Item,
                '',
                '',
                'ALL-UNIT',
                0D,
                '',
                0,
                0)
            THEN BEGIN
                CustomerSalesRebateSetup.Init();
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

            //"Entity Type", "Entity No.", "Territory Code", "Line Type", "No.", "Variant Code", 
            //"Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount"
            IF NOT CustomerSalesRebateSetup.GET(CustomerSalesRebateSetup."Entity Type"::Customer,
                '',
                '',
                CustomerSalesRebateSetup."Line Type"::Item,
                '',
                '',
                'ALL-PCT',
                0D,
                '',
                0,
                0)
            THEN BEGIN
                CustomerSalesRebateSetup.Init();
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

        end;
    end;

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