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
                // group("Sell-To")
                // {
                //     field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Customer No.';
                //         ToolTip = 'Specifies the value of the Sell-To Customer No. field.', Comment = '%';
                //     }
                //     field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Name';
                //         ToolTip = 'Specifies the value of the Sell-To Customer Name field.', Comment = '%';
                //     }
                //     field("Sell-To Customer Name 2"; Rec."Sell-To Customer Name 2")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Name 2';
                //         ToolTip = 'Specifies the value of the Sell-To Customer Name 2 field.', Comment = '%';
                //         Importance = Additional;
                //     }
                //     field("Sell-To Address"; Rec."Sell-To Address")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Address';
                //         ToolTip = 'Specifies the value of the Sell-To Address field.', Comment = '%';
                //     }
                //     field("Sell-To Address 2"; Rec."Sell-To Address 2")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Address 2';
                //         ToolTip = 'Specifies the value of the Sell-To Address 2 field.', Comment = '%';
                //         Importance = Additional;
                //     }
                //     field("Sell-To Contact"; Rec."Sell-To Contact")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Contact';
                //         ToolTip = 'Specifies the value of the Sell-To Contact field.', Comment = '%';
                //     }
                //     field("Sell-To Post Code"; Rec."Sell-To Post Code")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Post Code';
                //         ToolTip = 'Specifies the value of the Sell-To ZIP Code field.', Comment = '%';
                //     }
                //     field("Sell-To City"; Rec."Sell-To City")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'City';
                //         ToolTip = 'Specifies the value of the Sell-To City field.', Comment = '%';
                //     }
                //     field("Sell-To Country/Region Code"; Rec."Sell-To Country/Region Code")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Country/Region Code';
                //         ToolTip = 'Specifies the value of the Sell-To Country/Region Code field.', Comment = '%';
                //     }
                //     field("Sell-To County"; Rec."Sell-To County")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'State';
                //         ToolTip = 'Specifies the value of the Sell-To State field.', Comment = '%';
                //     }
                // }
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
                // group("Bill-To")
                // {
                //     field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Customer No.';
                //         ToolTip = 'Specifies the value of the Bill-To Customer No. field.', Comment = '%';
                //     }
                //     field("Bill-To Name"; Rec."Bill-To Name")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Name';
                //         ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                //     }
                //     field("Bill-To Name 2"; Rec."Bill-To Name 2")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Name 2';
                //         ToolTip = 'Specifies the value of the Name 2 field.', Comment = '%';
                //         Importance = Additional;
                //     }
                //     field("Bill-To Address"; Rec."Bill-To Address")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Address';
                //         ToolTip = 'Specifies the value of the Address field.', Comment = '%';
                //     }
                //     field("Bill-To Address 2"; Rec."Bill-To Address 2")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Address 2';
                //         ToolTip = 'Specifies the value of the Address 2 field.', Comment = '%';
                //         Importance = Additional;
                //     }
                //     field("Bill-To Contact"; Rec."Bill-To Contact")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Contact';
                //         ToolTip = 'Specifies the value of the Contact field.', Comment = '%';
                //     }
                //     field("Bill-To Post Code"; Rec."Bill-To Post Code")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Post Code';
                //         ToolTip = 'Specifies the value of the ZIP Code field.', Comment = '%';
                //     }
                //     field("Bill-To City"; Rec."Bill-To City")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'City';
                //         ToolTip = 'Specifies the value of the City field.', Comment = '%';
                //     }
                //     field("Bill-To Country/Region Code"; Rec."Bill-To Country/Region Code")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'Country/Region Code';
                //         ToolTip = 'Specifies the value of the Country/Region Code field.', Comment = '%';
                //     }
                //     field("Bill-To County"; Rec."Bill-To County")
                //     {
                //         ApplicationArea = All;
                //         Caption = 'State';
                //         ToolTip = 'Specifies the value of the Bill-To State field.', Comment = '%';
                //     }
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
            action("Customer Rebate Details")
            {
                ApplicationArea = All;
                Caption = 'Customer Rebate Details';
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
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Rebates';
                actionref(Comments_Promoted; Comments)
                {
                }
                actionref(Customer_Rebate_Details_Promoted; "Customer Rebate Details")
                {
                }
            }
        }
    }
}