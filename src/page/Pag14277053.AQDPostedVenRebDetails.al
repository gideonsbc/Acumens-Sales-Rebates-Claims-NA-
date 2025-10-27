page 14277053 "AQD Posted Vend Rebate Details"
{
    Caption = 'Posted Vendor Rebate Details';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    SourceTable = "AQD Posted Ven Reb Details";
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Rebate No."; Rec."Rebate No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Line No."; Rec."Rebate Line No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line No. field.', Comment = '%';
                }
                field("Rebate Item Category Code"; Rec."Rebate Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Category Code field.', Comment = '%';
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Program Code field.', Comment = '%';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field.', Comment = '%';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field.', Comment = '%';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Type field.', Comment = '%';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                }
                field("Rebate Per Quantity"; Rec."Rebate Per Quantity")
                {
                    ApplicationArea = All;
                }
                // field("Rebate Amount"; Rec."Rebate Amount")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Rebate Amount field.', Comment = '%';
                // }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount Incl. Tax';
                    ToolTip = 'Specifies the value of the Amount Including VAT field.', Comment = '%';
                }
                field("Calculated Line Rebate Amount"; Rec."Calculated Line Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.', Comment = '%';
                }
                field("AQD Use Rebate Setup From"; Rec."AQD Use Rebate Setup From")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Use Rebate Setup From field.', Comment = '%';
                }
                field("AQD Rebate Posting Type"; Rec."AQD Rebate Posting Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Rebate Posting Type field.', Comment = '%';
                }
                field(Exclude; Rec.Exclude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exclude field.', Comment = '%';
                }
                field("Rebate Amount Changed By"; Rec."Rebate Amount Changed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Amount Changed By field.', Comment = '%';
                }
                field("Rebate Amount Changed DateTime"; Rec."Rebate Amount Changed DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Amount Changed DateTime field.', Comment = '%';
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchaser Code field.', Comment = '%';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.', Comment = '%';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.', Comment = '%';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        RebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Purchaser then
            RebateUserSetup.TestField("Salesperson Code Filter");
        if RebateUserSetup."Salesperson Code Filter" <> '' then
            Rec.SetFilter("Purchaser Code", RebateUserSetup."Salesperson Code Filter");
        if RebateUserSetup."Global Dimension 1 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", RebateUserSetup."Global Dimension 1 Filter");
        if RebateUserSetup."Global Dimension 2 Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", RebateUserSetup."Global Dimension 2 Filter");
        if RebateUserSetup."Location Filter" <> '' then
            Rec.SetFilter("Location Code", RebateUserSetup."Location Filter");
        if RebateUserSetup."State Filter" <> '' then
            Rec.SetFilter(State, RebateUserSetup."State Filter");
        Rec.FilterGroup(0);
    end;

    var
        RebateUserSetup: Record "AQD Rebate User Setup";
}