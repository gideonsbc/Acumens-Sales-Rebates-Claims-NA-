table 14277048 "AQD Posted Vend Rebate Header"
{
    Caption = 'Posted Vendor Rebate Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Posted Vendor Rebates";
    LookupPageId = "AQD Posted Vendor Rebates";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(20; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
        }
        field(30; "Buy-from Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            Editable = false;
        }
        field(40; "Buy-from Vendor Name 2"; Text[50])
        {
            Caption = 'Buy-from Vendor Name 2';
            Editable = false;
        }
        field(50; "Buy-from Address"; Text[100])
        {
            Caption = 'Buy-from Address';
            Editable = false;
        }
        field(60; "Buy-from Address 2"; Text[50])
        {
            Caption = 'Buy-from Address 2';
            Editable = false;
        }
        field(70; "Buy-from City"; Text[30])
        {
            Caption = 'Buy-from City';
            Editable = false;
        }
        field(80; "Buy-from Contact"; Text[100])
        {
            Caption = 'Buy-from Contact';
            Editable = false;
        }
        field(90; "Buy-from Post Code"; Code[20])
        {
            Caption = 'Buy-from ZIP Code';
            Editable = false;
        }
        field(100; "Buy-from County"; Text[30])
        {
            Caption = 'Buy-from State';
            Editable = false;
        }
        field(110; "Buy-from Country/Region Code"; Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            Editable = false;
        }
        field(150; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
        }
        field(170; "Pay-to Name"; Text[100])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(180; "Pay-to Name 2"; Text[50])
        {
            Caption = 'Name 2';
            Editable = false;
        }
        field(190; "Pay-to Address"; Text[100])
        {
            Caption = 'Address';
            Editable = false;
        }
        field(200; "Pay-to Address 2"; Text[50])
        {
            Caption = 'Address 2';
            Editable = false;
        }
        field(210; "Pay-to City"; Text[30])
        {
            Caption = 'City';
            Editable = false;
        }
        field(220; "Pay-to Contact"; Text[100])
        {
            Caption = 'Contact';
            Editable = false;
        }
        field(230; "Pay-to Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            Editable = false;
        }
        field(240; "Pay-to County"; Text[30])
        {
            Caption = 'Pay-to State';
            Editable = false;
        }
        field(250; "Pay-to Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
        }
        field(300; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            Editable = false;
        }
        field(310; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
        }
        field(320; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        field(330; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            Editable = false;

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
            Editable = false;

            trigger OnValidate()
            begin
                PurchaseHeader.ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(360; "Rebate Purchase Doc Type"; Enum "AQD Rebate Purchase Doc Type")
        {
            Caption = 'Rebate Purchase Doc Type';
            Editable = false;
        }
        field(400; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(410; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(420; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(430; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(500; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Vend Rebate Line".Amount where("Rebate No." = field("No.")));
            Editable = false;
        }
        field(510; "Purchase Amount Including VAT"; Decimal)
        {
            Caption = 'Purchase Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Vend Rebate Line"."Amount Including VAT" where("Rebate No." = field("No.")));
            Editable = false;
        }
        field(520; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            CalcFormula = sum("AQD Posted Ven Reb Details"."Calculated Line Rebate Amount" where("Rebate No." = field("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(530; "Vendor Rebate Amount"; Decimal)
        {
            Caption = 'Vendor Rebate Amount';
            CalcFormula = sum("AQD Posted Ven Reb Details"."Vendor Rebate Amount" where("Rebate No." = field("No.")));
            FieldClass = FlowField;
            Editable = false;
        }

        field(540; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(550; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(560; "Rebate Status"; Enum "AQD Vendor Rebate Status")
        {
            Caption = 'Rebate Status';
            DataClassification = CustomerContent;
        }
        field(570; "AQD Calculation Date"; Enum "AQD VendRebateCalculation Type")
        {
            Caption = 'Calculation Date';
        }
        field(600; "Batch Entry No."; Integer)
        {
            Editable = FALSE;
            Caption = 'Batch Entry No.';
        }
        field(700; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        // field(900; "Salesperson Code"; Code[20])
        // {
        //     Caption = 'Salesperson Code';
        //     TableRelation = "Salesperson/Purchaser";
        // }
        field(901; State; Text[30])
        {
            Caption = 'State';
        }
        field(902; Approved; Boolean)
        {
            Caption = 'Approved';
        }
        field(903; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            Editable = false;
        }
        field(904; "Approved Date Time"; DateTime)
        {
            Caption = 'Approved Date Time';
            Editable = false;
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
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            RebateSetup.Get;
            RebateSetup.TestField("Vendor Rebate Nos");
            "No. Series" := RebateSetup."Vendor Rebate Nos";
            "No." := NoSeriesMgt.GetNextNo("No. Series");
            //NoSeriesMgt.InitSeries(RebateSetup."Vendor Rebate Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    var
        RebateSetup: Record "AQD Acumens Rebate Setup";
        NoSeriesMgt: Codeunit "No. Series";
        Vend: Record Vendor;
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        PurchaseHeader: Record "Purchase Header";
}