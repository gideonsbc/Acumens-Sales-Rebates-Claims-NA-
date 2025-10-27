pageextension 14277017 "AQD Gen. Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addafter("Bank Statement Import Format")
        {
            field("AQD AER Rebate"; Rec."AQD Rebate")
            {
                ApplicationArea = All;
            }
        }
    }
}

