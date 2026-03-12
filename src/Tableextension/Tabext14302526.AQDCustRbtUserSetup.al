tableextension 14302526 "AQD Cust Rbt User Setup Ext" extends "User Setup"
{
    fields
    {
        field(14302510; "AQD Cust Rbt Rebate Role"; Option)
        {
            Caption = 'Rebate Role';
            OptionCaption = 'Salesperson,Sales Manager,Admin';
            OptionMembers = Salesperson,"Sales Manager",Admin;
            DataClassification = CustomerContent;
            InitValue = Admin;
            ObsoleteState = Pending;
            ObsoleteReason = 'Rebate role is moved to a new field in User Setup table.';
            ObsoleteTag = 'Removed From 25.1023.0.3';
        }
        field(14302511; "AQD Cust Rbt GlobalDim1Filter"; Code[250])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14302512; "AQD Cust Rbt GlobalDim2Filter"; Code[250])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14302513; "AQD Cust Rbt Location Filter"; Code[250])
        {
            Caption = 'Location Filter';
            TableRelation = Location;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14302514; "AQD Cust Rbt SP Code Filter"; Code[250])
        {
            Caption = 'Salesperson/Purch. Code Filter';
            TableRelation = "Salesperson/Purchaser";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14302515; "AQD Cust Rbt State Filter"; Text[250])
        {
            Caption = 'Territory Filter';
            TableRelation = Territory;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14302516; "AQD Cust Rebate Rebate Role"; Enum "AQD Cust Rebate Rebate Role")
        {
            Caption = 'Rebate Role';
            DataClassification = CustomerContent;
            InitValue = Admin;
        }
    }
}