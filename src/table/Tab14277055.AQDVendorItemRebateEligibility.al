table 14277055 "AQD VendItem Rebate Eligib"
{
    Caption = 'Vendor Item Rebate Eligibility';
    DataClassification = CustomerContent;

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
                            end;
                        Rec."Line Type"::Resource:
                            begin
                                Resource.Get("No.");
                                Description := Resource.Name;
                            end;
                        Rec."Line Type"::"G/L Account":
                            begin
                                GLAccount.Get("No.");
                                Description := GLAccount.Name;
                            end;
                        Rec."Line Type"::"Fixed Asset":
                            begin
                                FixAsset.Get("No.");
                                Description := FixAsset.Description;
                            end;
                        Rec."Line Type"::"Charge (Item)":
                            begin
                                ItemCharge.Get("No.");
                                Description := ItemCharge.Description;
                            end;
                        Rec."Line Type"::"Rebate Category":
                            begin
                                RebateItemCategory.Get("No.");
                                Description := RebateItemCategory.Description;
                            end;
                    end;
                end;
            end;
        }
        field(3; "Vendor Type"; Enum "AQD Rebate Vendor Type")
        {
            Caption = 'Vendor Type';
        }
        field(4; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = if ("Vendor Type" = const("Vendor Type")) "AQD Rebate Vendor Type"
            else if ("Vendor Type" = const(Vendor)) Vendor;
        }
        field(6; "Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Rebate Program Code";
        }

        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(100; "Purchase Amount Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Purchase Amount Threshold';
        }
        field(110; "Purchase Quantity Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Purchase Quantity Threshold';
        }
        field(120; "EligiblePeriodAfterFirstRcpt"; DateFormula)
        {
            Caption = 'Eligible Period After First Receipt';
        }
        field(950; "Blocked"; Boolean)
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
        field(960; "Blocked By"; Code[50])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(970; "Blocked Date Time"; DateTime)
        {
            Caption = 'Blocked Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Line Type", "No.", "Vendor Type", "Vendor No.", "Rebate Program Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Line Type", "No.", "Vendor Type", "Vendor No.", "Rebate Program Code")
        {
        }
        fieldgroup(Brick; "Line Type", "No.", "Vendor Type", "Vendor No.", "Rebate Program Code")
        {
        }
    }
    var
        Vend: Record Vendor;
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
        RebateItemCategory: Record "AQD Rebate Item Category";
}