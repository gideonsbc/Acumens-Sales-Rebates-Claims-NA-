pageextension 14302526 "AQDCustRbt PostedSalesInvoices" extends "Posted Sales Invoices"
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
        }
        addlast(Promoted)
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
            }
        }
    }
}

