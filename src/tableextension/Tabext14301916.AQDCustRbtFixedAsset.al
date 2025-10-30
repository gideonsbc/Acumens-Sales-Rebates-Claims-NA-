tableextension 14301916 "AQD CustRbt Fixed Asset Ext" extends "Fixed Asset"
{
    fields
    {
        field(14277004; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14277030; "AQD Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            TableRelation = "AQD Cust Rebate Item Category";
        }
        field(14277050; "AQD Use Rebate Setup From"; enum "AQD Use Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From';
            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Fixed Asset can have Use Rebate Setup From either Fixed Asset or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Rebate Setup From" IN
                        [Rec."AQD Use Rebate Setup From"::" ",
                         Rec."AQD Use Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Rebate Setup From"::"Fixed Asset"])
                then
                    Error(AllowedValueValidationLable);
            end;
        }
    }
}

