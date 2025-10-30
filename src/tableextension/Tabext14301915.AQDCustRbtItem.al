tableextension 14301915 "AQD CustRbt Item Ext" extends Item
{
    fields
    {
        field(14277004; "AQD Customer Rebate Enabled"; Boolean)
        {
            Caption = 'Customer Rebate Enabled';
            DataClassification = CustomerContent;
        }
        field(14277012; "AQD Rebate Category Code"; Code[20])
        {
            Caption = 'Rebate Category Code';
            TableRelation = "AQD Cust Rebate Item Category";
        }
        field(14277020; "AQD Purchases (Qty.)"; Decimal)
        {
            CalcFormula = sum("Item Ledger Entry".Quantity where("Entry Type" = const(Purchase),
                                                                 "Item No." = field("No."),
                                                                 "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                 "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                 "Location Code" = field("Location Filter"),
                                                                 "Drop Shipment" = field("Drop Shipment Filter"),
                                                                 "Variant Code" = field("Variant Filter"),
                                                                 "Posting Date" = field("Date Filter"),
                                                                 "Lot No." = field("Lot No. Filter"),
                                                                 "Serial No." = field("Serial No. Filter"),
                                                                 "Package No." = field("Package No. Filter")));
            Caption = 'Purchases (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(14277050; "AQD Use Rebate Setup From"; enum "AQD Use Rebate Setup From")
        {
            Caption = 'Use Rebate Setup From';

            trigger OnValidate()
            var
                AllowedValueValidationLable: Label 'Item can have Use Rebate Setup From either Item or Rebate Code.';
            begin
                IF NOT (Rec."AQD Use Rebate Setup From" IN
                        [Rec."AQD Use Rebate Setup From"::" ",
                         Rec."AQD Use Rebate Setup From"::"Rebate Code",
                         Rec."AQD Use Rebate Setup From"::Item])
                then
                    Error(AllowedValueValidationLable);

                IF Rec."AQD Use Rebate Setup From" = Rec."AQD Use Rebate Setup From"::"Rebate Code" then
                    Rec."AQD Cust Rebate Posting Type" := Rec."AQD Cust Rebate Posting Type"::" ";
            end;
        }
        field(14277060; "AQD Cust Rebate Posting Type"; enum "AQD Cust Rebate Posting Type")
        {
            Caption = 'Rebate Cost Posting Type';
        }
    }
}