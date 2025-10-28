table 14301925 "AQD Cust Rebate Document Entry"
{
    Caption = 'Customer Rebate Document Entry';
    DrillDownPageID = "AQD Rebate Document Entry";
    LookupPageID = "AQD Rebate Document Entry";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "Rebate Code"; Code[20])
        {
            Caption = 'Rebate Code';
        }
        field(14277005; "Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            Editable = false;
            OptionCaption = ' ,Vendor,Customer';
            OptionMembers = " ",Vendor,Customer;
        }
        field(14277006; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = ' ,Invoice,Credit Memo';
            OptionMembers = " ",Invoice,"Credit Memo";
        }
        field(14277007; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = IF ("Document Type" = CONST(Invoice)) "Sales Invoice Header"."No."
            ELSE
            IF ("Document Type" = CONST("Credit Memo")) "Sales Cr.Memo Header"."No.";
        }
        field(14277008; "Document Posting Date"; Date)
        {
            Caption = 'Document Posting Date';
            Editable = false;
        }
        field(14277009; "State"; Text[30])
        {
            Caption = 'State';
        }
        field(14277010; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(14277011; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(14277012; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
        }
        field(14277013; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
        }
        field(14277014; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(14277015; "Bill-to Customer Name"; Text[100])
        {
            Caption = 'Bill-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
        }
        field(14277016; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(14277017; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14277018; "Open"; Boolean)
        {
            Caption = 'Open';
        }
        field(14277019; "Payable"; Boolean)
        {
            Caption = 'Payable';
        }
        field(14277020; "Document Amount"; Decimal)
        {
            Caption = 'Document Amount';
            Editable = false;
        }
        field(14277021; "Base Amount"; Decimal)
        {
            CalcFormula = Sum("AQD Customer Rebate Entry"."Base Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                              "Document No." = FIELD("Document No."),
                                                                              "Rebate Program Code" = FIELD("Rebate Code"),
                                                                              "Rebate Type" = FIELD("Rebate Type"),
                                                                              "Do Not Pay Rebate" = FILTER(false)));
            Caption = 'Base Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277022; "Rebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Rebate Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                        "Document No." = FIELD("Document No."),
                                                                        "Rebate Program Code" = FIELD("Rebate Code"),
                                                                        "Rebate Type" = FIELD("Rebate Type"),
                                                                        "Do Not Pay Rebate" = FILTER(false)));
            Caption = 'Rebate Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277023; "Remaining Rebate Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Remaining Rebate Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                                  "Document No." = FIELD("Document No."),
                                                                                  "Rebate Program Code" = FIELD("Rebate Code"),
                                                                                  "Rebate Type" = FIELD("Rebate Type"),
                                                                                  "Do Not Pay Rebate" = FILTER(false)));
            Caption = 'Remaining Rebate Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277024; "Profit Amount"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Profit Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                        "Document No." = FIELD("Document No."),
                                                                        "Rebate Program Code" = FIELD("Rebate Code"),
                                                                        "Rebate Type" = FIELD("Rebate Type"),
                                                                        "Do Not Pay Rebate" = FILTER(false)));
            Caption = 'Profit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277025; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
            end;
        }
        field(14277026; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(14277027; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(14277028; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(14277029; "Amount Due"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Remaining Rebate Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                                  "Document No." = FIELD("Document No."),
                                                                                  "Rebate Program Code" = FIELD("Rebate Code"),
                                                                                  "Rebate Type" = FIELD("Rebate Type"),
                                                                                  "Do Not Pay Rebate" = FILTER(false)));
            Caption = 'Amount Due';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277030; "Total Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("AQD Customer Rebate Entry"."Quantity" WHERE("Document Type" = FIELD("Document Type"),
                                                                 "Document No." = FIELD("Document No."),
                                                                 "Rebate Program Code" = FIELD("Rebate Code"),
                                                                 "Do Not Pay Rebate" = CONST(false)));
            Caption = 'Total Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277031; "Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            Editable = false;
            TableRelation = "Cust. Ledger Entry"."Entry No.";
        }
        field(14277032; "Cust. Ledger Entry Open"; Boolean)
        {
            CalcFormula = Lookup("Cust. Ledger Entry".Open WHERE("Entry No." = FIELD("Cust. Ledger Entry No.")));
            Caption = 'Cust. Ledger Entry Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277033; "Cust. Ledger Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Cust. Ledger Entry No." = FIELD("Cust. Ledger Entry No."),
                                                                         "Entry Type" = FILTER("Initial Entry" | "Unrealized Loss" | "Unrealized Gain" | "Realized Loss" | "Realized Gain" | "Payment Discount" | "Payment Discount (VAT Excl.)" | "Payment Discount (VAT Adjustment)")));
            Caption = 'Cust. Ledger Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277034; "Cust. Ledger Rem. Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Cust. Ledger Entry No." = FIELD("Cust. Ledger Entry No.")));
            Caption = 'Cust. Ledger Remaining Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277035; "Vendor Document No."; Code[20])
        {
            Caption = 'Vendor Document No.';
        }
        field(14277036; "Vendor Ledger Entry No."; Integer)
        {
            Caption = 'Vendor Ledger Entry No.';
            TableRelation = "Vendor Ledger Entry"."Entry No.";
        }
        field(14277037; "Vendor Ledger Entry Open"; Boolean)
        {
            CalcFormula = Lookup("Vendor Ledger Entry".Open WHERE("Entry No." = FIELD("Vendor Ledger Entry No.")));
            Caption = 'Vendor Ledger Entry Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277038; "Payment V. Ledg. Entry No."; Integer)
        {
            Caption = 'Payment Vender Ledg. Entry No.';
            TableRelation = "Vendor Ledger Entry"."Entry No.";
        }
        field(14277039; "Check No."; Code[20])
        {
            Caption = 'Check No.';
        }
        field(14277040; "Credit C. Ledg. Entry No."; Integer)
        {
            Caption = 'Credit Cust. Ledger Entry No.';
            Editable = false;
            TableRelation = "Cust. Ledger Entry"."Entry No.";
        }
        field(14277041; "Credit C. Ledg. Entry Open"; Boolean)
        {
            CalcFormula = Lookup("Cust. Ledger Entry".Open WHERE("Entry No." = FIELD("Cust. Ledger Entry No.")));
            Caption = 'Credit Cust. Ledger Entry Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277042; "Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
        }
        field(14277043; "Rebate Register No."; Integer)
        {
            BlankZero = true;
            Caption = 'Rebate Register No.';
            Editable = false;
        }
        field(14277044; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(14277045; "Journal Batch Name"; Code[50])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(14277046; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
        }
        field(14277047; "Journal Document No."; Code[20])
        {
            Caption = 'Journal Document No.';
        }
        field(14277048; "Rebate Approved"; Boolean)
        {
            Caption = 'Rebate Approved';
            Editable = false;
        }
        field(14277049; "Rebate Approved Date"; Date)
        {
            Caption = 'Rebate Approved Date';
            Editable = false;
        }
        field(14277050; "Rebate Approved By"; Code[50])
        {
            Caption = 'Rebate Approved By';
            Editable = false;
        }
        field(14277051; "Rebate Paid"; Boolean)
        {
            Caption = 'Rebate Paid';
            Editable = false;
        }
        field(14277052; "Rebate Paid Date"; Date)
        {
            Caption = 'Rebate Paid Date';
            Editable = false;
        }
        field(14277053; "Rebate Paid By"; Code[50])
        {
            Caption = 'Rebate Paid By';
            Editable = false;
        }
        field(14277054; "Payment Status"; Option)
        {
            Caption = 'Payment Status';
            OptionCaption = ' ,Approved,Journal,Posted,Paid';
            OptionMembers = " ",Approved,Journal,Posted,Paid;
        }
        field(14277055; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Rebate Code", "Document Type", "Document No.", "Rebate Type")
        {
            Clustered = true;
        }
        key(Key2; "Document No.")
        {
        }
        key(Key3; "Rebate Code", "Sell-to Customer No.", "Document No.")
        {
        }
        key(Key4; "Vendor Ledger Entry No.")
        {
        }
        key(Key5; "Rebate Code", "Check No.", "Sell-to Customer Name")
        {
        }
        key(Key6; "Journal Template Name", "Journal Batch Name", "Journal Line No.")
        {
        }
        key(Key7; "Rebate Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RebateEntry: Record "AQD Customer Rebate Entry";
    begin
        TestField("Vendor Ledger Entry No.", 0);

        if "Rebate Register No." <> 0 then
            Error(Text0001, TableCaption);

        Clear(RebateEntry);
        RebateEntry.SetCurrentKey("Document Type", "Document No.", "Rebate Program Code");
        RebateEntry.SetRange("Document Type", "Document Type");
        RebateEntry.SetRange("Document No.", "Document No.");
        RebateEntry.SetRange("Rebate Program Code", "Rebate Code");
        RebateEntry.DeleteAll(true);
    end;

    var
        Text0001: Label '%1 cannot be deleted as it is already posted. Please go to Rebate Register to make change.';
}