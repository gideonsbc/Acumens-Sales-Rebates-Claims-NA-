// namespace AcumenseRebatesBC.AcumenseRebatesBC;

// page 14277023 "AQD Rebate Cust Type Matrix"
// {
//     ApplicationArea = All;
//     Caption = 'Rebate Customer Type Matrix';
//     PageType = List;
//     SourceTable = "AQD RebateCustTypeEligibility";
//     UsageCategory = Lists;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field("Code"; Rec."Rebate Customer Type")
//                 {
//                     ToolTip = 'Specifies the  Customer Type for the Rebate Customer Type.';
//                 }
//                 field(Description; Rec.Description)
//                 {
//                     ToolTip = 'Specifies the description of the Rebate Customer Type.';
//                 }
//                 field("Sales Amount Threshold"; Rec."Sales Amount Threshold")
//                 {
//                     ToolTip = 'Specifies the Sales Amount Threshold of the Rebate Customer Type.';
//                 }
//                 field(Blocked; Rec.Blocked)
//                 {
//                     ToolTip = 'Specifies the Block of the Rebate Customer Type.';
//                 }
//             }
//         }
//     }
// }
