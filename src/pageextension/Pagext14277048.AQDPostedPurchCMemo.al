pageextension 14277048 "AQD Posted Purch. C. Memo" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addafter("Posting Date")
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
                Editable = false;
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
                field("AQD Rebate Status"; Rec."AQD Rebate Status")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate No."; Rec."AQD Rebate No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}