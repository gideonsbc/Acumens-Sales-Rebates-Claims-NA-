namespace AcumenseRebatesBC.AcumenseRebatesBC;
using System.Security.User;

page 14301943 "AQD Customer Rebate Batch"
{
    ApplicationArea = All;
    Caption = 'Customer Rebate Batch';
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "AQD Customer Rebate Batch";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(BatchID; Rec.BatchID)
                {
                    ToolTip = 'Specifies the value of the BatchId field.', Comment = '%';
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                    Visible = ShowBillToCustomer;
                }
                field("Bill-To Customer Name"; Rec."Bill-To Customer Name")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer Name field.', Comment = '%';
                    Visible = ShowBillToCustomer;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Amount field.', Comment = '%';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
            }
            part("AQD Customer Rebate Subpg"; "AQD Customer Rebate Subpg")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Documents';
                SubPageLink = "Batch Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AQDCustomerRebateBatchPost)
            {
                ApplicationArea = All;
                Caption = 'Post Batch';
                Image = PostDocument;
                Visible = PostEnabled;

                trigger OnAction()
                var
                    UserConfirmLabel: Label 'Do you want to post Rebate Batch %1?';
                    CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
                begin
                    CustomerRebateSetup.GET;
                    if Confirm(StrSubstNo(UserConfirmLabel, Rec.BatchID)) then
                        CustomerRebatePost.PostCustomerRebateBatch(Rec);

                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        RebateUserSetup.Get(UserId);
        PostEnabled := false;
        ApproveEnabled := false;

        IF NOT RebateSetup.GET THEN
            RebateSetup.INIT;
        ShowBillToCustomer := RebateSetup."Post Rebates by Bill-To Cust";

        if RebateUserSetup."AQD Cust Rbt Rebate Role" in
          [RebateUserSetup."AQD Cust Rbt Rebate Role"::"Sales Manager",
           RebateUserSetup."AQD Cust Rbt Rebate Role"::Admin]
        then
            PostEnabled := true;

        if RebateUserSetup."AQD Cust Rbt Rebate Role" in
          [RebateUserSetup."AQD Cust Rbt Rebate Role"::Salesperson,
           RebateUserSetup."AQD Cust Rbt Rebate Role"::"Sales Manager",
           RebateUserSetup."AQD Cust Rbt Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    var
        CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
        PostEnabled: Boolean;
        ApproveEnabled: Boolean;
        RebateUserSetup: Record "User Setup";
        RebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        ShowBillToCustomer: Boolean;
}