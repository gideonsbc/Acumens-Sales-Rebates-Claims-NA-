table 14277043 "AQD Vendor Rebate Rate"
{
    Caption = 'Vendor Rebate Rates';

    fields
    {
        field(1; "Line Type"; Enum "AQD Vendor Rebate Line Type")
        {
            Caption = 'Line Type';
            trigger OnValidate()
            begin
                IF Rec."Line Type" <> xRec."Line Type" then
                    Rec."No." := '';
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Line Type" = const("Rebate Category")) "AQD Rebate Item Category"
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
                                Item.Get("No.");
                                Description := Item.Description;
                                Rec."Unit of Measure Code" := Item."Purch. Unit of Measure";
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::Resource:
                            begin
                                Resource.Get("No.");
                                Description := Resource.Name;
                                Rec."Unit of Measure Code" := Resource."Base Unit of Measure";
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"G/L Account":
                            begin
                                GLAccount.Get("No.");
                                Description := GLAccount.Name;
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"Fixed Asset":
                            begin
                                FixAsset.Get("No.");
                                Description := FixAsset.Description;
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"Charge (Item)":
                            begin
                                ItemCharge.Get("No.");
                                Description := ItemCharge.Description;
                                Rec."Unit of Measure Code" := '';
                                Rec."Variant Code" := '';
                            end;
                        Rec."Line Type"::"Rebate Category":
                            begin
                                ItemRebateCategory.Get("No.");
                                Description := ItemRebateCategory.Description;
                            end;
                    end;
                end;
            end;
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
        }
        field(4; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = if ("Vendor Type" = const("Vendor Type")) "AQD Rebate Vendor Type"
            else if ("Vendor Type" = const(Vendor)) Vendor;
        }
        field(5; "Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Rebate Program Code";

            trigger OnValidate()
            var
                RebateProgramCodeRec: Record "AQD Rebate Program Code";
            begin
                RebateProgramCodeRec.GET(Rec."Rebate Program Code");
                IF RebateProgramCodeRec."Vendor Default Rebate Type" = RebateProgramCodeRec."Vendor Default Rebate Type"::" " then begin
                    Rec."Rebate Type" := RebateProgramCodeRec."Vendor Default Rebate Type";
                    Rec."Rebate %" := RebateProgramCodeRec."Vendor Default Rebate %";
                    Rec."Rebate Per Quantity" := RebateProgramCodeRec."Vendor Def Rebate Per Quantity";
                end;
            end;
        }
        field(6; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(7; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(8; "Vendor Type"; Enum "AQD Rebate Vendor Type")
        {
            Caption = 'Vendor Type';
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
                    Rec."Rebate Per Quantity" := 0;
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
        field(50; "Rebate Per Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate Per Quantity';
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
        field(70; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if ("Line Type" = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
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
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;
        }
        field(530; "Last Rebate Per Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Last Rebate Per Quantity';
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
        key(Key1; "Line Type", "No.", "Variant Code", "Vendor Type", "Vendor No.", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Rebate Program Code", "Line Type", "No.", "Variant Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Line Type", "No.", "Variant Code", "Vendor No.", "Rebate Program Code", "Starting Date", "Unit of Measure Code", "Minimum Quantity")
        {
        }
    }

    trigger OnInsert()
    var
        RebateProgramCodeRec: Record "AQD Rebate Program Code";
    begin
        //Rec.TestField("Vendor No.");
        //Rec.TestField("No.");
        Rec.TestField("Rebate Program Code");

        RebateProgramCodeRec.GET(Rec."Rebate Program Code");
        IF RebateProgramCodeRec."Vendor Default Rebate Type" = RebateProgramCodeRec."Vendor Default Rebate Type"::" " then begin
            Rec."Rebate Type" := RebateProgramCodeRec."Vendor Default Rebate Type";
            Rec."Rebate %" := RebateProgramCodeRec."Vendor Default Rebate %";
            Rec."Rebate Per Quantity" := RebateProgramCodeRec."Vendor Def Rebate Per Quantity";
        end;
    end;

    trigger OnRename()
    begin
        //Rec.TestField("Vendor No.");
        //Rec.TestField("No.");
    end;

    var
        Vend: Record Vendor;
        Text000: Label '%1 cannot be after %2';
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
        ItemRebateCategory: Record "AQD Rebate Item Category";

    procedure CopyVendorPurchPriceToVendorsPurchPrice(var VendorPurchRebates: Record "AQD Vendor Rebate Rate"; VendNo: Code[20])
    var
        NewVendorPurchRebates: Record "AQD Vendor Rebate Rate";
    begin
        if VendorPurchRebates.FindSet() then
            repeat
                NewVendorPurchRebates := VendorPurchRebates;
                NewVendorPurchRebates."Vendor No." := VendNo;
                OnBeforeNewPurchasePriceInsert(NewVendorPurchRebates, VendorPurchRebates);
                if NewVendorPurchRebates.Insert() then;
            until VendorPurchRebates.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNewPurchasePriceInsert(var NewPurchaseRebates: Record "AQD Vendor Rebate Rate"; PurchaseRebates: Record "AQD Vendor Rebate Rate")
    begin
    end;
}