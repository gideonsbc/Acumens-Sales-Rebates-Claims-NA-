page 14302532 "AQD Customer Rebates Documents"
{
    ApplicationArea = All;
    AnalysisModeEnabled = false;
    Caption = 'Sales Rebate Documents';
    CardPageId = "AQD Customer Rebate Document";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Header";
    UsageCategory = Lists;
    SourceTableView = sorting("No.") order(descending);
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Rebate-To Customer No."; Rec."Rebate Pay-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate-To Customer No. field.', Comment = '%';
                }
                field("Rebate-To Name"; Rec."Rebate-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate-To Name Name field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Description field.', Comment = '%';
                }
                field("Commission Type"; Rec."Commission Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the commission is paid to or collected from the customer.', Comment = '%';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.', Comment = '%';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Rebate Amount';
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebate Amount';
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.';
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
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Territory Code field.', Comment = '%';
                    Importance = Additional;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Generate Customer Rebates")
            {
                ApplicationArea = All;
                Caption = 'Generate Customer Rebates';
                Image = CreateDocuments;
                RunObject = report "AQD Generate Customer Rebates";
            }
        }

        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Rebates';

                actionref(Generate_Customer_Rebates_Promoted; "Generate Customer Rebates")
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CustomerRebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if CustomerRebateUserSetup."AQD Cust Rebate Rebate Role" = CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Salesperson then
            CustomerRebateUserSetup.TestField("AQD Cust Rbt SP Code Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt SP Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code", CustomerRebateUserSetup."AQD Cust Rbt SP Code Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt GlobalDim1Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 1 Code", CustomerRebateUserSetup."AQD Cust Rbt GlobalDim1Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt GlobalDim2Filter" <> '' then
            Rec.SetFilter("Shortcut Dimension 2 Code", CustomerRebateUserSetup."AQD Cust Rbt GlobalDim2Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt Location Filter" <> '' then
            Rec.SetFilter("Location Code", CustomerRebateUserSetup."AQD Cust Rbt Location Filter");
        if CustomerRebateUserSetup."AQD Cust Rbt State Filter" <> '' then
            Rec.SetFilter("Territory Code", CustomerRebateUserSetup."AQD Cust Rbt State Filter");
        Rec.SetRange(Preview, false);
        Rec.FilterGroup(0);
    end;

    var
        CustomerRebateUserSetup: Record "User Setup";
}