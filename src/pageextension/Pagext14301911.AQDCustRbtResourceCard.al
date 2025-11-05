pageextension 14301911 "AQD CustRbt Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                group(CustomerRebate)
                {
                    Caption = 'Rebate';
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
                    field("AQD Use Cust Rebate Setup From"; Rec."AQD Use Cust Rebate Setup From")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate Enabled";
                        Enabled = Rec."AQD Customer Rebate Enabled";
                    }
                }
            }
        }
    }
}

