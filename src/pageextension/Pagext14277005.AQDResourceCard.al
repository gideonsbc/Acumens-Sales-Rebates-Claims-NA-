pageextension 14277005 "AQD Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';

                group("Customer Regate")
                {
                    Caption = 'Customer Rebate';
                    field("AQD Customer Rebatable"; Rec."AQD Customer Rebatable")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Vendor Rebate")
                {
                    Caption = 'Vendor Rebate';

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
    }
}

