page 14277045 "AQD Vendor Rebates"
{
    ApplicationArea = All;
    AnalysisModeEnabled = false;
    Caption = 'Vendor Rebate Documents';
    CardPageId = "AQD Vendor Rebate";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Vendor Rebate Header";
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
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor No. field.', Comment = '%';
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor Name field.', Comment = '%';
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pay-to Vendor No. field.', Comment = '%';
                }
                field("Pay-to Name"; Rec."Pay-to Name")
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
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Rebate Amount';
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Rebate Amount';
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.';
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
            action("Generate Vendor Rebates")
            {
                ApplicationArea = All;
                Caption = 'Generate Vendor Rebates';
                Image = CreateDocuments;
                RunObject = report "AQD Generate Vendor Rebs";
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
                    BatchPostVendorRebate: Report "AQD Batch Post Vendor Rebates";
                begin
                    //VendorRebateHeader.Reset();
                    //VendorRebateHeader.SetRange("No.", Rec."No.");

                    Clear(BatchPostVendorRebate);
                    //BatchPostVendorRebate.SetTableView(VendorRebateHeader);
                    BatchPostVendorRebate.Run();
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

                actionref(Generate_Vendor_Rebates_Promoted; "Generate Vendor Rebates")
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

        PostEnabled := false;
        ApproveEnabled := false;

        if RebateSetup."Rebate Role" in
           [RebateSetup."Rebate Role"::"Purchase Manager",
            RebateSetup."Rebate Role"::Admin]
        then
            PostEnabled := true;

        if RebateSetup."Rebate Role" in
          [RebateSetup."Rebate Role"::Purchaser,
           RebateSetup."Rebate Role"::"Purchase Manager",
           RebateSetup."Rebate Role"::Admin]
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

        RebateSetup.Get(UserId);
        PostEnabled := false;
        ApproveEnabled := false;
        if RebateSetup."Rebate Role" in
           [RebateSetup."Rebate Role"::"Purchase Manager",
            RebateSetup."Rebate Role"::Admin]
        then
            PostEnabled := true;

        if RebateSetup."Rebate Role" in
           [RebateSetup."Rebate Role"::Purchaser,
            RebateSetup."Rebate Role"::"Purchase Manager",
            RebateSetup."Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    local procedure GetVendorRebateAmount()
    var
        VendorRebateLines: Record "AQD Vendor Rebate Line";
    begin
        VendorRebateAmount := 0;

        VendorRebateLines.RESET;
        VendorRebateLines.SetRange("Rebate No.", Rec."No.");
        IF VendorRebateLines.FindFirst() THEN begin
            repeat
                VendorRebateLines.CalcFields("Vendor Rebate Amount");
                VendorRebateAmount += VendorRebateLines."Vendor Rebate Amount";
            until VendorRebateLines.Next() = 0;
        end;
    end;

    var
        VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
        RebateUserSetup: Record "AQD Rebate User Setup";
        VendorRebateAmount: Decimal;
        PostEnabled, ApproveEnabled : Boolean;
        RebateSetup: Record "AQD Rebate User Setup";
}