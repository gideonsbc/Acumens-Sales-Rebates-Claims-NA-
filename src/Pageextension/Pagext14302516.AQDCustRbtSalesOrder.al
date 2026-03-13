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

                Group(AcumensCustomerRebate)
                {
                    Caption = 'Customer Rebate';
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
                Group(AcumensCustomerClaim)
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
                    group("AQDClaim Info")
                    {
                        ShowCaption = FALSE;
                        Editable = ClaimEditable;
                        Enabled = ClaimEditable;
                        Visible = FullClaimFieldVisible;

                        field("AQM Claim Vendor No."; Rec."AQD Claim Vendor No.")
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
                group(Claims)
                {
                    ShowCaption = FALSE;
                    part(CustomerClaims; "AQD Customer Claims")
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
                    begin
                        clear(CustomerRebateCalcPreview);
                        CustomerRebateCalcPreview.CustomerRebateCalcPreview(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Acumens CustClaim ManualCreate")
                {
                    ApplicationArea = All;
                    Caption = 'Create Claim';
                    Image = CreateCreditMemo;

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
                actionref("Acumens CustClaim ManualCreateRef"; "Acumens CustClaim ManualCreate") { }
            }
        }
    }
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

    var
        ClaimEditable: Boolean;
        FullClaimFieldVisible: Boolean;
}