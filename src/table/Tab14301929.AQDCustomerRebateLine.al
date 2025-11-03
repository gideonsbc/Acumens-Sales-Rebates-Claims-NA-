table 14301929 "AQD Customer Rebate Line"
{
    Caption = 'Customer Rebate Line';
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
        field(180; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Customer Rebate Amount';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(181; "Cust Rebate Amt(Item Charge)"; Decimal)
        {
            Caption = 'Customer Rebate Amount (Item Charge)';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const("Item Charge"),
                                                                                           Exclude = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(182; "Customer Rebate Amt (GL)"; Decimal)
        {
            Caption = 'Customer Rebate Amt (GL)';
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                           "Rebate Line No." = field("Line No."),
                                                                                           "AQD Cust Rebate Posting Type" = const("G/L Account"),
                                                                                           Exclude = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(190; Exclude; Boolean)
        {
            Caption = 'Exclude';
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
        field(510; "Pay-To Vendor No."; Code[20])
        {
            Caption = 'Pay-To Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(560; "Rebate Status"; Enum "AQD Customer Rebate Status")
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

        CASE RebateSetup."Calculate Cust Rebate using" OF
            RebateSetup."Calculate Cust Rebate using"::"Posted Invoice and Cr Memo":
                BEGIN
                    IF Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
                        IF SalesInvHdr.GET(Rec."Document No.") THEN begin
                            SalesInvHdr."AQD Do Not Pay Cust Rebate" := Rec.Exclude;
                            SalesInvHdr.Modify();
                        end;
                    END ELSE IF Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
                        IF SalesCrMemoHdr.GET(Rec."Document No.") THEN begin
                            SalesCrMemoHdr."AQD Do Not Pay Cust Rebate" := Rec.Exclude;
                            SalesCrMemoHdr.Modify();
                        end;
                    END;
                END;
            RebateSetup."Calculate Cust Rebate using"::"Posted Shipment and Return Receipt":
                BEGIN
                    // RebateItemLdgrEntry.RESET;
                    // RebateItemLdgrEntry.SetRange("Document Type", Rec."Original Document Type");
                    // RebateItemLdgrEntry.SetRange("Document No.", Rec."Document No.");
                    // RebateItemLdgrEntry.ModifyAll("AQD Do Not Pay Rebate", Rec.Exclude);
                END;
        END;

        CustomerRebateDetails.Reset();
        CustomerRebateDetails.SetRange("Rebate No.", "Rebate No.");
        CustomerRebateDetails.SetRange("Rebate Line No.", "Line No.");
        if CustomerRebateDetails.FindSet() then begin
            repeat
                CustomerRebateDetails.Validate(Exclude, Rec.Exclude);
                CustomerRebateDetails.Modify(true);
            until CustomerRebateDetails.Next() = 0;
        end;
    end;

    var
        SalesHeader: Record "Sales Header";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
}