// page 14301913 "AQD CustRebateCategory Subpage"
// {
//     ApplicationArea = All;
//     AutoSplitKey = True;
//     Caption = 'Lines';
//     PageType = ListPart;
//     RefreshOnActivate = true;
//     UsageCategory = Lists;
//     SourceTable = "AQD Cust Rebate Category Lines";

//     layout
//     {
//         area(Content)
//         {
//             repeater(Group)
//             {
//                 field("Line No."; Rec."Line No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
//                     Visible = FALSE;
//                 }
//                 field("Rebate Program Code"; Rec."Rebate Program Code")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Rebate Program Code field.', Comment = '%';
//                     trigger OnValidate()
//                     var
//                         CustRebateProgramCode: Record "AQD Cust Rebate Program Code";
//                     begin
//                         IF CustRebateProgramCode.get(Rec."Rebate Program Code") THEN
//                             Rec.Description := CustRebateProgramCode.Description
//                         ELSE
//                             Rec.Description := '';
//                     end;
//                 }
//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the value of the Description field.', Comment = '%';
//                 }
//             }
//         }
//     }
// }