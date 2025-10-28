table 14301922 "AQD Cust Item Rebate Eligib"
{
    Caption = 'Customer Item Rebate Eligibility';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line Type"; Enum "AQD Customer Rebate Line Type")
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
            TableRelation = if ("Line Type" = const("Rebate Category")) "AQD Cust Rebate Item Category"
            else if ("Line Type" = const(Item)) Item
            else if ("Line Type" = const("G/L Account")) "G/L Account"
            else if ("Line Type" = const(Resource)) Resource
            else if ("Line Type" = const("Fixed Asset")) "Fixed Asset"
            else if ("Line Type" = const("Charge (Item)")) "Item Charge";

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
                        Rec."Line Type"::Resource:
                            begin
                                IF Resource.Get("No.") THEN
                                    Description := Resource.Name
                                ELSE
                                    Description := '';
                            end;
                        Rec."Line Type"::"G/L Account":
                            begin
                                IF GLAccount.Get("No.") THEN
                                    Description := GLAccount.Name
                                ELSE
                                    Description := '';
                            end;
                        Rec."Line Type"::"Fixed Asset":
                            begin
                                IF FixAsset.Get("No.") THEN
                                    Description := FixAsset.Description
                                ELSE
                                    Description := '';
                            end;
                        Rec."Line Type"::"Charge (Item)":
                            begin
                                IF ItemCharge.Get("No.") THEN
                                    Description := ItemCharge.Description
                                ELSE
                                    Description := '';
                            end;
                        Rec."Line Type"::"Rebate Category":
                            begin
                                IF ItemRebateCategory.Get("No.") THEN
                                    Description := ItemRebateCategory.Description
                                ELSE
                                    Description := '';
                            end;
                    end;
                end;
            end;
        }
        field(3; "Customer Type"; Enum "AQD Rebate Customer Type")
        {
            Caption = 'Customer Type';
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = if ("Customer Type" = const("Customer Type")) "AQD Rebate Customer Type"
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
        field(110; "Sales Quantity Threshold"; Decimal)
        {
            BlankZero = TRUE;
            Caption = 'Sales Quantity Threshold';
        }
        //Not Required for Customer
        //field(120; "EligiblePeriodAfterFirstRcpt"; DateFormula)
        //{
        //    Caption = 'Eligible Period After First Shipment';
        //}
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
        key(Key1; "Line Type", "No.", "Customer Type", "Customer No.", "Rebate Program Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Line Type", "No.", "Customer Type", "Customer No.", "Rebate Program Code")
        {
        }
        fieldgroup(Brick; "Line Type", "No.", "Customer Type", "Customer No.", "Rebate Program Code")
        {
        }
    }
    var
        Vend: Record Vendor;
        Item: Record Item;
        Resource: Record Resource;
        GLAccount: Record "G/L Account";
        ItemCharge: Record "Item Charge";
        FixAsset: Record "Fixed Asset";
        ItemRebateCategory: Record "AQD Cust Rebate Item Category";
}