page 14301920 "AQD Cust Rebate Change To Paid"
{
    Caption = 'Customer Rebate Change To Paid';
    PageType = ConfirmationDialog;
    RefreshOnActivate = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field("Payment Date"; PaymentDate)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Payment Date';
            }
            field("Payment Ref. No."; PaymentCheckNo)
            {
                Caption = 'Payment Ref. No.';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        PaymentDate := Today;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK, ACTION::Yes] then
            if PaymentDate = 0D then
                Error(BlankPaymentDateError);
    end;

    var
        PaymentDate: Date;
        PaymentCheckNo: Code[20];
        BlankPaymentDateError: Label 'Payment Date must not be blank.';


    procedure GetCheckInformation(var PaymentDateIn: Date; var PaymentCheckNoIn: Code[20])
    begin
        PaymentDateIn := PaymentDate;
        PaymentCheckNoIn := PaymentCheckNo;
    end;
}

