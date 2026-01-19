tableextension 14301913 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14301910; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
            BEGIN
                IF CustomerRebateSetup.GET and
                   Rec."AQD Enroll for Cust Rebate"
                THEN
                    Rec."AQD Cust Rebate Customer No." := CustomerRebateSetup."Default Rebate Customer No";
            END;
        }
        field(14301920; "AQD Cust Rebate Customer No."; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Customer Rebate Category Code';
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