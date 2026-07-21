table 14302520 "AQD Customer Rebate Line"
{
    Caption = 'Sales Rebate Line';
    DataClassification = CustomerContent;
    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm;

    fields
    {
        field(1; "Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            Editable = false;
        }
        field(2; "Line No."; Integer)
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
        field(100; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Editable = false;
        }
        field(120; "Original Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Original Document Type';
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
            CalcFormula = sum("AQD Customer Rebate Details"."Calculated Line Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                                  "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(178; "Vendor Commission"; Decimal)
        {
            Caption = 'Vendor Commission';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Do Not Credit" = filter(false),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "Entity Type" = const(Vendor)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(179; "Employee Commission"; Decimal)
        {
            Caption = 'Employee Commission';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Do Not Credit" = filter(false),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "Entity Type" = const(Employee)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(180; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Sales Rebate Amount';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Do Not Credit" = filter(false),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "Entity Type" = filter(Customer)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(181; "Cust Rebate Amt(Item Charge)"; Decimal)
        {
            Caption = 'Sales Rebate Amount (Item Charge)';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const(Inventory),
                                                                                           "Do Not Credit" = const(false),
                                                                                           "Entity Type" = filter(Customer)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(182; "Customer Rebate Amt (GL)"; Decimal)
        {
            Caption = 'Sales Rebate Amt (GL)';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const(Expense),
                                                                                           "Do Not Credit" = const(false),
                                                                                           "Entity Type" = filter(Customer)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(190; "Do Not Credit"; Boolean)
        {
            Caption = 'Do Not Credit';
            trigger OnValidate()
            begin
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
        field(230; Ineligible; Boolean)
        {
            Caption = 'Ineligible';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = max("AQD Customer Rebate Details".Ineligible where("Rebate No." = field("Rebate No."),
                                                                             "Rebate Line No." = field("Line No.")));
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
        field(350; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
        }
        field(400; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
        field(499; "Sell-To Customer Name"; Text[100])
        {
            Caption = 'Sell-To Customer Name';
            Editable = false;
        }
        field(500; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-To Customer No.';
            Editable = false;
        }
        field(501; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Invoice Bill-To Customer No.';
            Editable = false;
        }
        field(502; "Bill-To Customer Name"; Text[100])
        {
            Caption = 'Invoice Bill-To Customer Name';
            Editable = false;
        }
        field(510; "Rebate Pay-To Customer No."; Code[20])
        {
            Caption = 'Rebate Pay-To Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(560; "Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Rebate Status';
            DataClassification = CustomerContent;
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
        field(960; "Preview"; Boolean)
        {
            Caption = 'Preview';
            Editable = FALSE;
        }
        field(970; "Cust Rebate Program Code"; Code[10])
        {
            Caption = 'Sales Rebate Program Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Program Code";
        }
        field(980; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            DataClassification = CustomerContent;
            TableRelation = "AQD Marketplace";
        }
        field(990; "Off-Invoice Rebate"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9200; "CatchUp Rebate"; Boolean)
        {
            Caption = 'CatchUp Rebate';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Rebate No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
    begin
        CustomerRebateDetails.RESET;
        CustomerRebateDetails.SetRange("Rebate No.", Rec."Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", Rec."Line No.");
        IF CustomerRebateDetails.FindFirst() then
            CustomerRebateDetails.DeleteAll(true);
    END;

    local procedure UpdateChangedBy()
    var
        //RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        RebateSetup.GET;

        "Rebate Amount Changed By" := UserId;
        "Rebate Amount Changed DateTime" := CurrentDateTime;

        IF Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
            IF SalesInvHdr.GET(Rec."Document No.") THEN begin
                SalesInvHdr."AQD No Customer Rebate" := Rec."Do Not Credit";
                SalesInvHdr.Modify();
            end;
        END ELSE IF Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
            IF SalesCrMemoHdr.GET(Rec."Document No.") THEN begin
                SalesCrMemoHdr."AQD No Customer Rebate" := Rec."Do Not Credit";
                SalesCrMemoHdr.Modify();
            end;
        END;

        CustomerRebateDetails.Reset();
        CustomerRebateDetails.SetRange("Rebate No.", "Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", "Line No.");
        if CustomerRebateDetails.FindSet() then begin
            repeat
                CustomerRebateDetails.Validate("Do Not Credit", Rec."Do Not Credit");
                CustomerRebateDetails.Modify(true);
            until CustomerRebateDetails.Next() = 0;
        end;
    end;

    var
        SalesHeader: Record "Sales Header";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
}