tableextension 14301916 "AQD CustRbt Item Charge Ext" extends "Item Charge"
{
    fields
    {
        field(14301910; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Cust Rebate Category Code';
            TableRelation = "AQD Cust Rebate Item Category";
        }

        field(14301930; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Use Cust Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Use Cust Rebate Setup From';
            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Item Charge can have Use Cust Rebate Setup From either Item Charge or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Cust Rebate Setup From" IN
                        [Rec."AQD Use Cust Rebate Setup From"::" ",
                         Rec."AQD Use Cust Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Cust Rebate Setup From"::"Charge (Item)"])
                then
                    Error(AllowedValueValidationLable);
            end;
        }
    }
}