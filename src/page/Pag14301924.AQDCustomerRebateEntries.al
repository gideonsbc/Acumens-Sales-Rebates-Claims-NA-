page 14301924 "AQD Customer Rebate Entries"
{
    Caption = 'Customer Rebate Entries';
    ApplicationArea = All;
    UsageCategory = Lists;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "AQD Customer Rebate Entry";
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Item Category Code"; Rec."Rebate Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                }
                field("Document Posting Date"; Rec."Document Posting Date")
                {
                    ApplicationArea = All;
                }
                field(State; Rec."State")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Billl-to Customer Name"; Rec."Billl-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Open; Rec.Open)
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Payable; Rec.Payable)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Profit Amount"; Rec."Profit Amount")
                {
                    ApplicationArea = All;
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    Editable = false;
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Rebate Per Quantity"; Rec."Rebate Per Quantity")
                {
                    Editable = false;
                }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Remaining Rebate Amount"; Rec."Remaining Rebate Amount")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Do Not Pay Rebate"; Rec."Do Not Pay Rebate")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Rebate Register No."; Rec."Rebate Register No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    Editable = false;
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
        }
    }

    trigger OnOpenPage()
    begin
        CustomerRebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if CustomerRebateUserSetup."Rebate Role" = CustomerRebateUserSetup."Rebate Role"::Salesperson then
            CustomerRebateUserSetup.TestField("Salesperson Code Filter");
        if CustomerRebateUserSetup."Salesperson Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code", CustomerRebateUserSetup."Salesperson Code Filter");
        if CustomerRebateUserSetup."Global Dimension 1 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", CustomerRebateUserSetup."Global Dimension 1 Filter");
        if CustomerRebateUserSetup."Global Dimension 2 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", CustomerRebateUserSetup."Global Dimension 2 Filter");
        if CustomerRebateUserSetup."Location Filter" <> '' then
            Rec.SetFilter("Location Code", CustomerRebateUserSetup."Location Filter");
        if CustomerRebateUserSetup."State Filter" <> '' then
            Rec.SetFilter(State, CustomerRebateUserSetup."State Filter");
        Rec.FilterGroup(0);
        "Do Not PayEnable" := Rec.GetFilter("Remaining Rebate Amount") <> '';
        "Do Not PayVisible" := Rec.GetFilter("Remaining Rebate Amount") <> '';
    end;

    var
        CustomerRebateUserSetup: Record "AQD Customer Rebate User Setup";
        Navigate: Page Navigate;
        "Do Not PayVisible": Boolean;
        "Do Not PayEnable": Boolean;
        UserIsRebateAdmin: Boolean;
        SalespersonFilter: Code[250];
}