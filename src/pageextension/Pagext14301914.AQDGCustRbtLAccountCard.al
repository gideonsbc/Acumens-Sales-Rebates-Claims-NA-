pageextension 14301914 "AQD CustRbt G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                field("AQD Customer Rebate Enable"; Rec."AQD Customer Rebate Enabled")
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