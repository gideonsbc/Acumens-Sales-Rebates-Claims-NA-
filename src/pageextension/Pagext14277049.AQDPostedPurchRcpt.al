pageextension 14277049 "AQD Posted Purchase Receipt" extends "Posted Purchase Receipt"
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
        addafter(Shipping)
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
                field("AQD Rebate No."; Rec."AQD Rebate No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}