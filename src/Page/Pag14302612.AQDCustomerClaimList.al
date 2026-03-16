page 14302612 "AQD Customer Claim List"
{
    ApplicationArea = All;
    Caption = 'Customer Claims';
    //CardPageId = "AQD Customer Claim";
    Editable = false;
    PageType = List;
    SourceTable = "AQD Customer Claim Header";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';

                    trigger OnDrillDown()
                    BEGIN
                        CASE Rec."Claim Type" OF
                            Rec."Claim Type"::"Full Price":
                                BEGIN
                                    Page.RunModal(PAGE::"AQD FullPrice Customer Claim", Rec)
                                END;
                            Rec."Claim Type"::"Price Match":
                                BEGIN
                                    IF Rec.Status <> Rec.Status::"Credit Posted" THEN
                                        Page.RunModal(PAGE::"AQD Price Match Customer Claim", Rec)
                                END;
                        END;
                    END;
                }
                field("Claim Type"; Rec."Claim Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim Type field.', Comment = '%';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
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
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
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
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.', Comment = '%';
                }
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

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetFilter(Status, '<%1', Rec.Status::"Credit Posted");
        Rec.FilterGroup(0);
    end;
}