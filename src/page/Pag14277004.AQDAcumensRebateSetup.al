page 14277004 "AQD Acumens Rebate Setup"
{
    Caption = 'Acumens Claims & Rebates Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "AQD Acumens Rebate Setup";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("Customer Rebate")
            {
                Caption = 'Customer Rebate';
                field("Item Rebatable"; Rec."Item Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Resource Rebatable"; Rec."Resource Rebatable")
                {
                    ApplicationArea = All;
                }
                field("G/L Account Rebatable"; Rec."G/L Account Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Item Charge Rebatable"; Rec."Item Charge Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Fixed Asset Rebatable"; Rec."Fixed Asset Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Customer Rebate Source Code"; Rec."Customer Rebate Source Code")
                {
                    ApplicationArea = All;
                }
                field(AutoCreateSaleRebateRateonRcpt; Rec.AutoCreateSaleRebateRateonRcpt)
                {
                    ApplicationArea = All;
                }
                field(BlockAutoCreatedSaleRebateRate; Rec.BlockAutoCreatedSaleRebateRate)
                {
                    ApplicationArea = All;
                    Enabled = Rec.BlockAutoCreatedSaleRebateRate;
                }
                field("Auto Update Rebate Cust Type"; Rec."Auto Update Rebate Cust Type")
                {
                    ApplicationArea = All;
                }
                field("Min GP% for Rebate"; Rec."Min GP% for Rebate")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("Prevent Negative Rebate"; Rec."Prevent Negative Rebate")
                {
                    ApplicationArea = All;
                }
                field("Rebate Expense G/L Account No."; Rec."Rebate Expense Account")
                {
                    ApplicationArea = All;
                }
                field("Pay Customer Rebate On"; Rec."Pay Customer Rebate On")
                {
                    ApplicationArea = All;
                }
                group(CustomerDefaultSetup)
                {
                    Caption = 'Default Setup';
                    field("Default Rebate Type"; Rec."Default Rebate Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Type';
                    }
                    field("Default Rebate %"; Rec."Default Rebate %")
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        Caption = 'Rebate %';
                        Editable = Rec."Default Rebate Type" = Rec."Default Rebate Type"::Percentage;
                        Enabled = Rec."Default Rebate Type" = Rec."Default Rebate Type"::Percentage;
                    }
                    field("Default Rebate Per Quantity"; Rec."Default Rebate Per Quantity")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Per Quantity';
                        Editable = Rec."Default Rebate Type" = Rec."Default Rebate Type"::"Per Quantity";
                        Enabled = Rec."Default Rebate Type" = Rec."Default Rebate Type"::"Per Quantity";
                    }
                    field("Default Rebate Payment Method"; Rec."Def. Rebate Payment Method")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Payment Method';

                        trigger OnValidate()
                        begin
                            if Rec."Def. Rebate Payment Method" = Rec."Def. Rebate Payment Method"::Check then begin
                                Rec."Sales Journal Template Name" := '';
                                Rec."Sales Journal Batch Name" := '';
                            end else
                                if Rec."Def. Rebate Payment Method" = Rec."Def. Rebate Payment Method"::"Credit Memo" then begin
                                    Rec."Purch Journal Template Name" := '';
                                    Rec."Purch Journal Batch Name" := '';
                                    Rec."Payment Journal Template" := '';
                                    Rec."Payment Journal Batch Name" := '';
                                end;
                        end;
                    }
                }
                group("Rebate Purchase Journal")
                {
                    Caption = 'Rebate Purchase Journal';
                    field("Purch Journal Template Name"; Rec."Purch Journal Template Name")
                    {
                        Caption = 'Journal Template Name';
                        ApplicationArea = All;
                    }
                    field("Purch Journal Batch Name"; Rec."Purch Journal Batch Name")
                    {
                        Caption = 'Journal Batch Name';
                        ApplicationArea = All;
                    }
                }
                group("Rebate Payment Journal")
                {
                    Caption = 'Rebate Payment Journal';
                    field("Payment Journal Template Name"; Rec."Payment Journal Template")
                    {
                        Caption = 'Journal Template Name';
                        ApplicationArea = All;
                    }
                    field("Payment Journal Batch Name"; Rec."Payment Journal Batch Name")
                    {
                        Caption = 'Journal Batch Name';
                        ApplicationArea = All;
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
                group("Rebate General Journal")
                {
                    Caption = 'Rebate General Journal';
                    field("General Journal Template Name"; Rec."General Journal Template Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                    }
                    field("General Journal Batch Name"; Rec."General Journal Batch Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';
                    }
                }
            }
            group("Vendor Rebate")
            {
                Caption = 'Vendor Rebate';
                field("Vendor Item Rebatable"; Rec."Vendor Item Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Vendor Resource Rebatable"; Rec."Vendor Resource Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Vendor G/L Account Rebatable"; Rec."Vendor G/L Account Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item Charge Rebatable"; Rec."Vendor Item Charge Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Vendor Fixed Asset Rebatable"; Rec."Vendor Fixed Asset Rebatable")
                {
                    ApplicationArea = All;
                }
                field("Calculate Vendor Rebate using"; Rec."Calculate Vendor Rebate using")
                {
                    ApplicationArea = All;
                }
                field("Vendor Rebate Source Code"; Rec."Vendor Rebate Source Code")
                {
                    ApplicationArea = All;
                }
                field(AutoCreatePurRebateSetuponRcpt; Rec.AutoCreatePurRebateRateonRcpt)
                {
                    ApplicationArea = All;
                }
                field(BlockAutoCreatedPurRebateSetup; Rec.BlockAutoCreatedPurRebateRate)
                {
                    ApplicationArea = All;
                    Enabled = Rec.AutoCreatePurRebateRateonRcpt;
                }
                field("Auto Update Rebate Vendor Type"; Rec."Auto Update Rebate Vendor Type")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Batch Frequency"; Rec."AQD Rebate Batch Frequency")
                {
                    ApplicationArea = All;
                }
                field("Vendor Rebate Start Date"; Rec."Vendor Rebate Start Date")
                {
                    ApplicationArea = All;
                }
                field("Use Vendor Rebate Criteria"; Rec."Use Vendor Rebate Criteria")
                {
                    ApplicationArea = All;
                }
                field("Prevent Negative Vendor Rebate"; Rec."Prevent Negative Vendor Rebate")
                {
                    ApplicationArea = All;
                }
                field("Vendor Rebate Expense G/L"; Rec."Vendor Rebate Expense G/L")
                {
                    ApplicationArea = All;
                }
                field("Pay Vendor Rebate On"; Rec."Pay Vendor Rebate On")
                {
                    ApplicationArea = All;
                }
                field("Rebate Cr. Memo Posting"; Rec."Rebate Cr. Memo Posting")
                {
                    ApplicationArea = All;
                }
                group(DefaultSetup)
                {
                    Caption = 'Default Setup';
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
                    field("Default Item Charge No."; Rec."Default Item Charge No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Charge No.';
                    }
                }
                field("Min GP% for Vendor Rebate"; Rec."Min GP% for Vendor Rebate")
                {
                    ApplicationArea = All;
                    Visible = false; // Not In Use
                }
            }
            group("Number Series")
            {
                Caption = 'Number Series';
                group(VendorRebate)
                {
                    Caption = 'Vendor Rebate';
                    field("Vendor Rebate Nos"; Rec."Vendor Rebate Nos")
                    {
                        ApplicationArea = All;
                    }
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
                trigger OnAction()
                var
                    RebateCalculationMgt: Codeunit "AQD Rebate Calculation Mgt";
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
                RunObject = Page "AQD Rebate User Setup";
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
        IF NOT SourceCodeRec.GET('VREBTGNLJL') THEN BEGIN
            SourceCodeRec.Init();
            SourceCodeRec.Code := 'VREBTGNLJL';
            SourceCodeRec.Description := 'Vendor Rebate';
            SourceCodeRec.Insert();
        END;

        IF NOT SourceCodeRec.GET('CREBTGNLJL') THEN BEGIN
            SourceCodeRec.Init();
            SourceCodeRec.Code := 'CREBTGNLJL';
            SourceCodeRec.Description := 'Customer Rebate';
            SourceCodeRec.Insert();
        END;

        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init();
            Rec."Vendor Rebate Source Code" := 'VREBTGNLJL';
            Rec."Customer Rebate Source Code" := 'CREBTGNLJL';
            Rec.Insert();
            InitializeDefaultSetups();
        end;
    end;

    local procedure InitializeDefaultSetups()
    var
        GLAccount: Record "G/L Account";
    begin
        if Confirm('Do you want to Initialize default setups?') then begin
            ResetNoSeries();
            Rec.Validate("Item Rebatable", true);
            Rec.Validate("Resource Rebatable", true);
            Rec.Validate("G/L Account Rebatable", true);
            Rec.Validate("Item Charge Rebatable", true);
            Rec.Validate("Fixed Asset Rebatable", true);
            Rec."Pay Customer Rebate On" := Rec."Pay Customer Rebate On"::"All Invoices";
            Rec."Def. Rebate Payment Method" := Rec."Def. Rebate Payment Method"::Check;
            //Purchase
            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Purchases);
            if GenJournalTemplate.FindFirst() then begin
                Rec."Purch Journal Template Name" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."Purch Journal Batch Name" := GenJournalBatch.Name;
            end;
            //Payment
            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
            if GenJournalTemplate.FindFirst() then begin
                Rec."Payment Journal Template" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."Payment Journal Batch Name" := GenJournalBatch.Name;
            end;
            //Sales
            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Sales);
            if GenJournalTemplate.FindFirst() then begin
                Rec."Sales Journal Template Name" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."Sales Journal Batch Name" := GenJournalBatch.Name;
            end;
            //General
            GenJournalTemplate.Reset();
            GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
            if GenJournalTemplate.FindFirst() then begin
                Rec."General Journal Template Name" := GenJournalTemplate.Name;
                GenJournalBatch.Reset();
                GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
                GenJournalBatch.SetRange("AQD Rebate", true);
                if GenJournalBatch.FindFirst() then
                    Rec."General Journal Batch Name" := GenJournalBatch.Name;
            end;
            Rec."Vendor Rebate Nos" := 'VRB';
            Rec.Modify(true);
        end;
    end;

    local procedure ResetNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Reset();
        if not NoSeries.Get('VRB') then begin
            NoSeries.Init();
            NoSeries.Code := 'VRB';
            NoSeries.Description := 'Vendor Rebate Nos';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            NoSeriesLine.Reset();
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'VRB';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'VRB00001';
            if NoSeriesLine.Insert() then;
        end;
    end;

    local procedure DeleteDefaultSetups()
    begin
        if Confirm('Please note that this action will delete all default settings. Proceed?') then begin
            Rec.DeleteAll();
        end;
    end;

    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
}

