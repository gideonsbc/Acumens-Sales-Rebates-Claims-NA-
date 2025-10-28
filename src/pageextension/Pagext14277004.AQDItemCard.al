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
        }
        addlast(Category_Category6)
        {
            actionref("AQD SetSalesRebates"; "AQD Setup Sales Rebates") { }
        }
    }
}


