pageextension 14302512 "AQD CustRbt G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                group(AcumensCustomerRebate)
                {
                    Caption = 'Customer Rebate';
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
                }
                Group(AcumensCustomerClaim)
                {
                    Caption = 'Customer Claim';

                    field("AQM Customer Claim Enabled"; Rec."AQM Customer Claim Enabled")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}