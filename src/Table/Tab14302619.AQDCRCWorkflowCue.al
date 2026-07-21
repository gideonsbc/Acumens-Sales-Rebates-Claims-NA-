Table 14302619 "AQD CRC Workflow Cue"
{
    Caption = 'Sales Rebates Workflow Cue';
    Permissions =
    tabledata "Dimension Value" = R;
    DrillDownPageID = "AQD CRC Workflow Cue";
    LookupPageID = "AQD CRC Workflow Cue";
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Request to Approve"; Integer)
        {
            CalcFormula = count("Approval Entry" where("Table ID" = filter(Database::"AQD Sales Rebate Approvals"), "Approver ID" = field("User ID Filter"),
                                                        Status = filter(Open)));
            Caption = 'Request to Approve';
            FieldClass = FlowField;
        }

        field(30; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(40; "Global Dimension 1 Filter"; Code[80])
        {
            Caption = 'Global Dimension 1 Filter';
            CaptionClass = '1,3,1';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(50; "Global Dimension 2 Filter"; Code[80])
        {
            Caption = 'Global Dimension 2 Filter';
            CaptionClass = '1,3,2';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(60; "Salesperson Code Filter"; Code[250])
        {
            Caption = 'Salesperson Code Filter';
            FieldClass = FlowFilter;
        }
        field(70; "Location Filter"; Code[250])
        {
            Caption = 'Location Code';
            FieldClass = FlowFilter;
            TableRelation = Location where("Use As In-Transit" = const(false));
            ValidateTableRelation = false;
        }
        field(80; "Responsibility Centre Filter"; Code[250])
        {
            Caption = 'Responsibility Centre Filter';
            FieldClass = FlowFilter;
            TableRelation = Location where("Use As In-Transit" = const(false));
            ValidateTableRelation = false;
        }
        field(90; "Pending Approvals"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("AQD Sales Rebate Approvals" where("Approval Status" = filter("Pending Approval"), "Salesperson Code" = FIELD("Salesperson Code Filter"), "Location Code" = field("Location Filter"), "Responsibility Center" = field("Responsibility Centre Filter"), Posted = filter(false)));
            Caption = 'Pending Approvals';
        }
        field(100; "Fully Approved"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("AQD Sales Rebate Approvals" where("Approval Status" = filter(Approved), "Salesperson Code" = FIELD("Salesperson Code Filter"), "Location Code" = field("Location Filter"), Posted = filter(false)));
            Caption = 'Approved';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
