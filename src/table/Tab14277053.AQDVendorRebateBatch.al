table 14277053 "AQD Vendor Rebate Batch"
{
    Caption = 'Vendor Rebate Batch';
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
        field(60; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Vendor Rebate Line".Amount where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(70; "Purchase Amount Including VAT"; Decimal)
        {
            Caption = 'Purchase Amount Including VAT';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Vendor Rebate Line"."Amount Including VAT" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(80; "Calculated Rebate Amount"; Decimal)
        {
            Caption = 'Calculated Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Vendor Rebate Details"."Calculated Line Rebate Amount" where("Batch Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(90; "Vendor Rebate Amount"; Decimal)
        {
            Caption = 'Vendor Rebate Amount';
            FieldClass = FlowField;
            CalcFormula = sum("AQD Vendor Rebate Details"."Vendor Rebate Amount" where("Batch Entry No." = field("Entry No."), Exclude = filter(false)));
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
                LocalVendorRebateHeader: Record "AQD Vendor Rebate Header";
            begin
                if Approved then begin
                    "Approved By" := UserId;
                    "Approved Date Time" := CurrentDateTime;
                end else begin
                    Clear("Approved By");
                    Clear("Approved Date Time");
                end;

                LocalVendorRebateHeader.RESET;
                LocalVendorRebateHeader.SetRange("Batch Entry No.", Rec."Entry No.");
                IF LocalVendorRebateHeader.FindFirst() THEN begin
                    repeat
                        LocalVendorRebateHeader.Validate(Approved, Rec.Approved);
                        LocalVendorRebateHeader.Modify(true);
                    Until LocalVendorRebateHeader.Next() = 0;
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
        VendorRebateHeader: Record "AQD Vendor Rebate Header";
    begin
        VendorRebateHeader.RESET;
        VendorRebateHeader.SetRange("Batch Entry No.", Rec."Entry No.");
        IF VendorRebateHeader.FindFirst() THEN begin
            Repeat
                IF VendorRebateHeader.BatchID <> '' THEN
                    VendorRebateHeader.Delete(TRUE);
            Until VendorRebateHeader.Next() = 0;
        end;
    end;
}