tableextension 14301910 "AQD CustRbt Item Ext" extends Item
{
    fields
    {
        field(14301910; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(14301930; "AQD CustRbt Source No. Filter"; Code[20])
        {
            Caption = 'Customer Rebate Source No. Filter';
            FieldClass = FlowFilter;
            TableRelation = Customer."No.";
        }
        field(14301940; "AQD Cust Rbt Sales (Qty.)"; Decimal)
        {
            CalcFormula = - sum("Value Entry"."Invoiced Quantity" where("Item Ledger Entry Type" = const(Sale),
                                                                        "Item No." = field("No."),
                                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                        "Location Code" = field("Location Filter"),
                                                                        "Drop Shipment" = field("Drop Shipment Filter"),
                                                                        "Variant Code" = field("Variant Filter"),
                                                                        "Posting Date" = field("Date Filter"),
                                                                        "Source Type" = filter(Customer),
                                                                        "Source No." = field("AQD CustRbt Source No. Filter")));
            Caption = 'Sales (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            AutoFormatType = 0;
        }
        field(14301950; "AQD Cust Rbt Sales (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            CalcFormula = sum("Value Entry"."Sales Amount (Actual)" where("Item Ledger Entry Type" = const(Sale),
                                                                           "Item No." = field("No."),
                                                                           "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                           "Location Code" = field("Location Filter"),
                                                                           "Drop Shipment" = field("Drop Shipment Filter"),
                                                                           "Variant Code" = field("Variant Filter"),
                                                                           "Posting Date" = field("Date Filter"),
                                                                           "Source Type" = filter(Customer),
                                                                           "Source No." = field("AQD CustRbt Source No. Filter")));
            Caption = 'Sales (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}