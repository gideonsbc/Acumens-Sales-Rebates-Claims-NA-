page 14277013 "AQD Rebate Document Entry"
{
    Caption = 'Rebate Document Entries';
    ApplicationArea = All;
    UsageCategory = Lists;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Cust Rebate Document Entry";
    SourceTableView = SORTING("Rebate Code", "Document Type", "Document No.");
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                }
                field("Rebate Code"; Rec."Rebate Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Document Posting Date"; Rec."Document Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Sell-to Customer Name")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Do Not Pay Rebate"; Rec."Do Not Pay Rebate")
                {
                    ApplicationArea = All;
                }
                field("<Base Amount>"; Rec."Base Amount")
                {
                    Caption = 'Base Amount';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("<Remaining Amount>"; Rec."Remaining Rebate Amount")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("<Amount Due>"; Rec."Amount Due")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("<Open>"; Rec.Open)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Payable; Rec.Payable)
                {
                    ApplicationArea = All;
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("<Vendor Document No.>"; Rec."Vendor Document No.")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("<Vendor Ledger Entry No.>"; Rec."Vendor Ledger Entry No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Payment Vender Ledg. Entry No."; Rec."Payment V. Ledg. Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Cust. Ledger Entry Open"; Rec."Cust. Ledger Entry Open")
                {
                    ApplicationArea = All;
                }
                field("Cust. Ledger Amount"; Rec."Cust. Ledger Amount")
                {
                    ApplicationArea = All;
                }
                field("Cust. Ledger Remaining Amount"; Rec."Cust. Ledger Rem. Amount")
                {
                    ApplicationArea = All;
                }
                field("Check No."; Rec."Check No.")
                {
                    ApplicationArea = All;
                }
                field("<Journal Template Name>"; Rec."Journal Template Name")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("<Journal Batch Name>"; Rec."Journal Batch Name")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("<Journal Line No.>"; Rec."Journal Line No.")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Approved"; Rec."Rebate Approved")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Approved Date"; Rec."Rebate Approved Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Approved By"; Rec."Rebate Approved By")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Paid"; Rec."Rebate Paid")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Paid Date"; Rec."Rebate Paid Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Paid By"; Rec."Rebate Paid By")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Navigate.SetDoc(Rec."Document Posting Date", Rec."Document No.");
                    Navigate.Run;
                end;
            }
            action(DoNotPayRebate)
            {
                Caption = 'Do Not Pay Rebate';
                Image = StopPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = DoNotPayRebateVisible;
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then
            RebateUserSetup.TestField("Salesperson Code Filter");
        if RebateUserSetup."Salesperson Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code", RebateUserSetup."Salesperson Code Filter");
        if RebateUserSetup."Global Dimension 1 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", RebateUserSetup."Global Dimension 1 Filter");
        if RebateUserSetup."Global Dimension 2 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", RebateUserSetup."Global Dimension 2 Filter");
        if RebateUserSetup."Location Filter" <> '' then
            Rec.SetFilter("Location Code", RebateUserSetup."Location Filter");
        if RebateUserSetup."State Filter" <> '' then
            Rec.SetFilter(State, RebateUserSetup."State Filter");
        Rec.FilterGroup(0);

        "Do Not PayEnable" := Rec.GetFilter("Vendor Ledger Entry No.") <> '';
        "Do Not PayVisible" := Rec.GetFilter("Vendor Ledger Entry No.") <> '';
        "Amount To PayEnable" := Rec.GetFilter("Vendor Ledger Entry No.") <> '';
        "Amount To PayVisible" := Rec.GetFilter("Vendor Ledger Entry No.") <> '';
        DoNotPayRebateVisible := not HideDoNotPayRebateAction;
    end;

    var
        RebateUserSetup: Record "AQD Rebate User Setup";
        RebateLdgrEntry: Record "AQD Rebate Entry";
        Navigate: Page Navigate;
        "Do Not PayEnable": Boolean;
        "Do Not PayVisible": Boolean;
        "Amount To PayVisible": Boolean;
        "Amount To PayEnable": Boolean;
        HideDoNotPayRebateAction: Boolean;
        DoNotPayRebate: Boolean;
        SalespersonFilter: Code[250];
        UserIsRebateAdmin: Boolean;
        DoNotPayRebateVisible: Boolean;

    local procedure DoNotPayOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    procedure HideDoNotPayRebate(HideDoNotPayRebateAction_P: Boolean)
    begin
        HideDoNotPayRebateAction := HideDoNotPayRebateAction_P;
    end;
}

