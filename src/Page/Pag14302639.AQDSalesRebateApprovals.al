page 14302639 "AQD Sales Rebate Approvals"
{
    Caption = 'Sales Rebate Approvals';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AQD Sales Rebate Approvals";
    Permissions = tabledata Workflow = RIMD;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting("Sales Document Type", "Sales Document No.", "Rebate Program Code") order(descending);
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sales Document Type"; Rec."Sales Document Type")
                {
                    ToolTip = 'Specifies the value of the Sales Document Type field.', Comment = '%';
                }
                field("Sales Document No."; Rec."Sales Document No.")
                {
                    ToolTip = 'Specifies the value of the Sales Document No. field.', Comment = '%';
                }
                field("Sales Document Posting Date"; Rec."Sales Document Posting Date")
                {
                    ToolTip = 'Specifies the value of the Sales Document Posting Date field.', Comment = '%';
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Sell-To Customer No. field.', Comment = '%';
                }
                field("AQD Sell-To Customer Name"; Rec."AQD Sell-To Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                }
                field("AQD Bill-To Customer Name"; Rec."AQD Bill-To Customer Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Pay-To Customer No."; Rec."Rebate Pay-To Customer No.")
                {
                    ToolTip = 'Specifies the value of the Rebate Pay-To Customer No. field.', Comment = '%';
                }
                field("Vendor Document Type"; Rec."Vendor Document Type")
                {
                    ToolTip = 'Specifies the value of the Vendor Document Type field.', Comment = '%';
                }
                field("Vendor Document No."; Rec."Vendor Document No.")
                {
                    ToolTip = 'Specifies the value of the Vendor Document No. field.', Comment = '%';
                }
                field("Rebate Program Code"; Rec."Rebate Program Code")
                {
                    ToolTip = 'Specifies the value of the Rebate Program Code field.', Comment = '%';
                }
                field("Document Amount"; Rec."Document Amount")
                {
                    ToolTip = 'Specifies the value of the Document Amount field.', Comment = '%';
                }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Rebate Amount field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        PostedRebateDetails: Record "AQD Posted Cust Reb Details";
                        PostedRebateDetailsPage: Page "AQD Posted CustRbtDetail List";
                    begin
                        case Rec."Sales Document Type" of
                            Rec."Sales Document Type"::"Credit Memo":
                                PostedRebateDetails.SetRange("Document Type", PostedRebateDetails."Document Type"::"Credit Memo");
                            Rec."Sales Document Type"::Invoice:
                                PostedRebateDetails.SetRange("Document Type", PostedRebateDetails."Document Type"::Invoice);
                            Rec."Sales Document Type"::"Return Receipt":
                                PostedRebateDetails.SetRange("Document Type", PostedRebateDetails."Document Type"::"Return Receipt");
                            Rec."Sales Document Type"::Shipment:
                                PostedRebateDetails.SetRange("Document Type", PostedRebateDetails."Document Type"::Shipment);
                        end;
                        PostedRebateDetails.SetRange("Document No.", Rec."Sales Document No.");
                        PostedRebateDetails.SetRange("Rebate Program Code", Rec."Rebate Program Code");

                        PostedRebateDetailsPage.SetTableView(PostedRebateDetails);
                        PostedRebateDetailsPage.RunModal();
                    end;
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ToolTip = 'Specifies the value of the Rebate % field.', Comment = '%';
                }
                field("Rebate Per Unit"; Rec."Rebate Per Unit")
                {
                    ToolTip = 'Specifies the value of the Rebate Per Unit field.', Comment = '%';
                }
                field("Approval Status"; Rec."Approval Status")
                {
                    ToolTip = 'Specifies the value of the Approval Status field.', Comment = '%';
                    Editable = false;
                }
                field("AQD CRBApproval Date"; Rec."AQD CRBApproval Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("AQD Document Approvals")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;

                action("AQD SendApprovalRequest")
                {
                    ApplicationArea = All;
                    Caption = 'Send A&pproval Request';
                    Enabled = (not AQDOpenApprovalEntriesExist) and AQDCanRequestApprovalForFlow and (Not RecordIsApproved);
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval to change the record.';
                    trigger OnAction()
                    var
                        Workflow: Record Workflow;
                        SelectedLinestoApprove: Record "AQD Sales Rebate Approvals";
                    begin
                        // if RebateClaimsWorkflowMgmt.CheckPostedCustRebateLineApprovalsWorkflowEnabled(Rec) then
                        //     RebateClaimsWorkflowMgmt.OnSendPostedCustRebateLineForApproval(Rec);

                        CurrPage.SetSelectionFilter(SelectedLinestoApprove);
                        if SelectedLinestoApprove.ISEMPTY then
                            exit;

                        if SelectedLinestoApprove.ISTEMPORARY then
                            exit;

                        if SelectedLinestoApprove.FindFirst() then
                            repeat
                                if SelectedLinestoApprove."Approval Status" = SelectedLinestoApprove."Approval Status"::Open then
                                    if RebateClaimsWorkflowMgmt.CheckPostedCustRebateLineApprovalsWorkflowEnabled(SelectedLinestoApprove) then
                                        RebateClaimsWorkflowMgmt.OnSendPostedCustRebateLineForApproval(SelectedLinestoApprove);

                            until SelectedLinestoApprove.Next() = 0;
                    end;
                }
                action("AQD Reopen")
                {
                    ApplicationArea = All;
                    Caption = 'Reopen';
                    Enabled = RecordIsApproved;
                    Image = SendApprovalRequest;
                    ToolTip = 'Reopen to change the record.';
                    trigger OnAction()
                    begin
                        if Rec."Approval Status" <> Rec."Approval Status"::Approved then
                            Rec.FieldError("Approval Status");

                        if Rec."Approval Status" = Rec."Approval Status"::Approved then
                            RebateClaimsWorkflowMgmt.ReopenRecord(Rec);
                    end;

                }

                action("AQD CancelApprovalRequest")
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = AQDCanCancelApprovalForRecord or AQDCanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        SelectedLinestoApprove: Record "AQD Sales Rebate Approvals";
                    begin
                        if not ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId) then
                            Error('Approval request for ' + Format(Rec.RecordId) + ' can only be cancelled by the sender or approval administrator');

                        // RebateClaimsWorkflowMgmt.OnCancelPostedCustRebateLineRequest(Rec);
                        // WorkflowWebhookManagementRec.FindAndCancel(Rec.RecordId);

                        CurrPage.SetSelectionFilter(SelectedLinestoApprove);
                        if SelectedLinestoApprove.ISEMPTY then
                            exit;

                        if SelectedLinestoApprove.ISTEMPORARY then
                            exit;

                        if SelectedLinestoApprove.FindFirst() then
                            repeat
                                if SelectedLinestoApprove."Approval Status" = SelectedLinestoApprove."Approval Status"::"Pending Approval" then begin
                                    RebateClaimsWorkflowMgmt.OnCancelPostedCustRebateLineRequest(SelectedLinestoApprove);
                                    WorkflowWebhookManagementRec.FindAndCancel(SelectedLinestoApprove.RecordId);
                                end;
                            until SelectedLinestoApprove.Next() = 0;
                    end;
                }
                action("AQD Approval Entries")
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        AQDApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        AQDApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
                action(ViewDocument)
                {
                    ApplicationArea = All;
                    Caption = 'View Document';
                    Image = Vendor;
                    trigger OnAction()
                    var
                        SalesInvHdr: Record "Sales Invoice Header";
                        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
                        SalesInvoicePg: Page "Posted Sales Invoice";
                        SalesCrMemoPg: Page "Posted Sales Credit Memo";
                    begin
                        Rec.TestField("Sales Document No.");
                        case Rec."Sales Document Type" of
                            Rec."Sales Document Type"::Invoice:
                                begin
                                    SalesInvHdr.Reset();
                                    SalesInvHdr.SetRange("No.", Rec."Sales Document No.");

                                    Clear(SalesInvoicePg);
                                    SalesInvoicePg.SetTableView(SalesInvHdr);
                                    SalesInvoicePg.Run;
                                end;
                            Rec."Sales Document Type"::"Credit Memo":
                                begin
                                    SalesCrMemoHdr.Reset();
                                    SalesCrMemoHdr.SetRange("No.", Rec."Sales Document No.");

                                    Clear(SalesCrMemoPg);
                                    SalesCrMemoPg.SetTableView(SalesCrMemoHdr);
                                    SalesCrMemoPg.Run;
                                end;
                        end;
                    end;
                }
                action("AQD CRC Attachments")
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Executes the Attachments action.';
                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GETTABLE(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RUNMODAL();
                    end;
                }
                action("AQD Comments")
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    ToolTip = 'View or add comments for the record';
                    Image = ViewComments;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                Visible = (OpenApprovalEntriesExistCurrUser and DocApprovalEnabled);
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'View Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action("AQD View Attachments")
                {
                    ApplicationArea = All;
                    Caption = 'View Attachments';
                    Image = Attach;
                    ToolTip = 'Executes the View Attachments action.';
                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GETTABLE(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RUNMODAL();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'Home';

                actionref(ViewDocument_Promoted; ViewDocument)
                {
                }
                group("AQD Category_Category5")
                {
                    Caption = 'Request Approval', Comment = 'Generated from the PromotedActionCategories property index 4.';
                    ShowAs = SplitButton;
                    actionref("AQD SendApprovalRequest_Promoted"; "AQD SendApprovalRequest")
                    {
                    }
                    actionref("AQD Reopen_Promoted"; "AQD Reopen")
                    {
                    }
                }
                actionref("AQD CancelApprovalRequest_Promoted"; "AQD CancelApprovalRequest")
                {
                }
                actionref("AQD CRC Attachments_Promoted"; "AQD CRC Attachments")
                {
                }
                actionref("AQD Comments_Promoted"; "AQD Comments")
                {
                }
                actionref("AQD Approval Entries_Promoted"; "AQD Approval Entries")
                {
                }
            }
            group(Category_Approval)
            {
                Caption = 'Approvals';
                Visible = (OpenApprovalEntriesExistCurrUser and DocApprovalEnabled);
                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
                actionref(Comment_Promoted; Comment)
                {
                }
                actionref("AQD View Attachments_Promoted"; "AQD View Attachments")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        //  DocApprovalEnabled := RebateClaimsWorkflowMgmt.IsCustomerClaimsandRebatesApprovalsEnabled();
        SetWorkflowControlsAppearance();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetWorkflowControlsAppearance();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetWorkflowControlsAppearance();
    end;

    var
        DocApprovalEnabled: Boolean;
        RebateClaimsWorkflowMgmt: Codeunit "AQD Cust. Claims_Rebates Appr.";
        AQDOpenApprovalEntriesExist: Boolean;
        AQDCanRequestApprovalForFlow: Boolean;
        AQDCanCancelApprovalForFlow: Boolean;
        AQDCanCancelApprovalForRecord: Boolean;
        WorkflowWebhookManagementRec: Codeunit "Workflow Webhook Management";
        OpenApprovalEntriesExistCurrUser: Boolean;
        RecordIsApproved: Boolean;

    local procedure SetWorkflowControlsAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        DocApprovalEnabled := RebateClaimsWorkflowMgmt.IsSalesClaimsandRebatesApprovalsEnabled();
        AQDOpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        AQDCanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookManagementRec.GetCanRequestAndCanCancel(Rec.RecordId, AQDCanRequestApprovalForFlow, AQDCanCancelApprovalForFlow);

        OpenApprovalEntriesExistCurrUser := false;

        if ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId) then
            OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);

        RecordIsApproved := Rec."Approval Status" = Rec."Approval Status"::Approved;
    end;
}