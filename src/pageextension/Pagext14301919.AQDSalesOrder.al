pageextension 14301919 "AQD Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Invoice Details")
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

