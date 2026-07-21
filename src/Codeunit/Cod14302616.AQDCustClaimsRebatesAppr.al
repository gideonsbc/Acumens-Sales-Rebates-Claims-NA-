codeunit 14302616 "AQD Cust. Claims_Rebates Appr."
{
    Permissions = tabledata "Approval Entry" = rimd,
                  tabledata "Document Attachment" = rimd;

    var
        Workflow: Record Workflow;
        WorkflowStepArgument: Record "Workflow Step Argument";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowWebhookManagementRec: Codeunit "Workflow Webhook Management";
        BlankDateFormula: DateFormula;
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        //  PendingPostedCustRebateLineApprovalExistsErr: Label 'An approval request already exists.', Comment = '%1 is the Document No. of the Sales Rebate Approvals';
        // PostedCustRebateLineDocategoryTxt: Label 'Sales Rebates';
        PostedCustRebateLineRequestCancelEventDescTxt: Label 'An approval request for Sales Rebate Approvals is canceled.';
        PostedCustRebateLineSendForApprovalEventDescTxt: Label 'Approval of a Sales Rebate Approvals is requested.';
        PostedCustRebateLineCategoryCode: Label 'SalesRebates';
        PostedCustRebateLineCategoryDescriptionTxt: Label 'Sales Rebates';
        PostedCustRebateLineApprWorkflowCodeTxt: Label 'SRAW';
        PostedCustRebateLineApprWorkflowDescTxt: Label 'Sales Rebates Approval Workflow';
        PostedCustRebateLineCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="AQD Sales Rebate Approvals">%1</DataItem></DataItems></ReportParameters>';
        RestrictPostedCustRebateLineUsageDetailsLbl: Label 'The restriction was imposed because the Sales Rebate Approvals requires approval.';

    procedure IsSalesClaimsandRebatesApprovalsEnabled(): Boolean
    var
        AcumensRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin

        if AcumensRebateSetup.Get() then
            exit(AcumensRebateSetup."Enable Rebate Approvals")
        else
            exit(false);
    end;

    procedure BuildPostedCustRebateLineConditions(Status: Enum "AQD Rebate Approval Status"): Text
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    Begin
        PostedCustRebateLine.SETRANGE("Approval Status", Status);
        EXIT(STRSUBSTNO(PostedCustRebateLineCondnTxt, WorkflowSetup.Encode(PostedCustRebateLine.GETVIEW(FALSE))));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', false, false)]
    local procedure p1173_OnBeforeInsertAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            DATABASE::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(PostedCustRebateLine);
                    DocumentAttachment.Validate("No.", PostedCustRebateLine."Sales Document No.");
                    DocumentAttachment.Validate("Document Type", DocumentAttachment."Document Type"::"AQD Customer Rebates&Claims");
                    DocumentAttachment.Validate("AQD CF RecordId", PostedCustRebateLine.RecordId);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure p1173_OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        RecNo: Code[20];
        FieldRef: FieldRef;
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            DATABASE::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(PostedCustRebateLine);
                    FieldRef := RecRef.Field(PostedCustRebateLine.FieldNo("Sales Document No."));
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                    DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::"AQD Customer Rebates&Claims");
                    DocumentAttachment.SetRange("AQD CF RecordId", PostedCustRebateLine.RecordId);
                end;
        end;
    end;

    procedure CheckPostedCustRebateLineApprovalsWorkflowEnabled(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals"): Boolean
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if not WorkflowManagement.CanExecuteWorkflow(PostedCustRebateLine, RunWorkflowOnSendPostedCustRebateLineForApprovalCode())
        then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    procedure RunWorkflowOnSendPostedCustRebateLineForApprovalCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDSALESREBATEAPPROVALSFORAPPROVAL');
    end;

    procedure RunWorkflowOnCancelPostedCustRebateLineRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELSALESREBATEAPPROVALSAPPROVALREQUEST');
    end;

    procedure ShowPostedCustRebateLineApprovalEntries(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetFilter("Table ID", '%1', Database::"AQD Sales Rebate Approvals");
        ApprovalEntry.SetFilter("Record ID to Approve", '%1', PostedCustRebateLine.RecordId);
        ApprovalEntry.SetRange("Related to Change", false);
        Page.Run(Page::"Approval Entries", ApprovalEntry);
    end;

    local procedure UpdateRestriction(RecVar: Variant; xRecVar: Variant)
    var
        RestrictedRecord: Record "Restricted Record";
        RecRef: RecordRef;
        xRecRef: RecordRef;
    begin
        xRecRef.GetTable(xRecVar);
        RecRef.GetTable(RecVar);

        if RecRef.IsTemporary then
            exit;

        if RestrictedRecord.IsEmpty then
            exit;

        RestrictedRecord.SetRange("Record ID", xRecRef.RecordId);
        RestrictedRecord.ModifyAll("Record ID", RecRef.RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure c1520_OnAddWorkflowEventsToLibrary()
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPostedCustRebateLineForApprovalCode(), Database::"AQD Sales Rebate Approvals",
          PostedCustRebateLineSendForApprovalEventDescTxt, 0, false);

        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPostedCustRebateLineRequestCode(), Database::"AQD Sales Rebate Approvals",
          PostedCustRebateLineRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure c1521_OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(), RunWorkflowOnSendPostedCustRebateLineForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():

                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(), RunWorkflowOnSendPostedCustRebateLineForApprovalCode());
            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(), RunWorkflowOnCancelPostedCustRebateLineRequestCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(), RunWorkflowOnCancelPostedCustRebateLineRequestCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', false, false)]
    local procedure C1502_WorkflowSetup_OnAddWorkflowCategoriesToLibrary()
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        WorkflowSetup.InsertWorkflowCategory(PostedCustRebateLineCategoryCode, PostedCustRebateLineCategoryDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure C1502_OnAfterInitWorkflowTemplates()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
        ApprovalEntry: Record "Approval Entry";
        WorkflowTemplate: Record Workflow;
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        WorkflowSetup.InsertTableRelation(DATABASE::"AQD Sales Rebate Approvals", 0,
          DATABASE::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));

        InsertPostedCustRebateLineApprovalWorkflowTemplate();
    end;

    local procedure InsertPostedCustRebateLineApprovalWorkflowTemplate()
    var
        WorkflowTemplates: Record Workflow;
    begin

        WorkflowTemplates.Reset();
        WorkflowTemplates.SetRange(Code, 'MS-' + PostedCustRebateLineApprWorkflowCodeTxt);
        WorkflowTemplates.SetRange(Template, true);
        if not WorkflowTemplates.FindFirst() then begin
            WorkflowSetup.InsertWorkflowTemplate(Workflow, PostedCustRebateLineApprWorkflowCodeTxt,
                      PostedCustRebateLineApprWorkflowDescTxt, PostedCustRebateLineCategoryCode);
            InsertPostedCustRebateLineApprovalWorkflowDetails(Workflow);
            WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
        end;
    end;

    local procedure InsertPostedCustRebateLineApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument,
          WorkflowStepArgument."Approver Type"::"Workflow User Group", WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
          0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
          BuildPostedCustRebateLineConditions(PostedCustRebateLine."Approval Status"::Open),
          RunWorkflowOnSendPostedCustRebateLineForApprovalCode(),
          BuildPostedCustRebateLineConditions(PostedCustRebateLine."Approval Status"::"Pending Approval"),
          RunWorkflowOnCancelPostedCustRebateLineRequestCode(),
          WorkflowStepArgument, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure c1535_OnPopulateApprovalEntryArgurment(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            Database::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(PostedCustRebateLine);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::"AQD Customer Rebates&Claims";
                    ApprovalEntryArgument."Document No." := PostedCustRebateLine."Sales Document No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::"AQD Customer Rebates&Claims"
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure c1521_OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
        PostedCustRebateLine1: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            Database::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(PostedCustRebateLine1);
                    PostedCustRebateLine.Get(PostedCustRebateLine1.RecordId);
                    PostedCustRebateLine.Validate("Approval Status", PostedCustRebateLine."Approval Status"::Open);
                    PostedCustRebateLine.SetSkipStatusCheck(true);
                    PostedCustRebateLine.Modify(true);
                    Handled := true;
                    RestrictPostedCustRebateLineRecord(PostedCustRebateLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure c1535_OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        RecRef.GetTable(Variant);

        case RecRef.Number of
            Database::"AQD Sales Rebate Approvals":
                begin
                    PostedCustRebateLine.Get(RecRef.RecordId);
                    PostedCustRebateLine.Validate("Approval Status", PostedCustRebateLine."Approval Status"::"Pending Approval");
                    PostedCustRebateLine.Modify(false);
                    Variant := PostedCustRebateLine;
                    IsHandled := true;

                    RestrictPostedCustRebateLineRecord(PostedCustRebateLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure c1521_OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
        CustClaimsandRebatesEvents: Codeunit "AQD Claims and Rebates Events";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            Database::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(PostedCustRebateLine);
                    PostedCustRebateLine.Validate("Approval Status", PostedCustRebateLine."Approval Status"::Approved);
                    PostedCustRebateLine.SetSkipStatusCheck(true);
                    PostedCustRebateLine.Modify(true);
                    Handled := true;

                    RemovePostedCustRebateLineRecordRestriction(PostedCustRebateLine);
                    CustClaimsandRebatesEvents.ReleaseSalesRebateForPaymentAfterApproval(PostedCustRebateLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", 'OnAfterRenameEvent', '', false, false)]
    local procedure Tab14302534_AQDPostedCustRebateLine_OnAfterRenameEvent(var Rec: Record "AQD Sales Rebate Approvals"; var xRec: Record "AQD Sales Rebate Approvals"; RunTrigger: Boolean)
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        ApprovalsMgmt.OnRenameRecordInApprovalRequest(xRec.RecordId, Rec.RecordId);
        UpdateRestriction(Rec, xRec);
    end;

    procedure ReopenRecord(PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    var
    //      myInt: Integer;
    begin
        if PostedCustRebateLine."Approval Status" <> PostedCustRebateLine."Approval Status"::Approved then
            exit;

        if PostedCustRebateLine."Approval Status" = PostedCustRebateLine."Approval Status"::"Pending Approval" then
            PostedCustRebateLine.FieldError("Approval Status");

        PostedCustRebateLine."Approval Status" := PostedCustRebateLine."Approval Status"::Open;
        PostedCustRebateLine.SetSkipStatusCheck(true);
        PostedCustRebateLine.Modify(true);

        RestrictPostedCustRebateLineRecord(PostedCustRebateLine);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"AQD Cust. Claims_Rebates Appr.", 'OnCancelPostedCustRebateLineRequest', '', false, false)]
    local procedure CU14259559_OnCancelPostedCustRebateLineRequest(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    begin
        if PostedCustRebateLine."Approval Status" = PostedCustRebateLine."Approval Status"::"Pending Approval" then begin
            WorkflowManagement.HandleEvent(RunWorkflowOnCancelPostedCustRebateLineRequestCode(), PostedCustRebateLine);
            WorkflowWebhookManagementRec.FindAndCancel(PostedCustRebateLine.RecordId);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    procedure C1535_OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RecRef: RecordRef;
        PostedCustRebateLine: Record "AQD Sales Rebate Approvals";
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case ApprovalEntry."Table ID" of
            Database::"AQD Sales Rebate Approvals":
                begin
                    PostedCustRebateLine.Get(ApprovalEntry."Record ID to Approve");
                    PostedCustRebateLine."Approval Status" := PostedCustRebateLine."Approval Status"::Open;
                    PostedCustRebateLine.SetSkipStatusCheck(true);
                    PostedCustRebateLine.Modify(true);

                    RestrictPostedCustRebateLineRecord(PostedCustRebateLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", OnGetDocumentTypeAndNumber, '', false, false)]
    local procedure c1510_OnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        lvPostedCustRebateLine: Record "AQD Sales Rebate Approvals";
        FieldRef: FieldRef;
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        case RecRef.Number of
            DATABASE::"AQD Sales Rebate Approvals":
                begin
                    RecRef.SetTable(lvPostedCustRebateLine);

                    DocumentType := RecRef.Caption;
                    FieldRef := RecRef.Field(1);
                    DocumentNo := Format(FieldRef.Value);
                    FieldRef := RecRef.Field(2);
                    DocumentNo += ',' + Format(FieldRef.Value);

                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", OnBeforeInsertEvent, '', false, false)]
    local procedure Tab14302534_AQDPostedCustRebateLine_OnBeforeInsertEvent(var Rec: Record "AQD Sales Rebate Approvals")
    begin
        if Rec.IsTemporary then
            exit;

        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;
        ;
        Rec."Approval Status" := Rec."Approval Status"::Open;

    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", OnAfterInsertEvent, '', false, false)]
    local procedure Tab14302534_AQDPostedCustRebateLine_OnAfterInsertEvent(var Rec: Record "AQD Sales Rebate Approvals")
    begin
        if Rec.IsTemporary then
            exit;

        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if Rec."Rebate Program Code" <> '' then
            RestrictPostedCustRebateLineRecord(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", 'OnBeforeModifyEvent', '', false, false)]
    local procedure Tab14302534_AQDPostedCustRebateLine_OnBeforeModifyEvent(var Rec: Record "AQD Sales Rebate Approvals"; var xRec: Record "AQD Sales Rebate Approvals"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        if Format(Rec) = Format(xRec) then
            exit;

        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if not WorkflowManagement.CanExecuteWorkflow(Rec, RunWorkflowOnSendPostedCustRebateLineForApprovalCode()) then
            exit;

        //TODO: To determine which fields should not be modified.

        //Add Obvious checks
        if Rec."Approval Status" = Rec."Approval Status"::"Pending Approval" then begin
            if RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Rec) then
                Error(RestrictPostedCustRebateLineUsageDetailsLbl);

            Error('Sales Rebate Approvals ' + Format(Rec.RecordId) + ' cannot be modified as it is pending Approval.');
        end;

        if (xRec."Approval Status" = xRec."Approval Status"::Approved) and (Rec."Approval Status" = Rec."Approval Status"::Open) then begin
            ApprovalsMgmt.PostApprovalEntries(Rec.RecordId, Rec.RecordId, Rec."Rebate Program Code");

            RestrictPostedCustRebateLineRecord(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"AQD Cust. Claims_Rebates Appr.", 'OnSendPostedCustRebateLineForApproval', '', false, false)]
    local procedure c14259559_OnSendPostedCustRebateLineForApproval(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        RestrictPostedCustRebateLineRecord(PostedCustRebateLine);

        WorkflowManagement.HandleEvent(RunWorkflowOnSendPostedCustRebateLineForApprovalCode(), PostedCustRebateLine);

    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", OnBeforeDeleteEvent, '', false, false)]
    local procedure Tab14302534_AQDPostedCustRebateLine_OnBeforeDeleteEvent(var Rec: Record "AQD Sales Rebate Approvals"; RunTrigger: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        PostedCustRebateLinemgmt: Codeunit "Serv-Documents Mgt.";
    begin
        if Rec.IsTemporary then
            exit;

        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if Rec."Approval Status" = Rec."Approval Status"::"Pending Approval" then
            Error(RestrictPostedCustRebateLineUsageDetailsLbl);

        RemovePostedCustRebateLineRecordRestriction(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Sales Rebate Approvals", OnAfterDeleteEvent, '', false, false)]
    local procedure Tab14302534_AQDADAPostedCustRebateLine_OnAfterDeleteEvent(var Rec: Record "AQD Sales Rebate Approvals"; RunTrigger: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        PostedCustRebateLinemgmt: Codeunit "Serv-Documents Mgt.";
    begin
        if Rec.IsTemporary then
            exit;

        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        ApprovalsMgmt.PostApprovalEntries(Rec.RecordId, Rec.RecordId, Rec."Rebate Program Code");
        ApprovalsMgmt.DeleteApprovalEntries(Rec.RecordId);
    end;

    procedure RestrictPostedCustRebateLineRecord(PostedCustRebateLineRec: Record "AQD Sales Rebate Approvals")
    begin
        if not IsSalesClaimsandRebatesApprovalsEnabled() then
            exit;

        if WorkflowManagement.CanExecuteWorkflow(PostedCustRebateLineRec, RunWorkflowOnSendPostedCustRebateLineForApprovalCode()) then
            RecordRestrictionMgt.RestrictRecordUsage(PostedCustRebateLineRec, RestrictPostedCustRebateLineUsageDetailsLbl);
    end;

    procedure RemovePostedCustRebateLineRecordRestriction(PostedCustRebateLineRec: Record "AQD Sales Rebate Approvals")
    begin
        RecordRestrictionMgt.AllowRecordUsage(PostedCustRebateLineRec);
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPostedCustRebateLineRequest(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPostedCustRebateLineForApproval(var PostedCustRebateLine: Record "AQD Sales Rebate Approvals")
    begin
    end;
}
