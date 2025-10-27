pageextension 14277006 "AQD Fixed Asset Card" extends "Fixed Asset Card"
{
    layout
    {
        addafter(Maintenance)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                group("Customer Rebate")
                {
                    Caption = 'Customer Rebate';
                    field("AQD AQD Customer Rebatable"; Rec."AQD Customer Rebatable")
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



