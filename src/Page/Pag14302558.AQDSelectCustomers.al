namespace AAPBBCOnPrem.AAPBBCOnPrem;

using Microsoft.Sales.Customer;
using System.Security.User;

page 14302558 "AQD Select Customers"
{
    ApplicationArea = All;
    Caption = 'Customers';
    PageType = List;
    SourceTable = Customer;
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            field(CustSearchString; CustomerSearchString)
            {
                ApplicationArea = All;
                Caption = 'Search Source No.';

                trigger OnValidate()
                begin
                    ApplyCustomerFilter(CustomerSearchString);
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
                            if not TempCust.get(Rec."No.") then begin
                                TempCust.Init();
                                TempCust."No." := Rec."No.";
                                TempCust.Name := rec.Name;
                                TempCust.Insert();
                            end
                        end ELSE begin
                            IF TempCust.get(Rec."No.") then
                                TempCust.Delete();
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
        Select := TempCust.get(Rec."No.");
    end;

    trigger OnOpenPage()
    var
        CustRec: Record Customer;
    begin

        IF LocalSource_No <> '' then begin
            LastChar := CopyStr(LocalSource_No, StrLen(LocalSource_No) - 1);
            if LastChar = '..' then
                LocalSource_No := DelChr(LocalSource_No, '>', LastChar);
            CustRec.Reset();
            if LocalSource_No = '' then
                exit;
            CustRec.SetFilter("No.", LocalSource_No);
            if CustRec.FindSet() then
                repeat
                    TempCust.Init();
                    TempCust."No." := CustRec."No.";
                    TempCust.Name := CustRec.Name;
                    TempCust.Insert();
                until CustRec.Next() = 0;

            if UserMgt.GetSalesFilter() <> '' then begin
                Rec.FilterGroup(2);
                Rec.SetRange("Responsibility Center", UserMgt.GetSalesFilter());
                Rec.FilterGroup(0);
            end;
            Rec.FilterGroup(2);
            Rec.SetRange(Blocked, Rec.Blocked::" ");
            Rec.FilterGroup(0);
            if (UserSetup.Get(UserId)) and (UserSetup."AQD Acumens SalesPerson Filter" <> '') then begin
                Rec.FILTERGROUP(-1);
                IF USERID = 'CN' THEN
                    Rec.SETFILTER("Salesperson Code", '%1|%2|%3', UserSetup."AQD Acumens SalesPerson Filter", 'ALL', 'C.N.H.')
                ELSE
                    Rec.SETFILTER("Salesperson Code", '%1|%2', UserSetup."AQD Acumens SalesPerson Filter", 'ALL');
                IF USERID = 'CN' THEN
                    Rec.SETFILTER("Salesperson Code", '%1|%2|%3', UserSetup."AQD Acumens SalesPerson Filter", 'ALL', 'C.N.H.')
                ELSE
                    Rec.SETFILTER("Salesperson Code", '%1|%2', UserSetup."AQD Acumens SalesPerson Filter", 'ALL');

                IF Rec.FINDFIRST THEN
                    REPEAT
                        Rec.MARK(TRUE);
                    UNTIL Rec.NEXT = 0;
                Rec.MARKEDONLY(TRUE);
                IF Rec.FINDFIRST THEN;
                Rec.FILTERGROUP(0);
            end;
        end;
    end;

    procedure GetSelectedCustomers() SelctedCustString: Text
    begin
        if TempCust.FindFirst() then
            repeat
                if SelctedCustString = '' then
                    SelctedCustString := TempCust."No." else
                    if LastChar = '..' then
                        SelctedCustString += '..' + TempCust."No."
                    else
                        SelctedCustString += '|' + TempCust."No.";
            until TempCust.Next() = 0;
        exit(SelctedCustString);
    end;

    procedure ApplyCustomerFilter(CustomerSearchString: Text[100])
    begin
        Rec.MarkedOnly(false);
        Rec.SetRange("No.");
        Rec.SetRange(Name);

        IF CustomerSearchString <> '' THEN BEGIN
            Rec.FilterGroup(-1);
            Rec.SetFilter("No.", '@*' + UpperCase(CustomerSearchString) + '*');
            Rec.SetFilter(Rec.Name, '@*' + CustomerSearchString + '*');
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

    procedure SetSourceNoFilter(Source_No: Text)
    begin
        LocalSource_No := Source_No
    end;


    var
        Select: Boolean;
        TempCust: Record Customer temporary;
        LocalSource_No: Text;
        LastChar: Text[2];
        CustomerSearchString: Text[80];
        UserMgt: Codeunit "User Setup Management";
        UserSetup: Record "User Setup";

}
