table 14302523 "AQD Rebate Journal Line"
{
    Caption = 'Rebate Journal Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Batch Name"; Code[10])
        {
            Caption = 'Batch Name';
            TableRelation = "AQD Rebate Journal Batch";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Rebate No."; Code[20])
        {
            Caption = 'Sales Rebate No.';
            Editable = false;
            TableRelation = "AQD Customer Rebate Header";
        }
        field(6; "Rebate Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Sales Rebate Line No.';
            Editable = false;
        }
        field(7; "Rebate Detail Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Sales Rebate Detail Line No.';
            Editable = false;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(11; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(15; "Document Type"; Enum "AQD Cust Rebate Document Type")
        {
            Caption = 'Document Type';
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(20; "Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Document Line No.';
        }
        field(40; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(45; "Entity Type"; Enum "AQD CR Rebate Entity Type")
        {
            Caption = 'Payee Type';
            //InitValue = Customer;

            trigger OnValidate()
            begin
                if "Entity Type" <> xRec."Entity Type" then
                    if "Entity Type" = "Entity Type"::Customer then
                        "Entity No." := "Rebate Pay-To Customer No."
                    else
                        "Entity No." := '';
            end;
        }
        field(46; "Entity No."; Code[20])
        {
            Caption = 'Payee No.';
            TableRelation = if ("Entity Type" = const(Customer)) Customer."No."
            else if ("Entity Type" = const(Employee)) Employee."No."
            else if ("Entity Type" = const(Vendor)) Vendor."No.";
        }
        field(50; Type; Enum "AQD Cust Rebate Record Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(60; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const("G/L Account")) "G/L Account"."No."
            else if (Type = const(Item)) Item."No."
            else if (Type = const(Resource)) Resource."No.";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
                Item: Record Item;
                Resource: Record Resource;
            begin
                if "No." = '' then begin
                    "Rebate Item Category Code" := '';
                    exit;
                end;
                case Type of
                    Type::"G/L Account":
                        begin
                            GLAccount.Get("No.");
                            Description := GLAccount.Name;
                        end;
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                            "Rebate Item Category Code" := Item."Item Category Code";
                        end;
                    Type::Resource:
                        begin
                            Resource.Get("No.");
                            Description := Resource.Name;
                        end;
                end;
            end;
        }
        field(65; "Rebate Item Category Code"; Code[20])
        {
            Caption = 'Rebate Item Category Code';
            TableRelation = "Item Category".Code;
        }
        field(66; "Rebate Program Code"; Code[10])
        {
            Caption = 'Rebate Program Code';
            TableRelation = "AQD Cust Rebate Program Code";

            trigger OnValidate()
            var
                RebateProgramCode: Record "AQD Cust Rebate Program Code";
            begin
                if "Rebate Program Code" = '' then begin
                    "Entity Type" := "Entity Type"::" ";
                    "Entity No." := '';
                    exit;
                end;
                RebateProgramCode.Get("Rebate Program Code");
                if RebateProgramCode."Customer Rebate Posting Type" <> RebateProgramCode."Customer Rebate Posting Type"::" " then
                    "Cust Rebate Posting Type" := RebateProgramCode."Customer Rebate Posting Type"
                else
                    "Cust Rebate Posting Type" := "Cust Rebate Posting Type"::Expense;
                if "Rebate Payment Method Code" = '' then
                    "Rebate Payment Method Code" := RebateProgramCode."Rebate Payment Method Code";

                case RebateProgramCode."Payee Type" of
                    RebateProgramCode."Payee Type"::CustomerRebate:
                        begin
                            "Entity Type" := "Entity Type"::Customer;
                            "Entity No." := "Rebate Pay-To Customer No.";
                        end;
                    RebateProgramCode."Payee Type"::"Employee Commission":
                        begin
                            "Entity Type" := "Entity Type"::Employee;
                            "Entity No." := RebateProgramCode."Payee No.";
                        end;
                    RebateProgramCode."Payee Type"::"Vendor Commission":
                        begin
                            "Entity Type" := "Entity Type"::Vendor;
                            "Entity No." := RebateProgramCode."Payee No.";
                        end;
                end;
            end;
        }
        field(67; "CustRbt Rate Type"; Enum "AQD CustRbt Rate Type")
        {
            Caption = 'Rebate Rate Type';
        }
        field(70; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(80; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(90; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(100; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(110; "Rebate Type"; Option)
        {
            Caption = 'Rebate Type';
            OptionCaption = ' ,Per Unit,Percentage';
            OptionMembers = " ","Per Unit",Percentage;
        }
        field(125; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            DecimalPlaces = 0 : 5;
        }
        field(130; "Rebate Per Unit"; Decimal)
        {
            Caption = 'Rebate Per Unit';
        }
        field(140; "Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
        }
        field(150; Amount; Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(160; "Amount Including VAT"; Decimal)
        {
            Caption = 'Sales Amount Including VAT';
        }
        field(180; "Rebate Amount"; Decimal)
        {
            Caption = 'Rebate Amount';
        }
        field(300; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(310; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(320; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(325; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
        }
        field(330; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(340; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(350; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(370; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(380; "Order Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No.';
        }
        field(401; State; Text[30])
        {
            Caption = 'State';
        }
        field(499; "Sell-To Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                SellToCustomer: Record Customer;
            begin
                "Sell-To Customer Name" := '';
                if "Sell-To Customer No." = '' then
                    exit;
                SellToCustomer.Get("Sell-To Customer No.");
                "Sell-To Customer Name" := SellToCustomer.Name;
                if "Bill-To Customer No." = '' then
                    if SellToCustomer."Bill-to Customer No." <> '' then
                        Validate("Bill-To Customer No.", SellToCustomer."Bill-to Customer No.")
                    else
                        Validate("Bill-To Customer No.", SellToCustomer."No.");
            end;
        }
        field(500; "Sell-To Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
        }
        field(501; "Bill-To Customer No."; Code[20])
        {
            Caption = 'Bill-To Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                BillToCustomer: Record Customer;
            begin
                "Bill-To Customer Name" := '';
                if "Bill-To Customer No." = '' then
                    exit;
                BillToCustomer.Get("Bill-To Customer No.");
                "Bill-To Customer Name" := BillToCustomer.Name;
                "Customer Rebate Category" := BillToCustomer."AQD Cust Rebate Category";
                if "Payment Terms Code" = '' then
                    "Payment Terms Code" := BillToCustomer."Payment Terms Code";
                if "Rebate Pay-To Customer No." = '' then
                    if BillToCustomer."AQD Cust Rebate Customer No." <> '' then
                        Validate("Rebate Pay-To Customer No.", BillToCustomer."AQD Cust Rebate Customer No.")
                    else
                        Validate("Rebate Pay-To Customer No.", BillToCustomer."No.");
            end;
        }
        field(502; "Bill-To Customer Name"; Text[100])
        {
            Caption = 'Bill-To Customer Name';
            Editable = false;
        }
        field(510; "Rebate Pay-To Customer No."; Code[20])
        {
            Caption = 'Rebate Pay-To Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if "Entity Type" = "Entity Type"::Customer then
                    "Entity No." := "Rebate Pay-To Customer No.";
            end;
        }
        field(565; "Commission Type"; Enum "AQD CR Commission Type")
        {
            Caption = 'Commission Type';
            InitValue = "Pay Commission";
        }
        field(570; "Applies-to Doc. Type"; Enum "Sales Applies-to Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(580; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            TableRelation = if ("Applies-to Doc. Type" = const(Invoice)) "Sales Invoice Header"."No."
            else if ("Applies-to Doc. Type" = const("Credit Memo")) "Sales Cr.Memo Header"."No."
            else if ("Applies-to Doc. Type" = const(Shipment)) "Sales Shipment Header"."No."
            else if ("Applies-to Doc. Type" = const("Return Receipt")) "Return Receipt Header"."No.";
            ValidateTableRelation = false;
        }
        field(590; "Applies-to Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Doc. Line No.';
        }
        field(7060; "Cust Rebate Posting Type"; Enum "AQD CustRebate CostPostingType")
        {
            Caption = 'Rebate Posting Type';
            InitValue = Expense;
        }
        field(7071; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            TableRelation = "AQD Marketplace";
        }
        field(9000; "Customer Rebate Category"; Code[20])
        {
            Caption = 'Customer Rebate Category';
            TableRelation = "AQD Rebate Customer Category";
        }
        field(9020; "Payment Terms Code"; Code[20])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(9050; "Line Type"; Enum "AQD Customer Rebate Line Type")
        {
            Caption = 'Line Type';
        }
        field(9060; "Rebate Payment Method Code"; Code[10])
        {
            Caption = 'Rebate Payment Method Code';
            TableRelation = "Payment Method";
        }
    }

    keys
    {
        key(Key1; "Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Batch Name", "Document No.", "Posting Date")
        {
        }
        key(Key3; "Rebate No.")
        {
        }
    }

    procedure SetUpNewLine(LastRebateJournalLine: Record "AQD Rebate Journal Line")
    var
        RebateJournalBatch: Record "AQD Rebate Journal Batch";
        RebateJournalLine: Record "AQD Rebate Journal Line";
        NoSeries: Codeunit "No. Series";
    begin
        RebateJournalLine.SetRange("Batch Name", "Batch Name");
        if not RebateJournalLine.IsEmpty() then begin
            "Posting Date" := LastRebateJournalLine."Posting Date";
            "Document Date" := LastRebateJournalLine."Document Date";
            "Document No." := LastRebateJournalLine."Document No.";
        end else begin
            "Posting Date" := WorkDate();
            "Document Date" := WorkDate();
            if RebateJournalBatch.Get("Batch Name") then
                if RebateJournalBatch."No. Series" <> '' then
                    "Document No." := NoSeries.PeekNextNo(RebateJournalBatch."No. Series", "Posting Date");
        end;
        "Entity Type" := "Entity Type"::" ";
        "Entity No." := '';
        "Cust Rebate Posting Type" := "Cust Rebate Posting Type"::Expense;
        "Commission Type" := "Commission Type"::"Pay Commission";
    end;
}
