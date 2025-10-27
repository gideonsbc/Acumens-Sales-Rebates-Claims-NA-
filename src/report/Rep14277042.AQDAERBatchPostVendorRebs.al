report 14277042 "AQD Batch Post Vendor Rebates"
{
    Caption = 'Batch Post Vendor Rebates';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(AERVendorRebateHeader; "AQD Vendor Rebate Header")
        {
            RequestFilterFields = "No.", "Posting Date Filter", "Responsibility Center", "Location Code";
            trigger OnAfterGetRecord()
            begin
                VendorRebateHeader.Copy(AERVendorRebateHeader);
                VendorRebateHeader.SetRange("No.", AERVendorRebateHeader."No.");
                if StartDate <> 0D then
                    VendorRebateHeader.SetFilter("Posting Date", '>=%1', StartDate);
                if EndDate <> 0D then
                    VendorRebateHeader.SetFilter("Posting Date", '<=%1', EndDate);
                if VendorRebateHeader.FindFirst() then begin
                    if not VendorRebateHeader.Approved then
                        Error(Error002, VendorRebateHeader."No.");
                    VendorRebatePost.PostVendorRebate(VendorRebateHeader, false);
                end;
            end;
        }
    }

    // requestpage
    // {
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(Options)
    //             {
    //                 field(StartDate; StartDate)
    //                 {
    //                     Caption = 'Start Posting Date';
    //                     ApplicationArea = All;
    //                 }
    //                 field(EndDate; EndDate)
    //                 {
    //                     Caption = 'End Posting Date';
    //                     ApplicationArea = All;
    //                 }
    //             }
    //         }
    //     }
    // }
    trigger OnPreReport()
    begin
        if AERVendorRebateHeader.GetFilter("Posting Date Filter") = '' then
            Error(Error001);
        StartDate := AERVendorRebateHeader.GetRangeMin("Posting Date Filter");
        EndDate := AERVendorRebateHeader.GetRangeMax("Posting Date Filter");
    end;

    var
        StartDate: Date;
        EndDate: Date;
        VendorRebateHeader: Record "AQD Vendor Rebate Header";
        VendorRebatePost: Codeunit "AQD Vendor Rebate Post";
        Error001: Label 'Please input the Posting Date Filter';
        Error002: Label 'Please approve document #%1 before posting.';
}