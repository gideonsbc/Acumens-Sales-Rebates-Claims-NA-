// pageextension 14301936 "AQD Posted Purchase Receipt" extends "Posted Purchase Receipt"
// {
//     layout
//     {
//         addafter(Shipping)
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
//                 field("AQD Rebate No."; Rec."AQD Rebate No.")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
// }