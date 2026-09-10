page 14302707 "AQD Processed Sales Comm Dct"
{
    ApplicationArea = All;
    Caption = 'Processed Sales Commission Document';
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    SourceTable = "AQD Sales Comm. Doc. Header";
    SourceTableView = where(Processed = const(true));
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Commission Type"; Rec."Commission Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                group("Sell-to")
                {
                    field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                    {
                        Caption = 'Customer No.';
                        ApplicationArea = All;
                    }
                    field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                    {
                        Caption = 'Customer Name';
                        ApplicationArea = All;
                    }
                }
                group("Bill-to")
                {
                    field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                    {
                        Caption = 'Customer No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Bill-To Customer Name"; Rec."Bill-To Customer Name")
                    {
                        Caption = 'Customer Name';
                        ApplicationArea = All;
                    }
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Rebate Order Date"; Rec."Rebate Order Date")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate No"; Rec."Rebate No")
                {
                    ApplicationArea = All;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                // field(Imported; Rec.Imported)
                // {
                //     ApplicationArea = All;
                // }
                // field("Error Message"; Rec."Error Message")
                // {
                //     ApplicationArea = All;
                // }
                group(Dimensions)
                {
                    field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                    {
                        ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.', Comment = '%';
                    }
                    field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                    {
                        ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.', Comment = '%';
                    }
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field("Do Not Collect"; Rec."Do Not Collect")
                {
                    ToolTip = 'Specifies the value of the Do Not Collect field.', Comment = '%';
                }
            }
            part(Lines; "AQD Sales Comm. Doc. Lines")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}
