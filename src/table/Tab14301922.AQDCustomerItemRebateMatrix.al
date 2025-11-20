table 14301922 "AQD Cust Item Rebate Matrix"
{
    Caption = 'Customer Item Rebate Matrix';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line Type"; Enum "AQD CustItemRebate Matrix Type")
        {
            Caption = 'Line Type';
            trigger OnValidate()
            begin
                IF Rec."Line Type" <> xRec."Line Type" then
                    Rec."No." := '';
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Line Type" = const("Rebate Category")) "Item Category".Code where("AQD Customer Rebate" = const(true))
            else if ("Line Type" = const(Item)) Item;

            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    Case Rec."Line Type" OF
                        Rec."Line Type"::Item:
                            begin
                                IF Item.Get("No.") THEN
                                    Description := Item.Description
                                ELSE
                                    Description := '';
                            end;
                        Rec."Line Type"::"Rebate Category":
                            begin
                                IF ItemCategory.Get("No.") THEN
                                    Description := ItemCategory.Description
                                ELSE
                                    Description := '';
                            end;
                    end;
                end;
            end;
        }
        field(3; "Customer Type"; Enum "AQD Cust Rebate Customer Type")
        {
            Caption = 'Customer Type';
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = if ("Customer Type" = const("Customer Type")) "AQD CustRbt RebateCustomerType"
            else if ("Customer Type" = const(Customer)) Customer;
        }
        field(6; "Rebate Program Code"; Code[20])
        {
            Caption = 'Rebate Program Code';
            NotBlank = true;
            TableRelation = "AQD Cust Rebate Program Code";
        }

        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(100; "Sales Amount Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Amount Threshold';
        }
        field(105; "Sales Amount Threshold (YTD)"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Amount Threshold (YTD)';
        }

        field(110; "Sales Quantity Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Quantity Threshold';
        }
        field(115; "Sales Quantity Threshold (YTD)"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Quantity Threshold (YTD)';
        }
        field(120; EligiblePeriodAfterFirstShpt; DateFormula)
        {
            Caption = 'Eligible Period After First Shipment';
        }
        field(950; "Blocked"; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if Blocked then begin
                    "Blocked By" := UserId;
                    "Blocked Date Time" := CurrentDateTime;
                end else begin
                    Clear("Blocked By");
                    Clear("Blocked Date Time");
                end;
            end;
        }
        field(960; "Blocked By"; Code[50])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(970; "Blocked Date Time"; DateTime)
        {
            Caption = 'Blocked Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Customer Type", "Customer No.", "Line Type", "No.", "Rebate Program Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Customer Type", "Customer No.", "Line Type", "No.", "Rebate Program Code")
        {
        }
        fieldgroup(Brick; "Customer Type", "Customer No.", "Line Type", "No.", "Rebate Program Code")
        {
        }
    }
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
}