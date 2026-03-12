pageextension 14302520 "AQD CustRbt Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Document Date")
        {
            field("AQD Customer Rebate OrderDate"; Rec."AQD Customer Rebate Order Date")
            {
                ApplicationArea = All;
            }
        }
        addafter(SalesLines)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';

                field("AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Customer Rebate Order Date"; Rec."AQD Customer Rebate Order Date")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Last Changed By"; Rec."AQD Rebate Last Changed By")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate LastChangd DateTime"; Rec."AQD Rebate LastChangd DateTime")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addafter("&Invoice")
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Customer Rebate';
                action("AQD Customer Rebate Info")
                {
                    ApplicationArea = All;
                    Caption = 'Preview Customer Rebate';
                    Image = Statistics;

                    trigger OnAction()
                    var
                        CustomerRebateCalcPreview: Codeunit "AQD Cust Rebate Calc Preview";
                    begin
                        clear(CustomerRebateCalcPreview);
                        CustomerRebateCalcPreview.CustomerRebateCalcPreview(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        addafter(Category_Category7)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Customer Rebate';
                actionref("AQD Customer Rebate Info_Promoted"; "AQD Customer Rebate Info")
                {
                }
            }
        }
    }
}
