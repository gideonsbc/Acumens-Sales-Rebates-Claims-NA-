namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14277057 "AQD Vendor Rebate Batch"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Batch';
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "AQD Vendor Rebate Batch";

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
                field("AQD Rebate Batch Frequency"; Rec."AQD Rebate Batch Frequency")
                {
                    ToolTip = 'Specifies the value of the Rebate Batch Frequency field.', Comment = '%';
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
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ToolTip = 'Specifies the value of the Purchase Amount field.', Comment = '%';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.', Comment = '%';
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = All;
                    Editable = ApproveEnabled;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved Date Time"; Rec."Approved Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part("AQD Vendor Rebate Subpg"; "AQD Vendor Rebate Subpg")
            {
                ApplicationArea = All;
                Caption = 'Vendor Rebate Documents';
                SubPageLink = "Batch Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AQDVendorRebateBatchPost)
            {
                ApplicationArea = All;
                Caption = 'Post Batch';
                Image = PostDocument;
                Visible = PostEnabled;

                trigger OnAction()
                var
                    UserConfirmLabel: Label 'Do you want to post Rebate Batch %1?';
                begin
                    if not Rec.Approved then
                        Error('Vendor Rebate Batch is not approved. Please approve it before posting.');

                    if Confirm(StrSubstNo(UserConfirmLabel, Rec.BatchID)) then
                        VendorRebatePost.PostVendorRebateBatch(Rec);

                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        RebateSetup.Get(UserId);
        PostEnabled := false;
        ApproveEnabled := false;

        if RebateSetup."Rebate Role" in
          [RebateSetup."Rebate Role"::"Purchase Manager",
           RebateSetup."Rebate Role"::Admin]
        then
            PostEnabled := true;

        if RebateSetup."Rebate Role" in
          [RebateSetup."Rebate Role"::Purchaser,
           RebateSetup."Rebate Role"::"Purchase Manager",
           RebateSetup."Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    var
        VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
        PostEnabled: Boolean;
        ApproveEnabled: Boolean;
        RebateSetup: Record "AQD Rebate User Setup";
}