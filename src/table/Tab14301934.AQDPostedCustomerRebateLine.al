table 14301934 "AQD Posted Cust Rebate Line"
{
    Caption = 'Posted Customer Rebate Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
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
        field(40; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
        }
        field(50; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(60; "Order Date"; Date)
        {
            Caption = 'Order Date';
            Editable = false;
        }
        field(65; "Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            Editable = false;
        }
        field(70; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(80; "Vendor Order No."; Code[35])
        {
            Caption = 'Vendor Order No.';
            Editable = false;
        }
        field(90; "Vendor Shipment No."; Code[35])
        {
            Caption = 'Vendor Shipment No.';
            Editable = false;
        }
        field(100; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
            Editable = false;
        }
        field(110; "Vendor Cr. Memo No."; Code[35])
        {
            Caption = 'Vendor Cr. Memo No.';
            Editable = false;
        }
        field(120; "Original Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
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
        field(170; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Calculated Line Rebate Amount" where("Rebate No." = field("Rebate No."), "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(180; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Customer Rebate Amount';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."), "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(181; "Cust Rebate Amt(Item Charge)"; Decimal)
        {
            Caption = 'Customer Rebate Amount (Item Charge)';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const("Item Charge")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(182; "Customer Rebate Amt (GL)"; Decimal)
        {
            Caption = 'Customer Rebate Amt (GL)';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const("G/L Account")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(190; "Do Not Credit"; Boolean)
        {
            Caption = 'Do Not Credit';
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
        field(300; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(310; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
        }
        field(320; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
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
        field(350; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
        }
        field(360; "Rebate Sales Doc Type"; Enum "AQD Post Cust Rebate Using")
        {
            Caption = 'Rebate Sales Doc Type';
            Editable = false;
        }
        field(361; "Credit Document No."; Code[20])
        {
            Caption = 'Credit Document No.';
            Editable = false;
        }
        field(362; "Credit Document Line No."; Integer)
        {
            Caption = 'Credit Document Line No.';
            Editable = false;
        }
        field(400; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
        field(500; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-To Customer No.';
            Editable = false;
        }
        field(501; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            Editable = false;
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
        field(600; "Batch Entry No."; Integer)
        {
            Editable = FALSE;
            Caption = 'Batch Entry No.';
        }
        field(910; "Sales Jnl Template Name"; Code[10])
        {
            Caption = 'Sales Jnl Template Name';
            Editable = false;
        }
        field(915; "Sales Jnl Batch Name"; Code[10])
        {
            Caption = 'Sales Jnl Batch Name';
            Editable = false;
        }
        field(920; "Sales Jnl Line No."; Integer)
        {
            Caption = 'Sales Jnl Line No.';
            Editable = false;
        }
        field(950; BatchID; Code[50])
        {
            Caption = 'BatchId';
        }
    }
    keys
    {
        key(Key1; "Rebate No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
}