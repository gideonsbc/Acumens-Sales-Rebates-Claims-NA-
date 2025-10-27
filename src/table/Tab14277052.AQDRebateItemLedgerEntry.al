table 14277052 "AQD Rebate Item Ledger Entry"
{
    Caption = 'Rebate Item Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor
            else
            if ("Source Type" = const(Item)) Item;
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(33; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(34; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(36; Positive; Boolean)
        {
            Caption = 'Positive';
        }
        field(41; "Source Type"; Enum "Analysis Source Type")
        {
            Caption = 'Source Type';
        }
        field(47; "Drop Shipment"; Boolean)
        {
            Caption = 'Drop Shipment';
        }
        field(61; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(79; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(80; "Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Document Line No.';
        }
        field(90; "Order Type"; Enum "Inventory Order Type")
        {
            Caption = 'Order Type';
            Editable = false;
        }
        field(91; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
        }
        field(92; "Order Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No.';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5706; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5803; "Cost Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Cost Amount (Expected)" where("Item Ledger Entry No." = field("Entry No.")));
            Caption = 'Cost Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5804; "Cost Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Cost Amount (Actual)" where("Item Ledger Entry No." = field("Entry No.")));
            Caption = 'Cost Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5805; "Cost Amount (Non-Invtbl.)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Cost Amount (Non-Invtbl.)" where("Item Ledger Entry No." = field("Entry No.")));
            Caption = 'Cost Amount (Non-Invtbl.)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5813; "Purchase Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Purchase Amount (Expected)" where("Item Ledger Entry No." = field("Entry No.")));
            Caption = 'Purchase Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5814; "Purchase Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Purchase Amount (Actual)" where("Item Ledger Entry No." = field("Entry No.")));
            Caption = 'Purchase Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5817; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(6510; "Item Tracking"; Enum "Item Tracking Entry Type")
        {
            Caption = 'Item Tracking';
            Editable = false;
        }
        field(6602; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(14277004; "AQD Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277005; "AQD Rebate %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate %';
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(14277006; "AQD Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor WHERE("AQD Vendor Type" = CONST("Rebate Vendor"));
            DataClassification = CustomerContent;
        }
        field(14277007; "AQD Rebate Entry Created"; Boolean)
        {
            Caption = 'Rebate Entry Created';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277008; "AQD Rebate Last Changed By"; Code[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14277009; "AQD Rebate LastChangd DateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            DataClassification = CustomerContent;
        }
        field(14277010; "AQD Rebate No"; Code[20])
        {
            Caption = 'Rebate No.';
            DataClassification = CustomerContent;
        }
        field(14277015; "AQD Rebate Line No"; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Line No.';
            DataClassification = CustomerContent;
        }
        field(14277020; "AQD Rebate Detail Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Detail Line No.';
            DataClassification = CustomerContent;
        }
        field(14277021; "AQD Rebate Status"; Enum "AQD Vendor Rebate Status")
        {
            Caption = 'Rebate Status';
            DataClassification = CustomerContent;
        }
        field(14277022; "AQD Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;
            Editable = false;
        }
        field(14277023; "Rebate Per Quantity"; Decimal)
        {
            Caption = 'Rebate Per Quantity';
            Editable = false;
        }
        field(14277024; "Rebate Amount"; Decimal)
        {
            Caption = 'Rebate Amount';
            Editable = false;
        }
        field(14277030; "AQD Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            TableRelation = Vendor;
            ToolTip = 'Specifies the number of the vendor that you received the invoice from.';
        }
        field(14277040; "AQD Pay-to Name"; Text[100])
        {
            Caption = 'Pay-to Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = Field("AQD Pay-To Vendor No.")));
            Editable = false;
        }
        field(14277050; "AQD Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;
            ToolTip = 'Specifies the number of the vendor that you have purchased from.';
        }
        field(14277060; "AQD Buy-from Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = Field("AQD Buy-from Vendor No.")));
        }
        field(14277070; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(14277080; "AQD Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(14277090; "AQD Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
        }
        field(14277100; "Document Posting Description"; Text[100])
        {
            Caption = 'Document Posting Description';
        }
        field(14277110; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(14277120; "Vendor Order No."; Code[35])
        {
            Caption = 'Vendor Order No.';
        }
        field(14277140; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(14277150; "Vendor Cr. Memo No."; Code[35])
        {
            Caption = 'Vendor Cr. Memo No.';
        }
        field(14277160; "AQD Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        Key(Key2; "AQD Pay-to Vendor No.", "AQD Buy-From Vendor No.", "Posting Date", "Document Type", "Document No.", "Document Line No.", "Location Code")
        {
            SumIndexFields = Quantity, "Invoiced Quantity";
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Entry No.", Description, "Item No.", "Posting Date", "Entry Type", "Document No.")
        {
        }
        fieldgroup(Brick; "Item No.", Description, Quantity, "Document No.")
        { }
    }
}