Page 14302640 "AQD CRC Workflow Cue"
{
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "AQD CRC Workflow Cue";
    ApplicationArea = All;
    Caption = 'Sales Rebates Workflow Cues';

    layout
    {
        area(content)
        {
            cuegroup("Sales Rebates Cues")
            {
                ShowCaption = false;
                field(RequesttoApprove; Rec."Request to Approve")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Requests to Approve";
                    ToolTip = 'Specifies the value of the Request to Approve field.';
                }
                field(PendingApprovals; Rec."Pending Approvals")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "AQD Sales Rebate Approvals";
                    ToolTip = 'Specifies the value of the Pending Approvals field.';
                }
                field("Fully Approved"; Rec."Fully Approved")
                {
                    ApplicationArea = All;
                    Caption = 'Fully Approved';
                    DrillDownPageID = "AQD Sales Rebate Approvals";
                    Style = Favorable;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Fully Approved field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetRange(Rec."User ID Filter", UserId);

        ApplyUserFilters();
    end;

    procedure ApplyUserFilters()
    var
        UserSetup: Record "User Setup";
        LocFilterString: Code[80];
        SalespersonCodeFilter: Code[1024];
    begin

        UserSetup.Get(UserId);

        Clear(SalespersonCodeFilter);
        Clear(LocFilterString);

        Rec.FilterGroup(3);

        if UserSetup."AQD Acumens Management Role" <> UserSetup."AQD Acumens Management Role"::Admin then begin
            case UserSetup."AQD Acumens Management Role" of
                UserSetup."AQD Acumens Management Role"::"Sales Team Manager":
                    begin
                        SalespersonCodeFilter := GetSalesPersonFilter();//Get Sales Person Filter string
                        if SalespersonCodeFilter = '' then// Use Sales Person filter on User setup if it not set on salesperson page
                          begin
                            UserSetup.TestField("AQD Acumens SalesPerson Filter");
                            SalespersonCodeFilter := UserSetup."AQD Acumens SalesPerson Filter";
                        end;

                        Rec.SetFilter(Rec."Salesperson Code Filter", SalespersonCodeFilter);
                    end;

                UserSetup."AQD Acumens Management Role"::"Sales Person":
                    begin
                        UserSetup.TestField("AQD Acumens SalesPerson Filter");
                        Rec.SetFilter(Rec."Salesperson Code Filter", UserSetup."AQD Acumens SalesPerson Filter");
                    end;

                UserSetup."AQD Acumens Management Role"::Location:
                    begin
                        UserSetup.TestField("AQD Acumens Location Filter");
                        LocFilterString := GetLocationFilter();
                        //Get Location Filter
                        Rec.SetFilter(Rec."Location Filter", LocFilterString);
                    end;

                UserSetup."AQD Acumens Management Role"::"Responsibility Center":
                    begin
                        UserSetup.TestField("AQD Acumens Resp. Ctr. Filter");
                        Rec.SetFilter(Rec."Responsibility Centre Filter", UserSetup."AQD Acumens Resp. Ctr. Filter");
                    end;

                UserSetup."AQD Acumens Management Role"::"Dimension 1":
                    begin
                        UserSetup.TestField("AQD Acumens Dim. 1 Filter");
                        Rec.SetFilter(Rec."Global Dimension 1 Filter", UserSetup."AQD Acumens Dim. 1 Filter");
                    end;

                UserSetup."AQD Acumens Management Role"::"Dimension 2":
                    begin
                        UserSetup.TestField("AQD Acumens Dim. 2 Filter");
                        Rec.SetFilter(Rec."Global Dimension 2 Filter", UserSetup."AQD Acumens Dim. 2 Filter");
                    end;
            end;

            Rec.FilterGroup(0);//Filter Group
        end;
    end;

    procedure GetLocationFilter(): Text[250]
    var
        UserSetup: Record "User Setup";
        Location: Record Location;
        LocFilterString: Text[250];
    begin
        UserSetup.Get(UserId);

        if UserSetup."AQD Acumens Location Filter" = '' then
            exit('');

        Clear(LocFilterString);

        Location.Reset();
        Location.SetFilter(Code, UserSetup."AQD Acumens Location Filter");
        if Location.FindFirst() then
            repeat
                if StrLen(LocFilterString + '|' + Location.Code) <= MaxStrLen(LocFilterString) then begin
                    if LocFilterString <> '' then
                        LocFilterString := LocFilterString + '|';
                    LocFilterString := LocFilterString + Location.Code;
                end;
            until Location.Next() = 0;

        if LocFilterString = '' then
            LocFilterString := '''''';

        exit(LocFilterString);
    end;

    procedure GetSalesPersonFilter(): Code[1024]
    var
        UserSetup: Record "User Setup";
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonFilter: Code[1024];
    begin
        UserSetup.Get(UserId);
        Clear(SalespersonFilter);

        Salesperson.Reset();
        Salesperson.SetFilter("AQD Acumens Sales Team Manager", UserId);
        if Salesperson.FindFirst() then
            repeat
                if StrLen(SalespersonFilter + '|' + Salesperson.Code) <= MaxStrLen(SalespersonFilter) then begin
                    if SalespersonFilter <> '' then
                        SalespersonFilter := SalespersonFilter + '|';
                    SalespersonFilter := SalespersonFilter + Salesperson.Code;
                end;
            until Salesperson.Next() = 0;

        exit(SalespersonFilter);
    end;
}
