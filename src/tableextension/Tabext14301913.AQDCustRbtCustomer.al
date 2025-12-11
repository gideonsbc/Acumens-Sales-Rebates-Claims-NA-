tableextension 14301913 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14301910; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec."AQD Cust Rebate Customer No." := Rec."No.";
            end;
        }
        field(14301920; "AQD Cust Rebate Customer No."; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Customer Rebate Category"; Code[20])
        {
            Caption = 'Customer Rebate Category';
            DataClassification = CustomerContent;
            TableRelation = "AQD Rebate Customer Category";
        }
        field(14301960; "AQD CustRbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}