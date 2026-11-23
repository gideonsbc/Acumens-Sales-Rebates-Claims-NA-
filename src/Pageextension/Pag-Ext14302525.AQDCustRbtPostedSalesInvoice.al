pageextension 14302525 "AQDCustRbt Posted SalesInvoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Shipping and Billing")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Sales Rebates';
                Editable = false;

                Group("AQD AcumensCustomerClaim")
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
                Group("AQD AcumensCustomerRebate")
                {
                    Caption = 'Sales Rebate';
                    field("AQD Cust Rebate Program Code"; Rec."AQD Cust Rebate Program Code")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Marketplace Code"; Rec."AQD Marketplace Code")
                    {
                        ApplicationArea = All;
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
                        SubPageLink = "Posted Invoice No." = Field("No.");
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
                        ObsoleteTag = 'Deprecated in v25.1023.1.45';
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
        }
        addlast(Promoted)
        {
            group("AQD Acumens Claims Rebates")
            {
                Caption = 'Acumens Sales Rebates';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
    end;

    trigger OnAfterGetRecord()
    begin
    end;

    trigger OnOpenPage()
    BEGIN
        IF NOT ClaimSetup.GET THEN
            ClaimSetup.INIT;

        // This is for Price Match Claim Only
        CreateClaimVisible := ClaimSetup."Price Match Create Claim On" = ClaimSetup."Price Match Create Claim On"::Manual;
    END;

    var
        AQDRemovedClaimValue: Text;
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        FullClaimFieldVisible: Boolean;
        CreateClaimVisible: Boolean;
}

