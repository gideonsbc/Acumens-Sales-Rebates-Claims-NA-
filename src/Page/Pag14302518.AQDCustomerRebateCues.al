page 14302518 "AQD Customer Rebate Cues"
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
                field("Rebate Document"; Rec."Rebate Documents")
                {
                    Caption = 'Rebate Documents';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Customer Rebates Documents";
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
        if RebateUserSetup."AQD Cust Rebate Rebate Role" = RebateUserSetup."AQD Cust Rebate Rebate Role"::Salesperson then
            RebateUserSetup.TestField("AQD Cust Rbt SP Code Filter");
        if RebateUserSetup."AQD Cust Rbt SP Code Filter" <> '' then
            Rec.SetFilter("Salesperson Code Filter", RebateUserSetup."AQD Cust Rbt SP Code Filter");
        if RebateUserSetup."AQD Cust Rbt GlobalDim1Filter" <> '' then
            Rec.SetFilter("Global Dimension 1 Filter", RebateUserSetup."AQD Cust Rbt GlobalDim1Filter");
        if RebateUserSetup."AQD Cust Rbt GlobalDim2Filter" <> '' then
            Rec.SetFilter("Global Dimension 2 Filter", RebateUserSetup."AQD Cust Rbt GlobalDim2Filter");
        if RebateUserSetup."AQD Cust Rbt Location Filter" <> '' then
            Rec.SetFilter("Location Filter", RebateUserSetup."AQD Cust Rbt Location Filter");
        if RebateUserSetup."AQD Cust Rbt State Filter" <> '' then
            Rec.SetFilter("State Filter", RebateUserSetup."AQD Cust Rbt State Filter");
        Rec.FilterGroup(0);
    end;

    var
        RebateUserSetup: Record "User Setup";
}