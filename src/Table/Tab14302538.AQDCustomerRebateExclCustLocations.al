table 14302538 "AQD Cust Rbt Exclude Cust Loc"
{
    Caption = 'Exclude Customer Location';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer Type"; Enum "AQD Cust Rebate Customer Type")
        {
            Caption = 'Customer Type';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = if ("Customer Type" = const("Customer Category")) "AQD Rebate Customer Category"
            else if ("Customer Type" = const(Customer)) Customer;
        }
        field(3; "Location Type"; ENUM "AQD CustRbt Cust Location Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF Rec."Location Type" <> xRec."Location Type" THEN begin
                    Rec."Location Code" := '';
                    Rec.Description := '';
                end
            end;
        }
        field(4; "Location Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Location Type" = const(Location)) Location where("Use As In-Transit" = const(false))
            else if ("Location Type" = const(Territory)) Territory
            else if ("Location Type" = const("Ship-To Address")) "Ship-to Address".Code;

            trigger OnValidate()
            begin
                CASE "Location Type" OF
                    "Location Type"::Location:
                        BEGIN
                            IF Location.GET("Location Code") then
                                Description := Location.Name
                            ELSE
                                Description := '';
                        END;
                    "Location Type"::Territory:
                        BEGIN
                            IF Territory.GET("Location Code") then
                                Description := Territory.Name
                            ELSE
                                Description := '';
                        END;
                    "Location Type"::"Ship-To Address":
                        BEGIN
                            Rec.TestField("Customer Type", Rec."Customer Type"::Customer);
                            Rec.TestField("Customer No.");
                            Rec.TestField("Location Type", Rec."Location Type"::"Ship-To Address");
                            IF ShipToAddress.GET("Customer No.", "Location Code") THEN
                                Description := ShipToAddress.Name
                            ELSE IF Customer.GET("Customer No.") THEN
                                Description := Customer.Name;
                        END;
                END;
            END;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Customer Type", "Customer No.", "Location Type", "Location Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Customer Type", "Customer No.", "Location Type", "Location Code")
        {
        }
        fieldgroup(Brick; "Customer Type", "Customer No.", "Location Type", "Location Code")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Location Type");
        Rec.TESTFIELD("Location Code");
    end;

    var
        Location: Record Location;
        Customer: Record Customer;
        Territory: Record Territory;
        ShipToAddress: Record "Ship-to Address";
}