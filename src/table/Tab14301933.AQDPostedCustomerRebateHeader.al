table 14301933 "AQD Posted Cust Rebate Header"
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
        field(20; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Sell-To Customer No.';
            Editable = false;
        }
        field(30; "Sell-To Customer Name"; Text[100])
        {
            Caption = 'Sell-To Customer Name';
            Editable = false;
        }
        field(40; "Sell-To Customer Name 2"; Text[50])
        {
            Caption = 'Sell-To Customer Name 2';
            Editable = false;
        }
        field(50; "Sell-To Address"; Text[100])
        {
            Caption = 'Sell-To Address';
            Editable = false;
        }
        field(60; "Sell-To Address 2"; Text[50])
        {
            Caption = 'Sell-To Address 2';
            Editable = false;
        }
        field(70; "Sell-To City"; Text[30])
        {
            Caption = 'Sell-To City';
            Editable = false;
        }
        field(80; "Sell-To Contact"; Text[100])
        {
            Caption = 'Sell-To Contact';
            Editable = false;
        }
        field(90; "Sell-To Post Code"; Code[20])
        {
            Caption = 'Sell-To ZIP Code';
            Editable = false;
        }
        field(100; "Sell-To County"; Text[30])
        {
            Caption = 'Sell-To State';
            Editable = false;
        }
        field(110; "Sell-To Country/Region Code"; Code[10])
        {
            Caption = 'Sell-To Country/Region Code';
            Editable = false;
        }
        field(150; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            Editable = false;
        }
        field(170; "Bill-To Name"; Text[100])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(180; "Bill-To Name 2"; Text[50])
        {
            Caption = 'Name 2';
            Editable = false;
        }
        field(190; "Bill-To Address"; Text[100])
        {
            Caption = 'Address';
            Editable = false;
        }
        field(200; "Bill-To Address 2"; Text[50])
        {
            Caption = 'Address 2';
            Editable = false;
        }
        field(210; "Bill-To City"; Text[30])
        {
            Caption = 'City';
            Editable = false;
        }
        field(220; "Bill-To Contact"; Text[100])
        {
            Caption = 'Contact';
            Editable = false;
        }
        field(230; "Bill-To Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            Editable = false;
        }
        field(240; "Bill-To County"; Text[30])
        {
            Caption = 'Pay-to State';
            Editable = false;
        }
        field(250; "Bill-To Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
        }
        field(260; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
        }
        field(261; "Pay-to Name"; Text[100])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(262; "Pay-to Name 2"; Text[50])
        {
            Caption = 'Name 2';
            Editable = false;
        }
        field(263; "Pay-to Address"; Text[100])
        {
            Caption = 'Address';
            Editable = false;
        }
        field(264; "Pay-to Address 2"; Text[50])
        {
            Caption = 'Address 2';
            Editable = false;
        }
        field(265; "Pay-to City"; Text[30])
        {
            Caption = 'City';
            Editable = false;
        }
        field(266; "Pay-to Contact"; Text[100])
        {
            Caption = 'Contact';
            Editable = false;
        }
        field(267; "Pay-to Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            Editable = false;
        }
        field(268; "Pay-to County"; Text[30])
        {
            Caption = 'Pay-to State';
            Editable = false;
        }
        field(269; "Pay-to Country/Region Code"; Code[10])
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
        field(360; "Rebate Purchase Doc Type"; Enum "AQD Rebate Credit Doc Type")
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
            Caption = 'Customer Rebate Amount';
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Rebate No." = field("No.")));
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
        field(560; "Rebate Status"; Enum "AQD Customer Rebate Status")
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
}