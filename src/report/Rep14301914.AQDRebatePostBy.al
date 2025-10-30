report 14301914 "AQD Cust Rebate Post By"
{
    Caption = 'Customer Rebate Post By';
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
    }

    requestpage
    {
        Caption = 'Rebate Posting Summary';

        layout
        {
            area(content)
            {
                group("Post Rebate Summary By")
                {
                    Caption = 'Post Rebate Summary By';
                    field("Rebate Type"; SummaryByRebateType)
                    {
                        Caption = 'Rebate Type';
                        ApplicationArea = All;
                    }
                    field("Rebate Code"; SummaryByRebateCode)
                    {
                        Caption = 'Rebate Code';
                        ApplicationArea = All;
                    }
                    field(Location; SummayByLocation)
                    {
                        Caption = 'Location';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            SetDisableSummaryByDocNo();
                        end;
                    }
                    field(State; SummayByCounty)
                    {
                        Caption = 'State';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            SetDisableSummaryByDocNo();
                        end;
                    }
                    field(SummayByGlobalDim1; SummayByGlobalDim1)
                    {
                        CaptionClass = '1,2,1';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            SetDisableSummaryByDocNo();
                        end;
                    }
                    field(SummayByGlobalDim2; SummayByGlobalDim2)
                    {
                        CaptionClass = '1,2,2';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            SetDisableSummaryByDocNo();
                        end;
                    }
                    field(SummaryByDocNo; SummaryByDocNo)
                    {
                        Caption = 'Document No.';
                        Enabled = EnableSummaryByDocNo;
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            EnableSummaryByDocNo := true;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction in [ACTION::OK, ACTION::LookupOK] then
                PressOk := true
            else
                PressOk := false;
        end;
    }

    labels
    {
    }

    var
        SummaryByRebateType: Boolean;
        SummaryByRebateCode: Boolean;
        SummayByLocation: Boolean;
        SummayByCounty: Boolean;
        SummayByGlobalDim1: Boolean;
        SummayByGlobalDim2: Boolean;
        SummaryByDocNo: Boolean;

        EnableSummaryByDocNo: Boolean;
        PressOk: Boolean;


    procedure GetSummaryByInfo(var SummaryByRebateTypeIn: Boolean; var SummaryByRebateCodeIn: Boolean; var SummayByLocationIn: Boolean; var SummayByCountyIn: Boolean; var SummayByGlobalDim1In: Boolean; var SummayByGlobalDim2In: Boolean; var SummaryByDocNoIn: Boolean)
    begin
        SummaryByRebateTypeIn := SummaryByRebateType;
        SummaryByRebateCodeIn := SummaryByRebateCode;
        SummayByLocationIn := SummayByLocation;
        SummayByCountyIn := SummayByCounty;
        SummayByGlobalDim1In := SummayByGlobalDim1;
        SummayByGlobalDim2In := SummayByGlobalDim2;
        SummaryByDocNoIn := SummaryByDocNo;
    end;

    local procedure SetDisableSummaryByDocNo()
    begin
        if not (SummayByLocation or SummayByCounty or SummayByGlobalDim1 or SummayByGlobalDim2) then
            EnableSummaryByDocNo := true
        else begin
            EnableSummaryByDocNo := false;
            SummaryByDocNo := false;
        end;
    end;


    procedure GetActionResult(): Boolean
    begin
        exit(PressOk);
    end;
}

