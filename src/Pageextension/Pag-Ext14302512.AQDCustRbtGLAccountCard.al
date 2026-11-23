pageextension 14302512 "AQD CustRbt G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates';
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
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                    ObsoleteTag = 'Deprecated in v25.1023.1.45';
                    Visible = false;
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