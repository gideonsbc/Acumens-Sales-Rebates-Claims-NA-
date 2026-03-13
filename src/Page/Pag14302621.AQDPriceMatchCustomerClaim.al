page 14302621 "AQD Price Match Customer Claim"
{
    ApplicationArea = All;
    Caption = 'Price Match Customer Claim';
    InsertAllowed = FALSE;
    PageType = Document;
    SourceTable = "AQD Customer Claim Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Claim Type"; Rec."Claim Type")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Claim Type field.', Comment = '%';
                    Visible = FALSE;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        CustClaimFunc: Codeunit "AQD Cust Claim Event And Func";
                    begin
                        clear(CustClaimFunc);
                        CustClaimFunc.ShowSalesOrder(Rec);
                        CurrPage.Update(FALSE);
                    end;
                }
                field("Posted Invoice No."; Rec."Posted Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Posted Invoice No. field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        CustClaimFunc: Codeunit "AQD Cust Claim Event And Func";
                    begin
                        clear(CustClaimFunc);
                        CustClaimFunc.ShowPostedSalesInvoice(Rec);
                        CurrPage.Update(FALSE);
                    end;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Salesperson Code field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Responsibility Center field.', Comment = '%';
                    Visible = FALSE;
                }
                field("Purchase Credit Memo No."; Rec."Purchase Credit Memo No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Purchase Credit Memo No. field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        CustClaimFunc: Codeunit "AQD Cust Claim Event And Func";
                    begin
                        clear(CustClaimFunc);
                        CustClaimFunc.ShowPurchaseCreditMemo(Rec);
                        CurrPage.Update(FALSE);
                    end;
                }
                field("Supplementary Invoice No."; Rec."Supplementary Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Supplementary Invoice No. field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        CustClaimFunc: Codeunit "AQD Cust Claim Event And Func";
                    begin
                        clear(CustClaimFunc);
                        CustClaimFunc.ShowSupplementaryInvoice(Rec);
                        CurrPage.Update(FALSE);
                    end;
                }
                field("Posted Supplementary Invoice No."; Rec."Posted Supplementary Inv No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Posted Supplementary Invoice No. field.', Comment = '%';
                    trigger OnDrillDown()
                    var
                        CustClaimFunc: Codeunit "AQD Cust Claim Event And Func";
                    begin
                        clear(CustClaimFunc);
                        CustClaimFunc.ShowPostedSupplementaryInvoice(Rec);
                        CurrPage.Update(FALSE);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                group(BillToAddress)
                {
                    Caption = 'Bill-To';
                    Editable = FALSE;
                    field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Customer No. field.', Comment = '%';
                    }
                    field("Bill-to Name"; Rec."Bill-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name field.', Comment = '%';
                    }
                    field("Bill-to Name 2"; Rec."Bill-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Name 2 field.', Comment = '%';
                        Visible = false;
                    }
                    field("Bill-to Address"; Rec."Bill-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address field.', Comment = '%';
                    }
                    field("Bill-to Address 2"; Rec."Bill-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Address 2 field.', Comment = '%';
                        Visible = false;
                    }
                    field("Bill-to City"; Rec."Bill-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to City field.', Comment = '%';
                    }
                    field("Bill-to Post Code"; Rec."Bill-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Post Code field.', Comment = '%';
                    }
                    field("Bill-to County"; Rec."Bill-to County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-To State field.', Comment = '%';
                    }
                    field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bill-to Country/Region Code field.', Comment = '%';
                    }
                }
                group(Vendor)
                {
                    Caption = 'Vendor';
                    Editable = FALSE;
                    field("Vendor No."; Rec."Vendor No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                    }
                    field("Vendor Name"; Rec."Vendor Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                    }
                    field("Vendor Name 2"; Rec."Vendor Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                        Visible = false;
                    }
                    field("Vendor Address"; Rec."Vendor Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                    }
                    field("Vendor Address 2"; Rec."Vendor Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                        Visible = false;
                    }
                    field("Vendor City"; Rec."Vendor City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City field.', Comment = '%';
                    }
                    field("Vendor Post Code"; Rec."Vendor Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                    }
                    field("Vendor County"; Rec."Vendor County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the State field.', Comment = '%';
                    }
                    field("Vendor Country/Region Code"; Rec."Vendor Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                    }
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.', Comment = '%';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.', Comment = '%';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Shipment Date field.', Comment = '%';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                FIELD("Claim Amount"; Rec."Claim Amount")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Claim Amount field.', Comment = '%';
                }
                FIELD("Approved Amount"; Rec."Line Approved Amount")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the value of the Approved Amount field.', Comment = '%';
                }
                group(ClaimSubmission)
                {
                    Caption = 'Submission';
                    field("Claim Submitted"; Rec."Claim Submitted")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Submitted field.', Comment = '%';
                    }
                    field("Claim Submitted By"; Rec."Claim Submitted By")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Submitted By field.', Comment = '%';
                    }
                    field("Claim Submitted DateTime"; Rec."Claim Submitted DateTime")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Submitted DateTime field.', Comment = '%';
                    }
                }
                group(ClaimRejected)
                {
                    Caption = 'Rejection';
                    field("Claim Rejected"; Rec."Claim Rejected")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Rejected field.', Comment = '%';
                    }
                    field("Claim Rejected By"; Rec."Claim Rejected By")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Rejected By field.', Comment = '%';
                    }
                    field("Claim Rejected DateTime"; Rec."Claim Rejected DateTime")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Rejected DateTime field.', Comment = '%';
                    }
                    field("Claim Rejected Comments"; Rec."Claim Rejected Comments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Rejected Comments field.', Comment = '%';
                    }
                }
                Group(ClaimApproval)
                {
                    Caption = 'Approval';
                    field("Vendor Cr. Memo No."; Rec."Vendor Cr. Memo No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Vendor Cr. Memo No. field.', Comment = '%';
                        ShowMandatory = TRUE;
                    }
                    field("Vendor Cr. Memo Date"; Rec."Vendor Cr. Memo Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Vendor Cr. Memo Date field.', Comment = '%';
                        ShowMandatory = TRUE;
                    }
                    field("Amount Approved"; Rec."Amount Approved")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount Approved field.', Comment = '%';
                        ShowMandatory = TRUE;
                    }
                    field("Delivery Commission"; Rec."Delivery Commission")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Delivery Commission field.', Comment = '%';
                    }
                    field("Purchase Discount"; Rec."Purchase Discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purchase Discount field.', Comment = '%';
                    }
                    field("Claim Approved"; Rec."Claim Approved")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Claim Approved field.', Comment = '%';
                    }
                    field("Claim Approved By"; Rec."Claim Approved By")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Approved By field.', Comment = '%';
                    }
                    field("Claim Approved DateTime"; Rec."Claim Approved DateTime")
                    {
                        ApplicationArea = All;
                        Editable = FALSE;
                        ToolTip = 'Specifies the value of the Claim Approved DateTime field.', Comment = '%';
                    }
                }
            }
            group(SellingAndShipping)
            {
                Caption = 'Selling and Shipping';
                Editable = FALSE;

                Group(SellToAddress)
                {
                    Caption = 'Sell-To';
                    field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Customer No. field.', Comment = '%';
                    }
                    field("Sell-to Name"; Rec."Sell-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Name field.', Comment = '%';
                    }
                    field("Sell-to Name 2"; Rec."Sell-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Name 2 field.', Comment = '%';
                        Visible = FALSE;
                    }
                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address field.', Comment = '%';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Address 2 field.', Comment = '%';
                        Visible = FALSE;
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to City field.', Comment = '%';
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to ZIP Code field.', Comment = '%';
                    }
                    field("Sell-to County"; Rec."Sell-to County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to State field.', Comment = '%';
                    }
                    field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sell-to Country/Region Code field.', Comment = '%';
                    }
                }
                GROUP(ShipToAddress)
                {
                    Caption = 'Ship-To';
                    field("Ship-to Code."; Rec."Ship-to Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Code field.', Comment = '%';
                    }
                    field("Ship-to Name"; Rec."Ship-to Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name field.', Comment = '%';
                    }
                    field("Ship-to Name 2"; Rec."Ship-to Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Name 2 field.', Comment = '%';
                        Visible = FALSE;
                    }
                    field("Ship-to Address"; Rec."Ship-to Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address field.', Comment = '%';
                    }
                    field("Ship-to Address 2"; Rec."Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Address 2 field.', Comment = '%';
                        Visible = FALSE;
                    }
                    field("Ship-to City"; Rec."Ship-to City")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to City field.', Comment = '%';
                    }
                    field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to Country/Region Code field.', Comment = '%';
                    }
                    field("Ship-to County"; Rec."Ship-to County")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to State field.', Comment = '%';
                    }
                    field("Ship-to Post Code"; Rec."Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ship-to ZIP Code field.', Comment = '%';
                    }
                }
            }
            part(ClaimLinesPart; "AQD Cust PriceMatchClaim Subpg")
            {
                ApplicationArea = All;
                Caption = 'Claim Lines';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PostCrMemo)
            {
                ApplicationArea = All;
                Caption = 'Post Credit Memo';
                Image = CreditMemo;
                ToolTip = 'Finalize the document by posting the amounts and quantities to the related accounts in your company books.';
                trigger OnAction()
                var
                    ClaimFunction: Codeunit "AQD Cust Claim Event And Func";
                begin
                    ClaimFunction.PostPurchaseCreditMemoFromClaim(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PostCrMemo_Promoted; PostCrMemo)
            {
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Claim Type", Rec."Claim Type"::"Price Match");
        Rec.SetFilter(Status, '<%1', Rec.Status::"Credit Posted");
        Rec.FilterGroup(0);
    end;
}