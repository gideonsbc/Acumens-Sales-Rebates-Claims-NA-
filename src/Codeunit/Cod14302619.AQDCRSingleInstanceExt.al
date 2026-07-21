codeunit 14302619 "AQD CR Single Instance Ext"
{
    SingleInstance = true;

    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";

    procedure SetVendorLedgerEntriesFilters(var VendorLedger_Local: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry.CopyFilters(VendorLedger_Local);
    end;

    procedure GetVendorLedgerEntriesFilters(var VendorLedger_Local: Record "Vendor Ledger Entry")
    begin
        VendorLedger_Local.CopyFilters(VendorLedgerEntry);
    end;
}
