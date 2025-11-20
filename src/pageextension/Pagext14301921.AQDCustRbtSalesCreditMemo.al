pageextension 14301921 "AQD CustRbt Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter("Document Date")
        {
            field("AQD Customer Rebate OrderDate"; Rec."AQD Customer Rebate Order Date")
            {
                ApplicationArea = All;
            }
        }

        addafter(Billing)
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Customer Rebate Order Date"; Rec."AQD Customer Rebate Order Date")
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
