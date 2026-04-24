table 14302516 "AQD Cust Rebate Program Code"
{
    Caption = 'Customer Rebate Program Codes';
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
            Caption = 'Customer Rebate Posting Type';
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
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
        }
        field(30; "Rebate Payable AC"; Code[20])
        {
            Caption = 'Rebate Payable A/C';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                "Account Type" = CONST(Posting),
                                                Blocked = CONST(false));
            ObsoleteState = Pending;
            ObsoleteReason = 'Used Customer Vendor Employee No.';
            ObsoleteTag = 'Discontinued 25.1023.0.2';
        }
        field(40; "Entity Type"; Enum "AQD Cust Rebate Customer Type")
        {
            Caption = 'Entity Type';

            trigger OnValidate()
            begin
                IF Rec."Entity Type" <> xRec."Entity Type" THEN
                    Rec."Entity No." := '';
            end;
        }
        field(50; "Entity No."; Code[20])
        {
            Caption = 'Entity No.';
            TableRelation = if ("Entity Type" = const("Customer Category")) "AQD Rebate Customer Category"
            else if ("Entity Type" = const(Customer)) Customer
            else if ("Entity Type" = const("Employee Commission")) Employee where(Status = const(Active))
            else if ("Entity Type" = const("Vendor Commission")) Vendor where(Blocked = filter(''));
        }
        field(60; "Specific Sales"; Boolean)
        {
            Caption = 'Specific Sales';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Specific Sales New';
        }
        field(61; "Specific Sales New"; Enum "AQD Specific Sales")
        {
            Caption = 'Specific Sales';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SalesRebateRate: Record "AQD Sales Rebates Rate";
            begin
                SalesRebateRate.Reset();
                SalesRebateRate.SetRange("Rebate Program Code", Code);
                if SalesRebateRate.FindSet() then begin
                    repeat
                        SalesRebateRate.Validate("Specific Sales New", Rec."Specific Sales New");
                        SalesRebateRate.Modify();
                    until SalesRebateRate.Next() = 0;
                end;
            end;
        }
        field(70; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(80; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Marketplace";
            trigger OnValidate()
            var
                SalesRebateRate: Record "AQD Sales Rebates Rate";
            begin
                if (xRec."Marketplace Code" <> '') and (Rec."Marketplace Code" = '') and ("Specific Sales New" = "Specific Sales New"::Marketplace) then begin
                    SalesRebateRate.Reset();
                    SalesRebateRate.SetRange("Rebate Program Code", Code);
                    if SalesRebateRate.FindFirst() then
                        Error('There are already existing rate(s) for this marketplace. Please delete the rate(s) before removing the value.');
                end;
                SalesRebateRate.Reset();
                SalesRebateRate.SetRange("Rebate Program Code", Code);
                if SalesRebateRate.FindSet() then begin
                    repeat
                        SalesRebateRate."Marketplace Code" := "Marketplace Code";
                        SalesRebateRate.Modify(false);
                    until SalesRebateRate.Next() = 0;
                end;
            end;
        }
        field(90; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            var
                SalesRebateRate: Record "AQD Sales Rebates Rate";
            begin
                SalesRebateRate.Reset();
                SalesRebateRate.SetRange("Rebate Program Code", Code);
                if SalesRebateRate.FindSet() then begin
                    repeat
                        SalesRebateRate.Validate(Blocked, Rec.Blocked);
                        SalesRebateRate.Modify();
                    until SalesRebateRate.Next() = 0;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
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
}