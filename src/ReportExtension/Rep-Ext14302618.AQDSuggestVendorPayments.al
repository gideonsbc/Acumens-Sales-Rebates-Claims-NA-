reportextension 14302618 "AQD Suggest Vendor Payments" extends "Suggest Vendor Payments"
{
    dataset
    {
        addlast(Vendor)
        {
            dataitem(VendorLedgerEntry; "Vendor Ledger Entry")
            {
                DataItemLinkReference = Vendor;
                DataItemLink = "Vendor No." = field("No.");
                RequestFilterFields = "AQD CR Rebate Program Code";
                DataItemTableView = sorting("Entry No.");
            }
        }
        modify(Vendor)
        {
            trigger OnBeforePreDataItem()
            var
                AQDCRSingleInstanceExt: Codeunit "AQD CR Single Instance Ext";
            begin
                AQDCRSingleInstanceExt.SetVendorLedgerEntriesFilters(VendorLedgerEntry);
            end;
        }
    }
}
