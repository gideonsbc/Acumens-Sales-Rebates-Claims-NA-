pageextension 14302527 "AQDCustRbt PostedSalesCrMemos" extends "Posted Sales Credit Memos"
{
    actions
    {
        addafter("&Navigate")
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
                Caption = 'Acumens Sales Rebates & Claims';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
            }
        }
    }
}

