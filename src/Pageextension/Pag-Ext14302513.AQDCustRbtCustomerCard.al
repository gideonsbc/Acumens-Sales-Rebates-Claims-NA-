pageextension 14302513 "AQD CustRbt Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
                    field("AQD Enroll for Rebate"; Rec."AQD Enroll for Cust Rebate")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Cust Rebate Customer No."; Rec."AQD Cust Rebate Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Rebate Bill-To Customer No.';
                        Editable = Rec."AQD Enroll for Cust Rebate";
                        Enabled = Rec."AQD Enroll for Cust Rebate";
                    }
                    field("AQD Customer Rebate Category"; Rec."AQD Cust Rebate Category")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Enroll for Cust Rebate";
                        Enabled = Rec."AQD Enroll for Cust Rebate";
                    }
                    field("AQD Calculation Date"; Rec."AQD CustRbt Calculation Date")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Enroll for Cust Rebate";
                        Enabled = Rec."AQD Enroll for Cust Rebate";
                    }
                    field("AQD Territory Code"; Rec."Territory Code")
                    {
                        ApplicationArea = All;
                    }
                }
                Group("AQD AcumensCustomerClaim")
                {
                    Caption = 'Customer Claim';
                    field("AQD Vendor Claim Customer"; Rec."AQD Customer Claim Customer")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Default Claim Type"; Rec."AQD Default Claim Type")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
        addafter(ActionGroupCRM)
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Sales Rebate';

                action("AQD Customer Rebate Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebates Rates';
                    Image = LineDiscount;
                    RunObject = Page "AQD Sales Rebates Rate Setup";
                    RunPageLink = "Customer Type" = CONST(Customer),
                                  "Customer No. Filter" = FIELD("No.");
                    RunPageView = SORTING("Customer Type", "Customer No. Filter");
                }
                action("AQD Customer Contract Prices")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Contract Prices';
                    Image = PriceWorksheet;
                    RunObject = Page "AQD Customer Contract Prices";
                    RunPageLink = "Customer No" = FIELD("No.");
                }
            }
        }
        addafter(Category_Synchronize)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Sales Rebate';
                actionref("AQD CustomerRebateSetup_Promoted"; "AQD Customer Rebate Setup") { }
            }
        }
    }
}

