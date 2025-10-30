pageextension 14301912 "AQD Fixed Asset Card" extends "Fixed Asset Card"
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
                    field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Rebate Category Code"; Rec."AQD Rebate Category Code")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate Enabled";
                        Enabled = Rec."AQD Customer Rebate Enabled";
                    }
                    field("AQD Use Rebate Setup From"; Rec."AQD Use Rebate Setup From")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Customer Rebate Enabled";
                        Enabled = Rec."AQD Customer Rebate Enabled";
                    }
                }
            }
        }
    }
}



