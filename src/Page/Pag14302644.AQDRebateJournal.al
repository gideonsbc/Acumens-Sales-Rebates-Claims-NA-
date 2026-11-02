page 14302644 "AQD Rebate Journal"
{
    ApplicationArea = All;
    Caption = 'Rebate Journal';
    AdditionalSearchTerms = 'manual rebate, rebate entry';
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "AQD Rebate Journal Line";
    UsageCategory = Tasks;

    AboutTitle = 'About Rebate Journal';
    AboutText = 'Review and post rebates sent from calculated Sales Rebate Documents, or enter rebate amounts manually. Posting creates a Posted Sales Rebate Document for each Sales Rebate No., and for each Document No. of manual lines, without recalculating the rebate.';

    layout
    {
        area(Content)
        {
            field(CurrentBatchName; CurrentBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the rebate journal batch.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    RebateJournalBatch: Record "AQD Rebate Journal Batch";
                begin
                    CurrPage.SaveRecord();
                    if RebateJournalBatch.Get(CurrentBatchName) then;
                    if Page.RunModal(0, RebateJournalBatch) <> Action::LookupOK then
                        exit(false);
                    Text := RebateJournalBatch.Name;
                    exit(true);
                end;

                trigger OnValidate()
                var
                    RebateJournalBatch: Record "AQD Rebate Journal Batch";
                begin
                    RebateJournalBatch.Get(CurrentBatchName);
                    CurrPage.SaveRecord();
                    SetBatchFilter();
                    CurrPage.Update(false);
                end;
            }
            repeater(Lines)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date of the rebate.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document date of the rebate.';
                    Visible = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the sales document the rebate relates to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the journal document number. Lines with the same document number are posted as one Sales Rebate document.';
                    // trigger OnDrillDown()
                    // var
                    //     RebateMgtEventsFunctions: Codeunit "AQD CustRbtMgt EventsFunctions";
                    // begin
                    //     clear(RebateMgtEventsFunctions);
                    //     RebateMgtEventsFunctions.ShowPostedDocument(Rec."Document Type", Rec."Document No.");
                    // end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an external reference for the rebate line.';
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer who purchased the goods the rebate is based on.';
                }
                field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the sell-to customer.';
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bill-to customer of the sales the rebate is based on.';
                    Visible = false;
                }
                field("Bill-To Customer Name"; Rec."Bill-To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the bill-to customer.';
                    Visible = false;
                }
                field("Rebate Pay-To Customer No."; Rec."Rebate Pay-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer that receives the rebate credit.';
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate program. The program''s Rebate Expense account is used when posting.';
                }
                field("Commission Type"; Rec."Commission Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the commission is paid out or collected. All lines with the same Document No. must have the same commission type.';
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the rebate is paid to a customer, or is a vendor or employee commission.';
                }
                field("Entity No."; Rec."Entity No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer, vendor or employee that the rebate is paid to.';
                }
                field("Cust Rebate Posting Type"; Rec."Cust Rebate Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the rebate is posted as an expense or as an item charge to inventory.';
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the item, G/L account or resource the rebate relates to.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item, G/L account or resource the rebate relates to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the rebate line.';
                }
                field("Rebate Item Category Code"; Rec."Rebate Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item category of the rebate.';
                    Visible = false;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number of the sales document the rebate relates to.';
                    Visible = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales order number the rebate relates to.';
                    Visible = false;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales order line number the rebate relates to.';
                    Visible = false;
                }
                field("Rebate Order Date"; Rec."Rebate Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order date used for the rebate.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity the rebate is based on.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price the rebate is based on.';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit cost the rebate is based on.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales amount the rebate is based on.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales amount including VAT the rebate is based on.';
                    Visible = false;
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies for reference how the rebate was determined.';
                    Visible = false;
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies for reference the rebate percentage used.';
                    Visible = false;
                }
                field("Rebate Per Unit"; Rec."Rebate Per Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies for reference the rebate per unit used.';
                    Visible = false;
                }
                field("CustRbt Rate Type"; Rec."CustRbt Rate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies for reference the rebate rate type.';
                    Visible = false;
                }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the rebate amount to post. The amount is posted as entered; no rebate calculation is performed.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the rebate.';
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the posted document the item charge is assigned to when the posting type is Inventory.';
                    Visible = false;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted document the item charge is assigned to when the posting type is Inventory.';
                    Visible = false;
                }
                field("Applies-to Doc. Line No."; Rec."Applies-to Doc. Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted document line the item charge is assigned to when the posting type is Inventory.';
                    Visible = false;
                }
                field("Marketplace Code"; Rec."Marketplace Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the marketplace of the rebate.';
                    Visible = false;
                }
                field("Customer Rebate Category"; Rec."Customer Rebate Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate category of the customer.';
                    Visible = false;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment terms of the rebate.';
                    Visible = false;
                }
                field("Rebate Payment Method Code"; Rec."Rebate Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how the rebate is paid.';
                    Visible = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the salesperson of the rebate.';
                    Visible = false;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the responsibility center of the rebate.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location of the rebate.';
                    Visible = false;
                }
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the territory of the rebate.';
                    Visible = false;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the state of the rebate.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'P&ost';
                Image = PostOrder;
                ShortcutKey = 'F9';
                ToolTip = 'Post the rebate journal lines. A Posted Sales Rebate Document is created for each Sales Rebate No., and for each Document No. of manual lines.';

                trigger OnAction()
                var
                    RebateJnlPost: Codeunit "AQD Rebate Jnl.-Post";
                    ConfirmPostQst: Label 'Do you want to post the rebate journal lines in batch %1?', Comment = '%1 = Batch Name';
                    PostedMsg: Label 'The journal lines were successfully posted. Posted Sales Rebate Document(s): %1', Comment = '%1 = Posted Rebate Nos.';
                begin
                    CurrPage.SaveRecord();
                    if not Confirm(ConfirmPostQst, false, CurrentBatchName) then
                        exit;
                    RebateJnlPost.PostBatch(CurrentBatchName);
                    Message(PostedMsg, RebateJnlPost.GetPostedRebateNos());
                    CurrPage.Update(false);
                end;
            }
        }
        // area(Navigation)
        // {
        //     action(PostedSalesRebates)
        //     {
        //         ApplicationArea = All;
        //         Caption = 'Posted Sales Rebates';
        //         Image = PostedOrder;
        //         RunObject = page "AQD Posted Customer Rebates";
        //         ToolTip = 'View the posted sales rebate documents.';
        //     }
        // }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Post_Promoted; Post)
                {
                }
                // actionref(PostedSalesRebates_Promoted; PostedSalesRebates)
                // {
                // }
            }
        }
    }

    trigger OnOpenPage()
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
    begin
        RebateJournalBatch.CreateDefaultBatch();
        if (CurrentBatchName = '') or not RebateJournalBatch.Get(CurrentBatchName) then begin
            RebateJournalBatch.FindFirst();
            CurrentBatchName := RebateJournalBatch.Name;
        end;
        SetBatchFilter();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Batch Name" := CurrentBatchName;
        Rec.SetUpNewLine(xRec);
    end;

    var
        CurrentBatchName: Code[10];

    procedure SetBatchName(NewBatchName: Code[10])
    begin
        CurrentBatchName := NewBatchName;
    end;

    local procedure SetBatchFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Batch Name", CurrentBatchName);
        // Lines sent from a Sales Rebate Document are posted automatically; users only work with manual entries here.
        Rec.SetRange("Rebate No.", '');
        Rec.FilterGroup(0);
        if Rec.FindFirst() then;
    end;
}
