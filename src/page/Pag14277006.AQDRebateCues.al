page 14277006 "AQD Rebate Cues"
{
    Caption = 'Rebate Cues';
    PageType = CardPart;
    SourceTable = "AQD Rebate Cues";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            cuegroup("Customer Rebate Activities")
            {
                Caption = 'Customer';
                field("Rebate Document Entries"; Rec."Rebate Document Entries")
                {
                    Caption = 'Rebate Document Entries';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Rebate Document Entry";
                }
                field("Rebate Entries"; Rec."Rebate Entries")
                {
                    Caption = 'Rebate Entries';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Rebate Entries";
                }
                field("Rebate Register"; Rec."Rebate Register")
                {
                    Caption = 'Rebate Register';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Rebate Register";
                }
            }
            cuegroup("Vendor Rebate Activities")
            {
                Caption = 'Vendor';
                field("Vendor Rebates"; Rec."Vendor Rebates")
                {
                    Caption = 'Vendor Rebates';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Vendor Rebates";
                }
                field("Vendor Rebate Details"; Rec."Vendor Rebate Details")
                {
                    Caption = 'Vendor Rebate Details';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Vendor Rebate Details";
                    Visible = false;
                }
                field("Posted Vendor Rebates"; Rec."Posted Vendor Rebates")
                {
                    Caption = 'Posted Vendor Rebates';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Posted Vendor Rebates";
                }
                field("Posted Vendor Rebate Details"; Rec."Posted Vendor Rebate Details")
                {
                    Caption = 'Posted Vendor Rebate Details';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Posted Vend Rebate Details";
                    Visible = false;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        ///Rec.SetRange("Date Filter", 0D, WorkDate());

        RebateUserSetup.Get(UserId);
        Rec.FilterGroup(2);
        if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then
            RebateUserSetup.TestField("Salesperson Code Filter");
        if RebateUserSetup."Salesperson Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code Filter", RebateUserSetup."Salesperson Code Filter");
        if RebateUserSetup."Global Dimension 1 Filter" <> '' then
            Rec.SetFilter("Global Dimension 1 Filter", RebateUserSetup."Global Dimension 1 Filter");
        if RebateUserSetup."Global Dimension 2 Filter" <> '' then
            Rec.SetFilter("Global Dimension 2 Filter", RebateUserSetup."Global Dimension 2 Filter");
        if RebateUserSetup."Location Filter" <> '' then
            Rec.SetFilter("Location Filter", RebateUserSetup."Location Filter");
        if RebateUserSetup."State Filter" <> '' then
            Rec.SetFilter("State Filter", RebateUserSetup."State Filter");
        Rec.FilterGroup(0);
    end;

    var
        RebateUserSetup: Record "AQD Rebate User Setup";
}