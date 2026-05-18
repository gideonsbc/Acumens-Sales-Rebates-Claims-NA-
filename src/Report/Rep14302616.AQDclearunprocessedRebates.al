report 14302616 "AQD Clear unprocessed Rebates"
{
    Caption = 'Clear unprocessed rebates';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    // requestpage
    // {
    //     AboutTitle = 'Teaching tip title';
    //     AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(Name; SourceExpression)
    //                 {

    //                 }
    //             }
    //         }
    //     }

    //     actions
    //     {
    //         area(processing)
    //         {
    //             action(LayoutName)
    //             {

    //             }
    //         }
    //     }
    // }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = Excel;
    //         LayoutFile = 'mySpreadsheet.xlsx';
    //     }
    // }
    trigger OnPreReport()
    begin
        CustomerRebateDetails.RESET;
        CustomerRebateDetails.DeleteAll();

        CustomerRebateDetails.Reset();
        CustomerRebateLine.DeleteAll();

        CustomerRebatecomments.Reset();
        CustomerRebatecomments.DeleteAll();

        CustomerRebateHeader.Reset();
        CustomerRebateHeader.DeleteAll();
    end;

    var
        CustomerRebateLine: Record "AQD Customer Rebate Line";
        CustomerRebateDetails: Record "AQD Customer Rebate Details";
        CustomerRebatecomments: Record "AQD Customer Rebate Comments";
        CustomerRebateHeader: Record "AQD Customer Rebate Header";

}