page 14302533 "AQD Customer Rebate Document"
{
    ApplicationArea = All;
    Caption = 'Sales Rebate Document';
    //DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "AQD Customer Rebate Header";
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
                group(RebateToCustomer)
                {
                    Caption = 'Rebate Pay-To';
                    field("Rebate-To Customer No."; Rec."Rebate Pay-To Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        ToolTip = 'Specifies the value of the Rebate-To Customer No. field.', Comment = '%';
                    }
                    field("Rebate-to Name"; Rec."Rebate-to Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                    }
                    field("Rebate-To Name 2"; Rec."Rebate-To Name 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Name 2';
                        ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Rebate-To Address"; Rec."Rebate-To Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                    }
                    field("Rebate-To Address 2"; Rec."Rebate-To Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Rebate-To Contact"; Rec."Rebate-To Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                    }
                    field("Rebate-To Post Code"; Rec."Rebate-To Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Zip Code';
                        ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                    }
                    field("Rebate-To City"; Rec."Rebate-To City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        ToolTip = 'Specifies the value of the City field.', Comment = '%';
                    }

                    field("Rebate-To Country/Region Code"; Rec."Rebate-To Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                    }
                    field("Rebate-To County"; Rec."Rebate-To County")
                    {
                        ApplicationArea = All;
                        Caption = 'County';
                        ToolTip = 'Specifies the value of the Rebate-To State field.', Comment = '%';
                    }
                }
                field("AQD Calculation Date"; Rec."AQD Calculation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Calculation Date';
                }
                field("Commission Type"; Rec."Commission Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the commission is paid to or collected from the customer.', Comment = '%';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Calculated Rebate Amount"; Rec."Calculated Rebate Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Calculated Rebate Amount';
                    ToolTip = 'Specifies the value of the Calculated Rebate Amount field.';
                }
                field("Customer Rebate Amount"; Rec."Customer Rebate Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Rebate Amount field.';
                }
                field("Vendor Commission"; Rec."Vendor Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of theVendor Commission Amount field.';
                }
                field("Employee Commission"; Rec."Employee Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Employee Commission field.';
                }
                field("Off-Invoice Rebate"; Rec."Off-Invoice Rebate")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field.', Comment = '%';
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
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Territory Code field.', Comment = '%';
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
            }
            part("AQD Customer Rebate Subpage"; "AQD Customer Rebate Subpage")
            {
                Caption = 'Documents';
                ApplicationArea = All;
                SubPageLink = "Rebate No." = field("No.");
                UpdatePropagation = Both;
            }
            part("AQD Customer Rebate Details"; "AQD Customer Rebate Details")
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
                var
                    CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
                    CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
                begin
                    CustomerRebateSetup.GET;
                    CustomerRebatePost.PostCustomerRebate(Rec, true);

                    CurrPage.Update(false);
                end;
            }
            action(Comments)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = Comment;
                RunObject = page "AQD Customer Rebate Comments";
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
        CustomerRebateUserSetup.Get(UserId);
        PostEnabled := false;
        ApproveEnabled := false;
        if CustomerRebateUserSetup."AQD Cust Rebate Rebate Role" in
           [CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Admin]
        then
            PostEnabled := true;

        if CustomerRebateUserSetup."AQD Cust Rebate Rebate Role" in
           [CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Salesperson,
            CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Admin]
        then
            ApproveEnabled := true;
        Rec.SetRange(Preview, false);
    end;

    trigger OnAfterGetRecord()
    begin
        CustomerRebateUserSetup.Get(UserId);

        PostEnabled := false;
        ApproveEnabled := false;

        if CustomerRebateUserSetup."AQD Cust Rebate Rebate Role" in
           [CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::"Sales Manager",
            CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Admin]
         then
            PostEnabled := true;

        if CustomerRebateUserSetup."AQD Cust Rebate Rebate Role" in
          [CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Salesperson,
           CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::"Sales Manager",
           CustomerRebateUserSetup."AQD Cust Rebate Rebate Role"::Admin]
        then
            ApproveEnabled := true;
    end;

    var
        PostEnabled: Boolean;
        ApproveEnabled: Boolean;
        CustomerRebateUserSetup: Record "User Setup";
}