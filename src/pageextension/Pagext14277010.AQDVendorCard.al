pageextension 14277010 "AQD Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("AQD Rebate")
            {
                Caption = 'Acumens Claims & Rebates';
                field("AQD AER Vendor Type"; Rec."AQD Vendor Type")
                {
                    ApplicationArea = All;
                }
                group(CustomerRebate)
                {
                    Caption = 'Customer Rebate';

                    field("AQD AER Payee Type"; Rec."AQD Payee Type")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD AQD Rebate Payment Method"; Rec."AQD Rebate Payment Method")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                }
                group(VendorRebate)
                {
                    Caption = 'Vendor Rebate';
                    field("AQD Enroll for Rebate"; Rec."AQD Enroll for Rebate")
                    {
                        ApplicationArea = All;
                    }
                    field("AQD Rebate Vendor No"; Rec."AQD Rebate Vendor No")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Enroll for Rebate";
                    }
                    field("AQD Vendor Rebate Type"; Rec."AQD Rebate Vendor Type")
                    {
                        ApplicationArea = All;
                        Editable = Rec."AQD Enroll for Rebate";
                    }
                    Field("AQD Calculation Date"; Rec."AQD Calculation Date")
                    {
                        ApplicationArea = All;
                        Caption = 'Calculation Date';
                        Editable = Rec."AQD Enroll for Rebate";
                        Enabled = Rec."AQD Enroll for Rebate";
                    }
                }
            }
        }
    }
}