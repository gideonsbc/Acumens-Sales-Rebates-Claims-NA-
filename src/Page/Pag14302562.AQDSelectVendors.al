namespace AAPBBCOnPrem.AAPBBCOnPrem;

using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

page 14302562 "AQD Select Vendors"
{
    ApplicationArea = All;
    Caption = 'Vendors';
    PageType = List;
    SourceTable = Vendor;

    layout
    {
        area(Content)
        {
            field(VendorSearchString; VendorSearchString)
            {
                ApplicationArea = All;
                Caption = 'Search Vendor No.';

                trigger OnValidate()
                begin
                    ApplyVendorFilter(VendorSearchString);
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
                            if not TempVend.get(Rec."No.") then begin
                                TempVend.Init();
                                TempVend."No." := Rec."No.";
                                TempVend.Name := rec.Name;
                                TempVend.Insert();
                            end
                        end ELSE begin
                            IF TempVend.get(Rec."No.") then
                                TempVend.Delete();
                        end;
                    end;
                }

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Select := TempVend.get(Rec."No.");
    end;

    trigger OnOpenPage()
    var
        VendRec: Record Vendor;

    begin

        IF LocalVend_No <> '' then begin
            LastChar := CopyStr(LocalVend_No, StrLen(LocalVend_No) - 1);
            if LastChar = '..' then
                LocalVend_No := DelChr(LocalVend_No, '>', LastChar);
            VendRec.Reset();
            if LocalVend_No = '' then
                exit;
            VendRec.SetFilter("No.", LocalVend_No);
            if VendRec.FindSet() then
                repeat
                    TempVend.Init();
                    TempVend."No." := VendRec."No.";
                    TempVend.Name := VendRec.Name;
                    TempVend.Insert();
                until VendRec.Next() = 0;
        end;
    end;

    procedure GetSelectedVendors() SelctedVendorsString: Text
    begin
        if TempVend.FindFirst() then
            repeat
                if SelctedVendorsString = '' then
                    SelctedVendorsString := TempVend."No." else
                    if LastChar = '..' then
                        SelctedVendorsString += '..' + TempVend."No."
                    else
                        SelctedVendorsString += '|' + TempVend."No.";
            until TempVend.Next() = 0;
        exit(SelctedVendorsString);
    end;

    procedure ApplyVendorFilter(VendorSearchString: Text[100])
    begin
        Rec.MarkedOnly(false);
        Rec.SetRange("No.");
        Rec.SetRange(Name);

        IF VendorSearchString <> '' THEN BEGIN
            Rec.FilterGroup(-1);
            Rec.SetFilter("No.", '@*' + UpperCase(VendorSearchString) + '*');
            Rec.SetFilter(Rec.Name, '@*' + VendorSearchString + '*');
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

    procedure SetVendorNoNoFilter(Vend_No: Text)
    begin
        LocalVend_No := Vend_No
    end;


    var
        Select: Boolean;
        TempVend: Record Vendor temporary;
        LocalVend_No: Text;
        LastChar: Text[2];
        VendorSearchString: Text[80];
}
