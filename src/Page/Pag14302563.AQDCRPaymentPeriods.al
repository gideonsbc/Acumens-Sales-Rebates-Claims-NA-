page 14302563 "AQD CR Payment Periods"
{
    ApplicationArea = All;
    Caption = 'Commission Payment Periods';
    PageType = List;
    SourceTable = "AQD CR Payment Period";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Payment Frequency"; Rec."Payment Frequency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment frequency of the period. The period applies to all rebate programs with this frequency.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first posting date included in the payment period.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last posting date included in the payment period.';
                }
                field("Commission Payable Date"; Rec."Commission Payable Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the commissions of the period become due for payment.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies whether the period is open or closed. Transactions back-posted into a closed period are assigned to the next open period.';
                }
                field("Closed By"; Rec."Closed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who closed the period.';
                }
                field("Closed At"; Rec."Closed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the period was closed.';
                }
                field("Reopened By"; Rec."Reopened By")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the user who last reopened the period.';
                }
                field("Reopened At"; Rec."Reopened At")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies when the period was last reopened.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClosePeriod)
            {
                ApplicationArea = All;
                Caption = 'Close Period';
                Image = ClosePeriod;
                Enabled = Rec.Status = Rec.Status::Open;
                ToolTip = 'Close the selected payment periods. A period can only be closed after it has ended and the commissions of all programs with its payment frequency are posted and paid.';

                trigger OnAction()
                var
                    PaymentPeriod: Record "AQD CR Payment Period";
                begin
                    CurrPage.SetSelectionFilter(PaymentPeriod);
                    PaymentPeriod.SetRange(Status, PaymentPeriod.Status::Open);
                    if PaymentPeriod.FindSet(true) then
                        repeat
                            PaymentPeriod.ClosePeriod();
                        until PaymentPeriod.Next() = 0;
                end;
            }
            action(ReopenPeriod)
            {
                ApplicationArea = All;
                Caption = 'Reopen Period';
                Image = ReOpen;
                Enabled = Rec.Status = Rec.Status::Closed;
                ToolTip = 'Reopen the selected closed payment period. Requires the Sales Rebate Admin permission set.';

                trigger OnAction()
                begin
                    Rec.ReopenPeriod();
                end;
            }
            action(UpdatePeriods)
            {
                ApplicationArea = All;
                Caption = 'Update Periods from Entries';
                Image = Refresh;
                ToolTip = 'Create any missing open payment periods from the commission payable dates of existing sales rebate details.';

                trigger OnAction()
                var
                    RebateProgramCode: Record "AQD Cust Rebate Program Code";
                begin
                    if Rec.GetFilter("Payment Frequency") <> '' then
                        RebateProgramCode.SetFilter("Payment Frequency", Rec.GetFilter("Payment Frequency"));
                    if RebateProgramCode.FindSet() then
                        repeat
                            RebateProgramCode.RegisterPaymentPeriodsFromEntries();
                        until RebateProgramCode.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ClosePeriod_Promoted; ClosePeriod) { }
                actionref(ReopenPeriod_Promoted; ReopenPeriod) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Closed then
            StatusStyle := 'Unfavorable'
        else
            StatusStyle := 'Favorable';
    end;

    var
        StatusStyle: Text;
}
