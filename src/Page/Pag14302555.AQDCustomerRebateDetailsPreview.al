page 14302555 "AQD CustRebate Details Preview"
{
    Caption = 'Customer Rebate Details Preview';
    PageType = Listpart;
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Details";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = FALSE;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line No. field.', Comment = '%';
                    Visible = false;
                }
                field("Rebate Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Entity Type field.', Comment = '%';
                }
                field("Rebate Entity No."; Rec."Entity No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Entity No. field.', Comment = '%';
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
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rebate Type field.', Comment = '%';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                }
                field("Rebate Per Unit"; Rec."Rebate Per Unit")
                {
                    ApplicationArea = All;
                }
                field("Calculated Line Rebate Amount"; Rec."Calculated Line Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                    Visible = false;
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("AQD Cust Rebate Posting Type"; Rec."AQD Cust Rebate Posting Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Custstomer Rebate Posting Type field.', Comment = '%';
                    Visible = false;
                }
                field(Ineligible; Rec.Ineligible)
                {
                    ApplicationArea = All;
                    Caption = 'Ineligible';
                    ToolTip = 'Specifies the value of the Ineligible field.', Comment = '%';
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
        Rec.FilterGroup(0);
    end;

    var
        CustomerRebateUserSetup: Record "User Setup";
}