pageextension 14301925 "AQDCustRbt Posted SalesInvoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Shipping and Billing")
        {
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                Editable = false;

                field("AQD AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
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
                field("AQD Customer Rebate Status"; Rec."AQD Customer Rebate Status")
                {
                    ApplicationArea = All;
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
        }
        addlast(Promoted)
        {
            group("AQD Acumens Claims Rebates")
            {
                Caption = 'Acumens Customer Rebates Claims';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
                //actionref("AQD UpdateRebate_AER"; "AQD Update Rebate") { }
            }
        }
    }
}

