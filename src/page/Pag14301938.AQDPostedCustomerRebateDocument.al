page 14301938 "AQD Posted Customer Rebate Doc"
{
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Document';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "AQD Posted Cust Rebate Header";

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
                    Caption = 'Rebate-To';
                    field("Rebate-To Customer No."; Rec."Rebate-To Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the "Rebate-To Customer No." field.', Comment = '%';
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
                    Caption = 'Customer Rebate Amount';
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
                // field(Approved; Rec.Approved)
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("Approved By"; Rec."Approved By")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("Approved Date Time"; Rec."Approved Date Time")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
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
                field("Rebate Status"; Rec."Customer Rebate Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part("AQD Posted Cust Reb Subpage"; "AQD Posted Cust Reb Subpage")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                Editable = false;
                SubPageLink = "Rebate No." = field("No.");
                UpdatePropagation = Both;
            }
            part("AQD Posted Cust Rebate Details"; "AQD Posted Cust Rebate Details")
            {
                ApplicationArea = All;
                Caption = 'Document Lines';
                Editable = false;
                SubPageLink = "Rebate No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Comments)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = Comment;
                RunObject = page "AQD Posted Cust Reb Comment";
                RunPageLink = "Rebate No." = field("No.");
            }
            // action("Customer Rebate Details")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Customer Rebate Details';
            //     Image = Report;

            //     trigger OnAction()
            //     var
            //         //VendorRebateDetails: Report "AQD Vendor Rebate Details";
            //         PostedCustRbtHeader: Record "AQD Posted Cust Rebate Header";
            //     begin
            //         PostedCustRbtHeader.Reset();
            //         //PostedCustRbtHeader.SetRange("No.", Rec."No.");
            //         //Clear(VendorRebateDetails);
            //         //VendorRebateDetails.SetTableView(PostedVRHeader);
            //         //VendorRebateDetails.Run();
            //     end;
            // }
        }
        area(Navigation)
        {
            // action("Create Sales Document")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Create Sales Document';
            //     Image = CreateDocument;

            //     trigger OnAction()
            //     var
            //         CustomerRebatePost: Codeunit "AQD Customer Rebate Post";
            //     begin
            //         clear(CustomerRebatePost);
            //         CustomerRebatePost.CreateSalesFromPostedRebateDocument(Rec, TRUE);
            //         CurrPage.UPDATE(false);
            //     end;
            // }
            // action("Sales Invoices")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Sales Invoices';
            //     Image = SalesInvoice;
            //     RunObject = Page "Sales Invoice List";
            //     RunPageLink = "AQD Customer Rebate No" = field("No.");
            //     ToolTip = 'Open the list of Sales Invoices.';
            // }
            // action("Sales Credit Memos")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Sales Credit Memos';
            //     Image = PurchaseCreditMemo;
            //     RunObject = Page "Sales Credit Memos";
            //     RunPageLink = "AQD Customer Rebate No" = field("No.");
            //     ToolTip = 'Open the list of Sales Credit Memos.';
            // }
            action("Posted Sales Invoices")
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Invoices';
                Image = PostDocument;
                RunObject = Page "Posted Sales Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Sales Invoices.';
            }
            action("Posted Sales Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Posted Sales Credit Memos';
                Image = PostedCreditMemo;
                RunObject = Page "Posted Sales Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Sales Credit Memos.';
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
                // actionref(Customer_Rebate_Details_Promoted; "Customer Rebate Details")
                // {
                // }
                // actionref(CreateSalesDocument_Promoted; "Create Sales Document")
                // {
                // }
                // actionref(SalesInvoices_Promoted; "Sales Invoices")
                // {
                // }
                // actionref(SalesCreditMemos_Promoted; "Sales Credit Memos")
                // {
                // }
                actionref(PostedSalesInvoices_Promoted; "Posted Sales Invoices")
                {
                }
                actionref(PostedSalesCreditMemos_Promoted; "Posted Sales Credit Memos")
                {
                }
            }
        }
    }
}