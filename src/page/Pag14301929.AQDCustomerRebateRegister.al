// page 14301929 "AQD Customer Rebate Register"
// {
//     ApplicationArea = All;
//     Caption = 'Customer Rebate Register';
//     DeleteAllowed = false;
//     Editable = false;
//     InsertAllowed = false;
//     ModifyAllowed = false;
//     PageType = List;
//     RefreshOnActivate = true;
//     SourceTable = "AQD Customer Rebate Register";
//     SourceTableView = SORTING("AQD Entry No.")
//                       ORDER(Descending);
//     UsageCategory = Lists;

//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {
//                 field("Entry No."; Rec."AQD Entry No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Creation DateTime"; Rec."AQD Creation DateTime")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Created By User ID"; Rec."AQD Created By User ID")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("Payee Type"; Rec."AQD Payee Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Rebate Type"; Rec."AQD Rebate Type")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("Rebate Code"; Rec."AQD Rebate Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Location Code"; Rec."AQD Location Code")
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
//                 field(State; Rec."AQD State")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Document Type"; Rec."AQD Document Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Document No."; Rec."AQDDocument No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Start Date"; Rec."AQD Start Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("End Date"; Rec."AQD End Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Batch Name"; Rec."AQD Batch Name")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Status; Rec."AQD Status")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("AQD Voided"; Rec."AQD Voided")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Voided DateTime"; Rec."AQD Voided DateTime")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("Voided By User ID"; Rec."AQD Voided By User ID")
//                 {
//                     Visible = false;
//                     ApplicationArea = All;
//                 }
//                 field("Payment Date"; Rec."AQD Payment Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Payment Ref. No."; Rec."AQD Payment Ref. No.")
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
//             }
//         }
//         area(factboxes)
//         {
//             systempart(Control1000000020; Notes)
//             {
//                 ApplicationArea = All;
//             }
//             systempart(Control1000000021; Links)
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     actions
//     {
//         area(navigation)
//         {
//             group("&Rebate")
//             {
//                 Caption = '&Rebate';
//                 Image = Check;
//                 action("Rebate Documents Entries")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Rebate Documents Entries';
//                     Image = Documents;
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     PromotedOnly = true;

//                     trigger OnAction()
//                     var
//                         CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
//                     begin
//                         Clear(CustomerRebatePost);
//                         CustomerRebatePost.ShowRebateDocumentEntries(Rec);
//                         CurrPage.Update(false);
//                     end;
//                 }
//                 action("Rebate Entries")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Rebate Entries';
//                     Image = EntriesList;
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     PromotedOnly = true;

//                     trigger OnAction()
//                     var
//                         CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
//                     begin
//                         Clear(CustomerRebatePost);
//                         CustomerRebatePost.ShowRebateEntries(Rec);
//                         CurrPage.Update(false);
//                     end;
//                 }
//                 action("Update Payment Info")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Update Payment Info';
//                     Image = UpdateUnitCost;
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     PromotedOnly = true;

//                     trigger OnAction()
//                     var
//                         RebateRegisterRec: Record "AQD Customer Rebate Register";
//                         CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
//                     begin
//                         CurrPage.SetSelectionFilter(RebateRegisterRec);

//                         Clear(CustomerRebatePost);
//                         CustomerRebatePost.UpdateW2EmployeeRebatePaid(RebateRegisterRec);
//                         CurrPage.Update(false);
//                     end;
//                 }
//                 action(Void)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     Caption = 'Void';
//                     Image = VoidCheck;
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     PromotedOnly = true;
//                     trigger OnAction()
//                     var
//                         RebateRegisterRec: Record "AQD Customer Rebate Register";
//                         CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
//                     begin
//                         CurrPage.SetSelectionFilter(RebateRegisterRec);

//                         Clear(CustomerRebatePost);
//                         CustomerRebatePost.VoidRebateRegister(RebateRegisterRec);
//                         CurrPage.Update(false);
//                     end;
//                 }
//                 action("Remittance Report")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Remittance Report';
//                     Image = "Report";
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     PromotedOnly = true;

//                     trigger OnAction()
//                     var
//                         RebateRemittanceReport: Report "AQD Cust Rebate Remittance";
//                         RebateRegister: Record "AQD Customer Rebate Register";
//                         ReportRunFrom: Option " ","Payment Journal","Rebate Register";
//                     begin
//                         CurrPage.SetSelectionFilter(RebateRegister);

//                         ReportRunFrom := ReportRunFrom::"Rebate Register";

//                         Clear(RebateRemittanceReport);
//                         RebateRemittanceReport.SetReportRunFrom(ReportRunFrom);
//                         RebateRemittanceReport.SetTableView(RebateRegister);
//                         RebateRemittanceReport.Run;
//                         CurrPage.Update(false);
//                     end;
//                 }
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         if Rec.FindFirst then;
//     end;

//     trigger OnQueryClosePage(CloseAction: Action): Boolean
//     begin
//         if CloseAction in [ACTION::OK, ACTION::LookupOK] then
//             CurrPage.SetSelectionFilter(RebateRegister);
//     end;

//     var
//         RebateRegister: Record "AQD Customer Rebate Register";

//     procedure GetSelectionFilters(var RebateRegisterIn: Record "AQD Customer Rebate Register")
//     begin
//         RebateRegisterIn.Copy(RebateRegister);
//     end;
// }

