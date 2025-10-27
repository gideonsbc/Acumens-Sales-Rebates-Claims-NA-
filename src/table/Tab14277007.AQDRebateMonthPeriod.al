table 14277007 "AQD Rebate Month Period"
{
    Caption = 'Rebates Month Period';
    DrillDownPageID = "AQD Rebate Month Period";
    LookupPageID = "AQD Rebate Month Period";
    DataClassification = CustomerContent;

    fields
    {
        field(14277004; "AQDEnding Date"; Date)
        {
            Caption = 'Ending Date';
            NotBlank = true;

            trigger OnValidate()
            begin
                AQDName := Format("AQDEnding Date", 0, Text000);
            end;
        }
        field(14277005; AQDName; Text[20])
        {
            Caption = 'Name';
        }
        field(14277006; AQDClosed; Boolean)
        {
            Caption = 'Closed';
            Editable = false;
        }
        field(14277007; "AQDPeriod Type"; Option)
        {
            Editable = false;
            OptionCaption = ' ,Monthly,Weekly';
            OptionMembers = " ",Monthly,Weekly;

            trigger OnValidate()
            begin
                AQDName := Text001 + Format(Date2DWY("AQDEnding Date", 2));
            end;
        }
    }

    keys
    {
        key(Key1; "AQDEnding Date")
        {
            Clustered = true;
        }
        key(Key2; AQDName, AQDClosed, "AQDPeriod Type")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "AQDEnding Date", AQDName, AQDClosed)
        {
        }
    }

    var
        Text000: Label '<Month Text>';
        Text001: Label 'Week ';
}

