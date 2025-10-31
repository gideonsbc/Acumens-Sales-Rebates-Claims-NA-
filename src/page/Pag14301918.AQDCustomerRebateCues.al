page 14301918 "AQD Customer Rebate Cues"
{
    Caption = 'Rebate Cues';
    PageType = CardPart;
    SourceTable = "AQD Customer Rebate Cues";
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
                    DrillDownPageId = "AQD Cust Rebate Doc Entries";
                }
                field("Rebate Entries"; Rec."Rebate Entries")
                {
                    Caption = 'Rebate Entries';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Customer Rebate Entries";
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
        RebateUserSetup: Record "AQD Customer Rebate User Setup";
}