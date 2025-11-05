table 14301932 "AQD Posted Cust Rebate Batch"
{
    Caption = 'Posted Customer Rebate Batch';
    DataClassification = CustomerContent;
    DataCaptionFields = BatchID;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
        }
        field(20; BatchID; Code[50])
        {
            Caption = 'BatchId';
            Editable = false;
        }
        field(50; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(60; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Rebate Line".Amount where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(70; "Sales Amount Including VAT"; Decimal)
        {
            Caption = 'Sales Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Rebate Line"."Amount Including VAT" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(80; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Reb Details"."Calculated Line Rebate Amount" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(90; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Customer Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Posted Cust Reb Details"."Customer Rebate Amount" where("Batch Entry No." = field("Entry No."), "Do Not Credit" = filter(false)));
            Editable = false;
        }
        field(100; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(110; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(120; "Start Date"; Date)
        {
            Caption = 'Start Date';
            Editable = false;
        }
        field(130; "End Date"; Date)
        {
            Caption = 'End Date';
            Editable = false;
        }
        field(140; "AQD Rebate Batch Frequency"; Enum "AQD Rebate Batch Frequency")
        {
            Caption = 'Rebate Batch Frequency';
            Editable = false;
        }
        field(902; Approved; Boolean)
        {
            Caption = 'Approved';
            Editable = false;
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
        field(910; "Last Processing Error Message"; Text[250])
        {
            Caption = 'Last Processing Error Message';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Entry No.", BatchID)
        {
        }
        fieldgroup(Brick; "Entry No.", BatchID)
        {
        }
    }
}