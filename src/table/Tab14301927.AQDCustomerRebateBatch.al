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
            CalcFormula = sum("AQD Customer Rebate Details"."Customer Rebate Amount" where("Batch Entry No." = field("Entry No."), Exclude = filter(false)));
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
            trigger OnValidate()
            var
                LocalCustomerRebateHeader: Record "AQD Customer Rebate Header";
            begin
                if Approved then begin
                    "Approved By" := UserId;
                    "Approved Date Time" := CurrentDateTime;
                end else begin
                    Clear("Approved By");
                    Clear("Approved Date Time");
                end;

                LocalCustomerRebateHeader.RESET;
                LocalCustomerRebateHeader.SetRange("Batch Entry No.", Rec."Entry No.");
                IF LocalCustomerRebateHeader.FindFirst() THEN begin
                    repeat
                        LocalCustomerRebateHeader.Validate(Approved, Rec.Approved);
                        LocalCustomerRebateHeader.Modify(true);
                    Until LocalCustomerRebateHeader.Next() = 0;
                end;
            end;
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