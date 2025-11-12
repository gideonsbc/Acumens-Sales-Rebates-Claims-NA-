pageextension 14301935 "AQD Cust Rbt User Setup Ext" extends "AQD CF User Setup card"
{
    layout
    {
        addafter("AQD Acumens Cash Flow Solutions")
        {
            Group(AQDCustomerRebate)
            {
                Caption = 'Customer Rebate';

                field("AQD Cust Rbt Rebate Role"; Rec."AQD Cust Rbt Rebate Role")
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