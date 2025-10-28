page 14277019 "AQD Customer Rebate Register"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Register';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Register";
    SourceTableView = SORTING("AQDEntry No.")
                      ORDER(Descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."AQDEntry No.")
                {
                    ApplicationArea = All;
                }
                field("Creation DateTime"; Rec."AQDCreation DateTime")
                {
                    ApplicationArea = All;
                }
                field("Created By User ID"; Rec."AQDCreated By User ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Payee Type"; Rec."AQDPayee Type")
                {
                    ApplicationArea = All;
                }
                field("Rebate Type"; Rec."AQDRebate Type")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Rebate Code"; Rec."AQDRebate Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."AQDLocation Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."AQDShortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."AQDShortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(State; Rec.AQDState)
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."AQDDocument Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."AQDDocument No.")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."AQDStart Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."AQDEnd Date")
                {
                    ApplicationArea = All;
                }
                field("Batch Name"; Rec."AQDBatch Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.AQDStatus)
                {
                    ApplicationArea = All;
                }
                field(Voided; Rec.AQDVoided)
                {
                    ApplicationArea = All;
                }
                field("Voided DateTime"; Rec."AQDVoided DateTime")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Voided By User ID"; Rec."AQDVoided By User ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Payment Date"; Rec."AQDPayment Date")
                {
                    ApplicationArea = All;
                }
                field("Payment Ref. No."; Rec."AQDPayment Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Base Amount"; Rec."AQDBase Amount")
                {
                    ApplicationArea = All;
                }
                field("Profit Amount"; Rec."AQDProfit Amount")
                {
                    ApplicationArea = All;
                }
                field("Rebate Amount"; Rec."AQDRebate Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1000000020; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control1000000021; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Rebate")
            {
                Caption = '&Rebate';
                Image = Check;
                action("Rebate Documents Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Documents Entries';
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RebatePost: Codeunit "AQD Rebate Post";
                    begin
                        Clear(RebatePost);
                        RebatePost.ShowRebateDocumentEntries(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Rebate Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RebatePost: Codeunit "AQD Rebate Post";
                    begin
                        Clear(RebatePost);
                        RebatePost.ShowRebateEntries(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Update Payment Info")
                {
                    ApplicationArea = All;
                    Caption = 'Update Payment Info';
                    Image = UpdateUnitCost;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RebateRegisterRec: Record "AQD Rebate Register";
                        RebatePost: Codeunit "AQD Rebate Post";
                    begin
                        CurrPage.SetSelectionFilter(RebateRegisterRec);

                        Clear(RebatePost);
                        RebatePost.UpdateW2EmployeeRebatePaid(RebateRegisterRec);
                        CurrPage.Update(false);
                    end;
                }
                action(Void)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Void';
                    Image = VoidCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        RebateRegisterRec: Record "AQD Rebate Register";
                        RebatePost: Codeunit "AQD Rebate Post";
                    begin
                        CurrPage.SetSelectionFilter(RebateRegisterRec);

                        Clear(RebatePost);
                        RebatePost.VoidRebateRegister(RebateRegisterRec);
                        CurrPage.Update(false);
                    end;
                }
                action("Remittance Report")
                {
                    ApplicationArea = All;
                    Caption = 'Remittance Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RebateRemittanceReport: Report "AQD Rebate Remittance";
                        RebateRegister: Record "AQD Rebate Register";
                        ReportRunFrom: Option " ","Payment Journal","Rebate Register";
                    begin
                        CurrPage.SetSelectionFilter(RebateRegister);

                        ReportRunFrom := ReportRunFrom::"Rebate Register";

                        Clear(RebateRemittanceReport);
                        RebateRemittanceReport.SetReportRunFrom(ReportRunFrom);
                        RebateRemittanceReport.SetTableView(RebateRegister);
                        RebateRemittanceReport.Run;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst then;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then
            CurrPage.SetSelectionFilter(RebateRegister);
    end;

    var
        RebateRegister: Record "AQD Rebate Register";

    procedure GetSelectionFilters(var RebateRegisterIn: Record "AQD Rebate Register")
    begin
        RebateRegisterIn.Copy(RebateRegister);
    end;
}

