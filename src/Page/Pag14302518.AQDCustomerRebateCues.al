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
                Caption = 'Rebate';
                field("Rebate Document"; Rec."Rebate Documents")
                {
                    Caption = 'Sales Rebate Documents';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Customer Rebates Documents";
                }
                field("Posted Rebate Document"; Rec."Posted Rebate Documents")
                {
                    Caption = 'Posted Sales Rebate Documents';
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Posted Customer Rebates";
                }
            }
            cuegroup("Full Price Claims")
            {
                Caption = 'Full Price Claim';
                field("Full Price Claims - Created"; Rec."Full Price Claims - Created")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Full Price Cust Claim List";
                }
                field("Full Price Claims - Submitted"; Rec."Full Price Claims - Submitted")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Full Price Cust Claim List";
                }
                field("Full Price Claims - Approved"; Rec."Full Price Claims - Approved")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD Full Price Cust Claim List";
                }
                field("Full Price Claims - Completed"; Rec."Full Price Claims - Completed")
                {
                    ApplicationArea = All;
                    DrillDownPageId = AQDCmpltedFullPriceCustClmList;
                }
            }
            cuegroup("Price Match Claims")
            {
                Caption = 'Price Match Claim';
                field("Price Match Claims - Created"; Rec."Price Match Claims - Created")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD PriceMatch Cust Claim List";
                }
                field("Price Match Claims - Submitted"; Rec."Price Match Claims - Submitted")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD PriceMatch Cust Claim List";
                }
                field("Price Match Claims - Approved"; Rec."Price Match Claims - Approved")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD PriceMatch Cust Claim List";
                }
                field("Price Match Claims - Completed"; Rec."Price Match Claims - Completed")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "AQD CmpltdPriceMthCustClmList";
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