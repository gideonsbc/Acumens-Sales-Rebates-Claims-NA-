page 14301910 "AQD Acumens CustRbtClaim Setup"
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
                        ShowMandatory = TRUE;
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
        GLAccount: Record "G/L Account";
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
                    GenJournalBatch.Init();
                    GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
                    GenJournalBatch.Name := 'CUSTREBATE';
                    GenJournalBatch.Description := 'Sales Rebate Batch';
                    GenJournalBatch."AQD Customer Rebate" := TRUE;
                    GenJournalBatch.Insert();
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name;
                end;
            end;
            Rec."Customer Rebate Document Nos" := 'CRB';
            Rec.Modify(true);
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