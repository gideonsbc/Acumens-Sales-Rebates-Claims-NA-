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
                group("Buy-from")
                {
                    field("Buy-from Vendor No."; Rec."Sell-To Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Vendor No. field.', Comment = '%';
                    }
                    field("Buy-from Vendor Name"; Rec."Sell-To Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Vendor Name field.', Comment = '%';
                    }
                    field("Buy-from Vendor Name 2"; Rec."Sell-To Customer Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Vendor Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Buy-from Address"; Rec."Sell-To Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Address field.', Comment = '%';
                    }
                    field("Buy-from Address 2"; Rec."Sell-To Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Buy-from Contact"; Rec."Sell-To Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Contact field.', Comment = '%';
                    }
                    field("Buy-from Post Code"; Rec."Sell-To Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from ZIP Code field.', Comment = '%';
                    }
                    field("Buy-from City"; Rec."Sell-To City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from City field.', Comment = '%';
                    }
                    field("Buy-from Country/Region Code"; Rec."Sell-To Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from Country/Region Code field.', Comment = '%';
                    }
                    field("Buy-from County"; Rec."Sell-To County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Buy-from State field.', Comment = '%';
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
                group("Pay-To")
                {
                    field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Pay-to Vendor No. field.', Comment = '%';
                    }
                    field("Pay-to Name"; Rec."Pay-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                    }
                    field("Pay-to Name 2"; Rec."Pay-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Pay-to Address"; Rec."Pay-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                    }
                    field("Pay-to Address 2"; Rec."Pay-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                        Importance = Additional;
                    }
                    field("Pay-to Contact"; Rec."Pay-to Contact")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                    }
                    field("Pay-to Post Code"; Rec."Pay-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                    }
                    field("Pay-to City"; Rec."Pay-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City field.', Comment = '%';
                    }
                    field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                    }
                    field("Pay-to County"; Rec."Pay-to County")
                    {
                        ApplicationArea = All;
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