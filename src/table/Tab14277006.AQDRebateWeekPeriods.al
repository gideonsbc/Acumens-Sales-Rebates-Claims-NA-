table 14277006 "AQD Rebate Week Periods"
{
    Caption = 'Rebates Week Period';
    DrillDownPageId = "AQD Rebate Week Periods";
    LookupPageID = "AQD Rebate Week Periods";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "AQDEnd Date"; Date)
        {
            Caption = 'End Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                AQDName := Format("AQDEnd Date", 0, Text000);
            end;
        }
        field(14277005; AQDName; Text[50])
        {
            Caption = 'Name';
        }
        field(14277006; AQDClosed; Boolean)
        {
            Caption = 'Closed';
            Editable = true;
        }
        field(14277007; "AQDPeriod Type"; Option)
        {
            Caption = 'Period Type';
            Editable = false;
            OptionCaption = ' ,1 Week,2 Week,3 Week,4 Week,Bi-Monthly';
            OptionMembers = " ","1 Week","2 Week","3 Week","4 Week","Bi-Monthly";

            trigger OnValidate()
            begin
                if "AQDEnd Date" <> 0D then
                    AQDName := Text001 + Format(Date2DWY("AQDEnd Date", 2));
            end;
        }
        field(14277008; "AQDStart Date"; Date)
        {
            Caption = 'Start Date';
        }
    }

    keys
    {
        key(Key1; "AQDEnd Date", "AQDPeriod Type")
        {
            Clustered = true;
        }
        key(Key2; AQDClosed)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "AQDEnd Date", AQDName, AQDClosed, "AQDPeriod Type")
        {
        }
        fieldgroup(DropDown; "AQDEnd Date", AQDClosed, "AQDPeriod Type", AQDName)
        {
        }
    }

    var
        Text000: Label '<Month Text>';
        Text001: Label 'Week ';
}

