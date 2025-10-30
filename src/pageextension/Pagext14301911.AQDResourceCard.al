pageextension 14301911 "AQD Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';

                group("Customer Regate")
                {
                    Caption = 'Customer Rebate';
                    field("AQD Customer Rebatable"; Rec."AQD Customer Rebate Enabled")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}

