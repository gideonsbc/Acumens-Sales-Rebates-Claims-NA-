pageextension 14277007 "AQD Item Charges" extends "Item Charges"
{
    layout
    {
        addafter("Search Description")
        {
            field("AQD Customer Rebatable"; Rec."AQD Customer Rebatable")
            {
                ApplicationArea = All;
            }
            field("AQD Rebate Option"; Rec."AQD Rebate Option")
            {
                ApplicationArea = All;
            }
            field("AQD Vendor Rebatable"; Rec."AQD Vendor Rebatable")
            {
                ApplicationArea = All;
                Caption = 'Rebatable';

            }
            // field("AQD Vendor Rebate Type"; Rec."AQD Vendor Rebate Type")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Rebate Type';
            // }
            // field("AQD Vendor Rebate %"; Rec."AQD Vendor Rebate %")
            // {
            //     ApplicationArea = All;
            //     Editable = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
            //     Enabled = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
            //     Caption = 'Rebate %';
            // }
            // field("AQD Ven Rebate Amount Per Qty"; Rec."AQD Ven Rebate Amount Per Qty")
            // {
            //     ApplicationArea = All;
            //     Editable = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
            //     Enabled = Rec."AQD Vendor Rebate Type" = Rec."AQD Vendor Rebate Type"::Percentage;
            //     Caption = 'Rebate per Quantity';
            // }
            field("AQD Rebate Category Code"; Rec."AQD Rebate Category Code")
            {
                ApplicationArea = All;
                Editable = Rec."AQD Vendor Rebatable";
                Enabled = Rec."AQD Vendor Rebatable";
            }
            field("AQD Use Rebate Setup From"; Rec."AQD Use Rebate Setup From")
            {
                ApplicationArea = All;
                Editable = Rec."AQD Vendor Rebatable";
                Enabled = Rec."AQD Vendor Rebatable";
            }
        }
    }
}


