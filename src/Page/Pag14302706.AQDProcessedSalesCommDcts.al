page 14302706 "AQD Processed Sales Comm Dcts"
{
    ApplicationArea = All;
    Caption = 'Processed Sales Commission Documents';
    CardPageId = "AQD Processed Sales Comm Dct";
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = "AQD Sales Comm. Doc. Header";
    SourceTableView = sorting("No.") order(descending) where(Processed = const(true));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Sell-To Customer No."; Rec."Sell-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-To Customer Name"; Rec."Sell-To Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Bill-To Customer No."; Rec."Bill-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Commission Type"; Rec."Commission Type")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec."Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                // field(Imported; Rec.Imported)
                // {
                //     ApplicationArea = All;
                // }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
