pageextension 14277014 "AQD Posted Sales Cr. Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                Editable = false;
                field("AQD Do Not Pay Rebate"; Rec."AQD Do Not Pay Rebate")
                {
                    ApplicationArea = All;
                }
                // field("AQD Rebate %"; Rec."AQD Rebate %")
                // {
                //     ApplicationArea = All;
                // }
                field("AQD Rebate Vendor No"; Rec."AQD Rebate Vendor No")
                {
                    ApplicationArea = All;
                }
                field("AQD Rebate Entry Created"; Rec."AQD Rebate Entry Created")
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
        }
    }
    actions
    {
        addafter(ActivityLog)
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

