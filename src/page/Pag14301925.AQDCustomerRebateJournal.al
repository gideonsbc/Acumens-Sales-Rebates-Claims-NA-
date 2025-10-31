// page 14301925 "AQD Customer Rebate Journal"
// {
//     ApplicationArea = All;
//     AutoSplitKey = true;
//     Caption = 'Customer Rebate Journal';
//     DelayedInsert = true;
//     InsertAllowed = false;
//     ModifyAllowed = false;
//     PageType = Worksheet;
//     SaveValues = true;
//     SourceTable = "AQD Cust Rebate Journal Line";
//     UsageCategory = Tasks;

//     layout
//     {
//         area(content)
//         {
//             group(Control1000000017)
//             {
//                 ShowCaption = false;
//                 field("USERID"; UserId)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'User ID';
//                     Editable = false;
//                     Enabled = false;
//                 }
//             }
//             repeater(Group)
//             {
//                 Editable = false;
//                 field("AQD User ID"; Rec."AQD User ID")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("AQD Line No."; Rec."AQD Line No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Pay-To Rebate Type"; Rec."AQD Pay-To Rebate Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Rebate Code"; Rec."AQD Rebate Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Name; Rec."AQD Name")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Document Type"; Rec."AQD Document Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Document No."; Rec."AQD Document No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Customer No."; Rec."AQD Customer No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Customer Name"; Rec."AQD Customer Name")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(State; Rec."AQD State")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Location Code"; Rec."AQD Location Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Location Name"; Rec."AQD Location Name")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Shortcut Dimension 1 Code"; Rec."AQD Shortcut Dimension 1 Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Shortcut Dimension 2 Code"; Rec."AQD Shortcut Dimension 2 Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Base Amount"; Rec."AQD Base Amount")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Profit Amount"; Rec."AQD Profit Amount")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Rebate Amount"; Rec."AQD Rebate Amount")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Payee Type"; Rec."AQD Payee Type")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//             group(Control1000000037)
//             {
//                 ShowCaption = false;
//                 fixed(Control1000000036)
//                 {
//                     ShowCaption = false;
//                     group(Control1000000033)
//                     {
//                         Caption = 'Base Amount';
//                         field(TotalBaseAmount; TotalBaseAmount)
//                         {
//                             ApplicationArea = Basic, Suite;
//                             Editable = false;
//                             ShowCaption = false;
//                             ToolTip = 'Specifies a description of the item.';
//                         }
//                     }
//                     group(Control1000000039)
//                     {
//                         Caption = 'Profit Amount';
//                         field(TotalProfitAmount; TotalProfitAmount)
//                         {
//                             ApplicationArea = Basic, Suite;
//                             Editable = false;
//                             ShowCaption = false;
//                             ToolTip = 'Specifies a description of the item.';
//                         }
//                     }
//                     group(Control1000000043)
//                     {
//                         Caption = 'Rebate Amount';
//                         field(TotalRebateAmount; TotalRebateAmount)
//                         {
//                             ApplicationArea = Basic, Suite;
//                             Editable = false;
//                             ShowCaption = false;
//                             ToolTip = 'Specifies a description of the item.';
//                         }
//                     }
//                 }
//             }
//         }
//         area(factboxes)
//         {
//             systempart(Control1000000014; Notes)
//             {
//                 ApplicationArea = All;
//             }
//             systempart(Control1000000015; Links)
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     actions
//     {
//         area(processing)
//         {
//             action("Show Document")
//             {
//                 ApplicationArea = All;
//                 Caption = 'Show Document';
//                 Image = Card;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;

//                 trigger OnAction()
//                 var
//                     RebateMgtEventsFuns: Codeunit "AQD Rebate Mgt EventsFunctions";
//                 begin
//                     Clear(RebateMgtEventsFuns);
//                     RebateMgtEventsFuns.ShowDocument(Rec);
//                     CurrPage.Update(false);
//                 end;
//             }
//             action("Calculate Rebate")
//             {
//                 ApplicationArea = All;
//                 Caption = 'Calculate Rebate';
//                 Image = Calculate;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;

//                 trigger OnAction()
//                 var
//                     CalculateRebateJnl: Report "AQD Calculate Cust Rebate Jnl";
//                 begin
//                     Clear(CalculateRebateJnl);
//                     CalculateRebateJnl.Run;
//                     CurrPage.Update(false);
//                 end;
//             }
//             action(Post)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Post';
//                 Image = PostBatch;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;

//                 trigger OnAction()
//                 var
//                     RebatePost: Codeunit "AQD Customer Rebate Post";
//                 begin
//                     Clear(RebatePost);
//                     RebatePost.Run(Rec);
//                     CurrPage.Update(false);
//                 end;
//             }
//         }
//     }

//     trigger OnAfterGetCurrRecord()
//     begin
//         if ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::ODataV4 then
//             UpdateBalance;
//     end;

//     trigger OnOpenPage()
//     begin
//         Rec.FilterGroup(2);
//         Rec.SetRange("AQD User ID", UserId);
//         Rec.FilterGroup(0);

//         TotalBaseAmount := 0;
//         TotalProfitAmount := 0;
//         TotalRebateAmount := 0;
//     end;

//     var
//         TotalBaseAmount: Decimal;
//         TotalProfitAmount: Decimal;
//         TotalRebateAmount: Decimal;
//         ClientTypeManagement: Codeunit "Client Type Management";

//     local procedure UpdateBalance()
//     var
//         RebateMgtEventsFuns: Codeunit "AQD Rebate Mgt EventsFunctions";
//     begin
//         RebateMgtEventsFuns.CalcBalance(Rec, TotalBaseAmount, TotalProfitAmount, TotalRebateAmount);
//     end;
// }

