// pageextension 14301935 "AQD Posted Purch. C. Memo" extends "Posted Purchase Credit Memo"
// {
//     layout
//     {
//         addafter("Shipping and Payment")
//         {
//             group("AQD Rebate")
//             {
//                 Caption = 'Acumens Claims & Rebates';
//                 Editable = false;
//                 field("AQD Rebate Vendor No"; Rec."AQD Rebate Vendor No")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Rebate Last Changed By"; Rec."AQD Rebate Last Changed By")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Rebate LastChangd DateTime"; Rec."AQD Rebate LastChangd DateTime")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Rebate Status"; Rec."AQD Rebate Status")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Rebate No."; Rec."AQD Rebate No.")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
// }