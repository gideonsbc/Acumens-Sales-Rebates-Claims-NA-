page 14302703 "AQD Sales Comm. Doc. Lines"
{
    ApplicationArea = All;
    Caption = 'Sales Commission Document Lines';
    AutoSplitKey = true;
    PageType = ListPart;
    SourceTable = "AQD Sales Comm. Doc. Line";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
            }
            group(Totals)
            {
                ShowCaption = false;
                field("Sales Amount"; SalesAmount)
                {
                    Caption = 'Total Excl. Tax';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Amount Including VAT"; SalesAmountVAT)
                {
                    Caption = 'Total Incl. Tax';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals();
    end;

    local procedure CalculateTotals()
    var
        SalesCommLine: Record "AQD Sales Comm. Doc. Line";
    begin
        SalesAmount := 0;
        SalesAmountVAT := 0;

        if SalesCommHeader.Get(Rec."Document No.") then begin
            SalesCommLine.Reset();
            SalesCommLine.SetRange("Document No.", SalesCommHeader."No.");
            SalesCommLine.CalcSums(Amount, "Amount Including VAT");
            SalesAmount := SalesCommLine.Amount;
            SalesAmountVAT := SalesCommLine."Amount Including VAT";
        end;
    end;

    var
        SalesAmount: Decimal;
        SalesAmountVAT: Decimal;
        SalesCommHeader: Record "AQD Sales Comm. Doc. Header";
}
