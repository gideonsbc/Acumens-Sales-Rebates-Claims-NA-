namespace AAPBBCOnPrem.AAPBBCOnPrem;
using Microsoft.Inventory.Item;
page 14302559 "AQD Select Items"
{

    ApplicationArea = All;
    Caption = 'Select Items';
    PageType = List;
    SourceTable = Item;
    layout
    {
        area(Content)
        {
            field(ItemSearchString; ItemSearchString)
            {
                ApplicationArea = All;
                Caption = 'Search Item';

                trigger OnValidate()
                begin
                    ApplyItemFilter(ItemSearchString);
                    CurrPage.Update(false);
                end;
            }
            repeater(General)
            {
                field(Select; Select)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Select then begin
                            if not TempItem.get(Rec."No.") then begin
                                TempItem.Init();
                                TempItem."No." := Rec."No.";
                                TempItem.Description := Rec.Description;
                                TempItem.Insert();
                            end
                        end ELSE begin
                            IF TempItem.get(Rec."No.") then
                                TempItem.Delete();
                        end;
                    end;
                }

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Select := TempItem.get(Rec."No.");
    end;

    trigger OnOpenPage()
    var
        ItemRec: Record Item;

    begin

        IF LocalItem_No <> '' then begin
            LastChar := CopyStr(LocalItem_No, StrLen(LocalItem_No) - 1);
            if LastChar = '..' then
                LocalItem_No := DelChr(LocalItem_No, '>', LastChar);
            ItemRec.Reset();
            if LocalItem_No = '' then
                exit;
            ItemRec.SetFilter("No.", LocalItem_No);
            if ItemRec.FindSet() then
                repeat
                    TempItem.Init();
                    TempItem."No." := ItemRec."No.";
                    TempItem.Description := ItemRec.Description;
                    TempItem.Insert();
                until ItemRec.Next() = 0;
        end;
    end;

    procedure GetSelectedItems() SelctedItemsString: Text
    begin
        if TempItem.FindFirst() then
            repeat
                if SelctedItemsString = '' then
                    SelctedItemsString := TempItem."No." else
                    if LastChar = '..' then
                        SelctedItemsString += '..' + TempItem."No."
                    else
                        SelctedItemsString += '|' + TempItem."No.";
            until TempItem.Next() = 0;
        exit(SelctedItemsString);
    end;

    procedure ApplyItemFilter(ItemSearchString: Text[100])
    begin
        Rec.MarkedOnly(false);
        Rec.SetRange("No.");
        Rec.SetRange(Description);

        IF ItemSearchString <> '' THEN BEGIN
            Rec.FilterGroup(-1);
            Rec.SetFilter("No.", '@*' + UpperCase(ItemSearchString) + '*');
            Rec.SetFilter(Rec.Description, '@*' + ItemSearchString + '*');
            IF Rec.FindFirst() then BEGIN
                Repeat
                    Rec.Mark(true);
                Until Rec.Next() = 0;
            END;
            Rec.MarkedOnly(TRUE);
            Rec.FilterGroup(0);
        END;
        IF Rec.FindFirst() THEN;
    end;

    procedure SetItemNoFilter(Source_No: Text)
    begin
        LocalItem_No := Source_No
    end;

    var
        Select: Boolean;
        TempItem: Record Item temporary;
        LocalItem_No: Text;
        LastChar: Text[2];
        ItemSearchString: Text[80];

}


