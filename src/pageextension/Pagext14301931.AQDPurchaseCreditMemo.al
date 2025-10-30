// pageextension 14301931 "AQD Purchase Credit Memo" extends "Purchase Credit Memo"
// {
//     layout
//     {
//         addafter("Shipping and Payment")
//         {
//             group("AQD Rebate")
//             {
//                 Caption = 'Acumens Claims & Rebates';
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
//             }
//         }
//     }
// }