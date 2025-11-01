table 14301935 "AQD Posted Cust Reb Details"
{
    Caption = 'Posted Customer Rebate Details';
    DataClassification = CustomerContent;
    // DrillDownPageID = "AQD Posted Cust Rebate Details";
    //LookupPageID = "AQD Posted Cust Rebate Details";

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            Editable = false;
        }
        field(2; "Rebate Line No."; Integer)
        {
            Caption = 'Rebate Line No.';
            Editable = false;
        }
        field(3; "Line No."; Integer)
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
        field(40; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
        }
        field(50; Type; enum "AQD Rebate Record Type")
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
            TableRelation = "AQD Cust Rebate Item Category";
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
        field(90; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            Editable = false;
        }
        field(100; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(110; "Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;
            Editable = false;
        }
        field(125; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            Editable = false;
        }
        field(130; "Rebate Per Quantity"; Decimal)
        {
            Caption = 'Rebate Per Quantity';
            Editable = false;
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
            Caption = 'Customer Rebate Amount';
            trigger OnValidate()
            var
                RebateStatusError: Label 'Rebate Status must not be %1.';
            begin
                IF Rec."Rebate Status" <> Rec."Rebate Status"::" " THEN
                    Error(RebateStatusError, Rec."Rebate Status");

                UpdateChangedBy();
            end;
        }
        field(190; Exclude; Boolean)
        {
            Caption = 'Exclude';
            trigger OnValidate()
            begin
                if Exclude then
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
        field(360; "Rebate Purchase Doc Type"; Enum "AQD Rebate Purchase Doc Type")
        {
            Caption = 'Rebate Purchase Doc Type';
            Editable = false;
        }
        field(361; "Purchase Document No."; Code[20])
        {
            Caption = 'Purchase Document No.';
            Editable = false;
        }
        field(362; "Purchase Document Line No."; Integer)
        {
            Caption = 'Purchase Document Line No.';
            Editable = false;
        }
        field(363; "Purchase Line No."; Integer)
        {
            Caption = 'Purchase Line No.';
            Editable = false;
        }
        field(401; State; Text[30])
        {
            Caption = 'State';
        }
        field(500; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
        }
        field(501; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
        }
        field(560; "Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Rebate Status';
            DataClassification = CustomerContent;
        }
        field(570; "Applies-to Doc. Type"; Enum "Purchase Applies-to Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(580; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Order)) "Purchase Header"."No." where("Document Type" = const(Order))
            else
            if ("Applies-to Doc. Type" = const(Invoice)) "Purchase Header"."No." where("Document Type" = const(Invoice))
            else
            if ("Applies-to Doc. Type" = const("Return Order")) "Purchase Header"."No." where("Document Type" = const("Return Order"))
            else
            if ("Applies-to Doc. Type" = const("Credit Memo")) "Purchase Header"."No." where("Document Type" = const("Credit Memo"))
            else
            if ("Applies-to Doc. Type" = const(Receipt)) "Purch. Rcpt. Header"."No."
            else
            if ("Applies-to Doc. Type" = const("Return Shipment")) "Return Shipment Header"."No.";
        }
        field(590; "Applies-to Doc. Line No."; Integer)
        {
            Caption = 'Applies-to Doc. Line No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Order)) "Purchase Line"."Line No." where("Document Type" = const(Order),
                                                                                                       "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const(Invoice)) "Purchase Line"."Line No." where("Document Type" = const(Invoice),
                                                                                                                                                                                         "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Return Order")) "Purchase Line"."Line No." where("Document Type" = const("Return Order"),
                                                                                                                                                                                                                                                                                  "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Credit Memo")) "Purchase Line"."Line No." where("Document Type" = const("Credit Memo"),
                                                                                                                                                                                                                                                                                                                                                                          "Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const(Receipt)) "Purch. Rcpt. Line"."Line No." where("Document No." = field("Applies-to Doc. No."))
            else
            if ("Applies-to Doc. Type" = const("Return Shipment")) "Return Shipment Line"."Line No." where("Document No." = field("Applies-to Doc. No."));
        }
        field(600; "Batch Entry No."; Integer)
        {
            Editable = FALSE;
            Caption = 'Batch Entry No.';
        }
        field(910; "Purchase Jnl Template Name"; Code[10])
        {
            Caption = 'Purchase Jnl Template Name';
            Editable = false;
        }
        field(915; "Purchase Jnl Batch Name"; Code[10])
        {
            Caption = 'Purchase Jnl Batch Name';
            Editable = false;
        }
        field(920; "Purchae Jnl Line No."; Integer)
        {
            Caption = 'Purchae Jnl Line No.';
            Editable = false;
        }
        field(950; BatchID; Code[50])
        {
            Caption = 'BatchId';
        }
        field(7050; "AQD Use Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Cust Rebate Posting By';
            Editable = FALSE;
        }
        field(7060; "AQD Cust Rebate Posting Type"; enum "AQD Cust Rebate Posting Type")
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
    var
        RebateStatusError: Label 'Rebate Status must not be %1.';
    begin
        IF Rec."Rebate Status" <> Rec."Rebate Status"::" " THEN
            Error(RebateStatusError, Rec."Rebate Status");

        Rec."Rebate Amount Changed By" := UserId;
        Rec."Rebate Amount Changed DateTime" := CurrentDateTime;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
}