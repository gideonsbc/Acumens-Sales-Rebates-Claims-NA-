table 14302612 "AQD Customer Claim Header"
{
    Caption = 'Customer Claim Header';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Vendor No.", "Vendor Name";

    fields
    {
        field(1; "Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            BEGIN
                IF "No." <> xRec."No." THEN BEGIN
                    GetClaimSetup();
                    NoSeries.TestManual(GetNoSeriesCode);
                END;
            END;
        }
        field(15; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(30; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(40; "Vendor Name"; Text[100])
        {
            Caption = 'Name';
        }
        field(50; "Vendor Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(60; "Vendor Address"; Text[100])
        {
            Caption = 'Address';
        }
        field(70; "Vendor Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(80; "Vendor City"; Text[30])
        {
            Caption = 'City';
        }
        field(90; "Vendor Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
        }
        field(100; "Vendor Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
        }
        field(110; "Vendor County"; Text[30])
        {
            Caption = 'State';
        }
        field(150; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
        }
        field(160; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
        }
        field(170; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
        }
        field(180; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
        }
        field(190; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
        }
        field(200; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
        }
        field(210; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
        }
        field(220; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-To State';
        }
        field(230; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
        }
        field(240; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
            ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
        }
        field(300; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
        }
        field(310; "Sell-to Name"; Text[100])
        {
            Caption = 'Sell-to Name';
        }
        field(320; "Sell-to Name 2"; Text[50])
        {
            Caption = 'Sell-to Name 2';
        }
        field(330; "Sell-to Address"; Text[100])
        {
            Caption = 'Sell-to Address';
        }
        field(340; "Sell-to Address 2"; Text[50])
        {
            Caption = 'Sell-to Address 2';
        }
        field(350; "Sell-to City"; Text[30])
        {
            Caption = 'Sell-to City';
        }
        field(360; "Sell-to Post Code"; Code[20])
        {
            Caption = 'Sell-to ZIP Code';
        }
        field(370; "Sell-to County"; Text[30])
        {
            Caption = 'Sell-to State';
        }
        field(380; "Sell-to Country/Region Code"; Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
        }
        field(390; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';
            ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
        }
        field(450; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
        }
        field(460; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }
        field(470; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
        }
        field(480; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
        }
        field(490; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(500; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
        }
        field(510; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to ZIP Code';
        }
        field(520; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to State';
        }
        field(530; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
        }
        field(535; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
            ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
        }
        field(540; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            ToolTip = 'Specifies the location from where items are to be shipped. This field acts as the default location for new lines. You can update the location code for individual lines as needed.';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(550; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            Editable = false;
            ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(560; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            Editable = false;
            ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(570; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(580; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
            TableRelation = "Salesperson/Purchaser" where(Blocked = const(false));
        }
        field(590; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(600; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(610; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(620; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(630; "Claim Amount"; Decimal)
        {
            Caption = 'Claim Amount';
            DecimalPlaces = 0 : 5;
            Editable = FALSE;
            FieldClass = FlowField;
            CalcFormula = SUM("AQD Customer Claim Line".Amount WHERE("Document No." = FIELD("No.")));
        }
        field(635; "Line Approved Amount"; Decimal)
        {
            Caption = 'Line Approved Amount';
            DecimalPlaces = 0 : 5;
            Editable = FALSE;
            FieldClass = FlowField;
            CalcFormula = SUM("AQD Customer Claim Line"."Approved Amount" WHERE("Document No." = FIELD("No.")));
        }
        field(700; Status; Enum "AQD Cust Claim Claim Status")
        {
            Caption = 'Status';
        }
        field(720; "Claim Submitted"; Boolean)
        {
            Caption = 'Claim Submitted';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
            BEGIN
                Rec.TESTFIELD("Claim Approved", FALSE);
                Rec."Claim Submitted By" := UserId;
                Rec."Claim Submitted DateTime" := CurrentDateTime;

                IF Rec."Claim Submitted" THEN BEGIN
                    Rec."Claim Submitted By" := UserId;
                    Rec."Claim Submitted DateTime" := CurrentDateTime;
                    Rec.Status := Rec.Status::Submitted;
                END ELSE BEGIN
                    Rec."Claim Submitted By" := '';
                    Rec."Claim Submitted DateTime" := 0DT;
                    Rec.Status := Rec.Status::Created;
                END;
            END;
        }
        field(730; "Claim Submitted By"; Code[50])
        {
            Caption = 'Claim Submitted By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(740; "Claim Submitted DateTime"; DateTime)
        {
            Caption = 'Claim Submitted DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(750; "Claim Approved"; Boolean)
        {
            Caption = 'Claim Approved';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
                ClaimFunction: Codeunit "AQD Cust Claim Event And Func";
                InputLineApprovedAmountError: Label 'Line Approved Amount is not entered. Do you still want to apporve claim?';
                AbortedMessage: Label 'The process is cancelled to respect user selection';
            BEGIN
                IF Rec."Claim Approved" THEN BEGIN
                    Rec.TESTFIELD("Claim Rejected", FALSE);
                    IF Rec."Vendor Cr. Memo No." = '' THEN
                        ERROR(ClaimApprovalBlankError, Rec.FieldCaption("Vendor Cr. Memo No."));
                    IF Rec."Vendor Cr. Memo Date" = 0D THEN
                        ERROR(ClaimApprovalBlankError, Rec.FieldCaption("Vendor Cr. Memo Date"));
                    IF Rec."Amount Approved" = 0 THEN
                        ERROR(ClaimApprovalError, Rec.FieldCaption("Amount Approved"));

                    Rec.CalcFields("Line Approved Amount");
                    IF Rec."Line Approved Amount" = 0 then
                        IF NOT CONFIRM(InputLineApprovedAmountError) THEN
                            ERROR(AbortedMessage);

                    Rec."Claim Approved By" := UserId;
                    Rec."Claim Approved DateTime" := CurrentDateTime;
                    Rec.Status := Rec.Status::Approved;
                END ELSE BEGIN
                    Rec."Claim Approved By" := '';
                    Rec."Claim Approved DateTime" := 0DT;
                    Rec.Status := Rec.Status::Submitted;
                END;

                IF SalesHeader.GET(SalesHeader."Document Type"::Order, Rec."Order No.") THEN BEGIN
                    SalesHeader.SuspendStatusCheck(TRUE);
                    SalesHeader."AQD Vendor Cr. Memo No." := Rec."Vendor Cr. Memo No.";
                    SalesHeader."AQD Claim Approved Amount" := Rec."Amount Approved";
                    SalesHeader."AQD Claim Delivery Commission" := Rec."Delivery Commission";
                    SalesHeader."AQD Claim Purchase Discount" := Rec."Purchase Discount";
                    SalesHeader.MODIFY;
                    SalesHeader.SuspendStatusCheck(FALSE);
                END;

                IF Rec."Claim Approved" THEN BEGIN
                    CASE Rec."Claim Type" OF
                        Rec."Claim Type"::"Full Price":
                            ClaimFunction.CreatePurchCrMemoForFullPriceClaim(SalesHeader, Rec, TRUE);
                        Rec."Claim Type"::"Price Match":
                            ClaimFunction.CreatePurchCrMemoForPriceMatchClaim(Rec, TRUE);
                    END;
                END;
            END;
        }
        field(760; "Claim Approved By"; Code[50])
        {
            Caption = 'Claim Approved By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(770; "Claim Approved DateTime"; DateTime)
        {
            Caption = 'Claim Approved DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(771; "Claim Rejected"; Boolean)
        {
            Caption = 'Claim Rejected';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
            BEGIN
                Rec.TESTFIELD("Claim Submitted", TRUE);
                Rec.TESTFIELD("Claim Approved", FALSE);
                IF Rec."Claim Rejected" THEN BEGIN
                    Rec."Claim Rejected By" := UserId;
                    Rec."Claim Rejected DateTime" := CurrentDateTime;
                    Rec.Status := Rec.Status::Rejected;
                END ELSE BEGIN
                    Rec."Claim Rejected By" := '';
                    Rec."Claim Rejected DateTime" := 0DT;
                    Rec.Status := Rec.Status::Submitted;
                END;
            END;
        }
        field(772; "Claim Rejected By"; Code[50])
        {
            Caption = 'Claim Rejected By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(773; "Claim Rejected DateTime"; DateTime)
        {
            Caption = 'Claim Rejected DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(774; "Claim Rejected Comments"; Text[250])
        {
            Caption = 'Claim Rejected Comments';
            DataClassification = CustomerContent;
        }
        field(780; "Vendor Cr. Memo No."; Code[20])
        {
            Caption = 'Vendor Cr. Memo No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                Rec.TESTFIELD("Claim Approved", FALSE);
            END;
        }
        field(790; "Vendor Cr. Memo Date"; Date)
        {
            Caption = 'Vendor Cr. Memo Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.TESTFIELD("Claim Approved", FALSE);
            end;
        }
        field(800; "Amount Approved"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Amount Approved';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                Rec.TESTFIELD("Claim Approved", FALSE);
            END;
        }
        field(810; "Delivery Commission"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Delivery Commission';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                Rec.TESTFIELD("Claim Approved", FALSE);
            END;
        }
        field(820; "Purchase Discount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Purchase Discount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                Rec.TESTFIELD("Claim Approved", FALSE);
            END;
        }
        field(830; "Posted Invoice No."; Code[20])
        {
            Caption = 'Posted Invoice No.';
            DataClassification = CustomerContent;
        }
        field(840; "Purchase Credit Memo No."; Code[20])
        {
            Caption = 'Purchase Credit Memo No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Header";
        }
        field(850; "Posted Purch Credit Memo No."; Code[20])
        {
            Caption = 'Posted Purchase Credit Memo No.';
            DataClassification = CustomerContent;
            TableRelation = "Purch. Cr. Memo Hdr.";
        }
        field(860; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(870; "Supplementary Invoice No."; Code[20])
        {
            Caption = 'Supplementary Invoice No';
            DataClassification = CustomerContent;
            Editable = FALSE;
            TableRelation = "Sales Header" where("Document Type" = filter(Invoice));
        }
        field(880; "Posted Supplementary Inv No."; Code[20])
        {
            Caption = 'Posted Supplementary Invoice No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
            TableRelation = "Sales Invoice Header";
        }
    }
    keys
    {
        key(PK; "Claim Type", "No.")
        {
            Clustered = true;
        }
        key(SK; "Order No.")
        {
        }
    }

    trigger OnInsert()
    begin
        InitInsert();
    end;

    trigger OnDelete()
    var
        ClaimLine: Record "AQD Customer Claim Line";
        SupplementaryInvoice: Record "Sales Header";
        PurchaseCreditMemo: Record "Purchase Header";
    BEGIN
        IF Rec."Claim Approved" THEN
            ERROR(ClaimIsAlreadyApproved);

        IF Rec."Claim Submitted" THEN
            ERROR(ClaimIsAlreadySubmitted);

        ClaimLine.RESET;
        ClaimLine.SETRANGE("Document No.", Rec."No.");
        IF ClaimLine.FINDFIRST THEN
            ClaimLine.DELETEALL;

        IF SupplementaryInvoice.GET(SupplementaryInvoice."Document Type"::Invoice,
            Rec."Supplementary Invoice No.")
        THEN BEGIN
            SupplementaryInvoice.SetHideCreditCheckDialogue(TRUE);
            SupplementaryInvoice.SuspendStatusCheck(TRUE);
            SupplementaryInvoice.DELETE(TRUE);
        END;

        IF PurchaseCreditMemo.GET(PurchaseCreditMemo."Document Type"::"Credit Memo",
            Rec."Purchase Credit Memo No.")
        THEN BEGIN
            PurchaseCreditMemo.SetHideValidationDialog(TRUE);
            PurchaseCreditMemo.SuspendStatusCheck(TRUE);
            PurchaseCreditMemo.DELETE(TRUE);
        END;
    END;

    procedure InitInsert()
    var
        IsHandled: Boolean;
    begin
        GetClaimSetup();
        IsHandled := FALSE;
        OnBeforeInitInsert(Rec, xRec, IsHandled);
        IF NOT IsHandled THEN
            IF "No." = '' THEN BEGIN
                TestNoSeries;
                Case Rec."Claim Type" OF
                    Rec."Claim Type"::"Full Price":
                        "No." := NoSeries.GetNextNo(ClaimSetup."Full Price Claim Nos.", "Order Date");
                    Rec."Claim Type"::"Price Match":
                        "No." := NoSeries.GetNextNo(ClaimSetup."Price Match Claim Nos.", "Order Date");
                End;
            END;

        OnInitInsertOnBeforeInitRecord(Rec, xRec);
    end;

    local procedure TestNoSeries()
    var
        IsHandled: Boolean;
    begin
        GetClaimSetup;
        IsHandled := FALSE;
        OnBeforeTestNoSeries(Rec, IsHandled);
        IF NOT IsHandled THEN BEGIN
            Case Rec."Claim Type" OF
                Rec."Claim Type"::"Full Price":
                    ClaimSetup.TestField("Full Price Claim Nos.");
                Rec."Claim Type"::"Price Match":
                    ClaimSetup.TestField("Price Match Claim Nos.");
            End;
        END;
        OnAfterTestNoSeries(Rec);
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
        IsHandled: Boolean;
    begin
        GetClaimSetup;
        IsHandled := FALSE;
        OnBeforeGetNoSeriesCode(Rec, ClaimSetup, NoSeriesCode, IsHandled);
        IF IsHandled THEN
            EXIT;

        Case Rec."Claim Type" OF
            Rec."Claim Type"::"Full Price":
                NoSeriesCode := ClaimSetup."Full Price Claim Nos.";
            Rec."Claim Type"::"Price Match":
                NoSeriesCode := ClaimSetup."Price Match Claim Nos.";
        End;

        OnAfterGetNoSeriesCode(Rec, ClaimSetup, NoSeriesCode);
        if not SelectNoSeriesAllowed then
            exit(NoSeriesCode);

        if NoSeries.IsAutomatic(NoSeriesCode) then
            exit(NoSeriesCode);

        if NoSeries.HasRelatedSeries(NoSeriesCode) then
            if NoSeries.LookupRelatedNoSeries(NoSeriesCode, "No. Series") then
                exit("No. Series");

        exit(NoSeriesCode);
    end;

    local procedure GetClaimSetup()
    begin
        ClaimSetup.GET;
    end;

    local procedure SetAllowSelectNoSeries()
    begin
        SelectNoSeriesAllowed := TRUE;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitInsert(var ClaimHeader: Record "AQD Customer Claim Header"; xClaimHeader: Record "AQD Customer Claim Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var ClaimHeader: Record "AQD Customer Claim Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitInsertOnBeforeInitRecord(var ClaimHeader: Record "AQD Customer Claim Header"; xClaimHeader: Record "AQD Customer Claim Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var ClaimHeader: Record "AQD Customer Claim Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNoSeries(var ClaimHeader: Record "AQD Customer Claim Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNoSeriesCode(VAR ClaimHeader: Record "AQD Customer Claim Header"; ClaimSetup: Record "AQD Acumens CustRbtClaim Setup"; VAR NoSeriesCode: Code[20]; VAR IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var ClaimHeader: Record "AQD Customer Claim Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var ClaimHeader: Record "AQD Customer Claim Header"; VAR IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNoSeriesCode(VAR ClaimHeader: Record "AQD Customer Claim Header"; ClaimSetup: Record "AQD Acumens CustRbtClaim Setup"; VAR NoSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPostingNoSeriesCode(ClaimHeader: Record "AQD Customer Claim Header"; VAR PostingNos: Code[20])
    begin
    end;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        NoSeries: Codeunit "No. Series";
        SelectNoSeriesAllowed: Boolean;
        ClaimIsAlreadyApproved: Label 'Claim is already apporved. It cannot be deleted.';
        ClaimIsAlreadySubmitted: Label 'Claim is already submitted. It cannot be deleted.';
        ClaimApprovalError: Label '%1 must not be zero to approve Claim.';
        ClaimApprovalBlankError: Label '%1 must not be blank to approve Claim.';
}