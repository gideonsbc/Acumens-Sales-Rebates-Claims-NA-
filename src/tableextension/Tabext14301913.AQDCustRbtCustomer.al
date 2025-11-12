tableextension 14301913 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14301910; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(14277030; "AQD Cust RebatePosting SrcType"; enum "AQD Cust RebatePosting SrcType")
        {
            Caption = 'Cust Rebate Posting Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            BEGIN
                IF Rec."AQD Cust RebatePosting SrcType" <> xRec."AQD Cust RebatePosting SrcType" THEN
                    Rec."AQD Cust Rebate Customer No" := '';
            END;
        }
        field(14301950; "AQD Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            DataClassification = CustomerContent;
            TableRelation = "AQD CustRbt RebateCustomerType";
        }
        field(14301960; "AQD CustRbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}