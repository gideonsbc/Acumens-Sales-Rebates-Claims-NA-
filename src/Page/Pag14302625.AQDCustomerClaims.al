page 14302625 "AQD Customer Claims"
{
    ApplicationArea = All;
    Caption = 'Claims';
    Editable = false;
    PageType = ListPart;
    SourceTable = "AQD Customer Claim Header";

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
                    begin
                        CASE Rec."Claim Type" OF
                            Rec."Claim Type"::"Full Price":
                                BEGIN
                                    IF Rec.Status <> Rec.Status::"Credit Posted" THEN
                                        Page.RunModal(PAGE::"AQD FullPrice Customer Claim", Rec)
                                    ELSE
                                        Page.RunModal(PAGE::"AQD CompltdFullPrice CustClaim", Rec);

                                END;
                            Rec."Claim Type"::"Price Match":
                                BEGIN
                                    IF Rec.Status <> Rec.Status::"Credit Posted" THEN
                                        Page.RunModal(PAGE::"AQD Price Match Customer Claim", Rec)
                                    ELSE
                                        Page.RunModal(PAGE::"AQD CompltdPriceMatchCustClaim", Rec);
                                END;
                        END;
                    end;
                }
                field("Claim Type"; Rec."Claim Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Claim Type field.', Comment = '%';
                    Visible = false;
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Claim Submitted"; Rec."Claim Submitted")
                {
                    ApplicationArea = All;
                }
                field("Claim Submitted By"; Rec."Claim Submitted By")
                {
                    ApplicationArea = All;
                }
                field("Claim Submitted DateTime"; Rec."Claim Submitted DateTime")
                {
                    ApplicationArea = All;
                }
                field("Vendor Cr. Memo No."; Rec."Vendor Cr. Memo No.")
                {
                    ApplicationArea = All;
                }
                field("Amount Approved"; Rec."Amount Approved")
                {
                    ApplicationArea = All;
                }
                field("Delivery Commission"; Rec."Delivery Commission")
                {
                    ApplicationArea = All;
                }
                field("Purchase Discount"; Rec."Purchase Discount")
                {
                    ApplicationArea = All;
                }
                field("Claim Approved"; Rec."Claim Approved")
                {
                    ApplicationArea = All;
                }
                field("Claim Approved By"; Rec."Claim Approved By")
                {
                    ApplicationArea = All;
                }
                field("Claim Approved DateTime"; Rec."Claim Approved DateTime")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}