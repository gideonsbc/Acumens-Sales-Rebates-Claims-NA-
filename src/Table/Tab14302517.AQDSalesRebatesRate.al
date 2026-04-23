table 14302517 "AQD Sales Rebates Rate"
{
    Caption = 'Sales Rebates Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = TRUE;
            Caption = 'Entry No.';
        }
        field(10; "CustRbt Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rebate Rate Type';
        }
        field(11; "Entity Type"; Enum "AQD Cust Rebate Customer Type")
        {
            Caption = 'Entity Type';
        }
        field(12; "Entity No."; Code[20])
        {
            Caption = 'Entity No.';
            TableRelation = if ("Entity Type" = const("Customer Category")) "AQD Rebate Customer Category"
            else if ("Entity Type" = const(Customer)) Customer
            else if ("Entity Type" = const("Employee Commission")) Employee where(Status = const(Active))
            else if ("Entity Type" = const("Vendor Commission")) Vendor where(Blocked = filter(''));
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
                IF Rec."Line Type" <> xRec."Line Type" then
                    Rec."No." := '';
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
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";

            trigger OnValidate()
            var
                RebateProgramCode: Record "AQD Cust Rebate Program Code";
            begin
                IF RebateProgramCode.GET(Rec."Rebate Program Code") THEN BEGIN
                    if RebateProgramCode."Specific Sales New" = RebateProgramCode."Specific Sales New"::Marketplace then
                        RebateProgramCode.TestField("Marketplace Code");
                    Rec."Rebate Type" := RebateProgramCode."Customer Default Rebate Type";
                    Rec."Rebate %" := RebateProgramCode."Customer Default Rebate %";
                    Rec."Rebate Per Unit" := RebateProgramCode."Customer Def Rebate Per Unit";
                    Rec."Entity Type" := RebateProgramCode."Entity Type";
                    Rec."Entity No." := RebateProgramCode."Entity No.";
                    Rec."Specific Sales New" := RebateProgramCode."Specific Sales New";
                    Rec."Marketplace Code" := RebateProgramCode."Marketplace Code";
                END;
            end;
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
        field(580; "Specific Sales"; Boolean)
        {
            Caption = 'Specific Sales';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Specific Sales New';
        }
        field(581; "Specific Sales New"; Enum "AQD Specific Sales")
        {
            Caption = 'Specific Sales';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(590; "Customer No."; Code[20])
        {
            Caption = 'Customer No. Filter';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            trigger OnValidate()
            var
                RebateProgramCode: Record "AQD Cust Rebate Program Code";
            begin
                if Rec."Customer No." <> xRec."Customer No." then
                    if RebateProgramCode.Get("Rebate Program Code") then begin
                        RebateProgramCode."Customer No." := Rec."Customer No.";
                        RebateProgramCode.Modify(false);
                    end;
            end;
        }
        field(600; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Marketplace";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "CustRbt Rate Type", "Entity Type", "Entity No.", "Territory Code", "Line Type", "No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "CustRbt Rate Type", "Entity Type", "Entity No.", "Territory Code", "Line Type", "No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount")
        {
        }
        fieldgroup(Brick; "CustRbt Rate Type", "Entity Type", "Entity No.", "Territory Code", "Line Type", "No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity", "Minimum Amount")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Rebate Program Code");
        CheckRecordAlreadyExist();
    end;

    trigger OnModify()
    begin
        Rec.TestField("Rebate Program Code");
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
        Rec.TestField("Rebate Program Code");
        CheckRecordAlreadyExist();
    end;

    procedure CheckRecordAlreadyExist()
    BEGIN
        //"CustRbt Rate Type", "Entity Type", "Entity No.", "Territory Code", "Line Type", 
        //"No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", 
        //"Minimum Quantity", "Minimum Amount"
        CustomerRebateRate.RESET;
        CustomerRebateRate.SETFILTER("Entry No.", '<>%1', Rec."Entry No.");
        CustomerRebateRate.SETRANGE("CustRbt Rate Type", Rec."CustRbt Rate Type");
        CustomerRebateRate.SETRANGE("Entity Type", Rec."Entity Type");
        CustomerRebateRate.SETRANGE("Entity No.", Rec."Entity No.");
        CustomerRebateRate.SETRANGE("Territory Code", Rec."Territory Code");
        CustomerRebateRate.SETRANGE("Line Type", Rec."Line Type");
        CustomerRebateRate.SETRANGE("No.", Rec."No.");
        CustomerRebateRate.SETRANGE("Variant Code", Rec."Variant Code");
        CustomerRebateRate.SETRANGE("Rebate Program Code", Rec."Rebate Program Code");
        CustomerRebateRate.SETRANGE("Starting Date", Rec."Starting Date");
        CustomerRebateRate.SETRANGE("Unit of Measure Code", Rec."Unit of Measure Code");
        CustomerRebateRate.SetRange("Minimum Quantity", Rec."Minimum Quantity");
        CustomerRebateRate.SetRange("Minimum Amount", Rec."Minimum Amount");
        IF CustomerRebateRate.FindFirst() THEN
            ERROR(Text002,
                Rec.FieldCaption("CustRbt Rate Type"), Rec."CustRbt Rate Type",
                Rec.FieldCaption("Entity Type"), Rec."Entity Type",
                Rec.FieldCaption("Entity No."), Rec."Entity No.",
                Rec.FieldCaption("Territory Code"), Rec."Territory Code",
                Rec.FieldCaption("Line Type"), Rec."Line Type",
                Rec.FieldCaption("No."), Rec."No.",
                Rec.FieldCaption("Variant Code"), Rec."Variant Code",
                Rec.FieldCaption("Rebate Program Code"), Rec."Rebate Program Code",
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