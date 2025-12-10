tableextension 14301944 "AQD CR Item Category Ext" extends "Item Category"
{
    fields
    {
        field(14301910; "AQD Customer Rebate"; Boolean)
        {
            Caption = 'Customer Rebate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                UserConfirmMsg: Label 'Do you want to update all Items having Customer Rebate Item Category %1?';
            BEGIN
                IF CONFIRM(StrSubstNo(UserConfirmMsg, Rec.Code)) THEN BEGIN
                    Item.RESET;
                    Item.SetRange("AQD Cust Rebate Category Code", Rec.Code);
                    Item.ModifyAll("AQD Customer Rebate Enabled", Rec."AQD Customer Rebate");
                END;
            END;
        }
    }
}