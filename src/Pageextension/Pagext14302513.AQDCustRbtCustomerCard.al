pageextension 14302513 "AQD CustRbt Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                Group(AcumensCustomerRebate)
                {
                    Caption = 'Customer Rebate';
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
                Group(AcumensCustomerClaim)
                {
                    Caption = 'Customer Claim';
                    field("AQM Vendor Claim Customer"; Rec."AQM Customer Claim Customer")
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
                Caption = 'Acumens Customer Rebate';

                action("AQD Customer Rebate Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Rebates Rates';
                    Image = LineDiscount;
                    RunObject = Page "AQD CustRbt SalesRebates Setup";
                    RunPageLink = "Entity Type" = CONST(Customer),
                                  "Entity No." = FIELD("No.");
                    RunPageView = SORTING("Entity Type", "Entity No.");
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
                Caption = 'Acumens Customer Rebate';
                actionref("AQD CustomerRebateSetup_Promoted"; "AQD Customer Rebate Setup") { }
            }
        }
    }
}

