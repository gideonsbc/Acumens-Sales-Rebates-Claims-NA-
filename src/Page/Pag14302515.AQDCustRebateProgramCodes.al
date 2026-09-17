page 14302515 "AQD Cust Rebate Program Codes"
{
    ApplicationArea = All;
    Caption = 'Sales Rebate & Commission Programs';
    PageType = List;
    SourceTable = "AQD Cust Rebate Program Code";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Rebate Program Code to attach to the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of what the code stands for.';
                }
                field("Customer Default Rebate Type"; Rec."Customer Default Rebate Type")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Type';
                }
                field("Cust Default Rebate %"; Rec."Customer Default Rebate %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Default Rebate %';
                    Editable = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::Percentage;
                    Enabled = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::Percentage;
                }
                field("Cust Def Rebate Per Unit"; Rec."Customer Def Rebate Per Unit")
                {
                    ApplicationArea = All;
                    Caption = 'Default Rebate Per Unit';
                    Editable = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::"Per Quantity";
                    Enabled = Rec."Customer Default Rebate Type" = Rec."Customer Default Rebate Type"::"Per Quantity";
                }
                field("Rebate Expense Type"; Rec."Rebate Expense Type")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Expense Type';
                }
                field("Rebate Expense AC"; Rec."Rebate Expense AC")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Expense A/C';
                    Editable = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    Enabled = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                    ShowMandatory = Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
                }
                field("Payee Type"; Rec."Payee Type")
                {
                    ApplicationArea = All;
                }
                field("Payee No."; Rec."Payee No.")
                {
                    ApplicationArea = All;
                }
                field("AQD Pay-to Vendor No."; Rec."AQD Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Pay-to Vendor No.';
                }
                field("AQD Default Trade Agreement"; Rec."AQD Default Trade Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Trade Agreement field.';
                }
                field("SO Rebate Program Filter"; Rec."SO Rebate Program Filter")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RebateProgramCodes: Page "AQD Cust Rebate Program Codes";
                    begin
                        RebateProgramCodes.LOOKUPMODE := TRUE;
                        IF RebateProgramCodes.RUNMODAL = ACTION::LookupOK THEN
                            Text := RebateProgramCodes.GetSelectionFilter
                        ELSE
                            EXIT(false);
                        EXIT(true);
                    end;
                }
                field("SO Marketplace Code Filter"; Rec."SO Marketplace Code Filter")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MArketplace: Page "AQD Marketplace";
                    begin
                        MArketplace.LOOKUPMODE := TRUE;
                        IF MArketplace.RUNMODAL = ACTION::LookupOK THEN
                            Text := MArketplace.GetSelectionFilter
                        ELSE
                            EXIT(false);
                        EXIT(true);
                    end;
                }
                field("SO Payment Term Filter"; Rec."SO Payment Term Filter")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentTerms: Page "Payment Terms";
                    begin
                        PaymentTerms.LOOKUPMODE := TRUE;
                        IF PaymentTerms.RUNMODAL = ACTION::LookupOK THEN
                            Text := PaymentTerms.GetSelectionFilter
                        ELSE
                            EXIT(false);
                        EXIT(true);
                    end;
                }
                field("Rebate Payment Method Code"; Rec."Rebate Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Posting Type"; Rec."Posting Type")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Type';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    trigger OnOpenPage()
    BEGIN
        IF NOT CustomerRebateSetup.GET THEN
            CustomerRebateSetup.Init();

        ControlEditable := Rec."Customer Rebate Posting Type" = Rec."Customer Rebate Posting Type"::Expense;
        ControlVisible := CustomerRebateSetup."Rebate Payable Ac" = CustomerRebateSetup."Rebate Payable Ac"::"Rebate Payable AC";
    END;

    procedure GetSelectionFilter(): Text
    var
        RebateProgramCodes: Record "AQD Cust Rebate Program Code";
        SelectionFilterManagement: Codeunit "AQD CR SelectionFilterMgt";
    begin
        CurrPage.SetSelectionFilter(RebateProgramCodes);
        exit(SelectionFilterManagement.GetSelectionFilterForRebateProgramCode(RebateProgramCodes));
    end;

    VAR
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
        ControlEditable: Boolean;
        ControlVisible: Boolean;
}