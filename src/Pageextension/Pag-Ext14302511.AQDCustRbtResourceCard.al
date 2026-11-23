pageextension 14302511 "AQD CustRbt Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
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
                Group("AQD AcumensCustomerClaim")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                    ObsoleteTag = 'Deprecated in v25.1023.1.45';
                    Visible = false;
                    Caption = 'Customer Claim';
                    field("AQD Vendor Claim Enabled"; Rec."AQD Customer Claim Enabled")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}

