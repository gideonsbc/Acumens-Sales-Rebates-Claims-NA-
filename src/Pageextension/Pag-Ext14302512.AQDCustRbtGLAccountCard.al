pageextension 14302512 "AQD CustRbt G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';
                group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
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
                Group("AQD AcumensCustomerClaim")
                {
                    Caption = 'Customer Claim';

                    field("AQD Customer Claim Enabled"; Rec."AQD Customer Claim Enabled")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}