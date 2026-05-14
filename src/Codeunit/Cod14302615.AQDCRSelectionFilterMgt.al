codeunit 14302615 "AQD CR SelectionFilterMgt"
{
    procedure GetSelectionFilterForPaymentTerms(var PaymentTerms: Record "Payment Terms"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(PaymentTerms);
        exit(GetSelectionFilter(RecRef, PaymentTerms.FieldNo(Code)));
    end;

    procedure GetSelectionFilterForRebateProgramCode(var RebateProgramCode: Record "AQD Cust Rebate Program Code"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RebateProgramCode);
        exit(GetSelectionFilter(RecRef, RebateProgramCode.FieldNo(Code)));
    end;

    procedure GetSelectionFilterForMarketplaceCode(var MarketplaceCode: Record "AQD Marketplace"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(MarketplaceCode);
        exit(GetSelectionFilter(RecRef, MarketplaceCode.FieldNo(Code)));
    end;

    procedure GetSelectionFilter(var TempRecRef: RecordRef; SelectionFieldID: Integer): Text
    var
        [SecurityFiltering(SecurityFilter::Ignored)]
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FirstRecRef: Text;
        LastRecRef: Text;
        SelectionFilter: Text;
        SavePos: Text;
        TempRecRefCount: Integer;
        More: Boolean;
    begin
        if TempRecRef.IsTemporary then begin
            RecRef := TempRecRef.Duplicate();
            RecRef.Reset();
        end else
            RecRef.Open(TempRecRef.Number, false, TempRecRef.CurrentCompany);

        TempRecRefCount := TempRecRef.Count();
        if TempRecRefCount > 0 then begin
            TempRecRef.Ascending(true);
            TempRecRef.Find('-');
            while TempRecRefCount > 0 do begin
                TempRecRefCount := TempRecRefCount - 1;
                RecRef.SetPosition(TempRecRef.GetPosition());
                RecRef.Find();
                FieldRef := RecRef.Field(SelectionFieldID);
                FirstRecRef := Format(FieldRef.Value);
                LastRecRef := FirstRecRef;
                More := TempRecRefCount > 0;
                while More do
                    if RecRef.Next() = 0 then
                        More := false
                    else begin
                        SavePos := TempRecRef.GetPosition();
                        TempRecRef.SetPosition(RecRef.GetPosition());
                        if not TempRecRef.Find() then begin
                            More := false;
                            TempRecRef.SetPosition(SavePos);
                        end else begin
                            FieldRef := RecRef.Field(SelectionFieldID);
                            LastRecRef := Format(FieldRef.Value);
                            TempRecRefCount := TempRecRefCount - 1;
                            if TempRecRefCount = 0 then
                                More := false;
                        end;
                    end;
                if SelectionFilter <> '' then
                    SelectionFilter := SelectionFilter + '|';
                if FirstRecRef = LastRecRef then
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef)
                else
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef) + '..' + AddQuotes(LastRecRef);
                if TempRecRefCount > 0 then
                    TempRecRef.Next();
            end;
            exit(SelectionFilter);
        end;
    end;

    procedure AddQuotes(inString: Text): Text
    begin
        inString := ReplaceString(inString, '''', '''''');
        if DelChr(inString, '=', ' &|()*@<>=.!?') = inString then
            exit(inString);
        exit('''' + inString + '''');
    end;

    procedure ReplaceString(String: Text; FindWhat: Text; ReplaceWith: Text) NewString: Text
    begin
        while STRPOS(String, FindWhat) > 0 do begin
            NewString := NewString + DELSTR(String, STRPOS(String, FindWhat)) + ReplaceWith;
            String := COPYSTR(String, STRPOS(String, FindWhat) + STRLEN(FindWhat));
        end;
        NewString := NewString + String;
    end;
}