pageextension 14301926 "AQDCustRbt PostedSalesInvoices" extends "Posted Sales Invoices"
{
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
            group("Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
                //actionref("AQD UpdateRebate_AER"; "AQD Update Rebate") { }
            }
        }
    }
}

