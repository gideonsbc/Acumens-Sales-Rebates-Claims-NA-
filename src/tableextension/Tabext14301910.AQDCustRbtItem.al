tableextension 14301910 "AQD CustRbt Item Ext" extends Item
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
            DataClassification = CustomerContent;
            TableRelation = "AQD Cust Rebate Item Category";
        }
        field(14301940; "AQD Use Cust Rebate Setup From"; enum "AQD Use Cust Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Item can have Use Rebate Setup From either Item or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Cust Rebate Setup From" IN
                        [Rec."AQD Use Cust Rebate Setup From"::" ",
                         Rec."AQD Use Cust Rebate Setup From"::"Rebate Program Code",
                         Rec."AQD Use Cust Rebate Setup From"::Item])
                then
                    Error(AllowedValueValidationLable);

                IF Rec."AQD Use Cust Rebate Setup From" = Rec."AQD Use Cust Rebate Setup From"::"Rebate Program Code" then
                    Rec."AQD Cust Rebate Posting Type" := Rec."AQD Cust Rebate Posting Type"::" ";
            end;
        }
        field(14301950; "AQD Cust Rebate Posting Type"; enum "AQD Cust Rebate Posting Type")
        {
            Caption = 'Rebate Cost Posting Type';
            DataClassification = CustomerContent;
        }
    }
}