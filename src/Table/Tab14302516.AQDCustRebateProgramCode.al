table 14302516 "AQD Cust Rebate Program Code"
{
    Caption = 'Sales Rebate Program Codes';
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
            TableRelation = if ("Rebate Expense Type" = filter("Rebate Accrual" | "Commission Accrual" | "Royalty Accrual")) "G/L Account" WHERE("Direct Posting" = CONST(true),
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
            Caption = 'Default Payee No.';
            TableRelation = if ("Payee Type" = const("Employee Commission")) Employee where(Status = const(Active))
            else if ("Payee Type" = const("Vendor Commission")) Vendor where(Blocked = filter(''));

            trigger onvalidate()
            begin
                if Rec."Payee No." <> xRec."Payee No." then
                    UpdateRates(FieldCaption("Payee No."));
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
            Caption = 'Default Trade Agreement';
            DataClassification = CustomerContent;
            TableRelation = "AQD CF Trade Agreement";
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
        SalesRebateRate.SetRange("Rebate Program Code", Code);
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

    var
        SalesRebateRate: Record "AQD Sales Rebates Rate";

}