pageextension 14302542 "AQD CustRbt DropShptInfo" extends "AQD Drop Shipment Information"
{
    layout
    {
        addlast(General)
        {
            field("AQD CustRbt Cust Rbt Amount"; Rec."AQD CustRbt Cust Rbt Amount")
            {
                ApplicationArea = All;
                Editable = false;

                trigger OnDrillDown()
                var
                    PostedCustomerRebateDetails: Record "AQD Posted Cust Reb Details";
                begin
                    PostedCustomerRebateDetails.RESET;
                    PostedCustomerRebateDetails.SetRange("Order No.", Rec."Sales Order No.");
                    PostedCustomerRebateDetails.SetRange("Order Line No.", Rec."Sales Order Line No.");
                    PAGE.RUN(PAGE::"AQD Posted Cust Rebate Details", PostedCustomerRebateDetails);
                end;
            }
        }
    }
}