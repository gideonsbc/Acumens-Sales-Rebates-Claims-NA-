table 14277045 "AQD Vendor Rebate Line"
{
    Caption = 'Vendor Rebate Line';
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
            BlankZero = true;
            Caption = 'Line No.';
            Editable = false;
        }
        field(20; "Document Type"; Enum "AQD Rebate Document Type")
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
            CalcFormula = sum("AQD Vendor Rebate Details"."Calculated Line Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                                "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(180; "Vendor Rebate Amount"; Decimal)
        {
            Caption = 'Vendor Rebate Amount';
            CalcFormula = sum("AQD Vendor Rebate Details"."Vendor Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                       "Rebate Line No." = field("Line No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(181; "Vendor Rebate Amt(Item Charge)"; Decimal)
        {
            Caption = 'Vendor Rebate Amount (Item Charge)';
            CalcFormula = sum("AQD Vendor Rebate Details"."Vendor Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                       "Rebate Line No." = field("Line No."),
                                                                                       "AQD Rebate Posting Type" = const("Item Charge"),
                                                                                       Exclude = const(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(182; "Vendor Rebate Amt (GL)"; Decimal)
        {
            Caption = 'Vendor Rebate Amt (GL)';
            CalcFormula = sum("AQD Vendor Rebate Details"."Vendor Rebate Amount" where("Rebate No." = field("Rebate No."),
                                                                                       "Rebate Line No." = field("Line No."),
                                                                                       "AQD Rebate Posting Type" = const("G/L Account"),
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
        field(300; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
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

            trigger OnValidate()
            begin
                PurchaseHeader.ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(340; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                PurchaseHeader.ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
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
        field(560; "Rebate Status"; Enum "AQD Vendor Rebate Status")
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
        VendorRebateDetails: Record "AQD Vendor Rebate Details";
    begin
        VendorRebateDetails.RESET;
        VendorRebateDetails.SetRange("Rebate No.", Rec."Rebate No.");
        VendorRebateDetails.SetRange("Rebate Line No.", Rec."Line No.");
        IF VendorRebateDetails.FindFirst() then
            VendorRebateDetails.DeleteAll(true);
    END;

    local procedure UpdateChangedBy()
    var
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
        RebateSetup: Record "AQD Acumens Rebate Setup";
        PurchInvHdr: Record "Sales Invoice Header";
        PurchCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        RebateSetup.GET;

        "Rebate Amount Changed By" := UserId;
        "Rebate Amount Changed DateTime" := CurrentDateTime;

        CASE RebateSetup."Calculate Vendor Rebate using" OF
            RebateSetup."Calculate Vendor Rebate using"::"Posted Invoice and Cr Memo":
                BEGIN
                    IF Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
                        IF PurchInvHdr.GET(Rec."Document No.") THEN begin
                            PurchInvHdr."AQD Do Not Pay Rebate" := Rec.Exclude;
                            PurchInvHdr.Modify();
                        end;
                    END ELSE IF Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
                        IF PurchCrMemoHdr.GET(Rec."Document No.") THEN begin
                            PurchCrMemoHdr."AQD Do Not Pay Rebate" := Rec.Exclude;
                            PurchCrMemoHdr.Modify();
                        end;
                    END;
                END;
            RebateSetup."Calculate Vendor Rebate using"::"Posted Receipt and Return Shipment":
                BEGIN
                    RebateItemLdgrEntry.RESET;
                    RebateItemLdgrEntry.SetRange("Document Type", Rec."Original Document Type");
                    RebateItemLdgrEntry.SetRange("Document No.", Rec."Document No.");
                    RebateItemLdgrEntry.ModifyAll("AQD Do Not Pay Rebate", Rec.Exclude);
                END;
        END;

        VendorRebateDetails.Reset();
        VendorRebateDetails.SetRange("Rebate No.", "Rebate No.");
        VendorRebateDetails.SetRange("Rebate Line No.", "Line No.");
        if VendorRebateDetails.FindSet() then begin
            repeat
                VendorRebateDetails.Validate(Exclude, Rec.Exclude);
                VendorRebateDetails.Modify(true);
            until VendorRebateDetails.Next() = 0;
        end;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        VendorRebateDetails: Record "AQD Vendor Rebate Details";
}