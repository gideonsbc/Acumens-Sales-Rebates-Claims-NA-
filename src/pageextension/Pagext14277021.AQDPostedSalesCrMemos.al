pageextension 14277021 "AQD Posted Sales Cr. Memos" extends "Posted Sales Credit Memos"
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
            action("AQD Update Rebate")
            {
                ApplicationArea = All;
                Caption = 'Update Rebate';
                Image = EditAdjustments;
                RunObject = Page "AQD Edit CrMemo Rebate";
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

