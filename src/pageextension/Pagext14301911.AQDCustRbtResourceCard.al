pageextension 14301911 "AQD CustRbt Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Customer Rebatable"; Rec."AQD Customer Rebate Enabled")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rebate Category Code"; Rec."AQD Cust Rebate Category Code")
                {
                    ApplicationArea = All;
                    Editable = Rec."AQD Customer Rebate Enabled";
                    Enabled = Rec."AQD Customer Rebate Enabled";
                }
            }
        }
    }
}

