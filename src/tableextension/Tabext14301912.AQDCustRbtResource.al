tableextension 14301912 "AQD CustRbt Resource Ext" extends Resource
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
            Caption = 'Use Rebate Cost Setup From';

            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Resource can have Use Rebate Setup From either Resource or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Cust Rebate Setup From" IN
                        [Rec."AQD Use Cust Rebate Setup From"::" ",
                         Rec."AQD Use Cust Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Cust Rebate Setup From"::Resource])
                then
                    Error(AllowedValueValidationLable);
            end;
        }
    }
}