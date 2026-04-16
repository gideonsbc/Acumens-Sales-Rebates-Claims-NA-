pageextension 14302524 "AQD CustRbt Posted SalesCrMemo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("AQD Acumens Customer Rebate and Claims")
            {
                Caption = 'Acumens Customer Rebates & Claims';
                Editable = false;

                field("AQD Do Not Pay Rebate"; Rec."AQD No Customer Rebate")
                {
                    ApplicationArea = All;
                }
                field("AQD CR Territory Code"; Rec."AQD CR Territory Code")
                {
                    ApplicationArea = All;
                }
                field("AQD Customer Rebate Status"; Rec."AQD Customer Rebate Status")
                {
                    ApplicationArea = All;
                }
                field("AQD Customer Rebate No."; Rec."AQD Customer Rebate No")
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
            // action("AQD Update Customer Rebate")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Update Customer Rebate';
            //     Image = EditAdjustments;
            //     RunObject = Page "AQD Edit CrMemo Cust Rebate";
            //     RunPageLink = "No." = FIELD("No.");
            // }
        }
        addlast(Promoted)
        {
            group("AQD Acumens Claims & Rebates")
            {
                Caption = 'Acumens Claims & Rebates';
                actionref("AQD DoNotPayRebate_AER"; "AQD DoNotPayRebate") { }
                //actionref("AQD UpdateRebate_AER"; "AQD Update Rebate") { }
            }
        }
    }
}

