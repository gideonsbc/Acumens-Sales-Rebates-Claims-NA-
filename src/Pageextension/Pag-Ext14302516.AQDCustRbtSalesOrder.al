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
                Caption = 'Acumens Customer Rebates & Claims';

                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Customer Rebate';
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
                Group("AQD AcumensCustomerClaim")
                {
                    Caption = 'Customer Claim';
                    field("AQD Claim Type"; Rec."AQD CustClaim Claim Type")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Claim Errors"; Rec."AQD Claim Errors")
                    {
                        ApplicationArea = All;
                    }
                    group("AQD AQDClaim Info")
                    {
                        ShowCaption = FALSE;
                        Editable = ClaimEditable;
                        Enabled = ClaimEditable;
                        Visible = FullClaimFieldVisible;

                        field("AQD Claim Vendor No."; Rec."AQD Claim Vendor No.")
                        {
                            ApplicationArea = All;
                            Editable = ClaimEditable;
                            Enabled = ClaimEditable;
                        }
                        FIELD("AQD Claim Status"; Rec."AQD Claim Status")
                        {
                            ApplicationArea = All;
                        }
                        FIELD("AQD Vendor Cr. Memo No."; Rec."AQD Vendor Cr. Memo No.")
                        {
                            ApplicationArea = All;
                        }
                        FIELD("AQD Claim Approved Amount"; Rec."AQD Claim Approved Amount")
                        {
                            ApplicationArea = All;
                        }
                        FIELD("AQD Claim Delivery Commission"; Rec."AQD Claim Delivery Commission")
                        {
                            ApplicationArea = All;
                        }
                        FIELD("AQD Claim Purchase Discount"; Rec."AQD Claim Purchase Discount")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
                group("AQD Claims")
                {
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
                Caption = 'Acumens Customer Rebate';
                action("AQD Customer Rebate Info")
                {
                    ApplicationArea = All;
                    Caption = 'Preview Customer Rebate';
                    Image = Statistics;

                    trigger OnAction()
                    var
                        CustomerRebateCalcPreview: Codeunit "AQD Cust Rebate Calc Preview";
                        CustomerRebateCalcMgt: Codeunit "AQD Sales Rebate Rate Calc Mgt";
                    begin
                        OnBeforeRebatePreviewAction(Rec);
                        clear(CustomerRebateCalcPreview);
                        CustomerRebateCalcPreview.CustomerRebateCalcPreview(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("AQD Acumens CustClaim ManualCreate")
                {
                    ApplicationArea = All;
                    Caption = 'Create Claim';
                    Image = CreateCreditMemo;
                    Visible = CreateClaimVisible;

                    trigger OnAction()
                    var
                        ClaimHeader: Record "AQD Customer Claim Header";
                        CustClaimFunctions: Codeunit "AQD Cust Claim Event And Func";
                        RecreateClaim: Boolean;
                        ClaimAlreadyCreateMessage: Label 'Claim is already created. Do you want to recreate it?';
                        ProcessAbortedMessage: Label 'Process is aborted to respect user selection';
                    begin
                        RecreateClaim := false;
                        ClaimHeader.RESET;
                        ClaimHeader.SetRange("Order No.", Rec."No.");
                        IF ClaimHeader.FindFirst() THEN BEGIN
                            IF NOT Confirm(ClaimAlreadyCreateMessage) THEN
                                MESSAGE(ProcessAbortedMessage)
                            ELSE BEGIN
                                RecreateClaim := TRUE;
                                CustClaimFunctions.CreateClaimFromSalesOrder(Rec, TRUE, TRUE, RecreateClaim);
                                CurrPage.Update(FALSE);
                            END;
                        END ELSE BEGIN
                            CustClaimFunctions.CreateClaimFromSalesOrder(Rec, TRUE, TRUE, RecreateClaim);
                            CurrPage.Update(FALSE);
                        END;
                    end;
                }
            }
        }

        addafter(Category_Category8)
        {
            group("AQD Customer Rebate GroupRef")
            {
                Caption = 'Acumens Customer Rebate';
                actionref("AQD Customer Rebate Info_Promoted"; "AQD Customer Rebate Info")
                {
                }
                actionref("AQD Acumens CustClaim ManualCreateRef"; "AQD Acumens CustClaim ManualCreate") { }
            }
        }
    }

    trigger OnOpenPage()
    BEGIN
        IF NOT ClaimSetup.GET THEN
            ClaimSetup.INIT;

        CreateClaimVisible := ClaimSetup."Create Claim On" = ClaimSetup."Create Claim On"::Manual; // This is for full Price Claim Only
    END;

    trigger OnAfterGetCurrRecord()
    begin
        ClaimEditable := Rec."AQD Claim Status".AsInteger() < Rec."AQD Claim Status"::Submitted.AsInteger();
        FullClaimFieldVisible := Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Full Price";
        SetPriceMatchFieldsvisibilityOnLines();
    end;

    trigger OnAfterGetRecord()
    begin
        ClaimEditable := Rec."AQD Claim Status".AsInteger() < Rec."AQD Claim Status"::Submitted.AsInteger();
        FullClaimFieldVisible := Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Full Price";
        SetPriceMatchFieldsvisibilityOnLines();
    end;

    procedure SetPriceMatchFieldsvisibilityOnLines()
    begin
        CurrPage.SalesLines.Page.SetPriceMatchFieldsvisibility(Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Price Match");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRebatePreviewAction(var SalesHeader: Record "Sales Header")
    begin
    end;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        ClaimEditable: Boolean;
        FullClaimFieldVisible: Boolean;
        CreateClaimVisible: Boolean;
}