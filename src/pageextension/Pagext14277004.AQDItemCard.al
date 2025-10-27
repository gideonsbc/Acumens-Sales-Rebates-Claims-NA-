pageextension 14277004 "AQD Item Card" extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                group("Customer Rebate")
                {
                    Caption = 'Customer Rebate';

                    field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebatable")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Enabled';
                    }
                }
                group("Vendor Rebate")
                {
                    Caption = 'Vendor Rebate';

                    field("AQD Vendor Rebatable"; Rec."AQD Vendor Rebatable")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Enabled';
                    }
                    // field("AQD Vendor Rebate Type"; Rec."AQD Vendor Rebate Type")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Rebate Type';
                    // }
                    // field("AQD Vendor Rebate %"; Rec."AQD Vendor Rebate %")
                    // {
                    //     ApplicationArea = All;
                    //     Editable = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
                    //     Enabled = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
                    //     Caption = 'Rebate %';
                    // }
                    // field("AQD Ven Rebate Amount Per Qty"; Rec."AQD Ven Rebate Amount Per Qty")
                    // {
                    //     ApplicationArea = All;
                    //     Editable = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
                    //     Enabled = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
                    //     Caption = 'Rebate per Quantity';
                    // }
                    field("AQD Rebate Category Code"; Rec."AQD Rebate Category Code")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Vendor Rebatable";
                        Enabled = Rec."AQD Vendor Rebatable";
                    }
                    field("AQD Use Rebate Setup From"; Rec."AQD Use Rebate Setup From")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Vendor Rebatable";
                        Enabled = Rec."AQD Vendor Rebatable";
                    }
                    field("AQD Rebate Cost Posting Type"; Rec."AQD Rebate Posting Type")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Vendor Rebatable" AND (Rec."AQD Use Rebate Setup From" = Rec."AQD Use Rebate Setup From"::Item);
                        Enabled = Rec."AQD Vendor Rebatable" AND (Rec."AQD Use Rebate Setup From" = Rec."AQD Use Rebate Setup From"::Item);
                    }
                }
            }
        }
    }
    actions
    {
        addafter("Set Special Discounts")
        {
            action("AQD Setup Sales Rebates")
            {
                ApplicationArea = All;
                Caption = 'Setup Sales Rebates';
                Image = LineDiscount;
                RunObject = Page "AQD Sales Rebates Setup";
                RunPageLink = "Line Type" = filter(Item), "No." = FIELD("No.");
            }
            action("AQD Set Purchase Rebates")
            {
                ApplicationArea = All;
                Caption = 'Set Purchase Rebate Rates';
                Image = Setup;
                Visible = not ExtendedPriceEnabled;
                RunObject = Page "AQD Vendor Rebate Rates";
                RunPageLink = "No." = field("No.");
                RunPageView = sorting("No.");
            }
        }
        addlast(Category_Category6)
        {
            actionref("AQD SetSalesRebates"; "AQD Setup Sales Rebates") { }
            actionref("AQD SetPurchaseRebates"; "AQD Set Purchase Rebates") { }
        }
    }
}


