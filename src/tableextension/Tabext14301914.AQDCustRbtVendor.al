tableextension 14301914 "AQD CustRbt Vendor Ext" extends Vendor
{
    fields
    {
        field(14277004; "AQD Vendor Type"; Option)
        {
            Caption = 'Vendor Type';
            OptionCaption = ' ,Rebate Vendor';
            OptionMembers = " ","Rebate Vendor";
            DataClassification = CustomerContent;
        }
        field(14277005; "AQD Payee Type"; Option)
        {
            Caption = 'Payee Type';
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Vendor,W2 Employee';
            OptionMembers = " ","1099 Vendor","W2 Employee";
            DataClassification = CustomerContent;
        }
        field(14277006; "AQD Enroll for Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;
        }
        // field(14277007; "AQD Rebate %"; Decimal)
        // {
        //     BlankZero = true;
        //     Caption = 'Rebate %';
        //     MaxValue = 100;
        //     MinValue = 0;
        //     DataClassification = CustomerContent;
        //     trigger OnValidate()
        //     begin
        //         TestField("AQD Rebate Type");
        //     end;
        // }
        field(14277008; "AQD Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        field(14277009; "AQD Rebate Payment Method"; Option)
        {
            Caption = 'Rebate Payment Method';
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
            DataClassification = CustomerContent;
        }
        // field(14277010; "AQD Rebate Type"; Option)
        // {
        //     Caption = 'Rebate Type';
        //     OptionCaption = ' ,Per Quantity,Percentage';
        //     OptionMembers = " ","Per Quantity",Percentage;
        //     DataClassification = CustomerContent;
        //     trigger OnValidate()
        //     begin
        //         IF Rec."AQD Rebate Type" <> xRec."AQD Rebate Type" THEN BEGIN
        //             Rec."AQD Rebate %" := 0;
        //             Rec."AQD Rebate Amount" := 0;
        //         END;
        //     end;
        // }
        // field(14277011; "AQD Rebate Amount"; Decimal)
        // {
        //     Caption = 'Rebate Per Quantity';
        //     MinValue = 0;
        //     DataClassification = CustomerContent;
        //     trigger OnValidate()
        //     begin
        //         TestField("AQD Rebate Type");
        //     end;
        // }
        field(14277012; "AQD Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            TableRelation = "AQD Rebate Customer Type";
        }
        field(14277020; "AQD Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor WHERE("AQD Vendor Type" = CONST("Rebate Vendor"));
            DataClassification = CustomerContent;
        }
        field(14277030; "AQD Calculation Date"; Enum "AQD VendRebateCalculation Type")
        {
            Caption = 'Calculation Date';
        }
    }
}

