page 14302710 "AQD CR Reb Item Ledger API"
{
    APIPublisher = 'sbcdynamicserp';
    APIGroup = 'aqd';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'Rebate Item Ledger Entries API';
    DelayedInsert = true;
    EntityName = 'rebateItemLedgerEntry';
    EntitySetName = 'rebateItemLedgerEntries';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "AQD CR Reb Item Ledger Entry";

    Editable = false;
    LinksAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { }
                field(entryNo; Rec."Entry No.") { }
                field(orderNo; Rec."Order No.") { }
                field(orderLineNo; Rec."Order Line No.") { }
                field(entryType; Rec."Entry Type") { }
                field(postingDate; Rec."Posting Date") { }
                field(customerRebateOrderDate; Rec."AQD customer Rebate Order Date") { }
                field(documentType; Rec."Document Type") { }
                field(documentNo; Rec."Document No.") { }
                field(documentLineNo; Rec."Document Line No.") { }
                field(itemNo; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(description; Rec.Description) { }
                field(locationCode; Rec."Location Code") { }
                field(quantity; Rec.Quantity) { }
                field(invoicedQuantity; Rec."Invoiced Quantity") { }
                field(positive; Rec.Positive) { }
                field(correction; Rec.Correction) { }
                field(itemCategoryCode; Rec."Item Category Code") { }
                field(costAmountActual; Rec."Cost Amount (Actual)") { }
                field(costAmountExpected; Rec."Cost Amount (Expected)") { }
                field(costAmountNonInvtbl; Rec."Cost Amount (Non-Invtbl.)") { }
                field(sourceNo; Rec."Source No.") { }
                field(sourceType; Rec."Source Type") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(customerCrMemoNo; Rec."Customer Cr. Memo No.") { }
                field(customerInvoiceNo; Rec."Customer Invoice No.") { }
                field(rebateAmount; Rec."Rebate Amount") { }
                field(rebateNo; Rec."AQD Rebate No") { }
                field(rebateStatus; Rec."AQD Rebate Status") { }
                field(documentPostingDescription; Rec."Document Posting Description") { }
                field(sellToCustomerNo; Rec."AQD Sell-to Customer No.") { }
                field(billToCustomerNo; Rec."AQD Bill-to Customer No.") { }
                field(billToCustomerName; Rec."AQD Bill-to Customer Name") { }
                field(rebateEntryCreated; Rec."AQD Rebate Entry Created") { }
                field(externalDocumentNo; Rec."External Document No.") { }
                field(rebateLastChangedBy; Rec."AQD Rebate Last Changed By") { }
                field(responsibilityCenter; Rec."Responsibility Center") { }
                field(orderType; Rec."Order Type") { }
                field(dateTimeCreated; Rec.SystemCreatedAt)
                {
                    Caption = 'Date\Time Created';
                }
                field(lastDateTimeModified; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Date/Time Modified';
                }
            }
        }
    }
}