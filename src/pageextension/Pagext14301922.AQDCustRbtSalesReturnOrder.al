pageextension 14301922 "AQD CustRbt Sales Return Order" extends "Sales Return Order"
{
    layout
    {
        addafter("Order Date")
        {
            field("AQD Customer Rebate OrderDate"; Rec."AQD Customer Rebate Order Date")
            {
                ApplicationArea = All;
            }
        }

        addafter("Shipping and Billing")
        {
            group("Acumens Customer Rebate and Claims")
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
        addafter("&Return Order")
        {
            group("AQD Customer Rebate Group")
            {
                Caption = 'Acumens Customer Rebate';
                action("AQD Customer Rebate Info")
                {
                    ApplicationArea = All;
                    Caption = 'Preview Customer Rebate';
                    Image = SalesInvoice;

                    trigger OnAction()
                    var
                    //VendorRebateCalcPreview: Codeunit "AQD Vendor Rebate Calc Preview";
                    begin
                        //clear(VendorRebateCalcPreview);
                        //VendorRebateCalcPreview.VendorRebateCalcPreview(Rec);
                        //CurrPage.Update(false);
                    end;
                }
            }
        }

        addafter(Category_Category11)
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

