table 14302706 "AQD Sales Comm. Doc. Header"
{
    Caption = 'Sales Commission Document Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Sales Commission Documents";
    LookupPageId = "AQD Sales Commission Documents";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Document Type"; enum "AQD CR Commission Doc. Type")
        {
            DataClassification = CustomerContent;
        }
        field(3; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
            trigger OnValidate()
            begin
                if Customer.Get("Sell-To Customer No.") then begin
                    "Sell-To Customer Name" := Customer.Name;
                    Validate("Bill-To Customer No.", Customer."Bill-to Customer No.");
                end;
            end;
        }
        field(6; "Sell-To Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            Editable = false;
        }
        field(7; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer;
            trigger OnValidate()
            begin
                if Customer.Get("Bill-To Customer No.") then
                    "Bill-To Customer Name" := Customer.Name;
            end;
        }
        field(8; "Bill-To Customer Name"; Text[100])
        {
            Caption = 'Bill-to Customer Name';
            Editable = false;
        }
        field(9; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(11; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(12; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(13; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(14; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
        }
        field(15; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
        }
        field(16; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
        }
        field(17; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(18; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(19; "Commission Type"; Enum "AQD CR Commission Type")
        {
            Caption = 'Commission Type';
            InitValue = 'Collect Commission';
        }
        field(20; Processed; Boolean)
        {
            Caption = 'Processed';
            Editable = false;
        }
        field(21; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Sales Comm. Doc. Line".Amount where("Document No." = field("No.")));
            Editable = false;
        }
        field(31; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Sales Comm. Doc. Line"."Amount Including VAT" where("Document No." = field("No.")));
            Editable = false;
        }
        field(40; "Do Not Collect"; Boolean)
        {
            Caption = 'Do Not Collect';
            DataClassification = CustomerContent;
        }
        field(44; "Order No."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Order No.';
            ToolTip = 'Specifies the number of the related order.';
        }
        field(46; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(50; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(55; "Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
        }
        field(60; "Rebate No"; Code[20])
        {
            Caption = 'Sales Rebate No.';
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(92; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
            ToolTip = 'Specifies the state, province or county as a part of the address.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "External Document No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "Commission Type" := "Commission Type"::"Collect Commission";
        "Document Date" := Today;
        "Posting Date" := Today;
        "Order Date" := Today;
        "Rebate Order Date" := Today;
    end;

    var
        Customer: Record Customer;
}
