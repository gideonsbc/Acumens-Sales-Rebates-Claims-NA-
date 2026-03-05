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
                THEN BEGIN
                    Rec."AQD Cust Rebate Customer No." := CustomerRebateSetup."Default Rebate Customer No";
                    Rec."AQD CustRbt Calculation Date" := Rec."AQD CustRbt Calculation Date"::"Shipment Date";
                    IF Rec."AQD Cust Rebate Customer No." = '' THEN BEGIN
                        IF Rec."Bill-to Customer No." <> '' THEN
                            Rec."AQD Cust Rebate Customer No." := Rec."Bill-to Customer No."
                        ELSE
                            Rec."AQD Cust Rebate Customer No." := Rec."No.";
                    END;
                END;
            END;
        }
        field(14301920; "AQD Cust Rebate Customer No."; Code[20])
        {
            Caption = 'Rebate Bill-To Customer No.';
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