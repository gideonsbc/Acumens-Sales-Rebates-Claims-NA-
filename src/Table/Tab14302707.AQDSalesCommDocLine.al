table 14302707 "AQD Sales Comm. Doc. Line"
{
    Caption = 'Sales Commission Document Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "AQD Sales Comm. Doc. Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(4; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = if (Type = const(" ")) "Standard Text"
            else
            if (Type = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false))
            else
            if (Type = const(Resource)) Resource
            else
            if (Type = const("Fixed Asset")) "Fixed Asset"
            else
            if (Type = const("Charge (Item)")) "Item Charge"
            else
            if (Type = const("Allocation Account")) "Allocation Account"
            else
            if (Type = const(Item)) Item where(Blocked = const(false));

            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    Case Rec.Type OF
                        Rec.Type::Item:
                            begin
                                IF "No." <> '' THEN BEGIN
                                    Item.Get("No.");
                                    Description := Item.Description;
                                    "Unit of Measure Code" := Item."Purch. Unit of Measure";
                                END ELSE BEGIN
                                    Description := '';
                                    "Unit of Measure Code" := '';
                                END;
                                "Variant Code" := '';
                            end;
                        Rec.Type::"Fixed Asset":
                            begin
                                IF "No." <> '' THEN BEGIN
                                    FixAsset.Get("No.");
                                    Description := FixAsset.Description;
                                END ELSE BEGIN
                                    Description := '';
                                    "Unit of Measure Code" := '';
                                END;
                                "Variant Code" := '';
                            end;
                        Rec.Type::Resource:
                            begin
                                IF Resource.Get("No.") THEN BEGIN
                                    Description := Resource.Name;
                                    "Unit of Measure Code" := Resource."Base Unit of Measure";
                                END ELSE BEGIN
                                    Description := '';
                                    "Unit of Measure Code" := '';
                                END;
                                "Variant Code" := '';
                            end;
                        Rec.Type::"G/L Account":
                            begin
                                IF GLAccount.Get("No.") THEN
                                    Description := GLAccount.Name
                                ELSE
                                    Description := '';
                                "Unit of Measure Code" := '';
                                "Variant Code" := '';
                            end;
                    END;
                END;
            END;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(8; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(9; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(10; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(12; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
        }
        field(13; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(14; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(15; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(16; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(17; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
        }
        field(18; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
        }
        field(19; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
        }
        field(20; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(21; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(22; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(23; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
        }
        field(24; "Shipment No."; Code[20])
        {
            Caption = 'Shipment No.';
        }
        field(25; "Shipment Line No."; Integer)
        {
            Caption = 'Shipment Line No.';
        }
        field(26; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(27; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
        }
        field(28; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Document No.", "Source Document Line No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if SalesDocHeader.Get("Document No.") then begin
            "Shortcut Dimension 1 Code" := SalesDocHeader."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := SalesDocHeader."Shortcut Dimension 2 Code";
        end;
    end;

    var
        SalesDocHeader: Record "AQD Sales Comm. Doc. Header";
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
}
