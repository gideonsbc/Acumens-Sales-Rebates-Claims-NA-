page 14277015 "AQD Rebate Journal"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Rebate Journal';
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "AQD Rebate Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control1000000017)
            {
                ShowCaption = false;
                field("USERID"; UserId)
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    Editable = false;
                    Enabled = false;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field("User ID"; Rec."AQDUser ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Line No."; Rec."AQDLine No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Type"; Rec."AQDRebate Type")
                {
                    ApplicationArea = All;
                }
                field("Rebate Code"; Rec."AQDRebate Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.AQDName)
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
                field("Customer No."; Rec."AQDCustomer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."AQDCustomer Name")
                {
                    ApplicationArea = All;
                }
                field(State; Rec.AQDState)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."AQDLocation Code")
                {
                    ApplicationArea = All;
                }
                field("Location Name"; Rec."AQDLocation Name")
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
                field("Payee Type"; Rec."AQDPayee Type")
                {
                    ApplicationArea = All;
                }
            }
            group(Control1000000037)
            {
                ShowCaption = false;
                fixed(Control1000000036)
                {
                    ShowCaption = false;
                    group(Control1000000033)
                    {
                        Caption = 'Base Amount';
                        field(TotalBaseAmount; TotalBaseAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies a description of the item.';
                        }
                    }
                    group(Control1000000039)
                    {
                        Caption = 'Profit Amount';
                        field(TotalProfitAmount; TotalProfitAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies a description of the item.';
                        }
                    }
                    group(Control1000000043)
                    {
                        Caption = 'Rebate Amount';
                        field(TotalRebateAmount; TotalRebateAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies a description of the item.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1000000014; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control1000000015; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Document")
            {
                ApplicationArea = All;
                Caption = 'Show Document';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RebateMgtEventsFuns: Codeunit "AQD Rebate Mgt Events&Funs";
                begin
                    Clear(RebateMgtEventsFuns);
                    RebateMgtEventsFuns.ShowDocument(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("Calculate Rebate")
            {
                ApplicationArea = All;
                Caption = 'Calculate Rebate';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    CalculateRebateJnl: Report "AQD Calculate Rebate Jnl";
                begin
                    Clear(CalculateRebateJnl);
                    CalculateRebateJnl.Run;
                    CurrPage.Update(false);
                end;
            }
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RebatePost: Codeunit "AQD Rebate Post";
                begin
                    Clear(RebatePost);
                    RebatePost.Run(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::ODataV4 then
            UpdateBalance;
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("AQDUser ID", UserId);
        Rec.FilterGroup(0);

        TotalBaseAmount := 0;
        TotalProfitAmount := 0;
        TotalRebateAmount := 0;
    end;

    var
        TotalBaseAmount: Decimal;
        TotalProfitAmount: Decimal;
        TotalRebateAmount: Decimal;
        ClientTypeManagement: Codeunit "Client Type Management";

    local procedure UpdateBalance()
    var
        RebateMgtEventsFuns: Codeunit "AQD Rebate Mgt Events&Funs";
    begin
        RebateMgtEventsFuns.CalcBalance(Rec, TotalBaseAmount, TotalProfitAmount, TotalRebateAmount);
    end;
}

