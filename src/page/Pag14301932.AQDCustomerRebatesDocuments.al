page 14301932 "AQD Customer Rebates Documents"
{
    ApplicationArea = All;
    AnalysisModeEnabled = false;
    Caption = 'Customer Rebate Documents';
    CardPageId = "AQD Customer Rebate Document";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Header";
    UsageCategory = Lists;
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
                field("Buy-from Vendor No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor No. field.', Comment = '%';
                }
                field("Buy-from Vendor Name"; Rec."Sell-To Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor Name field.', Comment = '%';
                }
                field("Pay-to Vendor No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pay-to Vendor No. field.', Comment = '%';
                }
                field("Pay-to Name"; Rec."Bill-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Caption = 'Customer Rebate Amount';
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
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post Batch';
                Image = PostBatch;
                Visible = PostEnabled;

                trigger OnAction()
                var
                //VendorRebateHeader: Record "AQD AER Vendor Rebate Header";
                //BatchPostVendorRebate: Report "AQD Batch Post Vendor Rebates";
                begin
                    //VendorRebateHeader.Reset();
                    //VendorRebateHeader.SetRange("No.", Rec."No.");
                    //Clear(BatchPostVendorRebate);
                    //BatchPostVendorRebate.SetTableView(VendorRebateHeader);
                    //BatchPostVendorRebate.Run();
                    IF Rec.FindFirst() THEN;

                    CurrPage.Update(false);
                end;
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
                actionref(Post_Promoted; Post)
                {
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

        PostEnabled := false;
        ApproveEnabled := false;

        if CustomerRebateUserSetup."Rebate Role" in
           [CustomerRebateUserSetup."Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."Rebate Role"::Admin]
        then
            PostEnabled := true;

        if CustomerRebateUserSetup."Rebate Role" in
          [CustomerRebateUserSetup."Rebate Role"::Salesperson,
           CustomerRebateUserSetup."Rebate Role"::"Sales Manager",
           CustomerRebateUserSetup."Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        //GetVendorRebateAmount();
    end;

    trigger OnAfterGetRecord()
    begin
        //GetVendorRebateAmount();

        CustomerRebateUserSetup.Get(UserId);
        PostEnabled := false;
        ApproveEnabled := false;
        if CustomerRebateUserSetup."Rebate Role" in
           [CustomerRebateUserSetup."Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."Rebate Role"::Admin]
        then
            PostEnabled := true;

        if CustomerRebateUserSetup."Rebate Role" in
           [CustomerRebateUserSetup."Rebate Role"::Salesperson,
            CustomerRebateUserSetup."Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    local procedure GetVendorRebateAmount()
    var
        CustomerRebateLines: Record "AQD Customer Rebate Line";
    begin
        VendorRebateAmount := 0;

        CustomerRebateLines.RESET;
        CustomerRebateLines.SetRange("Rebate No.", Rec."No.");
        IF CustomerRebateLines.FindFirst() THEN begin
            repeat
                CustomerRebateLines.CalcFields("Customer Rebate Amount");
                VendorRebateAmount += CustomerRebateLines."Customer Rebate Amount";
            until CustomerRebateLines.Next() = 0;
        end;
    end;

    var
        //VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
        CustomerRebateUserSetup: Record "AQD Customer Rebate User Setup";
        VendorRebateAmount: Decimal;
        PostEnabled, ApproveEnabled : Boolean;
}