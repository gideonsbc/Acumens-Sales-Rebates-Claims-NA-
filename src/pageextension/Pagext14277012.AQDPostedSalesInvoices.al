pageextension 14277012 "AQD Posted Sales Invoices" extends "Posted Sales Invoices"
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
            action("AQD Update Rebate")
            {
                ApplicationArea = All;
                Caption = 'Update Rebate';
                Image = EditAdjustments;
                RunObject = Page "AQD Edit Invoice Rebate";
                RunPageLink = "No." = FIELD("No.");
            }
        }
        addlast(Promoted)
        {
            group("AQD Acumens Claims & Rebates")
            {
                Caption = 'Acumens Claims & Rebates';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
                actionref("AQD UpdateRebate_AER"; "AQD Update Rebate") { }
            }
        }
    }
}

