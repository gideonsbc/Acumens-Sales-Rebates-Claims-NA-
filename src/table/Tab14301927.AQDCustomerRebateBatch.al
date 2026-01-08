table 14301927 "AQD Customer Rebate Batch"
{
    Caption = 'Customer Rebate Batch';
    DataClassification = CustomerContent;
    DataCaptionFields = BatchID;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(20; BatchID; Code[50])
        {
            Caption = 'BatchId';
            Editable = false;
            NotBlank = TRUE;
        }
        field(50; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(55; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            Editable = false;
        }
        field(56; "Bill-To Customer Name"; Text[100])
        {
            Caption = 'Bill-To Customer Name';
            Editable = false;
        }
        field(60; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Customer Rebate Line".Amount where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(70; "Sales Amount Including VAT"; Decimal)
        {
            Caption = 'Sales Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Customer Rebate Line"."Amount Including VAT" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(80; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Customer Rebate Details"."Calculated Line Rebate Amount" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(90; "Customer Rebate Amount"; Decimal)
        {
            Caption = 'Customer Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Batch Entry No." = field("Entry No."), "Do Not Credit" = filter(false)));
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

    trigger OnDelete()
    var
        CustomerRebateHeader: Record "AQD Customer Rebate Header";
    begin
        CustomerRebateHeader.RESET;
        CustomerRebateHeader.SetRange("Batch Entry No.", Rec."Entry No.");
        IF CustomerRebateHeader.FindFirst() THEN begin
            Repeat
                IF CustomerRebateHeader.BatchID <> '' THEN
                    CustomerRebateHeader.Delete(TRUE);
            Until CustomerRebateHeader.Next() = 0;
        end;
    end;
}