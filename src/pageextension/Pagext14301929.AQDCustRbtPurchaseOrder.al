// pageextension 14301929 "AQD Purchase Order" extends "Purchase Order"
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
//                 FIELD(AQDRebateOrderDate; Rec."AQD Rebate Order Date")
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