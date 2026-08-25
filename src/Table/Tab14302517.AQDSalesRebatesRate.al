table 14302517 "AQD Sales Rebates Rate"
{
    Caption = 'Sales Rebate & Commission Rates';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD CustRbt SalesRebates Setup";
    LookupPageId = "AQD CustRbt SalesRebates Setup";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = TRUE;
            Caption = 'Entry No.';
        }
        field(2; "Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rate Type';
        }
        field(3; "Program Code"; Code[20])
        {
            Caption = 'Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";

            trigger OnValidate()
            var
                RebateProgramCode: Record "AQD Cust Rebate Program Code";
            begin
                IF RebateProgramCode.GET(Rec."Program Code") THEN BEGIN
                    Rec."Rebate Type" := RebateProgramCode."Customer Default Rebate Type";
                    Rec."Rebate %" := RebateProgramCode."Customer Default Rebate %";
                    Rec."Rebate Per Unit" := RebateProgramCode."Customer Def Rebate Per Unit";
                    Rec."Payee Type" := RebateProgramCode."Payee Type";
                    Rec."Payee No." := RebateProgramCode."Payee No.";
                    Rec."Rebate Expense Type" := RebateProgramCode."Rebate Expense Type";
                    Rec."Default Setup" := RebateProgramCode."Default Setup";
                    Rec.Validate("AQD Trade Agreement", RebateProgramCode."AQD Default Trade Agreement");
                END;
            end;
        }
        field(5; "Payee Type"; Enum "AQD Sales Rebate Payee Type")
        {
            Caption = 'Payee Type';
            DataClassification = CustomerContent;
        }
        field(6; "Payee No."; Code[20])
        {
            Caption = 'Payee No.';
            TableRelation = if ("Payee Type" = const("Employee Commission")) Employee where(Status = const(Active))
            else if ("Payee Type" = const("Vendor Commission")) Vendor where(Blocked = filter(''));
        }
        field(8; "Customer Type"; Enum "AQD Sales Rebate Customer Type")
        {
            Caption = 'Customer Type';

            trigger onvalidate()
            begin
                IF Rec."Customer Type" <> xRec."Customer Type" THEN
                    Clear("Customer No. Filter New");
            end;
        }
        field(9; "Customer No. Filter New"; Text[250])
        {
            Caption = 'Customer No. Filter';
            DataClassification = CustomerContent;
        }
        field(10; "CustRbt Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rate Type';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by Rate Type';
        }
        field(13; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
        }
        field(14; "Line Type"; Enum "AQD Customer Rebate Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF Rec."Line Type" <> xRec."Line Type" then begin
                    Rec."No." := '';
                    Description := '';
                    Rec."No. Filter" := '';
                end;
            end;
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Line Type" = const("Rebate Category")) "Item Category".Code
            else if ("Line Type" = const(Item)) Item
            else if ("Line Type" = const("G/L Account")) "G/L Account"
            else if ("Line Type" = const(Resource)) Resource;
            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    Case Rec."Line Type" OF
                        Rec."Line Type"::Item:
                            begin
                                IF "No." <> '' THEN BEGIN
                                    Item.Get("No.");
                                    Description := Item.Description;
                                    Rec."Unit of Measure Code" := Item."Purch. Unit of Measure";
                                END ELSE BEGIN
                                    Description := '';
                                    Rec."Unit of Measure Code" := '';
                                END;
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::Resource:
                            begin
                                IF Resource.Get("No.") THEN BEGIN
                                    Description := Resource.Name;
                                    Rec."Unit of Measure Code" := Resource."Base Unit of Measure";
                                END ELSE BEGIN
                                    Description := '';
                                    Rec."Unit of Measure Code" := '';
                                END;
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"G/L Account":
                            begin
                                IF GLAccount.Get("No.") THEN
                                    Description := GLAccount.Name
                                ELSE
                                    Description := '';
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"Rebate Category":
                            BEGIN
                                IF ItemCategory.Get("No.") then
                                    Description := ItemCategory.Description
                                ELSE
                                    Description := '';
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            END;
                    END;
                    Clear("No. Filter");
                END;
            END;
        }
        field(16; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
        }
        field(17; "Rebate Program Code"; Code[20])
        {
            Caption = 'Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by Program Code';

            // trigger OnValidate()
            // var
            //     RebateProgramCode: Record "AQD Cust Rebate Program Code";
            // begin
            //     IF RebateProgramCode.GET(Rec."Rebate Program Code") THEN BEGIN
            //         Rec."Rebate Type" := RebateProgramCode."Customer Default Rebate Type";
            //         Rec."Rebate %" := RebateProgramCode."Customer Default Rebate %";
            //         Rec."Rebate Per Unit" := RebateProgramCode."Customer Def Rebate Per Unit";
            //         Rec."Payee Type" := RebateProgramCode."Payee Type";
            //         Rec."Payee No." := RebateProgramCode."Payee No.";
            //         Rec."Rebate Expense Type" := RebateProgramCode."Rebate Expense Type";
            //         Rec."Default Setup" := RebateProgramCode."Default Setup";
            //         Rec.Validate("AQD Trade Agreement", RebateProgramCode."AQD Default Trade Agreement");
            //     END;
            // end;
        }
        field(18; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(19; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if ("Line Type" = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(20; "Minimum Quantity"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 0;
            MinValue = 0;
        }
        field(21; "Minimum Amount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Minimum Amount';
            DecimalPlaces = 0 : 0;
            MinValue = 0;
        }
        field(30; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(35; "Program Description"; Text[100])
        {
            Caption = 'Program Description';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("AQD Cust Rebate Program Code".Description where("Code" = field("Program Code")));
        }
        field(40; "Rebate Type"; Option)
        {
            AutoFormatType = 2;
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;

            trigger OnValidate()
            begin
                IF Rec."Rebate Type" <> xRec."Rebate Type" THEN BEGIN
                    Rec."Rebate %" := 0;
                    Rec."Rebate Per Unit" := 0;
                END;
            end;
        }
        field(50; "Rebate %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate %';
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                Rec.TestField("Rebate Type");
            end;
        }
        field(60; "Rebate Per Unit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate Per Unit';
            MinValue = 0;
            trigger OnValidate()
            begin
                Rec.TestField("Rebate Type");
            end;
        }
        field(70; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                Rec.Validate("Starting Date");
            end;
        }
        field(100; "Rebate Expense Type"; Enum "AQD Rebate Expense Type")
        {
            Caption = 'Rebate Expense Type';
            DataClassification = CustomerContent;
        }
        field(110; "No. Filter"; Code[250])
        {
            DataClassification = CustomerContent;
        }
        field(500; "Last Changed DataTime"; DateTime)
        {
            Caption = 'Last Changed DataTime';
            Editable = false;
        }
        field(510; "Last Changed Changed By"; Code[50])
        {
            Caption = 'Last Changed Changed By';
            Editable = false;
        }
        field(520; "Last Rebate Type"; Option)
        {
            AutoFormatType = 2;
            Caption = 'Last Rebate Type';
            Editable = false;
            OptionCaption = ' ,Per Unit,Percentage';
            OptionMembers = " ","Per Unit",Percentage;
        }
        field(530; "Last Rebate Per Unit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Last Rebate Per Unit';
            Editable = false;
        }
        field(540; "Last Rebate %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Last Rebate %';
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(550; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if Blocked then begin
                    "Blocked By" := UserId;
                    "Blocked Date Time" := CurrentDateTime;
                end else begin
                    Clear("Blocked By");
                    Clear("Blocked Date Time");
                end;
            end;
        }
        field(560; "Blocked By"; Code[50])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(570; "Blocked Date Time"; DateTime)
        {
            Caption = 'Blocked Date Time';
            Editable = false;
        }
        field(586; "Customer No. Filter"; Code[500])
        {
            Caption = 'Customer No. Filter';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by Customer No. Filter New';
        }
        field(810; "Rate Priority"; Enum "AQD Rate Priority")
        {
            Caption = 'Rate Priority';
            DataClassification = CustomerContent;
        }
        field(850; "AQD Trade Agreement"; Code[10])
        {
            Caption = 'Trade Agreement';
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
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Rate Type", "Customer Type", "Customer No. Filter New", "Territory Code", "Line Type", "No.", "Variant Code", "Program Code", "Ending Date", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount", "Payee Type", "Payee No.")
        {
        }
        key(Key3; "Payee Type", "Payee No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Rate Type", "Customer Type", "Territory Code", "Line Type", "No.", "Variant Code", "Program Code", "Ending Date", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount")
        {
        }
        fieldgroup(Brick; "Rate Type", "Customer Type", "Territory Code", "Line Type", "No.", "Variant Code", "Program Code", "Ending Date", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Program Code");
        CheckRecordAlreadyExist();
    end;

    trigger OnModify()
    begin
        Rec.TestField("Program Code");
        CheckRecordAlreadyExist();

        IF (Rec."Rebate Type" <> xRec."Rebate Type") OR
          ((Rec."Rebate %" <> Rec."Rebate %") AND (xRec."Rebate %" <> 0))
        THEN BEGIN
            Rec."Last Changed Changed By" := USERID;
            Rec."Last Changed DataTime" := CURRENTDATETIME;
            Rec."Last Rebate Type" := xRec."Rebate Type";
            Rec."Last Rebate Per Unit" := xRec."Rebate Per Unit";
            Rec."Rebate %" := xRec."Rebate %";
        END;
    end;

    trigger OnRename()
    begin
        Rec.TestField("Program Code");
        CheckRecordAlreadyExist();
    end;

    procedure CheckRecordAlreadyExist()
    BEGIN
        CustomerRebateRate.RESET;
        CustomerRebateRate.SETFILTER("Entry No.", '<>%1', Rec."Entry No.");
        CustomerRebateRate.SETRANGE("Rate Type", Rec."Rate Type");
        CustomerRebateRate.SETRANGE("Customer Type", Rec."Customer Type");
        CustomerRebateRate.SETRANGE("Territory Code", Rec."Territory Code");
        CustomerRebateRate.SETRANGE("Line Type", Rec."Line Type");
        CustomerRebateRate.SETRANGE("No.", Rec."No.");
        CustomerRebateRate.SETRANGE("Variant Code", Rec."Variant Code");
        CustomerRebateRate.SETRANGE("Program Code", Rec."Program Code");
        CustomerRebateRate.SETRANGE("Starting Date", Rec."Starting Date");
        CustomerRebateRate.SETRANGE("Unit of Measure Code", Rec."Unit of Measure Code");
        CustomerRebateRate.SetRange("Minimum Quantity", Rec."Minimum Quantity");
        CustomerRebateRate.SetRange("Minimum Amount", Rec."Minimum Amount");
        CustomerRebateRate.SetRange("Customer No. Filter New", Rec."Customer No. Filter New");
        CustomerRebateRate.SetRange("Rate Priority", Rec."Rate Priority");
        IF CustomerRebateRate.FindFirst() THEN
            ERROR(Text002,
                Rec.FieldCaption("Rate Type"), Rec."Rate Type",
                Rec.FieldCaption("Customer Type"), Rec."Customer Type",
                Rec.FieldCaption("Customer No. Filter New"), Rec."Customer No. Filter New",
                Rec.FieldCaption("Territory Code"), Rec."Territory Code",
                Rec.FieldCaption("Line Type"), Rec."Line Type",
                Rec.FieldCaption("No."), Rec."No.",
                Rec.FieldCaption("Variant Code"), Rec."Variant Code",
                Rec.FieldCaption("Program Code"), Rec."Program Code",
                Rec.FieldCaption("Starting Date"), Rec."Starting Date",
                Rec.FieldCaption("Unit of Measure Code"), Rec."Unit of Measure Code",
                Rec.FieldCaption("Minimum Quantity"), Rec."Minimum Quantity",
                Rec.FieldCaption("Minimum Amount"), Rec."Minimum Amount");
    END;

    var
        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Text002: Label 'Customer Rebate Rate is already exists for %1=%2,%3=%4,%5=%6,%7=%8,%9=%10,%11=%12,%13=%14,%15=%16,%17=%18,%19=%20,%21=%22,%23=%24.';
        Customer: Record Customer;
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
        ItemCategory: Record "Item Category";
        CustomerRebateRate: Record "AQD Sales Rebates Rate";
}