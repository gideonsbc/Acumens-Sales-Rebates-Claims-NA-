table 14301930 "AQD Customer Rebate Details"
{
    Caption = 'Customer Rebate Details';
    DataClassification = CustomerContent;
    DrillDownPageID = "AQD Customer Rebate Details";
    LookupPageID = "AQD Customer Rebate Details";

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            Editable = false;
        }
        field(2; "Rebate Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Line No.';
            Editable = false;
        }
        field(3; "Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Line No.';
            Editable = false;
        }
        field(20; "Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(30; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(40; "Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Document Line No.';
            Editable = false;
        }
        field(45; "Entity Type"; Enum "AQD CR Rebate Entity Type")
        {
            Caption = 'Entity Type';
            Editable = false;
        }
        field(46; "Entity No."; Code[20])
        {
            Caption = 'Entity No.';
            Editable = false;
            TableRelation = if ("Entity Type" = const(Customer)) Customer."No."
            else if ("Entity Type" = const(Employee)) Employee."No."
            else if ("Entity Type" = const(Vendor)) Vendor."No.";
        }
        field(50; Type; enum "AQD Cust Rebate Record Type")
        {
            Caption = 'Type';
            Editable = false;
        }
        field(60; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(65; "Rebate Item Category Code"; Code[20])
        {
            Caption = 'Rebate Item Category Code';
            TableRelation = "Item Category".Code;
        }
        field(66; "Rebate Program Code"; Code[10])
        {
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(70; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(80; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
        }
        field(90; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(100; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            Editable = false;
        }
        field(104; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 2 : 2;
        }
        field(105; "Profit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Profit Amount';
        }
        field(110; "Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Unit,Percentage';
            OptionMembers = " ","Per Unit",Percentage;
            Editable = false;
        }
        field(125; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            Editable = false;
        }
        field(130; "Rebate Per Unit"; Decimal)
        {
            Caption = 'Rebate Per Unit';
            Editable = false;
        }
        field(140; "Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            Editable = false;
        }
        field(145; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(150; Amount; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
        }
        field(160; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            Editable = false;
        }
        field(170; "Calculated Line Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            Editable = false;
        }
        field(178; "Vendor Commission"; Decimal)
        {
            Caption = 'Vendor Commission';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "Entity Type" = const(Vendor)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(179; "Employee Commission"; Decimal)
        {
            Caption = 'Employee Commission';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "Entity Type" = const(Employee)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(180; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Customer Rebate Amount';
            trigger OnValidate()
            begin
                UpdateChangedBy();
            end;
        }
        field(190; "Do Not Credit"; Boolean)
        {
            Caption = 'Do Not Credit';
            trigger OnValidate()
            begin
                if "Do Not Credit" then
                    Validate("Customer Rebate Amount", 0)
                else
                    Validate("Customer Rebate Amount", "Calculated Line Rebate Amount");
                UpdateChangedBy();
            end;
        }
        field(200; "Rebate Amount Changed By"; Code[50])
        {
            Caption = 'Rebate Amount Changed By';
            Editable = false;
        }
        field(210; "Rebate Amount Changed DateTime"; DateTime)
        {
            Caption = 'Rebate Amount Changed DateTime';
            Editable = false;
        }
        field(220; "Original Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(230; "Ineligible"; Boolean)
        {
            Caption = 'Ineligible';
            Editable = false;
        }
        field(300; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(310; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(320; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(325; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
            DataClassification = CustomerContent;
            Editable = FALSE;
        }
        field(330; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
        }
        field(340; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
        }
        field(401; State; Text[30])
        {
            Caption = 'State';
        }
        field(500; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-To Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(501; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(510; "Rebate-To Customer No."; Code[20])
        {
            Caption = 'Rebate-To Customer No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(560; "Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Customer Rebate Status';
            DataClassification = CustomerContent;
        }
        field(570; "Applies-to Doc. Type"; Enum "Sales Applies-to Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(580; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Order)) "Sales Header"."No." where("Document Type" = const(Order))
            else
            if ("Applies-to Doc. Type" = const(Invoice)) "Sales Header"."No." where("Document Type" = const(Invoice))
            else
            if ("Applies-to Doc. Type" = const("Return Order")) "Sales Header"."No." where("Document Type" = const("Return Order"))
            else
            if ("Applies-to Doc. Type" = const("Credit Memo")) "Sales Header"."No." where("Document Type" = const("Credit Memo"))
            else
            if ("Applies-to Doc. Type" = const(Shipment)) "Sales Shipment Header"."No."
            else
            if ("Applies-to Doc. Type" = const("Return Receipt")) "Return Receipt Header"."No.";
        }
        field(590; "Applies-to Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Doc. Line No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Order)) "Sales Line"."Line No." where("Document Type" = const(Order),
                                                                                                       "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const(Invoice)) "Sales Line"."Line No." where("Document Type" = const(Invoice),
                                                                                                                                                                                         "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Return Order")) "Sales Line"."Line No." where("Document Type" = const("Return Order"),
                                                                                                                                                                                                                                                                                  "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Credit Memo")) "Sales Line"."Line No." where("Document Type" = const("Credit Memo"),
                                                                                                                                                                                                                                                                                                                                                                          "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const(Shipment)) "Sales Shipment Line"."Line No." where("Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Return Receipt")) "Return Receipt Line"."Line No." where("Document No." = field("Applies-to Doc. No."));
        }
        field(600; "Batch Entry No."; Integer)
        {
            Editable = FALSE;
            Caption = 'Batch Entry No.';
        }
        field(950; BatchID; Code[50])
        {
            Caption = 'BatchId';
        }
        field(960; Preview; Boolean)
        {
            Caption = 'Preview';
            Editable = FALSE;
        }
        field(7050; "AQD Use Cust Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Use Cust Rebate Setup From';
            Editable = FALSE;
        }
        field(7060; "AQD Cust Rebate Posting Type"; enum "AQD CustRebate CostPostingType")
        {
            Caption = 'Cust Rebate Posting Type';
            Editable = FALSE;
        }
    }

    keys
    {
        key(Key1; "Rebate No.", "Rebate Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure UpdateChangedBy()
    begin
        "Rebate Amount Changed By" := UserId;
        "Rebate Amount Changed DateTime" := CurrentDateTime;
    end;
}