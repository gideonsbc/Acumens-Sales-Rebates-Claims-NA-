table 14301923 "AQD Cust Rebate Journal Line"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "AQD User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("AQD User ID");
            end;
        }
        field(2; "AQD Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(20; "AQD Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
        }
        field(30; "AQD Pay-To Rebate Type"; Option)
        {
            Caption = 'Pay-To Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
        }
        field(40; "AQD Name"; Text[100])
        {
            Caption = 'Name';
        }
        field(50; "AQD State"; Text[30])
        {
            Caption = 'State';
        }
        field(60; "AQD Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(70; "AQD Location Name"; Text[100])
        {
            CalcFormula = Lookup(Location.Name WHERE(Code = FIELD("AQD Location Code")));
            Caption = 'Location Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "AQD Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(90; "AQD Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(100; "AQD Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = ' ,Invoice,Credit Memo,Adjustment';
            OptionMembers = " ",Invoice,"Credit Memo",Adjustment;
        }
        field(110; "AQD Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(120; "AQD Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(130; "AQD Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(140; "AQD Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(150; "AQD Bill-to Customer Name"; Text[100])
        {
            Caption = 'Bill-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
        }
        field(160; "AQD Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
            Editable = false;
        }
        field(170; "AQD Rebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Rebate Amount';
            Editable = false;
        }
        field(180; "AQD Profit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Profit Amount';
            Editable = false;
        }
        field(190; "AQD Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(200; "AQD End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(210; "AQD Run For"; Option)
        {
            Caption = 'Run For';
            OptionCaption = 'Review,Process';
            OptionMembers = Review,Process;
        }
        field(220; "AQD Payee Type"; Option)
        {
            Caption = 'Payee Type';
            Editable = false;
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Vendor,W2 Employee';
            OptionMembers = " ","1099 Vendor","W2 Employee";
        }
    }

    keys
    {
        key(Key1; "AQD User ID", "AQD Line No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
}