pageextension 14301921 "AQD Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter(Billing)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                group(CustomerRebate)
                {
                    Caption = 'Rebate';
                    field("AQD Do Not Pay Rebate"; Rec."AQD Do Not Pay Rebate")
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
}
