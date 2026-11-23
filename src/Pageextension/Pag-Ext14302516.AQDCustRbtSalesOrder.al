pageextension 14302516 "AQD CustRbt Sales Order" extends "Sales Order"
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
                Caption = 'Acumens Sales Rebates';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
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
                            SalesLine.DeleteAll();
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
                Group("AQD AcumensCustomerClaim")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                    ObsoleteTag = 'Deprecated in v25.1023.1.45';
                    Visible = false;
                    Caption = 'Customer Claim';
                    field("AQD Claim Type"; AQDRemovedClaimValue)
                    {
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                        ObsoleteTag = 'Deprecated in v25.1023.1.47';
                        ApplicationArea = All;
                    }
                    field("AQD Claim Errors"; AQDRemovedClaimValue)
                    {
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                        ObsoleteTag = 'Deprecated in v25.1023.1.47';
                        ApplicationArea = All;
                    }
                    group("AQD AQDClaim Info")
                    {
                        ShowCaption = FALSE;
                        Editable = ClaimEditable;
                        Enabled = ClaimEditable;
                        Visible = FullClaimFieldVisible;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                        ObsoleteTag = 'Deprecated in v25.1023.1.47';
                    }
                }
                group("AQD Claims")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                    ObsoleteTag = 'Deprecated in v25.1023.1.45';
                    Visible = false;
                    ShowCaption = FALSE;
                    part("AQD CustomerClaims"; "AQD Customer Claims")
                    {
                        ApplicationArea = All;
                        Caption = 'Claims';
                        Editable = false;
                        SubPageLink = "Order No." = Field("No.");
                    }
                }
            }
        }
    }
    actions
    {
        addafter("O&rder")
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
                        CustomerRebateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
                    begin
                        OnBeforeRebatePreviewAction(Rec);
                        clear(CustomerRebateCalcPreview);
                        CustomerRebateCalcPreview.CustomerRebateCalcPreview(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        addafter(Category_Category8)
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

    trigger OnOpenPage()
    BEGIN
        IF NOT ClaimSetup.GET THEN
            ClaimSetup.INIT;

        CreateClaimVisible := ClaimSetup."Create Claim On" = ClaimSetup."Create Claim On"::Manual; // This is for full Price Claim Only
    END;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeRebatePreviewAction(var SalesHeader: Record "Sales Header")
    begin
    end;

    var
        AQDRemovedClaimValue: Text;
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        ClaimEditable: Boolean;
        FullClaimFieldVisible: Boolean;
        CreateClaimVisible: Boolean;
}