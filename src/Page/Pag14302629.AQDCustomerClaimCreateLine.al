page 14302629 "AQD Cust Claim Create Line"
{
    ApplicationArea = All;
    Caption = 'Create New Line';
    PageType = StandardDialog;
    RefreshOnActivate = TRUE;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(TypeSelection; TypeSelection)
                {
                    Caption = 'Type';
                    ApplicationArea = All;
                    ShowMandatory = TRUE;
                }
                field(No; NoSelection)
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ShowMandatory = TRUE;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        Resource: Record Resource;
                        GLAccount: Record "G/L Account";
                        ItemList: Page "Item List";
                        ResourceList: Page "Resource List";
                        GLAccountList: Page "G/L Account List";
                    begin
                        CASE TypeSelection OF
                            TypeSelection::Resource:
                                BEGIN
                                    CLEAR(ResourceList);
                                    ResourceList.LookupMode(TRUE);
                                    IF ResourceList.RunModal() = Action::LookupOK THEN BEGIN
                                        ResourceList.GetRecord(Resource);
                                        NoSelection := Resource."No.";
                                        Description := Resource.Name;
                                        UoM := Resource."Base Unit of Measure";
                                        UnitCost := Resource."Unit Cost";
                                    END;
                                END;

                            TypeSelection::"G/L Account":
                                BEGIN
                                    CLEAR(GLAccountList);
                                    GLAccountList.LookupMode(TRUE);
                                    IF GLAccountList.RunModal() = Action::LookupOK THEN BEGIN
                                        GLAccountList.GetRecord(GLAccount);
                                        NoSelection := GLAccount."No.";
                                        Description := GLAccount.Name;
                                    END;
                                END;
                        END;
                    END;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(UoM; UoM)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Of Measure Code';
                    TableRelation = "Unit of Measure";
                    ShowMandatory = TRUE;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    ShowMandatory = TRUE;

                    trigger OnValidate()
                    BEGIN
                        Amount := ROUND(Quantity * UnitPrice, 0.01);
                        ApprovedAmount := Amount;
                        IF Quantity <> 0 THEN
                            ApprovedUnitPrice := Round(ApprovedAmount / Quantity, 0.00001);
                    END;
                }
                field(UnitPrice; UnitPrice)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Unit Price ($)';
                    DecimalPlaces = 0 : 5;
                    ShowMandatory = TRUE;

                    trigger OnValidate()
                    BEGIN
                        Amount := ROUND(Quantity * UnitPrice, 0.01);
                        ApprovedAmount := Amount;
                        IF Quantity <> 0 THEN
                            ApprovedUnitPrice := Round(ApprovedAmount / Quantity, 0.00001);
                    END;
                }
                field(UnitCost; UnitCost)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Unit Cost ($)';
                    DecimalPlaces = 0 : 5;
                    ShowMandatory = TRUE;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Amount';
                    ShowMandatory = TRUE;
                }
                field(ApprovedUnitPrice; ApprovedUnitPrice)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Approved Unit Price ($)';
                    DecimalPlaces = 0 : 5;
                    ShowMandatory = TRUE;

                    trigger OnValidate()
                    BEGIN
                        IF Quantity <> 0 THEN
                            ApprovedUnitPrice := Round(ApprovedAmount / Quantity, 0.00001);
                    END;
                }
                field(ApprovedAmount; ApprovedAmount)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Approved Amount';

                    trigger OnValidate()
                    BEGIN
                        ApprovedAmount := Amount;
                    END;
                }
                field(ClaimLineType; ClaimLineType)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Claim Line Type';
                }
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    BEGIN
        IF CloseAction IN [CloseAction::LookupOK, CloseAction::Yes, CloseAction::OK] THEN BEGIN
            IF NOT (TypeSelection IN [TypeSelection::Resource, TypeSelection::"G/L Account"])
            THEN
                ERROR(TypeSelectionBlankError);

            IF NoSelection = '' THEN
                Error(NoSelectionBlankError);

            IF UoM = '' THEN
                ERROR(UoMBlankError);

            IF Quantity = 0 THEN
                ERROR(QuantityBlankError);

            IF UnitPrice = 0 THEN
                ERROR(UnitPriceBlankError);

            CustomerClaimLine.RESET;
            CustomerClaimLine.SETRANGE("Document No.", ClaimHeader."No.");
            IF CustomerClaimLine.FindLast() THEN
                NextLineNo := CustomerClaimLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;

            CustomerClaimLine.Init();
            CustomerClaimLine."Document No." := ClaimHeader."No.";
            CustomerClaimLine."Line No." := NextLineNo;
            CustomerClaimLine.Type := TypeSelection;
            CustomerClaimLine."No." := NoSelection;
            CustomerClaimLine.Description := Description;
            CustomerClaimLine."Unit of Measure Code" := UoM;
            CustomerClaimLine."Location Code" := ClaimHeader."Location Code";
            CustomerClaimLine.Quantity := Quantity;
            CustomerClaimLine."Unit Price" := UnitPrice;
            CustomerClaimLine."Order Unit Price" := UnitPrice;
            CustomerClaimLine."Unit Cost (LCY)" := UnitCost;
            CustomerClaimLine."Line Amount" := Amount;
            CustomerClaimLine.Amount := Amount;
            CustomerClaimLine."Approved Unit Price" := ApprovedUnitPrice;
            CustomerClaimLine."Approved Amount" := ApprovedAmount;
            CustomerClaimLine."Amount Including VAT" := Amount;
            CustomerClaimLine."Order No." := '';
            CustomerClaimLine."Order Line No." := 0;
            CustomerClaimLine."Order Date" := ClaimHeader."Order Date";
            CustomerClaimLine."Responsibility Center" := ClaimHeader."Responsibility Center";
            CustomerClaimLine."Bill-to Customer No." := ClaimHeader."Bill-to Customer No.";
            CustomerClaimLine."Sell-to Customer No." := ClaimHeader."Sell-to Customer No.";
            CustomerClaimLine."Salesperson Code" := ClaimHeader."Salesperson Code";
            CustomerClaimLine."Ship-To Code" := ClaimHeader."Ship-to Code";
            CustomerClaimLine."Shortcut Dimension 1 Code" := ClaimHeader."Shortcut Dimension 1 Code";
            CustomerClaimLine."Shortcut Dimension 2 Code" := ClaimHeader."Shortcut Dimension 2 Code";
            CustomerClaimLine."Dimension Set ID" := ClaimHeader."Dimension Set ID";
            CustomerClaimLine."Manual Line" := true;
            CustomerClaimLine."Claim Line Type" := ClaimLineType;
            CustomerClaimLine.Insert();
        END;
    END;

    procedure SetClaimHeader(ClaimHeaderIn: Record "AQD Customer Claim Header")
    BEGIN
        ClaimHeader := ClaimHeaderIn;
    END;

    var
        ClaimHeader: Record "AQD Customer Claim Header";
        CustomerClaimLine: Record "AQD Customer Claim Line";
        TypeSelection: Enum "AQD Cust Claim Sales Line Type";
        ClaimLineType: Enum "AQD CustClmPrcMthClaimLineType";
        NoSelection: Code[20];
        UoM: Code[10];
        NextLineNo: Integer;
        Description: Text[100];
        Quantity: Decimal;
        UnitPrice: Decimal;
        UnitCost: Decimal;
        Amount: Decimal;
        ApprovedAmount: Decimal;
        ApprovedUnitPrice: Decimal;
        TypeSelectionBlankError: Label 'Type must not be blank.';
        NoSelectionBlankError: Label 'No. must not be blank.';
        UoMBlankError: Label 'Unit Of Measure Code must not be blank.';
        QuantityBlankError: Label 'Quantity must not be blank.';
        UnitPriceBlankError: Label 'Unit Price must not be blank.';
}