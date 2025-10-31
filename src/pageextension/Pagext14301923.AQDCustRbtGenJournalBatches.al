pageextension 14301923 "AQD Gen. Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addafter("Bank Statement Import Format")
        {
            field("AQD Customer Rebate"; Rec."AQD Customer Rebate")
            {
                ApplicationArea = All;
            }
        }
    }
}

