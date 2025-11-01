page 14301934 "AQD Customer Rebate Details"
{
    Caption = 'Customer Rebate Document Details';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Details";
    DeleteAllowed = false;
    InsertAllowed = false;

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
                    ToolTip = 'Specifies the value of the Rebate Item Category Code field.', Comment = '%';
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
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
                field("Calculated Line Rebate Amount"; Rec."Calculated Line Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("AQD Use Cust Rebate Setup From"; Rec."AQD Use Cust Rebate Setup From")
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
                    Caption = 'Changed By';
                    ToolTip = 'Specifies the value of the Rebate Amount Changed By field.', Comment = '%';
                }
                field("Rebate Amount Changed DateTime"; Rec."Rebate Amount Changed DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'Changed Date Time';
                    ToolTip = 'Specifies the value of the Rebate Amount Changed DateTime field.', Comment = '%';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field.', Comment = '%';
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
    end;

    var
        CustomerRebateUserSetup: Record "AQD Customer Rebate User Setup";
}