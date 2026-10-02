pageextension 14302509 "AQD CustRbt Item Card" extends "Item Card"
{
    layout
    {
        addafter(Replenishment)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
                    field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
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
                    field("AQD Vendor Claim Enabled"; Rec."AQD Customer Claim Enabled")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Contract Price"; Rec."AQD Contract Price")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    actions
    {
        addafter(PricesandDiscounts)
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Sales Rebate';

                action("AQD Customer Rebate Rates")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Rebate Rates';
                    Image = Setup;
                    RunObject = Page "AQD Sales Rebates Rate Setup";
                    RunPageLink = "Line Type" = CONST(Item);
                }
                // action("AQD Item attributes Values")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Get Item Attributes Values';
                //     trigger OnAction()
                //     var
                //         SalesRebateRateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
                //         Result: Dictionary of [Code[20], Text];
                //     begin
                //         Result := SalesRebateRateCalcMgt.GetItemAttributeValues(Rec."No.");
                //         Message(Format(Result));
                //     end;
                // }
            }
        }
        addafter(Category_Category6)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Sales Rebate';
                actionref(AQDCustomerRebateRatesRef; "AQD Customer Rebate Rates") { }
                //actionref(AQDItemattributesValues; "AQD Item attributes Values") { }
            }
        }
    }
}