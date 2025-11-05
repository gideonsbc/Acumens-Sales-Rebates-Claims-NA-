table 14301937 "AQD Cust Rbt Include Cust Loc"
{
    Caption = 'Include Customer Location';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Location Type"; ENUM "AQD CustRbt Cust Location Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(2; "Location Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Location Type" = const(Location)) Location where("Use As In-Transit" = const(false))
            else if ("Location Type" = const(Territory)) Territory
            else if ("Location Type" = const("Ship-To Address")) Customer;

            trigger OnValidate()
            begin
                IF Rec."Location Code" <> xRec."Location Code" THEN
                    Rec."Ship-To Code" := '';

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
                            IF ShipToAddress.GET("Location Code", "Ship-To Code") THEN
                                Description := ShipToAddress.Name
                            ELSE IF Customer.GET("Location Code") THEN
                                Description := Customer.Name;
                        END;
                END;
            END;
        }
        field(3; "Ship-To Code"; Code[10])
        {
            Caption = 'Ship-To Code';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code;
            trigger OnValidate()
            BEGIN
                Rec.TestField("Location Type", Rec."Location Type"::"Ship-To Address");
                Rec.TestField("Location Code");

                IF ShipToAddress.GET("Location Code", "Ship-To Code") THEN
                    Description := ShipToAddress.Name
                ELSE IF Customer.GET("Location Code") THEN
                    Description := Customer.Name;
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
        key(PK; "Location Type", "Location Code", "Ship-To Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Location Type", "Location Code", "Ship-To Code")
        {
        }
        fieldgroup(Brick; "Location Type", "Location Code", "Ship-To Code")
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