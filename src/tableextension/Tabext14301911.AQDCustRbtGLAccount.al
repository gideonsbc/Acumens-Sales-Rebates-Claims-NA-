tableextension 14301911 "AQD CustRbt G/L Account Ext" extends "G/L Account"
{
    fields
    {
        field(14301910; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            TableRelation = "AQD Cust Rebate Item Category";
        }
        field(14301930; "AQD Use Cust Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From';

            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'G/L Account can have Use Cust Rebate Setup From either G/L Account or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Cust Rebate Setup From" IN
                        [Rec."AQD Use Cust Rebate Setup From"::" ",
                         Rec."AQD Use Cust Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Cust Rebate Setup From"::"G/L Account"])
                then
                    Error(AllowedValueValidationLable);
            end;
        }
    }
}