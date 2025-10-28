tableextension 14301917 "AQD CustRbt Item Charge Ext" extends "Item Charge"
{
    fields
    {
        field(14277004; "AQD Customer Rebatable"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14277010; "AQD Vendor Rebatable"; Boolean)
        {
            Caption = 'Vendor Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14277030; "AQD Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            TableRelation = "AQD Cust Rebate Item Category";
        }

        field(14277040; "AQD Rebate Option"; Option)
        {
            Caption = 'Rebate Option';
            OptionMembers = " ",Purchase,Sales;
            OptionCaption = ' ,Purchase,Sales';
            DataClassification = CustomerContent;
        }
        field(14277050; "AQD Use Rebate Setup From"; enum "AQD Use Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From';
            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Item Charge can have Use Rebate Setup From either Item Charge or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Rebate Setup From" IN
                        [Rec."AQD Use Rebate Setup From"::" ",
                         Rec."AQD Use Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Rebate Setup From"::"Charge (Item)"])
                then
                    Error(AllowedValueValidationLable);
            end;
        }
    }
}