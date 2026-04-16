table 14302611 "AQD Customer Claim Vendors"
{
    Caption = 'Claim Vendors';
    DataClassification = CustomerContent;
    LookupPageID = "AQD Customer Claim Vendors";
    DrillDownPageId = "AQD Customer Claim Vendors";

    fields
    {
        field(1; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = TRUE;
            TableRelation = Customer."No.";
            trigger OnValidate()
            var
                Customer: Record Customer;
            BEGIN
                IF Rec."Bill-to Customer No." <> '' THEN BEGIN
                    Customer.GET(Rec."Bill-to Customer No.");
                    Rec."Bill-to Name" := Customer.Name;
                    Rec."Bill-to Name 2" := Customer."Name 2";
                    Rec."Bill-to Address" := Customer.Address;
                    Rec."Bill-to Address 2" := Customer."Address 2";
                    Rec."Bill-to City" := Customer.City;
                    Rec."Bill-to Post Code" := Customer."Post Code";
                    Rec."Bill-to County" := Customer.County;
                    Rec."Bill-to Country/Region Code" := Customer."Country/Region Code";
                END ELSE BEGIN
                    Rec."Bill-to Name" := '';
                    Rec."Bill-to Name 2" := '';
                    Rec."Bill-to Address" := '';
                    Rec."Bill-to Address 2" := '';
                    Rec."Bill-to City" := '';
                    Rec."Bill-to Post Code" := '';
                    Rec."Bill-to County" := '';
                    Rec."Bill-to Country/Region Code" := '';
                END;
            END;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = TRUE;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                IF "Vendor No." <> '' THEN BEGIN
                    Vendor.GET("Vendor No.");
                    "Vendor Name" := Vendor.Name;
                    "Vendor Name 2" := Vendor."Name 2";
                    "Vendor Address" := Vendor.Address;
                    "Vendor Address 2" := Vendor."Address 2";
                    "Vendor City" := Vendor."Post Code";
                    "Vendor Post Code" := Vendor."Post Code";
                    "Vendor County" := Vendor.County;
                    "Vendor Country/Region Code" := Vendor."Country/Region Code";
                END ELSE BEGIN
                    "Vendor Name" := '';
                    "Vendor Name 2" := '';
                    "Vendor Address" := '';
                    "Vendor Address 2" := '';
                    "Vendor City" := '';
                    "Vendor Post Code" := '';
                    "Vendor County" := '';
                    "Vendor Country/Region Code" := '';
                END;
            end;
        }

        field(20; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            Editable = true;
        }
        field(30; "Vendor Name 2"; Text[50])
        {
            Caption = 'Vendor Name 2';
            Editable = true;
        }
        field(40; "Vendor Address"; Text[100])
        {
            Caption = 'Vendor Address';
            Editable = true;
        }
        field(50; "Vendor Address 2"; Text[50])
        {
            Caption = 'Vendor Address 2';
            Editable = true;
        }
        field(60; "Vendor City"; Text[30])
        {
            Caption = 'Vendor City';
            Editable = true;
        }
        field(70; "Vendor Country/Region Code"; Code[10])
        {
            Caption = 'Vendor Country/Region Code';
            Editable = true;
        }
        field(80; "Vendor Post Code"; Code[20])
        {
            Caption = 'Vendor Post Code';
            Editable = true;
        }
        field(90; "Vendor County"; Text[30])
        {
            Caption = 'Vendor County';
            Editable = true;
            CaptionClass = '5,1,' + "Vendor Country/Region Code";
        }
        field(100; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            Editable = true;
        }
        field(110; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            Editable = true;
        }
        field(120; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            Editable = true;
        }
        field(130; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
            Editable = true;
        }
        field(140; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            Editable = true;
        }
        field(150; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            Editable = true;
        }
        field(160; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to County';
            Editable = true;
            CaptionClass = '5,1,' + "Bill-to Country/Region Code";
        }
        field(170; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            Editable = true;
        }
        field(180; "Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Bill-to Customer No.", "Vendor No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Vendor No.", "Vendor Name", "Bill-to Name")
        {
        }
        fieldgroup(Brick; "Vendor No.", "Vendor Name", "Bill-to Name")
        {
        }
    }
}