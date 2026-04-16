page 14302636 "AQD CustClmPostedSalesInvSubpg"
{
    AutoSplitKey = true;
    Caption = 'Posted Sales Invoice Lines';
    InsertAllowed = FALSE;
    DeleteAllowed = FALSE;
    Editable = TRUE;
    Permissions = tabledata "Sales Invoice Line" = RM;
    LinksAllowed = FALSE;
    PageType = Worksheet;
    SourceTable = "Sales Invoice Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the line type.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                Field("AQD CustClaim Mfg Product Code"; Rec."AQD CustClaim Mfg Product Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the Mfg Product Code on the line.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies a description of the product that was sold.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    Importance = Additional;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = FALSE;
                }
                field("AQD CustClaim Service Code"; Rec."AQD CustClaim Service Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = ShowServiceCodeMandatory;
                    ToolTip = 'Specifies the Claim Service Code on the line.';
                }
                field("AQD CustClaim Program Code"; Rec."AQD CustClaim Program Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = ShowProgramCodeMandatory;
                    ToolTip = 'Specifies the Claim Program Code on the line.';
                }
                field("AQD CustClaim Vendor No."; Rec."AQD CustClaim Vendor No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = TRUE;
                    ToolTip = 'Specifies the Claim Vendor No. on the line.';
                }
                field("AQD CustClaim Vendor Name"; Rec."AQD CustClaim Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    Width = 30;
                }
                field("Claim Created"; Rec."AQD Claim Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Claim Created on the line.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the inventory location from which the items sold should be picked and where the inventory decrease is registered.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = FALSE;
                    ToolTip = 'Specifies the number of units of the item specified on the line.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the cost, in LCY, of one unit of the item or resource on the line.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = FALSE;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = FALSE;
                    ToolTip = 'Specifies the sum of the amounts in the Amount Including VAT fields on the associated sales lines.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = FALSE;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }


            }
            group(Control28)
            {
                ShowCaption = false;
                group(Control23)
                {
                    ShowCaption = false;
                    field("Invoice Discount Amount"; TotalSalesInvoiceHeader."Invoice Discount Amount")
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = TotalSalesInvoiceHeader."Currency Code";
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetInvoiceDiscAmountWithVATCaption(TotalSalesInvoiceHeader."Prices Including VAT");
                        Caption = 'Invoice Discount Amount';
                        Editable = false;
                        ToolTip = 'Specifies a discount amount that is deducted from the value of the Total Incl. VAT field, based on sales lines where the Allow Invoice Disc. field is selected.';
                    }
                }
                group(Control9)
                {
                    ShowCaption = false;
                    field("Total Amount Excl. VAT"; TotalSalesInvoiceHeader.Amount)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = TotalSalesInvoiceHeader."Currency Code";
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalExclVATCaption(TotalSalesInvoiceHeader."Currency Code");
                        Caption = 'Total Amount Excl. VAT';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                    field("Total VAT Amount"; VATAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = TotalSalesInvoiceHeader."Currency Code";
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalVATCaption(TotalSalesInvoiceHeader."Currency Code");
                        Caption = 'Total VAT';
                        Editable = false;
                        ToolTip = 'Specifies the sum of VAT amounts on all lines in the document.';
                    }
                    field("Total Amount Incl. VAT"; TotalSalesInvoiceHeader."Amount Including VAT")
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = TotalSalesInvoiceHeader."Currency Code";
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalInclVATCaption(TotalSalesInvoiceHeader."Currency Code");
                        Caption = 'Total Amount Incl. VAT';
                        Editable = false;
                        Style = Strong;
                        StyleExpr = true;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DocumentTotals.CalculatePostedSalesInvoiceTotals(TotalSalesInvoiceHeader, VATAmount, Rec);
    end;

    trigger OnOpenPage()
    var
    begin
        SetDimensionsVisibility();
        ClaimSetup.GET;
        ShowServiceCodeMandatory := ClaimSetup."Price Match ClaimServCode Mand";
        ShowProgramCodeMandatory := ClaimSetup."Price Match ClaimProgCode Mand";

        Rec.FilterGroup(2);
        Rec.SETFILTER(Type, '%1|%2|%3',
            Rec.Type::Item,
            Rec.Type::Resource,
            Rec.Type::"G/L Account");
        Rec.SETFILTER("No.", '<>%1', '');
        Rec.SETFILTER(Quantity, '<>%1', 0);
        Rec.FilterGroup(0);
    end;

    var
        ClaimSetup: Record "AQD Acumens CustRbtClaim Setup";
        DocumentTotals: Codeunit "Document Totals";
        ShowServiceCodeMandatory: Boolean;
        ShowProgramCodeMandatory: Boolean;
        IsFoundation: Boolean;

    protected var
        TotalSalesInvoiceHeader: Record "Sales Invoice Header";
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        VATAmount: Decimal;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
        Clear(DimMgt);
    end;
}