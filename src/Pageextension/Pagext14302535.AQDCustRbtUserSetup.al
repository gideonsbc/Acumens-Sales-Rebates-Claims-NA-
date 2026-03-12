pageextension 14302535 "AQD Cust Rbt User Setup Ext" extends "AQD CF User Setup card"
{
    layout
    {
        addafter("AQD Acumens Cash Flow Solutions")
        {
            Group(AQDCustomerRebate)
            {
                Caption = 'Acumens Customer Rebate';

                field("AQD Cust Rbt Rebate Role"; Rec."AQD Cust Rbt Rebate Role")
                {
                    ApplicationArea = All;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Rebate role is moved to a new field in User Setup table.';
                    ObsoleteTag = 'Removed From 25.1023.0.3';
                    Visible = false;
                }
                field("AQD Cust Rebate Rebate Role"; Rec."AQD Cust Rebate Rebate Role")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rbt Location Filter"; Rec."AQD Cust Rbt Location Filter")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rbt SP Code Filter"; Rec."AQD Cust Rbt SP Code Filter")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rbt GlobalDim1Filter"; Rec."AQD Cust Rbt GlobalDim1Filter")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rbt GlobalDim2Filter"; Rec."AQD Cust Rbt GlobalDim2Filter")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rbt State Filter"; Rec."AQD Cust Rbt State Filter")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}