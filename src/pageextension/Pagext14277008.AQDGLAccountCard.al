pageextension 14277008 "AQD G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';

                group("Customer Rebate")
                {
                    Caption = 'Customer Regate';
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