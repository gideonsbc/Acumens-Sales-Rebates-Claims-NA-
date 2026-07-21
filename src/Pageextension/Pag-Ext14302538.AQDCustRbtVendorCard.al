pageextension 14302538 "AQD CustRbt Vendor Card" extends "Vendor Card"
{
    layout
    {
        addbefore(Payments)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
                    field("AQD Customer Rebate"; Rec."AQD Customer Rebate")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Territory Filter"; Rec."AQD Territory Filter")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate";
                        Enabled = Rec."AQD Customer Rebate";

                        trigger OnDrillDown()
                        var
                            CRVenEmpTerittoryFilter: Record "AQD CR Vend Emp Territory Filt";
                            CRVenEmpTerittoryFilterDrilldown: Page "AQD CR VenEmpTeritoryFiltDrill";
                        begin
                            CRVenEmpTerittoryFilter.Reset();
                            CRVenEmpTerittoryFilter.SETRANGE("Type", CRVenEmpTerittoryFilter.Type::Vendor);
                            CRVenEmpTerittoryFilter.SETRANGE("No.", Rec."No.");

                            CLEAR(CRVenEmpTerittoryFilterDrilldown);
                            CRVenEmpTerittoryFilterDrilldown.SetCalledFromMasterPage(true);
                            CRVenEmpTerittoryFilterDrilldown.SetTableView(CRVenEmpTerittoryFilter);
                            CRVenEmpTerittoryFilterDrilldown.RunModal();
                        end;
                    }
                    field("AQD Customer Filter"; Rec."AQD Customer Filter")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate";
                        Enabled = Rec."AQD Customer Rebate";

                        trigger OnDrillDown()
                        var
                            CRVenEmpCustomerFilter: Record "AQD CR Vend Emp Customer Filt";
                            CRVenEmpCustomerFilterDrilldown: Page "AQD CR Vend Emp Customer Filt";
                        begin
                            CRVenEmpCustomerFilter.Reset();
                            CRVenEmpCustomerFilter.SETRANGE("Type", CRVenEmpCustomerFilter.Type::Vendor);
                            CRVenEmpCustomerFilter.SETRANGE("No.", Rec."No.");

                            CLEAR(CRVenEmpCustomerFilterDrilldown);
                            CRVenEmpCustomerFilterDrilldown.SetCalledFromMasterPage(true);
                            CRVenEmpCustomerFilterDrilldown.SetTableView(CRVenEmpCustomerFilter);
                            CRVenEmpCustomerFilterDrilldown.RunModal();
                        end;
                    }
                }
                Group("AQD AcumensCustomerClaim")
                {
                    Caption = 'Customer Claim';
                    field("AQD Claim Vendor"; Rec."AQD Claim Vendor")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Claim From Customer No."; Rec."AQD Claim From Customer No.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    actions
    {
        addafter("&Purchases")
        {
            action("AQD Sales Rebates")
            {
                ApplicationArea = All;
                Caption = 'Sales Rebates';
                Image = LineDiscount;
                RunObject = Page "AQD CustRbt SalesRebates Setup";
                RunPageLink = "Entity Type" = CONST("Vendor Commission"),
                              "Entity No." = FIELD("No.");
                RunPageView = SORTING("Entity Type", "Entity No.");
            }
        }
        addlast("Category_Prices & Discounts")
        {
            actionref("AQD Rebates_Promoted"; "AQD Sales Rebates") { }
        }
    }
}