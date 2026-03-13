pageextension 14302525 "AQDCustRbt Posted SalesInvoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Shipping and Billing")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                Editable = false;

                Group(AcumensCustomerClaim)
                {
                    Caption = 'Customer Claim';


                    field("AQD AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD CR Territory Code"; Rec."AQD CR Territory Code")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Customer Rebate No."; Rec."AQD Customer Rebate No")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Customer Rebate Status"; Rec."AQD Customer Rebate Status")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Rebate Entry Created"; Rec."AQD Cust Rebate Entry Created")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Rebate Last Changed By"; Rec."AQD Cust Rebate LastChangedBy")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Rebate LastChangd DateTime"; Rec."AQD CustRbt LastChangdDateTime")
                    {
                        ApplicationArea = All;
                    }
                }
                Group(AcumensCustomerRebate)
                {
                    Caption = 'Customer Rebate';
                    field("AQD Claim Type"; Rec."AQD CustClaim Claim Type")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                    }
                    field("AQD Claim Errors"; Rec."AQD Claim Errors")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                    }
                    group("AQDClaim Info")
                    {
                        ShowCaption = FALSE;
                        Visible = FullClaimFieldVisible;
                        field("AQM Claim Vendor No."; Rec."AQD Claim Vendor No.")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
                        }
                        FIELD("AQD Claim Status"; Rec."AQD Claim Status")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
                        }
                        FIELD("AQD Vendor Cr. Memo No."; Rec."AQD Vendor Cr. Memo No.")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
                        }
                        FIELD("AQD Claim Approved Amount"; Rec."AQD Claim Approved Amount")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
                        }
                        FIELD("AQD Claim Delivery Commission"; Rec."AQD Claim Delivery Commission")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
                        }
                        FIELD("AQD Claim Purchase Discount"; Rec."AQD Claim Purchase Discount")
                        {
                            ApplicationArea = All;
                            Editable = FALSE;
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
                        SubPageLink = "Posted Invoice No." = Field("No.");
                    }
                }
            }
        }
    }
    actions
    {
        addafter(ShowCreditMemo)
        {
            action("AQD DoNotPayRebate")
            {
                Caption = 'Do Not Pay Rebate';
                Image = StopPayment;
                ApplicationArea = All;
            }
            // action("AQD Update Rebate")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Update Rebate';
            //     Image = EditAdjustments;
            //     RunObject = Page "AQD Edit Invoice Cust Rebate";
            //     RunPageLink = "No." = FIELD("No.");
            // }
            action("Acumens CustClaim UpdateLines")
            {
                ApplicationArea = All;
                Caption = 'Update Lines';
                Image = EditLines;
                RunObject = Page "AQD CustClmPostedSalesInvSubpg";
                RunPageLink = "Document No." = field("No.");
                ToolTip = 'View or add comments for the record.';
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
                BEGIN
                    RecreateClaim := false;
                    ClaimHeader.RESET;
                    ClaimHeader.SetRange("Order No.", Rec."No.");
                    IF ClaimHeader.FindFirst() THEN BEGIN
                        IF NOT Confirm(ClaimAlreadyCreateMessage) THEN
                            MESSAGE(ProcessAbortedMessage)
                        ELSE BEGIN
                            RecreateClaim := TRUE;
                            CLEAR(CustClaimFunctions);
                            CustClaimFunctions.CreateClaimFromPostedSalesInvoice(Rec, TRUE, TRUE, RecreateClaim);
                            CurrPage.Update(FALSE);
                        END;
                    END ELSE BEGIN
                        CustClaimFunctions.CreateClaimFromPostedSalesInvoice(Rec, TRUE, TRUE, RecreateClaim);
                        CurrPage.Update(FALSE);
                    END;
                END;
            }
        }
        addlast(Promoted)
        {
            group("AQD Acumens Claims Rebates")
            {
                Caption = 'Acumens Customer Rebates Claims';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
                //actionref("AQD UpdateRebate_AER"; "AQD Update Rebate") { }
                actionref("Acumens CustClaim UpdateLinesRef"; "Acumens CustClaim UpdateLines") { }
                actionref("Acumens CustClaim ManualCreateRef"; "Acumens CustClaim ManualCreate") { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FullClaimFieldVisible := Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Full Price";
        SetPriceMatchFieldsvisibilityOnLines();
    end;

    trigger OnAfterGetRecord()
    begin
        FullClaimFieldVisible := Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Full Price";
        SetPriceMatchFieldsvisibilityOnLines();
    end;

    procedure SetPriceMatchFieldsvisibilityOnLines()
    begin
        CurrPage.SalesInvLines.Page.SetPriceMatchFieldsvisibility(Rec."AQD CustClaim Claim Type" = Rec."AQD CustClaim Claim Type"::"Price Match");
    end;

    var
        FullClaimFieldVisible: Boolean;
}

