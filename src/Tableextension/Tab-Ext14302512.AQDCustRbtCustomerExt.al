tableextension 14302512 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14302510; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
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
        field(14302520; "AQD Cust Rebate Customer No."; Code[20])
        {
            Caption = 'Rebate Bill-To Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        field(14302550; "AQD Cust Rebate Category"; Code[20])
        {
            Caption = 'Customer Rebate Category';
            DataClassification = CustomerContent;
            TableRelation = "AQD Rebate Customer Category";
        }
        field(14302560; "AQD CustRbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
        field(14302610; "AQD Customer Claim Customer"; Boolean)
        {
            Caption = 'Claim Customer';
            DataClassification = CustomerContent;
        }
        field(14302620; "AQD Default Claim Type"; Enum "AQD Cust Claim Claim Type")
        {
            Caption = 'Default Claim Type';
            DataClassification = CustomerContent;
        }
    }
}