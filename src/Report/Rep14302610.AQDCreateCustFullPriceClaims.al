report 14302610 "AQD Create CustFullPriceClaims"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    ApplicationArea = All;
    Caption = 'Create Customer Price Match Claims';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Bill-to Customer No.", "Location Code", "Responsibility Center";

            trigger OnAfterGetRecord()
            begin

            end;

            trigger OnPostDataItem()
            begin
                CLEAR(ClaimMgt);
                ClaimMgt.SetCreateFullPriceClaimsParameters("Sales Header", FALSE, RecreateClaim, TRUE);
                ClaimMgt.RUN;
            end;

            trigger OnPreDataItem()
            begin
                CurrReport.BREAK;
            end;
        }
    }

    requestpage
    {
        Caption = 'Create Customer Price Match Claims';

        layout
        {
            area(Content)
            {
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    procedure SetRecreate(RecreateClaim_P: Boolean)
    begin
        RecreateClaim := RecreateClaim_P;
    end;

    var
        ClaimMgt: Codeunit "AQD Customer Claim Management";
        RecreateClaim: Boolean;
}