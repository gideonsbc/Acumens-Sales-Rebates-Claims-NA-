table 14302616 "AQD Claim Service Codes"
{
    Caption = 'Claim Service Codes';
    DrillDownPageID = "AQD Claim Service Codes";
    LookupPageID = "AQD Claim Service Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Service Code"; Code[20])
        {
            Caption = 'Service Code';
            ToolTip = 'Specifies the value of the Claim Service Code field';
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the value of the Description field';
        }
        field(30; "ERS Indicator"; Boolean)
        {
            Caption = 'ERS Indicator';
            ToolTip = 'Specifies the value of the ERS Indicator field';
        }
        field(40; "Dealer Location Indicator"; Boolean)
        {
            Caption = 'Dealer Location Indicator';
            ToolTip = 'Specifies the value of the Dealer Location Indicator field';
        }
        field(50; "Fleet Location Indicator"; Boolean)
        {
            Caption = 'Fleet Location Indicator';
            ToolTip = 'Specifies the value of the Fleet Location Indicator field';
        }
        field(60; "Time Required"; Boolean)
        {
            Caption = 'Time Required';
            ToolTip = 'Specifies the value of the Time Required field';
        }
    }
    keys
    {
        key(PK; "Service Code")
        {
            Clustered = true;
        }
        key(SK; Description)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Service Code", Description, "ERS Indicator", "Dealer Location Indicator", "Fleet Location Indicator", "Time Required")
        {
        }
        fieldgroup(Brick; "Service Code", Description, "ERS Indicator", "Dealer Location Indicator", "Fleet Location Indicator", "Time Required")
        {
        }
    }
}
