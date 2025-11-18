tableextension 14301942 "AQD Cust Rbt User Setup Ext" extends "User Setup"
{
    fields
    {
        field(14301910; "AQD Cust Rbt Rebate Role"; Option)
        {
            Caption = 'Rebate Role';
            OptionCaption = 'Salesperson,Sales Manager,Admin';
            OptionMembers = Salesperson,"Sales Manager",Admin;
        }
        field(14301911; "AQD Cust Rbt GlobalDim1Filter"; Code[250])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = false;
        }
        field(14301912; "AQD Cust Rbt GlobalDim2Filter"; Code[250])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;
        }
        field(14301913; "AQD Cust Rbt Location Filter"; Code[250])
        {
            Caption = 'Location Filter';
            TableRelation = Location;
            ValidateTableRelation = false;
        }
        field(14301914; "AQD Cust Rbt SP Code Filter"; Code[250])
        {
            Caption = 'Salesperson/Purch. Code Filter';
            TableRelation = "Salesperson/Purchaser";
            ValidateTableRelation = false;
        }
        field(14301915; "AQD Cust Rbt State Filter"; Text[250])
        {
            Caption = 'Territory Filter';
            TableRelation = Territory;
            ValidateTableRelation = false;
        }
    }
}