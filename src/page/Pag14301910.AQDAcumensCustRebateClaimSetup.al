page 14301910 "AQD Acumens CustRbtClaim Setup"
{
    Caption = 'Acumens Customer Rebates & Claims Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "AQD Acumens CustRbtClaim Setup";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("Customer Rebate")
            {
                Caption = 'General';
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
                    // field("Item Charge Rebate Enabled"; Rec."Item Charge Rebate Enabled")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Item Charge';
                    // }
                    // field("Fixed Asset Rebate Enabled"; Rec."Fixed Asset Rebate Enabled")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Fixed Asset';
                    // }
                }
                field("Customer Rebate Source Code"; Rec."Customer Rebate Source Code")
                {
                    ApplicationArea = All;
                }
                // field(AutoCreateSaleRebateRateonShpt; Rec.AutoCreateSaleRebateRateonShpt)
                // {
                //     ApplicationArea = All;
                // }
                // field(BlockAutoCreatedSaleRebateRate; Rec.BlockAutoCreatedSaleRebateRate)
                // {
                //     ApplicationArea = All;
                //     Enabled = Rec.BlockAutoCreatedSaleRebateRate;
                // }
                // field("Auto Update Rebate Cust Type"; Rec."Auto Update Rebate Cust Type")
                // {
                //     ApplicationArea = All;
                // }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("Exclude Credit Memo"; Rec."Exclude Credit Memo")
                {
                    ApplicationArea = All;
                }
                // field("Rebate Expense G/L Account No."; Rec."Rebate Expense Account")
                // {
                //     ApplicationArea = All;
                // }
                field("Pay Customer Rebate On"; Rec."Post Customer Rebates for")
                {
                    ApplicationArea = All;
                    Visible = FALSE;
                }
                // field("Calculate Cust Rebate using"; Rec."Calculate Cust Rebate using")
                // {
                //     ApplicationArea = All;
                // }
                // field("AQD Rebate Batch Frequency"; Rec."AQD Rebate Batch Frequency")
                // {
                //     ApplicationArea = All;
                // }
                field("Create Rebate per Bill-To Cust"; Rec."Post Rebates by Bill-To Cust")
                {
                    ApplicationArea = All;
                }
                field("Auto Process Customer Rebates"; Rec."Auto Process Customer Rebates")
                {
                    ApplicationArea = All;
                }
                // field("Post Customer Rebate Using"; Rec."Post Customer Rebate Using")
                // {
                //     ApplicationArea = All;
                // }
                field("Min GP% for Customer Rebate"; Rec."Min GP% for Customer Rebate")
                {
                    ApplicationArea = All;
                }
                group(ApprovalAndPosting)
                {
                    Caption = 'Approval And Posting';
                    ShowCaption = false;
                    // field("Require Cust Rebate Approval"; Rec."Require Cust Rebate Approval")
                    // {
                    //     ApplicationArea = All;
                    // }
                    // field("Job Queue Auto Approve Rebate"; Rec."Job Queue Auto Approve Rebate")
                    // {
                    //     ApplicationArea = All;
                    //     Editable = Rec."Require Cust Rebate Approval";
                    // }
                    // field("Auto Post Cust Rebate"; Rec."Auto Post Customer Rebate")
                    // {
                    //     ApplicationArea = All;
                    // }

                    // field("Rebate Cr. Memo Posting"; Rec."Rebate Cr. Memo Posting")
                    // {
                    //     ApplicationArea = All;
                    // }
                }
                group(DefaultSetup)
                {
                    Caption = 'Default Setup';

                    field("Default Rebate Posting Type"; Rec."Default Rebate Posting Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Rebate CUstomer Typ"; Rec."Bill-To Rebate Customer")
                    {
                        ApplicationArea = All;
                    }
                    // field("Default Rebate Customer No."; Rec."Default Rebate Customer No.")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Rebate Customer No.';
                    //     Editable = Rec."Bill-To Rebate Customer" = Rec."Bill-To Rebate Customer"::"Customer Card";
                    // }
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
                // group("Rebate Purchase Journal")
                // {
                //     Caption = 'Rebate Purchase Journal';
                //     Visible = false;
                //     field("Purch Journal Template Name"; Rec."Purch Journal Template Name")
                //     {
                //         Caption = 'Journal Template Name';
                //         ApplicationArea = All;
                //     }
                //     field("Purch Journal Batch Name"; Rec."Purch Journal Batch Name")
                //     {
                //         Caption = 'Journal Batch Name';
                //         ApplicationArea = All;
                //     }
                // }
                // group("Rebate Payment Journal")
                // {
                //     Caption = 'Rebate Payment Journal';
                //     Visible = false;
                //     field("Payment Journal Template Name"; Rec."Payment Journal Template")
                //     {
                //         Caption = 'Journal Template Name';
                //         ApplicationArea = All;
                //     }
                //     field("Payment Journal Batch Name"; Rec."Payment Journal Batch Name")
                //     {
                //         Caption = 'Journal Batch Name';
                //         ApplicationArea = All;
                //     }
                // }
                // group("Rebate General Journal")
                // {
                //     Caption = 'Rebate General Journal';
                //     Visible = false;
                //     field("General Journal Template Name"; Rec."General Journal Template Name")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Journal Template Name';
                //     }
                //     field("General Journal Batch Name"; Rec."General Journal Batch Name")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Journal Batch Name';
                //     }
                // }
            }
            group("Number Series")
            {
                Caption = 'Number Series';
                field("Customer Rebate Nos"; Rec."Customer Rebate Document Nos")
                {
                    ApplicationArea = All;
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
        }
        area(Promoted)
        {
            group(Home)
            {
                Caption = 'HOME';
                actionref(DeleteDefaultSetupsAction_Home; DeleteDefaultSetupsAction) { }
                actionref(ResetNoSeriesAction_Home; ResetNoSeriesAction) { }
                actionref(OldInvoice_Home; "Old Invoice & Credit Memo Non-Rebatable") { }
                actionref(UserSetup_Home; "User Setup") { }
            }
        }
    }

    trigger OnOpenPage()
    var
        SourceCodeRec: Record "Source Code";
    begin
        IF NOT SourceCodeRec.GET('CREBTGNLJL') THEN BEGIN
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
            Rec."Post Customer Rebate Using" := Rec."Post Customer Rebate Using"::"Sales Document";
            Rec."Auto Process Customer Rebates" := TRUE;
            Rec."Default Rebate Posting Type" := Rec."Default Rebate Posting Type"::Inventory;
            Rec.Insert();
            InitializeDefaultSetups();
        end;
    end;

    local procedure InitializeDefaultSetups()
    var
        GLAccount: Record "G/L Account";
    begin
        if Confirm('Do you want to initialize default setups?') then begin
            ResetNoSeries();
            //Rec.Validate("Item Rebate Enabled", true);
            //Rec.Validate("Resource Rebate Enabled", true);
            //Rec.Validate("G/L Account Rebate Enabled", true);
            //Rec.Validate("Item Charge Rebate Enabled", true);
            //Rec.Validate("Fixed Asset Rebate Enabled", true);
            Rec."Post Customer Rebates for" := Rec."Post Customer Rebates for"::"All Invoices";
            //Purchase
            // GenJournalTemplate.Reset();
            // GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Purchases);
            // if GenJournalTemplate.FindFirst() then begin
            //     Rec."Purch Journal Template Name" := GenJournalTemplate.Name;
            //     GenJournalBatch.Reset();
            //     GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
            //     GenJournalBatch.SetRange("AQD Customer Rebate", true);
            //     if GenJournalBatch.FindFirst() then
            //         Rec."Purch Journal Batch Name" := GenJournalBatch.Name
            //     ELSE begin
            //         GenJournalBatch.Init();
            //         GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
            //         GenJournalBatch.Name := 'CUSTREBATE';
            //         GenJournalBatch.Description := 'Purchase Rebate Batch';
            //         GenJournalBatch."AQD Customer Rebate" := TRUE;
            //         GenJournalBatch.Insert();
            //         Rec."Purch Journal Batch Name" := GenJournalBatch.Name;
            //     end;
            // end;
            // //Payment
            // GenJournalTemplate.Reset();
            // GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
            // if GenJournalTemplate.FindFirst() then begin
            //     Rec."Payment Journal Template" := GenJournalTemplate.Name;
            //     GenJournalBatch.Reset();
            //     GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
            //     GenJournalBatch.SetRange("AQD Customer Rebate", true);
            //     if GenJournalBatch.FindFirst() then
            //         Rec."Payment Journal Batch Name" := GenJournalBatch.Name
            //     ELSE begin
            //         GenJournalBatch.Init();
            //         GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
            //         GenJournalBatch.Name := 'CUSTREBATE';
            //         GenJournalBatch.Description := 'Payments Rebate Batch';
            //         GenJournalBatch."AQD Customer Rebate" := TRUE;
            //         GenJournalBatch.Insert();
            //         Rec."Payment Journal Batch Name" := GenJournalBatch.Name;
            //     end;
            // end;
            //Sales
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
            //General
            // GenJournalTemplate.Reset();
            // GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
            // if GenJournalTemplate.FindFirst() then begin
            //     Rec."General Journal Template Name" := GenJournalTemplate.Name;
            //     GenJournalBatch.Reset();
            //     GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
            //     GenJournalBatch.SetRange("AQD Customer Rebate", true);
            //     if GenJournalBatch.FindFirst() then
            //         Rec."General Journal Batch Name" := GenJournalBatch.Name
            //     ELSE begin
            //         GenJournalBatch.Init();
            //         GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
            //         GenJournalBatch.Name := 'CUSTREBATE';
            //         GenJournalBatch.Description := 'General Rebate Batch';
            //         GenJournalBatch."AQD Customer Rebate" := TRUE;
            //         GenJournalBatch.Insert();
            //         Rec."General Journal Batch Name" := GenJournalBatch.Name;
            //     end;
            // end;
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
    begin
        if Confirm('Please note that this action will delete all default settings. Do you want to continue?') then
            Rec.DeleteAll();
    end;

    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
}