page 14301938 "AQD Posted Customer Rebate"
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
                group("Sell-To")
                {
                    field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Customer No. field.', Comment = '%';
                    }
                    field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Customer Name field.', Comment = '%';
                    }
                    field("Sell-To Customer Name 2"; Rec."Sell-To Customer Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Customer Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Sell-To Address"; Rec."Sell-To Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Address field.', Comment = '%';
                    }
                    field("Sell-To Address 2"; Rec."Sell-To Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Sell-To Contact"; Rec."Sell-To Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Contact field.', Comment = '%';
                    }
                    field("Sell-To Post Code"; Rec."Sell-To Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To ZIP Code field.', Comment = '%';
                    }
                    field("Sell-To City"; Rec."Sell-To City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To City field.', Comment = '%';
                    }
                    field("Sell-To Country/Region Code"; Rec."Sell-To Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To Country/Region Code field.', Comment = '%';
                    }
                    field("Sell-To County"; Rec."Sell-To County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-To State field.', Comment = '%';
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
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = All;
                    Editable = false;
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
                group("Bill-To")
                {
                    field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                    }
                    field("Bill-To Name"; Rec."Bill-To Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                    }
                    field("Bill-To Name 2"; Rec."Bill-To Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Bill-To Address"; Rec."Bill-To Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                    }
                    field("Bill-To Address 2"; Rec."Bill-To Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Bill-To Contact"; Rec."Bill-To Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                    }
                    field("Bill-To Post Code"; Rec."Bill-To Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                    }
                    field("Bill-To City"; Rec."Bill-To City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City field.', Comment = '%';
                    }
                    field("Bill-To Country/Region Code"; Rec."Bill-To Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                    }
                    field("Bill-To County"; Rec."Bill-To County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-To State field.', Comment = '%';
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
                field("Rebate Status"; Rec."Rebate Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(PayToVendor)
            {
                Caption = 'Pay-To Vendor';
                field("Pay-To Vendor No."; Rec."Pay-To Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies the value of the Pay-To Vendor No. field.', Comment = '%';
                }
                field("Pay-To Name"; Rec."Pay-To Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Pay-To Name 2"; Rec."Pay-To Name 2")
                {
                    ApplicationArea = All;
                    Caption = 'Name 2';
                    ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                    Importance = Additional;
                }
                field("Pay-To Address"; Rec."Pay-To Address")
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                }
                field("Pay-To Address 2"; Rec."Pay-To Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';
                    ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                    Importance = Additional;
                }
                field("Pay-To Contact"; Rec."Pay-To Contact")
                {
                    ApplicationArea = All;
                    Caption = 'Contact';
                    ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                }
                field("Pay-To Post Code"; Rec."Pay-To Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Zip Code';
                    ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                }
                field("Pay-To City"; Rec."Pay-To City")
                {
                    ApplicationArea = All;
                    Caption = 'City';
                    ToolTip = 'Specifies the value of the City field.', Comment = '%';
                }

                field("Pay-To Country/Region Code"; Rec."Pay-To Country/Region Code")
                {
                    ApplicationArea = All;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                }
                field("Pay-To County"; Rec."Pay-To County")
                {
                    ApplicationArea = All;
                    Caption = 'County';
                    ToolTip = 'Specifies the value of the Bill-To State field.', Comment = '%';
                }
            }
            part("AQD Customer Rebate Subpage"; "AQD Posted Cust Reb Subpage")
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
            // Not Required For Now. Not Delete
            // action("Create Purchase Journal")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Create Purchase Journal';
            //     Image = CreateDocument;

            //     trigger OnAction()
            //     var
            //         VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
            //     begin
            //         clear(VendorRebatePost);
            //         VendorRebatePost.CreateVendorRebatePurchJournal(Rec);
            //         CurrPage.UPDATE(false);
            //     end;
            // }
            action("Create Purchase Document")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Document';
                Image = CreateDocument;

                trigger OnAction()
                var
                    VendorRebatePost: Codeunit "AQD Customer Rebate Post";
                begin
                    clear(VendorRebatePost);
                    //VendorRebatePost.CreatePurchaseDocument(Rec, TRUE);
                    CurrPage.UPDATE(false);
                end;
            }
            action("Vendor Rebate Details")
            {
                ApplicationArea = All;
                Caption = 'Vendor Rebate Details';
                Image = Report;

                trigger OnAction()
                var
                    //VendorRebateDetails: Report "AQD Vendor Rebate Details";
                    PostedCustRbtHeader: Record "AQD Posted Cust Rebate Header";
                begin
                    PostedCustRbtHeader.Reset();
                    //PostedCustRbtHeader.SetRange("No.", Rec."No.");
                    //Clear(VendorRebateDetails);
                    //VendorRebateDetails.SetTableView(PostedVRHeader);
                    //VendorRebateDetails.Run();
                end;
            }
        }
        area(Navigation)
        {
            // action("AQD Rebate Purchase Journal")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Rebate Purchase Journal';
            //     Image = OpenJournal;
            //     RunObject = Page "AQD Rebate Purch. Journal";
            //     ToolTip = 'Open the Rebate Purchase Journal.';
            // }
            action("Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Purchase Invoices';
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Purchase Invoices.';
            }
            action("Purchase Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Purchase Credit Memos';
                Image = PurchaseCreditMemo;
                RunObject = Page "Purchase Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Purchase Credit Memos.';
            }
            action("Posted Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Posted Purchase Invoices';
                Image = PostDocument;
                RunObject = Page "Posted Purchase Invoices";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Purchase Invoices.';
            }
            action("Posted Purchase Credit Memos")
            {
                ApplicationArea = All;
                Caption = 'Posted Purchase Credit Memos';
                Image = PostedCreditMemo;
                RunObject = Page "Posted Purchase Credit Memos";
                RunPageLink = "AQD Customer Rebate No" = field("No.");
                ToolTip = 'Open the list of Posted Purchase Credit Memos.';
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
                // actionref(CreatePurchaseJournal_Promoted; "Create Purchase Journal")
                // {
                // }
                actionref(CreatePurchaseDocument_Promoted; "Create Purchase Document")
                {
                }
                actionref(Vendor_Rebate_Details_Promoted; "Vendor Rebate Details")
                {
                }
                // actionref(RebatePurchaseJournal_Promoted; "AQD Rebate Purchase Journal")
                // {
                // }
                actionref(PurchaseInvoices_Promoted; "Purchase Invoices")
                {
                }
                actionref(PurchaseCreditMemos_Promoted; "Purchase Credit Memos")
                {
                }
                actionref(PostedPurchaseInvoices_Promoted; "Posted Purchase Invoices")
                {
                }
                actionref(PostedPurchaseCreditMemos_Promoted; "Posted Purchase Credit Memos")
                {
                }
            }
        }
    }
}