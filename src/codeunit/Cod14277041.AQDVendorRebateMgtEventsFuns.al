codeunit 14277041 "AQD Vendor RebateMgtEventsFuns"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", OnAfterInsertEvent, '', false, false)]
    local procedure Tab32_ItemLedgerEntry_OnAfterInsertEvent(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    var
        RebateItemLdgrEntry: Record "AQD Rebate Item Ledger Entry";
        LocalPurchRcptHdr: Record "Purch. Rcpt. Header";
        LocalPurchInvHdr: Record "Purch. Inv. Header";
        LocalPurchReturnShptHdr: Record "Return Shipment Header";
        LocalPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        IF Rec.IsTemporary THEN
            EXIT;

        IF Rec."Entry Type" <> Rec."Entry Type"::Purchase THEN
            EXIT;

        IF NOT (Rec."Document Type" IN
               [Rec."Document Type"::"Purchase Receipt",
                Rec."Document Type"::"Purchase Invoice",
                Rec."Document Type"::"Purchase Return Shipment",
                Rec."Document Type"::"Purchase Credit Memo"])
        THEN
            EXIT;

        RebateItemLdgrEntry.Init();
        RebateItemLdgrEntry.TransferFields(Rec);
        Case Rec."Document Type" OF
            Rec."Document Type"::"Purchase Receipt":
                BEGIN
                    IF LocalPurchRcptHdr.GET(Rec."Document No.") then begin
                        RebateItemLdgrEntry."AQD Buy-from Vendor No." := LocalPurchRcptHdr."Buy-from Vendor No.";
                        RebateItemLdgrEntry."AQD Pay-to Vendor No." := LocalPurchRcptHdr."Pay-to Vendor No.";
                        RebateItemLdgrEntry."Responsibility Center" := LocalPurchRcptHdr."Responsibility Center";
                        //RebateItemLdgrEntry."AQD Do Not Pay Rebate" := LocalPurchRcptHdr."AQD Do Not Pay Rebate";
                        RebateItemLdgrEntry."AQD Purchaser Code" := LocalPurchRcptHdr."Purchaser Code";
                        RebateItemLdgrEntry."AQD Ship-to County" := LocalPurchRcptHdr."Ship-to County";
                        RebateItemLdgrEntry."Document Posting Description" := LocalPurchRcptHdr."Posting Description";
                        RebateItemLdgrEntry."Order Date" := LocalPurchRcptHdr."Order Date";
                        RebateItemLdgrEntry."Vendor Order No." := LocalPurchRcptHdr."Vendor Order No.";
                        RebateItemLdgrEntry."AQD Rebate Order Date" := LocalPurchRcptHdr."AQD Rebate Order Date";
                    end;
                END;
            Rec."Document Type"::"Purchase Invoice":
                BEGIN
                    IF LocalPurchInvHdr.GET(Rec."Document No.") then begin
                        RebateItemLdgrEntry."AQD Buy-from Vendor No." := LocalPurchInvHdr."Buy-from Vendor No.";
                        RebateItemLdgrEntry."AQD Pay-to Vendor No." := LocalPurchInvHdr."Pay-to Vendor No.";
                        RebateItemLdgrEntry."Responsibility Center" := LocalPurchInvHdr."Responsibility Center";
                        //RebateItemLdgrEntry."AQD Do Not Pay Rebate" := LocalPurchRcptHdr."AQD Do Not Pay Rebate";
                        RebateItemLdgrEntry."AQD Purchaser Code" := LocalPurchInvHdr."Purchaser Code";
                        RebateItemLdgrEntry."AQD Ship-to County" := LocalPurchInvHdr."Ship-to County";
                        RebateItemLdgrEntry."Document Posting Description" := LocalPurchInvHdr."Posting Description";
                        RebateItemLdgrEntry."Order Date" := LocalPurchInvHdr."Order Date";
                        RebateItemLdgrEntry."Vendor Order No." := LocalPurchInvHdr."Vendor Order No.";
                        RebateItemLdgrEntry."Vendor Invoice No." := LocalPurchInvHdr."Vendor Invoice No.";
                        RebateItemLdgrEntry."AQD Rebate Order Date" := LocalPurchInvHdr."AQD Rebate Order Date";
                    end;
                END;
            Rec."Document Type"::"Purchase Return Shipment":
                BEGIN
                    IF LocalPurchReturnShptHdr.GET(Rec."Document No.") then begin
                        RebateItemLdgrEntry."AQD Buy-from Vendor No." := LocalPurchReturnShptHdr."Buy-from Vendor No.";
                        RebateItemLdgrEntry."AQD Pay-to Vendor No." := LocalPurchReturnShptHdr."Pay-to Vendor No.";
                        RebateItemLdgrEntry."Responsibility Center" := LocalPurchReturnShptHdr."Responsibility Center";
                        //RebateItemLdgrEntry."AQD Do Not Pay Rebate" := LocalPurchRcptHdr."AQD Do Not Pay Rebate";
                        RebateItemLdgrEntry."AQD Purchaser Code" := LocalPurchReturnShptHdr."Purchaser Code";
                        RebateItemLdgrEntry."AQD Ship-to County" := LocalPurchReturnShptHdr."Ship-to County";
                        RebateItemLdgrEntry."Document Posting Description" := LocalPurchReturnShptHdr."Posting Description";
                        RebateItemLdgrEntry."Order Date" := LocalPurchReturnShptHdr."Posting Date";
                        RebateItemLdgrEntry."Vendor Order No." := LocalPurchReturnShptHdr."Vendor Authorization No.";
                        RebateItemLdgrEntry."AQD Rebate Order Date" := LocalPurchReturnShptHdr."AQD Rebate Order Date";
                    end;
                END;
            Rec."Document Type"::"Purchase Credit Memo":
                BEGIN
                    IF LocalPurchCrMemoHdr.GET(Rec."Document No.") then begin
                        RebateItemLdgrEntry."AQD Buy-from Vendor No." := LocalPurchCrMemoHdr."Buy-from Vendor No.";
                        RebateItemLdgrEntry."AQD Pay-to Vendor No." := LocalPurchCrMemoHdr."Pay-to Vendor No.";
                        RebateItemLdgrEntry."Responsibility Center" := LocalPurchCrMemoHdr."Responsibility Center";
                        //RebateItemLdgrEntry."AQD Do Not Pay Rebate" := LocalPurchRcptHdr."AQD Do Not Pay Rebate";
                        RebateItemLdgrEntry."AQD Purchaser Code" := LocalPurchCrMemoHdr."Purchaser Code";
                        RebateItemLdgrEntry."AQD Ship-to County" := LocalPurchCrMemoHdr."Ship-to County";
                        RebateItemLdgrEntry."Document Posting Description" := LocalPurchCrMemoHdr."Posting Description";
                        RebateItemLdgrEntry."Order Date" := LocalPurchCrMemoHdr."Posting Date";
                        RebateItemLdgrEntry."Vendor Cr. Memo No." := LocalPurchCrMemoHdr."Vendor Cr. Memo No.";
                        RebateItemLdgrEntry."AQD Rebate Order Date" := LocalPurchCrMemoHdr."AQD Rebate Order Date";
                    end;
                END;
        End;
        RebateItemLdgrEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnAfterInitRecord, '', FALSE, FALSE)]
    local procedure Tab38_PurchaseHeader_OnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader."AQD Rebate Order Date" := PurchHeader."Order Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Show Applied Entries", 'OnFindAppliedEntryOnAfterSetFilters', '', false, false)]
    local procedure Cod5801_ShowAppliedEntries_OnFindAppliedEntryOnAfterSetFilters(var ItemApplicationEntry: Record "Item Application Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        RebateSingelInstance: Codeunit "AQD Rebate Single Instance";
        CalledFromRebate: Boolean;
    begin
        RebateSingelInstance.GetCalledFromRebate(CalledFromRebate);
        IF CalledFromRebate then
            ItemApplicationEntry.SetRange("Cost Application");
    end;
}