// pageextension 14301912 "AQD CustRbt Fixed Asset Card" extends "Fixed Asset Card"
// {
//     layout
//     {
//         addafter(Maintenance)
//         {
//             group("Acumens Customer Rebate and Claims")
//             {
//                 Caption = 'Acumens Customer Rebates & Claims';
//                 Visible = false;

//                 field("AQD Customer Rebate Enabled"; Rec."AQD Customer Rebate Enabled")
//                 {
//                     ApplicationArea = All;
//                     ObsoleteState = Pending;
//                 }
//                 field("AQD Cust Rebate Category Code"; Rec."AQD Cust Rebate Category Code")
//                 {
//                     ApplicationArea = All;
//                     Editable = Rec."AQD Customer Rebate Enabled";
//                     Enabled = Rec."AQD Customer Rebate Enabled";
//                     ObsoleteState = Pending;
//                     ObsoleteReason = 'Removed from Page to Disable User Access';
//                     ObsoleteTag = '25.1023.0.10';
//                     Visible = FALSE;
//                 }
//             }
//         }
//     }
// }