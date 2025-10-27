tableextension 14277028 "AQD Return Shipment Header Ext" extends "Return Shipment Header"
{
    fields
    {
        field(14277004; "AQD Do Not Pay Rebate"; Boolean)
        {
            Caption = 'Do Not Pay Rebate';
            DataClassification = CustomerContent;
        }
        field(14277005; "AQD Rebate %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Rebate %';
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(14277006; "AQD Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer."No."; //WHERE("AQD Customer Type" = CONST("Rebate Customer"));
            DataClassification = CustomerContent;
        }
        field(14277007; "AQD Rebate Last Changed By"; Code[50])
        {
            Caption = 'Last Changed By';
            TableRelation = "User Setup"."User ID";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277008; "AQD Rebate LastChangd DateTime"; DateTime)
        {
            Caption = 'Last Changed Date Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14277010; "AQD Rebate No."; Code[20])
        {
            Caption = 'Rebate No.';
            DataClassification = CustomerContent;
        }
        field(14277020; "AQD Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            DataClassification = CustomerContent;
        }
        field(14277030; "AQD Vendor Rebate No"; Code[20])
        {
            Caption = 'Vendor Rebate No.';
            DataClassification = CustomerContent;
        }
        field(14277040; "AQD Rebate Order Date"; Date)
        {
            Caption = 'Rebate Order Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}