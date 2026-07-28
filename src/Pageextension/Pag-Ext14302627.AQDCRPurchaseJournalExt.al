pageextension 14302627 "AQD CR Purchase Journal Ext." extends "Purchase Journal"
{
    layout
    {
        addafter(Description)
        {
            Field("AQD CR Rebate Program Code"; Rec."AQD CR Rebate Program Code")
            {
                ToolTip = 'Specifies the value of the Rebate Program Code field.';
                ApplicationArea = all;
                Editable = false;
            }
        }

    }
    actions
    {
        addafter("Page")
        {
            group("AQD AQDSuggestVendorPayments_Group")
            {
                Caption = 'Acumens Sales Rebate';
                Image = Payment;
                action("AQD SuggestVendorPayments")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Vendor Commissions & Rebates';
                    Image = SuggestVendorPayments;
                    ToolTip = 'Create Vendor Commissions as lines in the Purchase journal.';

                    trigger OnAction()
                    var
                        SuggestVendorcommission: Report "AQD Suggest Vendor Commissions";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        AQDOnBeforeSuggestVendorPaymentsAction(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Clear(SuggestVendorcommission);
                        SuggestVendorcommission.SetGenJnlLine(Rec);
                        SuggestVendorcommission.RunModal();
                    end;
                }
            }
        }

        addafter(Category_Category7)
        {
            group("AQD AQDAcumesCustomerRebates_Category8")
            {
                Caption = 'Acumens Sales Rebate', Comment = 'Generated from the PromotedActionCategories property index 8.';

                actionref(AQDSuggestVendorPayments_Promoted; "AQD SuggestVendorPayments")
                {
                }
            }
        }
    }

    [IntegrationEvent(true, false)]
    local procedure AQDOnBeforeSuggestVendorPaymentsAction(var GenJournalLine: Record "Gen. Journal Line"; var IsHanlded: Boolean)
    begin
    end;
}
