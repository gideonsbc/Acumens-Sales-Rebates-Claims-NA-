namespace AAPBBCOnPrem.AAPBBCOnPrem;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
page 14302560 "AQD Select Ship-To Codes"
{

    ApplicationArea = All;
    Caption = 'Select Ship-To Codes';
    PageType = List;
    SourceTable = "Ship-to Address";
    layout
    {
        area(Content)
        {
            field(ShipToCodeSearchString; ShipToCodeSearchString)
            {
                ApplicationArea = All;
                Caption = 'Search Ship-to Code';

                trigger OnValidate()
                begin
                    ApplyShipToCodeFilter(ShipToCodeSearchString);
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
                            if not TempShiptoAddress.Get(Rec."Customer No.", Rec.Code) then begin
                                TempShiptoAddress.Init();
                                TempShiptoAddress.TransferFields(Rec);
                                TempShiptoAddress.Insert();
                            end
                        end ELSE begin
                            IF TempShiptoAddress.Get(Rec."Customer No.", Rec.Code) then
                                TempShiptoAddress.Delete();
                        end;
                    end;
                }

                field("No."; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Select := TempShiptoAddress.get(Rec."Customer No.", Rec.Code);
    end;

    trigger OnOpenPage()
    var
        ShiptoAddressRec: Record "Ship-to Address";

    begin
        IF LocalItem_No <> '' then begin
            LastChar := CopyStr(LocalItem_No, StrLen(LocalItem_No) - 1);
            if LastChar = '..' then
                LocalItem_No := DelChr(LocalItem_No, '>', LastChar);
            ShiptoAddressRec.Reset();
            if LocalItem_No = '' then
                exit;
            ShiptoAddressRec.SetFilter(Code, LocalItem_No);
            if ShiptoAddressRec.FindSet() then
                repeat
                    TempShiptoAddress.Init();
                    TempShiptoAddress."Customer No." := ShiptoAddressRec."Customer No.";
                    TempShiptoAddress.Code := ShiptoAddressRec.Code;
                    TempShiptoAddress.Name := ShiptoAddressRec.Name;
                    TempShiptoAddress.Insert();
                until ShiptoAddressRec.Next() = 0;
        end;
    end;

    procedure GetSelectedShipToCodes() SelectedShipToCodesString: Text
    var
        TempCodeSet: Dictionary of [Code[20], Boolean];
    begin

        if TempShiptoAddress.FindFirst() then
            repeat
                if not TempCodeSet.ContainsKey(TempShiptoAddress.Code) then begin
                    TempCodeSet.Add(TempShiptoAddress.Code, true);
                    if SelectedShipToCodesString = '' then
                        SelectedShipToCodesString := TempShiptoAddress.Code else
                        if LastChar = '..' then
                            SelectedShipToCodesString += '..' + TempShiptoAddress.Code
                        else
                            SelectedShipToCodesString += '|' + TempShiptoAddress.Code;
                end;
            until TempShiptoAddress.Next() = 0;
        exit(SelectedShipToCodesString);
    end;

    procedure ApplyShipToCodeFilter(ShipToCodeSearchString: Text[100])
    begin
        Rec.MarkedOnly(false);
        Rec.SetRange(Code);
        Rec.SetRange(Name);

        IF ShipToCodeSearchString <> '' THEN BEGIN
            Rec.FilterGroup(-1);
            Rec.SetFilter(Code, '@*' + UpperCase(ShipToCodeSearchString) + '*');
            Rec.SetFilter(Rec.Name, '@*' + ShipToCodeSearchString + '*');
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

    procedure SetShipToCodeFilter(Source_No: Text)
    begin
        LocalItem_No := Source_No
    end;

    var
        Select: Boolean;
        TempShiptoAddress: Record "Ship-to Address" temporary;
        LocalItem_No: Text;
        LastChar: Text[2];
        ShipToCodeSearchString: Text[80];
}