table 14302535 "AQD Posted Cust Reb Details"
{
    Caption = 'Posted Customer Rebate Details';
    DataClassification = CustomerContent;
    DrillDownPageID = "AQD Posted Cust Rebate Details";
    LookupPageID = "AQD Posted Cust Rebate Details";

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
            Caption = 'Payee Type';
            Editable = false;
        }
        field(46; "Entity No."; Code[20])
        {
            Caption = 'Payee No.';
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
        field(67; "CustRbt Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rebate Rate Type';
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
        field(180; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Rebate Amount';
            trigger OnValidate()
            var
                RebateStatusError: Label 'Rebate Status must not be %1.';
            begin
                IF Rec."Customer Rebate Status" <> Rec."Customer Rebate Status"::" " THEN
                    Error(RebateStatusError, Rec."Customer Rebate Status");

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
        field(230; Ineligible; Boolean)
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
        field(360; "Rebate Payable A/C"; Enum "AQD Rebate Payable AC")
        {
            Caption = 'Rebate Payable A/C';
            Editable = false;
        }
        field(361; "Rebate Sales Document No."; Code[20])
        {
            Caption = 'Rebate Sales Document No.';
            Editable = false;
        }
        field(362; "Rebate Sales Document Line No."; Integer)
        {
            BlankZero = TRUE;
            Caption = 'Rebate Sales Document Line No.';
            Editable = false;
        }
        field(363; "Rebate Sales Line No."; Integer)
        {
            BlankZero = TRUE;
            Caption = 'Rebate Sales Line No.';
            Editable = false;
        }
        field(370; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(380; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
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
        field(510; "Rebate Pay-To Customer No."; Code[20])
        {
            Caption = 'Rebate Pay-To Customer No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(560; "Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Sales Rebate Status';
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
            else if ("Applies-to Doc. Type" = const(Invoice)) "Sales Header"."No." where("Document Type" = const(Invoice))
            else if ("Applies-to Doc. Type" = const("Return Order")) "Sales Header"."No." where("Document Type" = const("Return Order"))
            else if ("Applies-to Doc. Type" = const("Credit Memo")) "Sales Header"."No." where("Document Type" = const("Credit Memo"))
            else if ("Applies-to Doc. Type" = const(Shipment)) "Sales Shipment Header"."No."
            else if ("Applies-to Doc. Type" = const("Return Receipt")) "Return Receipt Header"."No.";
        }
        field(590; "Applies-to Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Doc. Line No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Order)) "Sales Line"."Line No." where("Document Type" = const(Order), "Document No." = field("Applies-to Doc. No."))
            else if ("Applies-to Doc. Type" = const(Invoice)) "Sales Line"."Line No." where("Document Type" = const(Invoice), "Document No." = field("Applies-to Doc. No."))
            else if ("Applies-to Doc. Type" = const("Return Order")) "Sales Line"."Line No." where("Document Type" = const("Return Order"), "Document No." = field("Applies-to Doc. No."))
            else if ("Applies-to Doc. Type" = const("Credit Memo")) "Sales Line"."Line No." where("Document Type" = const("Credit Memo"), "Document No." = field("Applies-to Doc. No."))
            else if ("Applies-to Doc. Type" = const(Shipment)) "Sales Shipment Line"."Line No." where("Document No." = field("Applies-to Doc. No."))
            else if ("Applies-to Doc. Type" = const("Return Receipt")) "Return Receipt Line"."Line No." where("Document No." = field("Applies-to Doc. No."));
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
        field(7070; "Special Rebate Program Code"; Code[10])
        {
            Caption = 'Special Rebate Program Code';
        }
        field(8070; "Vendor Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(8080; "Vendor Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(8090; "Rebate Rate Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9000; "Customer Rebate Category"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9020; "Payment Terms Code"; code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9030; "CatchUp Rebate"; Boolean)
        {
            Caption = 'CatchUp Rebate';
            DataClassification = CustomerContent;
        }
        field(9040; "AQD Default Trade Agreement"; Code[10])
        {
            Caption = 'Default Trade Agreement';
            DataClassification = CustomerContent;
            TableRelation = "AQD CF Trade Agreement";
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
    var
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        IF Rec."Customer Rebate Status" <> Rec."Customer Rebate Status"::" " THEN
            Error(RebateStatusError, Rec."Customer Rebate Status");

        Rec."Rebate Amount Changed By" := UserId;
        Rec."Rebate Amount Changed DateTime" := CurrentDateTime;
    end;


    var
        VLE: Record "Vendor Ledger Entry";
}