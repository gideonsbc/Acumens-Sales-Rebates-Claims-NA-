pageextension 14302522 "AQD CustRbt Sales Return Order" extends "Sales Return Order"
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

        addafter(SalesLines)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates & Claims';
                field("AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD Cust Rebate Program Code"; Rec."AQD Cust Rebate Program Code")
                {
                    ApplicationArea = All;
                }
                field("AQD Marketplace Code"; Rec."AQD Marketplace Code")
                {
                    ApplicationArea = All;
                }
                field("AQD Disallow Off-Inv Rebate"; Rec."AQD Disallow Off-Inv Rebate")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        SalesLine: Record "Sales Line";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);

                        SalesLine.Reset();
                        SalesLine.SetRange("Document Type", Rec."Document Type");
                        SalesLine.SetRange("Document No.", Rec."No.");
                        SalesLine.SetRange("AQD Off-Invoice Rebate", true);
                        if SalesLine.FindSet() then begin
                            repeat
                                SalesLine.Delete();
                            until SalesLine.Next() = 0;
                        end;
                        CurrPage.Update();
                    end;
                }
                // field("AQD Off-Invoice Calc. Level"; Rec."AQD Off-Invoice Calc. Level")
                // {
                //     ApplicationArea = All;
                //     Editable = Rec.Status = Rec.Status::Open;
                // }
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
                Caption = 'Acumens Sales Rebate';
                action("AQD Customer Rebate Info")
                {
                    ApplicationArea = All;
                    Caption = 'Preview Sales Rebate';
                    Image = Statistics;

                    trigger OnAction()
                    var
                        CustomerRebateCalcPreview: Codeunit "AQD Sales Rebate Calc Preview";
                    begin
                        OnBeforeRebatePreviewAction(Rec);
                        clear(CustomerRebateCalcPreview);
                        CustomerRebateCalcPreview.CustomerRebateCalcPreview(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        addafter(Category_Category11)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Sales Rebate';
                actionref("AQD Customer Rebate Info_Promoted"; "AQD Customer Rebate Info")
                {
                }
            }
        }
    }

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRebatePreviewAction(var SalesHeader: Record "Sales Header")
    begin
    end;
}

