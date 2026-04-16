table 14302613 "AQD Customer Claim Line"
{
    Caption = 'Customer Claim Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Claim Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(20; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(25; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
        }
        field(30; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
        }
        field(40; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
        }
        field(50; "Ship-To Code"; Code[10])
        {
            Caption = 'Ship-To Code';
        }
        field(60; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(70; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(80; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(90; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(100; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(110; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(120; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
            TableRelation = if (Type = const(Item),
                                "No." = filter(<> '')) "Item Unit of Measure".Code where("Item No." = field("No."))
            else
            if (Type = const(Resource),
                "No." = filter(<> '')) "Resource Unit of Measure".Code where("Resource No." = field("No."))
            else
            if (Type = filter("Charge (Item)" | "Fixed Asset" | "G/L Account")) "Unit of Measure";
        }
        field(130; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = true;
            ToolTip = 'Specifies how many units are being sold.';
        }
        field(131; "Quantity Shipped"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Shipped';
            CalcFormula = sum("Sales Shipment Line".Quantity where("Order No." = Field("Order No."),
                                                                   "Order Line No." = Field("Order Line No."),
                                                                   Quantity = filter(<> 0)));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies how many units are shipped.';
        }
        field(140; "Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 5;
            Editable = false;
            ToolTip = 'Specifies the price of each unit.';
        }
        // It is helpful in case of Price Match Claim Only
        field(141; "Order Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Order  Unit Price';
            DecimalPlaces = 0 : 5;
            Editable = false;
            ToolTip = 'Specifies the price of each unit on Order.';
        }

        field(145; "Approved Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Approved Unit Price';
            DecimalPlaces = 0 : 5;
            Editable = false;
            ToolTip = 'Specifies the price of each unit.';
        }
        field(150; "Unit Cost (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Unit Cost ($)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            ToolTip = 'Specifies the cost of each unit.';
        }
        field(160; "Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(170; "Line Discount Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount Amount';
            Editable = false;
        }
        field(180; Amount; Decimal)
        {
            BlankZero = true;
            Caption = 'Amount';
            Editable = false;
        }
        field(185; "Approved Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Approved Amount';
            MinValue = 0;

            trigger OnValidate()
            var
                ClaimHeader: Record "AQD Customer Claim Header";
            BEGIN
                IF ClaimHeader.GET(Rec."Claim Type", Rec."No.") THEN
                    IF ClaimHeader."Claim Approved" THEN
                        ERROR(ClaimAmountStatusError);

                IF Quantity <> 0 THEN
                    "Approved Unit Price" := ROUND("Approved Amount" / Quantity, 0.00001);
            END;
        }
        field(190; "Amount Including VAT"; Decimal)
        {
            BlankZero = true;
            Caption = 'Amount Including VAT';
            Editable = false;
        }
        field(200; "Line Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Amount';
            Editable = false;
        }
        field(300; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            Editable = false;
            ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(310; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            Editable = false;
            ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(320; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(330; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Editable = false;
            ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
            TableRelation = "Salesperson/Purchaser" where(Blocked = const(false));
        }
        field(340; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";
        }
        field(350; "Order Date"; Date)
        {
            Caption = 'Order Date';
            Editable = false;
        }
        field(360; "Manual Line"; Boolean)
        {
            Caption = 'Manual Line';
            Editable = false;
        }
        field(370; "Claim Line"; Boolean)
        {
            Caption = 'Claim Line';
            Editable = false;
        }
        FIELD(380; "Claim Line Type"; enum "AQD CustClmPrcMthClaimLineType")
        {
            Caption = 'Claim Line Type';
            Editable = FALSE;
        }
        field(390; "Cust Claim Mfg Product Code"; Code[20])
        {
            Caption = 'Mfg. Product Code';
            DataClassification = CustomerContent;
        }
        field(400; "Cust Claim Program Code"; Code[20])
        {
            Caption = 'Program Code';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            TableRelation = "AQD Cust Claim Program Code".Code;
        }
        field(410; "Cust Claim Service Code"; Code[20])
        {
            Caption = 'Claim Service Code';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            TableRelation = "AQD Claim Service Codes"."Service Code";
        }
        field(830; "Posted Invoice No."; Code[20])
        {
            Caption = 'Posted Invoice No.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Claim Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        ClaimHeader: Record "AQD Customer Claim Header";
    BEGIN
        IF ClaimHeader.GET(Rec."Claim Type", Rec."Document No.") THEN
            IF ClaimHeader."Claim Approved" THEN
                ERROR(ClaimAmountStatusError);
    END;

    trigger OnDelete()
    var
        ClaimHeader: Record "AQD Customer Claim Header";
        SupplementaryInvoiceLine: Record "Sales Line";
        PurchaseCreditMemoLine: Record "Purchase Line";
    BEGIN
        ClaimHeader.GET(Rec."Claim Type", Rec."Document No.");

        SupplementaryInvoiceLine.RESET;
        SupplementaryInvoiceLine.SETRANGE("Document Type", SupplementaryInvoiceLine."Document Type"::Invoice);
        SupplementaryInvoiceLine.SetRange("Document No.", ClaimHeader."Supplementary Invoice No.");
        SupplementaryInvoiceLine.SetRange("AQD CustClaim Orig Order No.", Rec."Order No.");
        SupplementaryInvoiceLine.SetRange("AQD CustClaim Orig OdrLine No.", Rec."Order Line No.");
        IF SupplementaryInvoiceLine.FindFirst() THEN BEGIN
            REPEAT
                SupplementaryInvoiceLine.SuspendStatusCheck(TRUE);
                SupplementaryInvoiceLine.SetHideValidationDialog(TRUE);
                SupplementaryInvoiceLine.DELETE(TRUE);
            UNTIL SupplementaryInvoiceLine.Next() = 0;
        END;

        PurchaseCreditMemoLine.RESET;
        PurchaseCreditMemoLine.SETRANGE("Document Type", PurchaseCreditMemoLine."Document Type"::"Credit Memo");
        PurchaseCreditMemoLine.SetRange("Document No.", ClaimHeader."Purchase Credit Memo No.");
        PurchaseCreditMemoLine.SetRange("AQD CustClaim Orig Order No.", Rec."Order No.");
        PurchaseCreditMemoLine.SetRange("AQD CustClaim Orig OdrLine No.", Rec."Order Line No.");
        IF PurchaseCreditMemoLine.FindFirst() THEN BEGIN
            REPEAT
                PurchaseCreditMemoLine.SuspendStatusCheck(TRUE);
                PurchaseCreditMemoLine.DELETE(TRUE);
            UNTIL PurchaseCreditMemoLine.Next() = 0;
        END;
    END;

    var
        ClaimAmountStatusError: Label 'You cannot change Approved Amount once Claim is approved.';
        ClaimCreateNewLineStatusError: Label 'You cannot create new Claim Line once Claim is approved.';
}