table 14302516 "AQD Cust Rebate Program Code"
{
    Caption = 'Sales Rebate & Commission Programs';
    LookupPageID = "AQD Cust Rebate Program Codes";
    DrillDownPageId = "AQD Cust Rebate Program Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            trigger OnValidate()
            var
                CustomerRebateSetupRec: Record "AQD Acumens CustRbtClaim Setup";
            begin
                IF Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::" " THEN
                    IF CustomerRebateSetupRec.GET THEN
                        Rec."Customer Rebate Posting Type" := CustomerRebateSetupRec."Default Rebate Posting Type";
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Customer Rebate Posting Type"; enum "AQD CustRebate CostPostingType")
        {
            Caption = 'Sales Rebate Posting Type';
        }
        field(5; "Customer Default Rebate %"; Decimal)
        {
            Caption = 'Default Rebate %';
            MaxValue = 100;
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Customer Default Rebate Type");
            end;
        }
        field(6; "Customer Default Rebate Type"; Option)
        {
            Caption = 'Default Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;

            trigger OnValidate()
            begin
                IF Rec."Customer Default Rebate Type" <> xRec."Customer Default Rebate Type" THEN BEGIN
                    Rec."Customer Default Rebate %" := 0;
                    Rec."Customer Def Rebate Per Unit" := 0;
                END;
            end;
        }
        field(7; "Customer Def Rebate Per Unit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Rebate Per Unit';
            MinValue = 0;
            trigger OnValidate()
            begin
                TestField("Customer Default Rebate Type");
            end;
        }
        field(20; "Rebate Expense AC"; Code[20])
        {
            Caption = 'Rebate Expense A/C';
            TableRelation = if ("Rebate Expense Type" = const("Rebate Accrual")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false))
            else if ("Rebate Expense Type" = const("Off-Invoice Rebate")) Resource where(Blocked = const(false));
        }
        field(45; "Payee Type"; Enum "AQD Sales Rebate Payee Type")
        {
            Caption = 'Default Payee Type';

            trigger OnValidate()
            begin
                if (Rec."Payee Type" in [Rec."Payee Type"::"Employee Commission", Rec."Payee Type"::"Vendor Commission"]) and (Rec."Rebate Expense Type" = Rec."Rebate Expense Type"::"Off-Invoice Rebate") then
                    Error('Off-Invoice Rebate is not applicable for Employee Commission or Vendor Commission.');

                IF Rec."Payee Type" <> xRec."Payee Type" THEN begin
                    Rec."Payee No." := '';

                    UpdateRates(FieldCaption("Payee Type"));
                end;
            end;
        }

        field(47; "Payee No."; Code[20])
        {
            Caption = 'Default Accrual Payee No.';
            TableRelation = if ("Payee Type" = const("Employee Commission")) Employee where(Status = const(Active))
            else if ("Payee Type" = const("Vendor Commission")) Vendor where(Blocked = filter(''));

            trigger onvalidate()
            begin
                if Rec."Payee No." <> xRec."Payee No." then
                    UpdateRates(FieldCaption("Payee No."));
            end;
        }
        field(50; "Rebate Payment Method Code"; Code[10])
        {
            Caption = 'Rebate Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(55; "Rate Priority"; Enum "AQD Rate Priority")
        {
            Caption = 'Rate Priority';
            DataClassification = CustomerContent;
        }
        field(60; "Posting Type"; Enum "AQD CR Posting Type")
        {
            Caption = 'Posting Type';
            DataClassification = CustomerContent;
        }
        field(65; "Payment Frequency"; Enum "AQD CR Payment Frequency")
        {
            Caption = 'Payment Frequency';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Payment Frequency" <> xRec."Payment Frequency" then
                    UpdateOpenRebateDetailsPayableDueDate();
            end;
        }
        field(90; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if Rec.Blocked <> xRec.Blocked then
                    UpdateRates(FieldCaption(Blocked));
            end;
        }
        field(100; "Rebate Expense Type"; Enum "AQD Rebate Expense Type")
        {
            Caption = 'Rebate Expense Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Rebate Expense Type" = Rec."Rebate Expense Type"::"Off-Invoice Rebate" then
                    Rec.Validate("Payee Type");

                if Rec."Rebate Expense Type" <> xRec."Rebate Expense Type" then begin
                    Rec."Rebate Expense AC" := '';

                    UpdateRates(FieldCaption("Rebate Expense Type"));
                end;
            end;
        }
        field(150; "SO Rebate Program Filter"; Code[100])
        {
            DataClassification = CustomerContent;
        }
        field(160; "SO Marketplace Code Filter"; Code[100])
        {
            DataClassification = CustomerContent;
        }
        field(200; "SO Payment Term Filter"; Code[100])
        {
            DataClassification = CustomerContent;
        }
        field(5000; "AQD Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";
        }
        field(5010; "AQD Default Trade Agreement"; Code[10])
        {
            Caption = 'Default Trade Agreement #';
            DataClassification = CustomerContent;
            TableRelation = "AQD CF Trade Agreement";
            ValidateTableRelation = false;
        }
        field(9000; "Default Setup"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Customer Rebate Posting Type")
        {
        }

        fieldgroup(Brick; "Code", Description, "Customer Rebate Posting Type")
        {
        }
    }
    trigger OnInsert()
    var
        CustomerRebateSetupRec: Record "AQD Acumens CustRbtClaim Setup";
    begin
        IF Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::" " THEN
            IF CustomerRebateSetupRec.GET THEN
                Rec."Customer Rebate Posting Type" := CustomerRebateSetupRec."Default Rebate Posting Type";
    end;

    local procedure UpdateRates(ChangedFieldName: Text[100])
    begin
        SalesRebateRate.Reset();
        SalesRebateRate.SetRange("Program Code", Code);
        if SalesRebateRate.FindSet() then begin
            repeat
                case ChangedFieldName of
                    FieldCaption(Blocked):
                        SalesRebateRate.Validate(Blocked, Rec.Blocked);
                    FieldCaption("Rebate Expense Type"):
                        SalesRebateRate.Validate("Rebate Expense Type", Rec."Rebate Expense Type");
                    FieldCaption("Payee Type"):
                        SalesRebateRate.Validate("Payee Type", Rec."Payee Type");
                    FieldCaption("Payee No."):
                        SalesRebateRate.Validate("Payee No.", Rec."Payee No.");
                end;
                SalesRebateRate.Modify();
            until SalesRebateRate.Next() = 0;
        end;
    end;

    // Due for Payment = end of the first open frequency period on or after the posting date + 1D
    procedure CalcPayableDueDate(PostingDate: Date): Date
    var
        PeriodStart: Date;
        PeriodEnd: Date;
    begin
        if PostingDate = 0D then
            exit(0D);

        if not FindOpenPaymentPeriod(PostingDate, PeriodStart, PeriodEnd) then
            exit(PostingDate);

        exit(PeriodEnd + 1);
    end;

    // Back-posting: a posting date in a closed payment period rolls forward to the next period that is still open
    procedure FindOpenPaymentPeriod(PostingDate: Date; var PeriodStart: Date; var PeriodEnd: Date): Boolean
    var
        PaymentPeriod: Record "AQD CR Payment Period";
        PeriodDate: Date;
        IsClosed: Boolean;
    begin
        PeriodDate := PostingDate;
        repeat
            if not GetFrequencyPeriod(PeriodDate, PeriodStart, PeriodEnd) then
                exit(false);

            IsClosed := PaymentPeriod.FindClosedPeriod("Payment Frequency", PeriodDate, PeriodEnd + 1);
            if IsClosed then
                if PaymentPeriod."Ending Date" > PeriodEnd then
                    PeriodDate := PaymentPeriod."Ending Date" + 1
                else
                    PeriodDate := PeriodEnd + 1;
        until not IsClosed;

        exit(true);
    end;

    procedure GetFrequencyPeriod(PostingDate: Date; var PeriodStart: Date; var PeriodEnd: Date): Boolean
    begin
        if PostingDate = 0D then
            exit(false);

        case "Payment Frequency" of
            "Payment Frequency"::Bimonthly:
                if Date2DMY(PostingDate, 1) <= 15 then begin
                    PeriodStart := CalcDate('<-CM>', PostingDate);
                    PeriodEnd := DMY2Date(15, Date2DMY(PostingDate, 2), Date2DMY(PostingDate, 3));
                end else begin
                    PeriodStart := DMY2Date(16, Date2DMY(PostingDate, 2), Date2DMY(PostingDate, 3));
                    PeriodEnd := CalcDate('<CM>', PostingDate);
                end;
            "Payment Frequency"::Monthly:
                begin
                    PeriodStart := CalcDate('<-CM>', PostingDate);
                    PeriodEnd := CalcDate('<CM>', PostingDate);
                end;
            "Payment Frequency"::Quarterly:
                begin
                    PeriodStart := CalcDate('<-CQ>', PostingDate);
                    PeriodEnd := CalcDate('<CQ>', PostingDate);
                end;
            "Payment Frequency"::"Half Year":
                if Date2DMY(PostingDate, 2) <= 6 then begin
                    PeriodStart := DMY2Date(1, 1, Date2DMY(PostingDate, 3));
                    PeriodEnd := DMY2Date(30, 6, Date2DMY(PostingDate, 3));
                end else begin
                    PeriodStart := DMY2Date(1, 7, Date2DMY(PostingDate, 3));
                    PeriodEnd := DMY2Date(31, 12, Date2DMY(PostingDate, 3));
                end;
            "Payment Frequency"::Annual:
                begin
                    PeriodStart := CalcDate('<-CY>', PostingDate);
                    PeriodEnd := CalcDate('<CY>', PostingDate);
                end;
            else
                exit(false);
        end;

        exit(true);
    end;

    // Makes the period behind a payable due date visible as an Open payment period so it can later be closed
    procedure RegisterPaymentPeriod(PayableDueDate: Date)
    var
        PaymentPeriod: Record "AQD CR Payment Period";
        PeriodStart: Date;
        PeriodEnd: Date;
    begin
        if PayableDueDate = 0D then
            exit;
        if PaymentPeriod.Get("Payment Frequency", PayableDueDate) then
            exit;
        if not GetFrequencyPeriod(PayableDueDate - 1, PeriodStart, PeriodEnd) then
            exit;
        if PeriodEnd + 1 <> PayableDueDate then
            exit;

        PaymentPeriod.Init();
        PaymentPeriod."Payment Frequency" := "Payment Frequency";
        PaymentPeriod."Commission Payable Date" := PayableDueDate;
        PaymentPeriod."Starting Date" := PeriodStart;
        PaymentPeriod."Ending Date" := PeriodEnd;
        PaymentPeriod.Status := PaymentPeriod.Status::Open;
        PaymentPeriod.Insert(true);
    end;

    procedure RegisterPaymentPeriodsFromEntries()
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        PostedCustRebDetails: Record "AQD Posted Cust Reb Details";
    begin
        PostedCustRebDetails.SetCurrentKey("Rebate Program Code", "Commission Payable Date");
        PostedCustRebDetails.SetLoadFields("Rebate Program Code", "Commission Payable Date");
        PostedCustRebDetails.SetRange("Rebate Program Code", Code);
        PostedCustRebDetails.SetFilter("Commission Payable Date", '<>%1', 0D);
        while PostedCustRebDetails.FindFirst() do begin
            RegisterPaymentPeriod(PostedCustRebDetails."Commission Payable Date");
            PostedCustRebDetails.SetFilter("Commission Payable Date", '>%1', PostedCustRebDetails."Commission Payable Date");
        end;

        CustomerRebateDetails.SetCurrentKey("Rebate Program Code", "Commission Payable Date");
        CustomerRebateDetails.SetLoadFields("Rebate Program Code", "Commission Payable Date");
        CustomerRebateDetails.SetRange("Rebate Program Code", Code);
        CustomerRebateDetails.SetRange(Preview, false);
        CustomerRebateDetails.SetFilter("Commission Payable Date", '<>%1', 0D);
        while CustomerRebateDetails.FindFirst() do begin
            RegisterPaymentPeriod(CustomerRebateDetails."Commission Payable Date");
            CustomerRebateDetails.SetFilter("Commission Payable Date", '>%1', CustomerRebateDetails."Commission Payable Date");
        end;
    end;

    local procedure UpdateOpenRebateDetailsPayableDueDate()
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        UpdateOpenDetailsQst: Label 'There are %1 open sales rebate detail lines for program %2.\Do you want to recalculate their Commission Payable Date using the %3 payment frequency?', Comment = '%1 = No. of lines, %2 = Program Code, %3 = Payment Frequency';
    begin
        CustomerRebateDetails.SetCurrentKey("Rebate Program Code", "Commission Payable Date");
        CustomerRebateDetails.SetRange("Rebate Program Code", Code);
        CustomerRebateDetails.SetRange(Preview, false);
        if CustomerRebateDetails.IsEmpty() then
            exit;

        if not GuiAllowed() then
            exit;

        if not Confirm(UpdateOpenDetailsQst, true, CustomerRebateDetails.Count(), Code, "Payment Frequency") then
            exit;

        // Iterate on the primary key, Commission Payable Date is part of the filtering key and changes in the loop
        CustomerRebateDetails.SetCurrentKey("Rebate No.", "Rebate Line No.", "Line No.");
        CustomerRebateDetails.SetLoadFields("Posting Date", "Commission Payable Date");
        if CustomerRebateDetails.FindSet(true) then
            repeat
                CustomerRebateDetails."Commission Payable Date" := CalcPayableDueDate(CustomerRebateDetails."Posting Date");
                CustomerRebateDetails.Modify(false);
                RegisterPaymentPeriod(CustomerRebateDetails."Commission Payable Date");
            until CustomerRebateDetails.Next() = 0;
    end;

    var
        SalesRebateRate: Record "AQD Sales Rebates Rate New";

}