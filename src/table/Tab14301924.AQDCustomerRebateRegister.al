// table 14301924 "AQD Customer Rebate Register"
// {
//     Caption = 'Customer Rebate Register';
//     DrillDownPageID = "AQD Customer Rebate Register";
//     LookupPageID = "AQD Customer Rebate Register";
//     DataClassification = CustomerContent;

//     fields
//     {
//         field(1; "AQD Entry No."; Integer)
//         {
//             Caption = 'Entry No.';
//         }
//         field(20; "AQD Rebate Type"; Option)
//         {
//             Caption = 'Pay-To Rebate Type';
//             Editable = false;
//             OptionCaption = ' ,Vendor,Customer';
//             OptionMembers = " ",Vendor,Customer;
//         }
//         field(30; "AQD Rebate Code"; Code[20])
//         {
//             Caption = 'Rebate Code';
//         }
//         field(40; "AQD Location Code"; Code[10])
//         {
//             Caption = 'Location Code';
//             TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
//         }
//         field(50; "AQD Shortcut Dimension 1 Code"; Code[20])
//         {
//             CaptionClass = '1,2,1';
//             Caption = 'Shortcut Dimension 1 Code';
//             TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
//         }
//         field(60; "AQD Shortcut Dimension 2 Code"; Code[20])
//         {
//             CaptionClass = '1,2,2';
//             Caption = 'Shortcut Dimension 2 Code';
//             TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
//         }
//         field(70; "AQD State"; Text[30])
//         {
//             Caption = 'State';
//         }
//         field(80; "AQD Document Type"; Enum "AQD Cust Rebate Document Type")
//         {
//             Caption = 'Document Type';
//             Editable = false;
//         }
//         field(90; "AQDDocument No."; Code[20])
//         {
//             Caption = 'Document No.';
//             TableRelation = IF ("AQD Document Type" = CONST(Invoice)) "Sales Invoice Header"."No."
//             ELSE
//             IF ("AQD Document Type" = CONST("Credit Memo")) "Sales Cr.Memo Header"."No.";
//         }
//         field(100; "AQD Payee Type"; Option)
//         {
//             Caption = 'Payee Type';
//             InitValue = "W2 Employee";
//             OptionCaption = ' ,1099 Vendor,W2 Employee';
//             OptionMembers = " ","1099 Vendor","W2 Employee";
//         }
//         field(110; "AQD External Document No."; Code[35])
//         {
//             Caption = 'External Document No.';
//         }
//         field(120; "AQD Payment Date"; Date)
//         {
//             Caption = 'Payment Date';
//         }
//         field(130; "AQD Payment Ref. No."; Code[20])
//         {
//             Caption = 'Payment Ref. No';
//         }
//         field(140; "AQD Start Date"; Date)
//         {
//             Caption = 'Start Date';
//         }
//         field(150; "AQD End Date"; Date)
//         {
//             Caption = 'End Date';
//         }
//         field(160; "AQD Base Amount"; Decimal)
//         {
//             BlankZero = true;
//             CalcFormula = Sum("AQD Customer Rebate Entry"."Base Amount" WHERE("Rebate Register No." = FIELD("AQD Entry No.")));
//             Caption = 'Base Amount';
//             Editable = false;
//             FieldClass = FlowField;
//         }
//         field(170; "AQD Rebate Amount"; Decimal)
//         {
//             AutoFormatType = 1;
//             BlankZero = true;
//             CalcFormula = Sum("AQD Customer Rebate Entry"."Rebate Amount" WHERE("Rebate Register No." = FIELD("AQD Entry No.")));
//             Caption = 'Rebate Amount';
//             Editable = false;
//             FieldClass = FlowField;
//         }
//         field(180; "AQD Profit Amount"; Decimal)
//         {
//             BlankZero = true;
//             CalcFormula = Sum("AQD Customer Rebate Entry"."Profit Amount" WHERE("Rebate Register No." = FIELD("AQD Entry No.")));
//             Caption = 'Profit Amount';
//             Editable = false;
//             FieldClass = FlowField;
//         }
//         field(190; "AQD Batch Name"; Code[50])
//         {
//             Caption = 'Batch Name';
//         }
//         field(200; "AQD Creation DateTime"; DateTime)
//         {
//             Caption = 'Creation DateTime';
//             Editable = false;
//         }
//         field(210; "AQD Created By User ID"; Code[50])
//         {
//             Caption = 'Created By User ID';
//             Editable = false;
//             TableRelation = User."User Name";
//         }
//         field(220; "AQD Status"; Option)
//         {
//             CalcFormula = Min("AQD Cust Rebate Document Entry"."Payment Status" WHERE("Rebate Register No." = FIELD("AQD Entry No.")));
//             Caption = 'Status';
//             Editable = false;
//             FieldClass = FlowField;
//             OptionCaption = ' ,Approved,Journal,Posted,Paid';
//             OptionMembers = " ",Approved,Journal,Posted,Paid;
//         }
//         field(230; "AQD Voided"; Boolean)
//         {
//             Caption = 'Voided';
//             Editable = false;
//         }
//         field(240; "AQD Voided DateTime"; DateTime)
//         {
//             Caption = 'Voided DateTime';
//             Editable = false;
//         }
//         field(250; "AQD Voided By User ID"; Code[50])
//         {
//             Caption = 'Voided By User ID';
//             Editable = false;
//             TableRelation = User."User Name";
//         }
//     }
//     keys
//     {
//         key(Key1; "AQD Entry No.")
//         {
//             Clustered = true;
//         }
//     }
//     fieldgroups
//     {
//     }
// }