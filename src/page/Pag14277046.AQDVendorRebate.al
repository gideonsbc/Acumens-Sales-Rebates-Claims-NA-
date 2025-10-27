page 14277046 "AQD Vendor Rebate"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Document';
    //DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "AQD Vendor Rebate Header";
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                group("Buy-from")
                {
                    field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies the value of the Buy-from Vendor No. field.', Comment = '%';
                    }
                    field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the value of the Buy-from Vendor Name field.', Comment = '%';
                    }
                    field("Buy-from Vendor Name 2"; Rec."Buy-from Vendor Name 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Name 2';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Buy-from Vendor Name 2 field.', Comment = '%';
                    }
                    field("Buy-from Address"; Rec."Buy-from Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        ToolTip = 'Specifies the value of the Buy-from Address field.', Comment = '%';
                    }
                    field("Buy-from Address 2"; Rec."Buy-from Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Buy-from Address 2 field.', Comment = '%';
                    }

                    field("Buy-from Contact"; Rec."Buy-from Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        ToolTip = 'Specifies the value of the Buy-from Contact field.', Comment = '%';
                    }
                    field("Buy-from Post Code"; Rec."Buy-from Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Zip Code';
                        ToolTip = 'Specifies the value of the Buy-from ZIP Code field.', Comment = '%';
                    }
                    field("Buy-from City"; Rec."Buy-from City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        ToolTip = 'Specifies the value of the Buy-from City field.', Comment = '%';
                    }
                    field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        ToolTip = 'Specifies the value of the Buy-from Country/Region Code field.', Comment = '%';
                    }
                    field("Buy-from County"; Rec."Buy-from County")
                    {
                        ApplicationArea = All;
                        Caption = 'County';
                        ToolTip = 'Specifies the value of the Buy-from State field.', Comment = '%';
                    }
                }
                field("AQD Calculation Date"; Rec."AQD Calculation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Calculation Date';
                }
                field("Purchase Amount"; Rec."Purchase Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Rebate Amount';
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Vendor Rebate Amount"; Rec."Vendor Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Rebate Amount';
                    ToolTip = 'Specifies the value of the Vendor Rebate Amount field.';
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

                group("Pay-To")
                {
                    field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies the value of the Pay-to Vendor No. field.', Comment = '%';
                    }
                    field("Pay-to Name"; Rec."Pay-to Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                    }
                    field("Pay-to Name 2"; Rec."Pay-to Name 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Name 2';
                        ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Pay-to Address"; Rec."Pay-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                    }
                    field("Pay-to Address 2"; Rec."Pay-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Pay-to Contact"; Rec."Pay-to Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                    }
                    field("Pay-to Post Code"; Rec."Pay-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Zip Code';
                        ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                    }
                    field("Pay-to City"; Rec."Pay-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        ToolTip = 'Specifies the value of the City field.', Comment = '%';
                    }

                    field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                    }
                    field("Pay-to County"; Rec."Pay-to County")
                    {
                        ApplicationArea = All;
                        Caption = 'County';
                        ToolTip = 'Specifies the value of the Pay-to State field.', Comment = '%';
                    }
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Description field.', Comment = '%';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.', Comment = '%';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field.', Comment = '%';
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchaser Code field.', Comment = '%';
                    Importance = Additional;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                    Importance = Additional;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                    Importance = Additional;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.', Comment = '%';
                    Importance = Additional;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.', Comment = '%';
                    Importance = Additional;
                }
            }
            part("AQD Vendor Rebate Subpage"; "AQD Vendor Rebate Subpage")
            {
                Caption = 'Document Lines';
                ApplicationArea = All;
                SubPageLink = "Rebate No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = PostDocument;
                Visible = PostEnabled;

                trigger OnAction()
                begin
                    if not Rec.Approved then
                        Error('The document is not approved. Please approve it before posting.');

                    VendorRebatePost.PostVendorRebate(Rec, true);

                    CurrPage.Update(false);
                end;
            }
            action(Comments)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = Comment;
                RunObject = page "AQD Vendor Rebate Comments";
                RunPageLink = "Rebate No." = field("No.");
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Rebates';
                actionref(Comments_Promoted; Comments)
                {
                }
                actionref(Post_Promoted; Post)
                {
                }
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

    trigger OnAfterGetRecord()
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