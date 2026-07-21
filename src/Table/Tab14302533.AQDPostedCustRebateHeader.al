table 14302533 "AQD Posted Cust Rebate Header"
{
    Caption = 'Posted Customer Rebate Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "AQD Posted Customer Rebates";
    LookupPageId = "AQD Posted Customer Rebates";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(260; "Rebate Pay-To Customer No."; Code[20])
        {
            Caption = 'Rebate Pay-To Customer No.';
            Editable = false;
        }
        field(261; "Rebate-to Name"; Text[100])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(262; "Rebate-To Name 2"; Text[50])
        {
            Caption = 'Name 2';
            Editable = false;
        }
        field(263; "Rebate-To Address"; Text[100])
        {
            Caption = 'Address';
            Editable = false;
        }
        field(264; "Rebate-To Address 2"; Text[50])
        {
            Caption = 'Address 2';
            Editable = false;
        }
        field(265; "Rebate-To City"; Text[30])
        {
            Caption = 'City';
            Editable = false;
        }
        field(266; "Rebate-To Contact"; Text[100])
        {
            Caption = 'Contact';
            Editable = false;
        }
        field(267; "Rebate-To Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            Editable = false;
        }
        field(268; "Rebate-To County"; Text[30])
        {
            Caption = 'Rebate-To State';
            Editable = false;
        }
        field(269; "Rebate-To Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
        }
        field(300; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
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
            Editable = false;
        }
        field(340; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            Editable = false;
        }
        field(360; "Rebate Payable AC"; Enum "AQD Rebate Payable AC")
        {
            Caption = 'Rebate Payable A/C';
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
        field(500; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Rebate Line".Amount where("Rebate No." = field("No.")));
            Editable = false;
        }
        field(510; "Sales Amount Including VAT"; Decimal)
        {
            Caption = 'Sales Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Rebate Line"."Amount Including VAT" where("Rebate No." = field("No.")));
            Editable = false;
        }
        field(520; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Calculated Line Rebate Amount" where("Rebate No." = field("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(530; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Sales Rebate Amount';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("No."),
                                                                                           "Entity Type" = const(Customer),
                                                                                           "Do Not Credit" = filter(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(531; "Vendor Commission"; Decimal)
        {
            Caption = 'Vendor Commission';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("No."),
                                                                                           "Entity Type" = const(Vendor),
                                                                                           "Do Not Credit" = filter(false)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(532; "Employee Commission"; Decimal)
        {
            Caption = 'Employee Commission';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("No."),
                                                                                           "Entity Type" = const(Employee),
                                                                                           "Do Not Credit" = filter(false)));
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
        field(560; "Customer Rebate Status"; Enum "AQD Customer Rebate Status")
        {
            Caption = 'Rebate Status';
            DataClassification = CustomerContent;
        }
        field(570; "AQD Calculation Date"; Enum "AQD CustRebateCalculation Type")
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
        field(5000; "Process CatchUp Rebate"; Boolean)
        {
            Caption = 'CatchUp Rebate';
            DataClassification = CustomerContent;
            Editable = false;
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
}