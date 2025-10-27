table 14277016 "AQD Rebate Entry"
{
    Caption = 'Rebate Entry';
    DrillDownPageID = "AQD Rebate Entries";
    LookupPageID = "AQD Rebate Entries";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(14277005; "Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
        }
        field(14277006; "AQD Rebate Type"; Option)
        {
            Caption = 'Pay-To Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
        }
        field(14277007; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Invoice,Credit Memo,Adjustment';
            OptionMembers = " ",Invoice,"Credit Memo",Adjustment;
        }
        field(14277008; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = IF ("Document Type" = CONST(Invoice)) "Sales Invoice Header"."No."
            ELSE
            IF ("Document Type" = CONST("Credit Memo")) "Sales Cr.Memo Header"."No.";
        }
        field(14277009; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(14277010; "Document Posting Date"; Date)
        {
            Caption = 'Document Posting Date';
            Editable = false;
        }
        field(14277011; "State"; Text[30])
        {
            Caption = 'State';
        }
        field(14277012; "Type"; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(14277013; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF ("Type" = FILTER("G/L Account")) "G/L Account"."No."
            ELSE
            IF ("Type" = CONST(Item)) Item."No."
            ELSE
            IF ("Type" = CONST(Resource)) Resource."No."
            ELSE
            IF ("Type" = CONST("Fixed Asset")) "Fixed Asset"."No.";
        }
        field(14277014; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(14277015; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(14277016; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(14277017; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                StandardCodesMgt: Codeunit "Standard Codes Mgt.";
            begin
            end;
        }
        field(14277018; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
        }
        field(14277019; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(14277020; "Billl-to Customer Name"; Text[100])
        {
            Caption = 'Billl-to Customer Name';
        }
        field(14277021; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(14277022; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14277023; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";

            trigger OnValidate()
            var
                ItemAttributeManagement: Codeunit "Item Attribute Management";
            begin
            end;
        }
        field(14277024; "Open"; Boolean)
        {
            Caption = 'Open';
        }
        field(14277025; "Payable"; Boolean)
        {
            Caption = 'Payable';
        }
        field(14277026; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
        field(14277027; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(14277028; "Line Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Amount';
        }
        field(14277029; "Base Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base Amount';
        }
        field(14277030; "Rebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Rebate Amount';
        }
        field(14277031; "Remaining Rebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Rebate Amount';
        }
        field(14277032; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            Editable = false;
        }
        field(14277033; "Rebate Payment Method"; Option)
        {
            Caption = 'Rebate Payment Method';
            Editable = false;
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
        }
        field(14277034; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 2 : 2;
        }
        field(14277035; "Profit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Profit Amount';
        }
        field(14277036; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
            end;
        }
        field(14277037; "Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
        }
        field(14277038; "Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Register No.';
            Editable = false;
        }
        field(14277039; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(14277040; "Journal Batch Name"; Code[50])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(14277041; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
        }
        field(14277042; "Journal Document No."; Code[20])
        {
            Caption = 'Journal Document No.';
        }
        field(14277043; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(14277050; "Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;
        }
        field(14277051; "Rebate Per Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate Per Quantity';
            MinValue = 0;
        }
        field(14277055; "Rebate Item Category Code"; Code[20])
        {
            Caption = 'Rebate Item Category Code';
            TableRelation = "AQD Rebate Item Category";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Rebate Code", "Document Posting Date", "Open", "Payable", "Document Type", "State")
        {
            SumIndexFields = "Remaining Rebate Amount", "Rebate Amount", "Base Amount";
        }
        key(Key3; "Document No.", "Document Line No.", "Rebate Code")
        {
            SumIndexFields = "Remaining Rebate Amount", "Rebate Amount", "Base Amount";
        }
        key(Key4; "Open", "Payable", "Rebate Code")
        {
            SumIndexFields = "Remaining Rebate Amount";
        }
        key(Key5; "Rebate Code", "Payable", "Open")
        {
            SumIndexFields = "Rebate Amount", "Remaining Rebate Amount";
        }
        key(Key6; "Document Posting Date", "Document No.", "Document Line No.")
        {
        }
        key(Key7; "Document Type", "Rebate Amount")
        {
        }
        key(Key8; "Rebate Code", "Document Posting Date", "Rebate Amount")
        {
        }
        key(Key9; "Sell-to Customer No.", "Document Type", "Rebate Code", "Document No.", "Document Line No.")
        {
        }
        key(Key10; "Sell-to Customer No.", "Document Type", "Rebate Code")
        {
        }
        key(Key11; "Document No.", "Sell-to Customer No.", "Document Line No.", "Document Type")
        {
        }
        key(Key12; "Journal Template Name", "Journal Batch Name", "Journal Line No.")
        {
        }
        key(Key13; "Rebate Code", "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

