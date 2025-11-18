table 14301920 "AQD Sales Rebates Rate"
{
    Caption = 'Sales Rebates Setup';

    fields
    {
        field(1; "Customer Type"; Enum "AQD Cust Rebate Customer Type")
        {
            Caption = 'Customer Type';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = if ("Customer Type" = const("Customer Type")) "AQD CustRbt RebateCustomerType"
            else if ("Customer Type" = const(Customer)) Customer;
        }
        field(3; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
        }
        field(4; "Line Type"; Enum "AQD Customer Rebate Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF Rec."Line Type" <> xRec."Line Type" then
                    Rec."No." := '';
            end;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Line Type" = const("Rebate Category")) "AQD Cust Rebate Item Category"
            else if ("Line Type" = const(Item)) Item
            else if ("Line Type" = const("G/L Account")) "G/L Account"
            else if ("Line Type" = const(Resource)) Resource
            else if ("Line Type" = const("Fixed Asset")) "Fixed Asset"
            else if ("Line Type" = const("Charge (Item)")) "Item Charge";
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
                        Rec."Line Type"::"Fixed Asset":
                            begin
                                IF FixAsset.Get("No.") THEN
                                    Description := FixAsset.Description
                                ELSE
                                    Description := '';
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"Charge (Item)":
                            BEGIN
                                IF ItemCharge.Get("No.") THEN
                                    Description := ItemCharge.Description;
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            END;
                        Rec."Line Type"::"Rebate Category":
                            BEGIN
                                IF RebateItemCategory.Get("No.") then
                                    Description := RebateItemCategory.Description
                                ELSE
                                    Description := '';
                            END;
                    END;
                END;
            END;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
        }

        field(7; "Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";

            trigger OnValidate()
            var
                RebateProgramCode: Record "AQD Cust Rebate Program Code";
            begin
                IF Rec."Rebate Program Code" <> '' THEN BEGIN
                    RebateProgramCode.GET(rEC."Rebate Program Code");
                    Rec."Rebate Type" := RebateProgramCode."Customer Default Rebate Type";
                    Rec."Rebate %" := RebateProgramCode."Customer Default Rebate %";
                    Rec."Rebate Per Unit" := RebateProgramCode."Customer Def Rebate Per Unit";
                END;
            end;
        }
        field(8; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if ("Line Type" = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(11; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(30; "Rebate Type"; Option)
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
        field(40; "Rebate %"; Decimal)
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
        field(50; "Rebate Per Unit"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate Per Unit';
            MinValue = 0;
            trigger OnValidate()
            begin
                Rec.TestField("Rebate Type");
            end;
        }
        field(60; "Ending Date"; Date)
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
        field(550; "Blocked"; Boolean)
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
        field(903; "Blocked By"; Code[50])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(904; "Blocked Date Time"; DateTime)
        {
            Caption = 'Blocked Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Customer Type", "Customer No.", "Territory Code", "Line Type", "No.", "Variant Code", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Rec.TestField("Rebate Program Code");
    end;

    trigger OnModify()
    begin
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

    var
        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Customer: Record Customer;
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
        RebateItemCategory: Record "AQD Cust Rebate Item Category";
}