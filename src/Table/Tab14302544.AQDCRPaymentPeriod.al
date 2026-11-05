table 14302544 "AQD CR Payment Period"
{
    Caption = 'Rebate Payment Period';
    DataClassification = CustomerContent;
    LookupPageId = "AQD CR Payment Periods";
    DrillDownPageId = "AQD CR Payment Periods";

    fields
    {
        field(1; "Payment Frequency"; Enum "AQD CR Payment Frequency")
        {
            Caption = 'Payment Frequency';
            Editable = false;
        }
        field(2; "Commission Payable Date"; Date)
        {
            Caption = 'Commission Payable Date';
            Editable = false;
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            Editable = false;
        }
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            Editable = false;
        }
        field(30; Status; Enum "AQD CR Payment Period Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(40; "Closed By"; Code[50])
        {
            Caption = 'Closed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(41; "Closed At"; Date)
        {
            Caption = 'Closed At';
            Editable = false;
        }
        field(50; "Reopened By"; Code[50])
        {
            Caption = 'Reopened By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(51; "Reopened At"; DateTime)
        {
            Caption = 'Reopened At';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Payment Frequency", "Commission Payable Date")
        {
            Clustered = true;
        }
        key(Key2; "Payment Frequency", Status, "Starting Date", "Ending Date")
        {
        }
    }

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnRename()
    begin
        Error(CannotRenameErr, TableCaption());
    end;

    // A period is closed for a date when a closed period covers that date, or its payable due date has already been closed
    procedure FindClosedPeriod(PaymentFrequency: Enum "AQD CR Payment Frequency"; PeriodDate: Date; PayableDueDate: Date): Boolean
    begin
        Reset();
        SetCurrentKey("Payment Frequency", Status, "Starting Date", "Ending Date");
        SetRange("Payment Frequency", PaymentFrequency);
        SetRange(Status, Status::Closed);
        SetRange("Commission Payable Date", PayableDueDate);
        if FindFirst() then
            exit(true);

        SetRange("Commission Payable Date");
        SetFilter("Starting Date", '..%1', PeriodDate);
        SetFilter("Ending Date", '%1..', PeriodDate);
        exit(FindLast());
    end;

    // The period is shared by all programs with this Payment Frequency, so every one of them must be settled
    procedure ClosePeriod()
    var
        RebateProgramCode: Record "AQD Cust Rebate Program Code";
        PeriodNotEndedErr: Label '%1 payment period %2..%3 cannot be closed before it has ended.', Comment = '%1 = Payment Frequency, %2 = Starting Date, %3 = Ending Date';
    begin
        TestField(Status, Status::Open);
        if "Ending Date" >= WorkDate() then
            Error(PeriodNotEndedErr, "Payment Frequency", "Starting Date", "Ending Date");

        RebateProgramCode.SetRange("Payment Frequency", "Payment Frequency");
        RebateProgramCode.SetLoadFields(Code);
        if RebateProgramCode.FindSet() then
            repeat
                CheckProgramSettled(RebateProgramCode.Code);
            until RebateProgramCode.Next() = 0;

        Status := Status::Closed;
        "Closed By" := CopyStr(UserId(), 1, MaxStrLen("Closed By"));
        "Closed At" := Today;//CurrentDateTime();
        Modify(true);
    end;

    local procedure CheckProgramSettled(ProgramCode: Code[10])
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        UnpostedRebatesErr: Label '%1 payment period %2..%3 cannot be closed because program %4 has unposted sales rebate documents due on %5.', Comment = '%1 = Payment Frequency, %2 = Starting Date, %3 = Ending Date, %4 = Program Code, %5 = Commission Payable Date';
        UnpostedJournalErr: Label '%1 payment period %2..%3 cannot be closed because program %4 has unposted journal lines due on %5.', Comment = '%1 = Payment Frequency, %2 = Starting Date, %3 = Ending Date, %4 = Program Code, %5 = Commission Payable Date';
        UnpaidEntriesErr: Label '%1 payment period %2..%3 cannot be closed because program %4 has unpaid vendor ledger entries due on %5.', Comment = '%1 = Payment Frequency, %2 = Starting Date, %3 = Ending Date, %4 = Program Code, %5 = Commission Payable Date';
    begin
        CustomerRebateDetails.SetCurrentKey("Rebate Program Code", "Commission Payable Date");
        CustomerRebateDetails.SetRange("Rebate Program Code", ProgramCode);
        CustomerRebateDetails.SetRange("Commission Payable Date", "Commission Payable Date");
        CustomerRebateDetails.SetRange(Preview, false);
        if not CustomerRebateDetails.IsEmpty() then
            Error(UnpostedRebatesErr, "Payment Frequency", "Starting Date", "Ending Date", ProgramCode, "Commission Payable Date");

        GenJournalLine.SetRange("AQD CR Rebate Program Code", ProgramCode);
        GenJournalLine.SetRange("AQD CR Commission Payable Date", "Commission Payable Date");
        if not GenJournalLine.IsEmpty() then
            Error(UnpostedJournalErr, "Payment Frequency", "Starting Date", "Ending Date", ProgramCode, "Commission Payable Date");

        VendorLedgerEntry.SetRange("AQD CR Rebate Program Code", ProgramCode);
        VendorLedgerEntry.SetRange("AQD CF Commission Payable Date", "Commission Payable Date");
        VendorLedgerEntry.SetRange(Open, true);
        if not VendorLedgerEntry.IsEmpty() then
            Error(UnpaidEntriesErr, "Payment Frequency", "Starting Date", "Ending Date", ProgramCode, "Commission Payable Date");
    end;

    // Correction process: only Sales Rebate Admins may reopen a closed period
    procedure ReopenPeriod()
    var
        ReopenQst: Label '%1 payment period %2..%3 is closed. Reopening it allows new back-posted transactions of all %1 programs to be assigned to it.\Do you want to reopen it?', Comment = '%1 = Payment Frequency, %2 = Starting Date, %3 = Ending Date';
    begin
        TestField(Status, Status::Closed);
        CheckReopenPermission();

        if GuiAllowed() then
            if not Confirm(ReopenQst, false, "Payment Frequency", "Starting Date", "Ending Date") then
                exit;

        Status := Status::Open;
        "Reopened By" := CopyStr(UserId(), 1, MaxStrLen("Reopened By"));
        "Reopened At" := CurrentDateTime();
        Modify(true);
    end;

    local procedure CheckReopenPermission()
    var
        AccessControl: Record "Access Control";
        User: Record User;
        NoPermissionErr: Label 'Only Sales Rebate Admin users can reopen a closed payment period.';
    begin
        if not User.Get(UserSecurityId()) then
            Error(NoPermissionErr);

        AccessControl.SetRange("User Name", User."User Name");
        AccessControl.SetRange("Role ID", 'AQD SREBATE ADMIN');
        if AccessControl.IsEmpty() then
            Error(NoPermissionErr);
    end;

    var
        CannotRenameErr: Label 'You cannot rename a %1.', Comment = '%1 = Table Caption';
}
