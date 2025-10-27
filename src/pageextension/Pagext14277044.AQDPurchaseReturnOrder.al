pageextension 14277044 "AQD Purchase Return Order" extends "Purchase Return Order"
{
    layout
    {
        addafter("Order Date")
        {
            FIELD(AQDRebateOrderDate2; Rec."AQD Rebate Order Date")
            {
                ApplicationArea = All;
            }
        }
        addafter("Shipping and Payment")
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                field("AQD Do Not Pay Rebate"; Rec."AQD Do Not Pay Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Vendor No"; Rec."AQD Rebate Vendor No")
                {
                    ApplicationArea = All;
                }
                FIELD(AQDRebateOrderDate; Rec."AQD Rebate Order Date")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Last Changed By"; Rec."AQD Rebate Last Changed By")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate LastChangd DateTime"; Rec."AQD Rebate LastChangd DateTime")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}