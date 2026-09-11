page 14302708 "AQD Posted Cust Reb Detail API"
{
    APIPublisher = 'sbcdynamicserp';
    APIGroup = 'aqd';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'Posted Customer Rebate Details API';
    DelayedInsert = true;
    EntityName = 'postedCustomerRebateDetail';
    EntitySetName = 'postedCustomerRebateDetails';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "AQD Posted Cust Reb Details";

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
                field(rebateLineNo; Rec."Rebate Line No.") { }
                field(lineNo; Rec."Line No.") { }
                field(documentType; Rec."Document Type") { }
                field(documentNo; Rec."Document No.") { }
                field(documentLineNo; Rec."Document Line No.") { }
                field(entityType; Rec."Entity Type") { }
                field(entityNo; Rec."Entity No.") { }
                field(type; Rec.Type) { }
                field(no; Rec."No.") { }
                field(description; Rec.Description) { }
                field(quantity; Rec.Quantity) { }
                field(unitCost; Rec."Unit Cost") { }
                field(unitPrice; Rec."Unit Price") { }
                field(rebateItemCategoryCode; Rec."Rebate Item Category Code") { }
                field(rebateProgramCode; Rec."Rebate Program Code") { }
                field(rebateType; Rec."Rebate Type") { }
                field(rebatePercent; Rec."Rebate %") { }
                field(rebatePerUnit; Rec."Rebate Per Unit") { }
                field(rebateOrderDate; Rec."Rebate Order Date") { }
                field(postingDate; Rec."Posting Date") { }
                field(amount; Rec.Amount) { }
                field(amountIncludingVAT; Rec."Amount Including VAT") { }
                field(calculatedLineRebateAmount; Rec."Calculated Line Rebate Amount") { }
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
                field(rebatePayToCustomerNo; Rec."Rebate Pay-To Customer No.") { }
                field(customerRebateStatus; Rec."Customer Rebate Status") { }
                field(orderNo; Rec."Order No.") { }
                field(orderLineNo; Rec."Order Line No.") { }
                field(batchId; Rec.BatchID) { }
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