tableextension 14277026 "AQD Item Ledger Entry Ext" extends "Item Ledger Entry"
{
    fields
    {
        field(14277061; "AQD Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Quantity,Percentage';
            OptionMembers = " ","Per Quantity",Percentage;
            Editable = false;
        }

        field(14277062; "AQD Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            Editable = false;
        }
        field(14277063; "AQD Rebate Per Quantity"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Rebate Per Quantity';
            Editable = false;
        }
        field(14277064; "AQD Customer Rebate Amount"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Customer Rebate Amount';
        }
    }
}

