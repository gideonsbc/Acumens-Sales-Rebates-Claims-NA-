page 14302709 "AQD Posted Cust Reb Line API"
{
    APIPublisher = 'sbcdynamicserp';
    APIGroup = 'aqd';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Lines API';
    DelayedInsert = true;
    EntityName = 'postedCustomerRebateLine';
    EntitySetName = 'postedCustomerRebateLines';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "AQD Posted Cust Rebate Line";

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
                field(rebateNo; Rec."Rebate No.") { }
                field(lineNo; Rec."Line No.") { }
                field(documentType; Rec."Document Type") { }
                field(documentNo; Rec."Document No.") { }
                field(orderNo; Rec."Order No.") { }
                field(description; Rec.Description) { }
                field(orderDate; Rec."Order Date") { }
                field(rebateOrderDate; Rec."Rebate Order Date") { }
                field(postingDate; Rec."Posting Date") { }
                field(customerOrderNo; Rec."Customer Order No.") { }
                field(customerShipmentNo; Rec."Customer Shipment No.") { }
                field(customerInvoiceNo; Rec."Customer Invoice No.") { }
                field(customerCrMemoNo; Rec."Customer Cr. Memo No.") { }
                field(amount; Rec.Amount) { }
                field(amountIncludingVAT; Rec."Amount Including VAT") { }
                field(calculatedRebateAmount; Rec."Calculated Rebate Amount") { }
                field(vendorCommission; Rec."Vendor Commission") { }
                field(employeeCommission; Rec."Employee Commission") { }
                field(customerRebateAmount; Rec."Customer Rebate Amount") { }
                field(doNotCredit; Rec."Do Not Credit") { }
                field(ineligible; Rec.Ineligible) { }
                field(salespersonCode; Rec."Salesperson Code") { }
                field(responsibilityCenter; Rec."Responsibility Center") { }
                field(locationCode; Rec."Location Code") { }
                field(territoryCode; Rec."Territory Code") { }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code") { }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code") { }
                field(sellToCustomerNo; Rec."Sell-To Customer No.") { }
                field(billToCustomerNo; Rec."Bill-To Customer No.") { }
                field(billToCustomerName; Rec."Bill-To Customer Name") { }
                field(rebatePayToCustomerNo; Rec."Rebate Pay-To Customer No.") { }
                field(customerRebateStatus; Rec."Customer Rebate Status") { }
                field(batchId; Rec.BatchID) { }
                field(custRebateProgramCode; Rec."Cust Rebate Program Code") { }
                field(marketplaceCode; Rec."Marketplace Code") { }
                field(offInvoiceRebate; Rec."Off-Invoice Rebate") { }
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