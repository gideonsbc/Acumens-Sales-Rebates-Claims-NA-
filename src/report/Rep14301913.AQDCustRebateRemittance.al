report 14301915 "AQD Cust Rebate Remittance"
{
    ApplicationArea = All;
    //     DefaultLayout = RDLC;
    //     RDLCLayout = './src/Layout/Rep14277010.AQDRebateRemittance.rdl';
    //     Caption = 'Rebate Remittance Report';
    //     PreviewMode = PrintLayout;
    //     ApplicationArea = All;

    //     dataset
    //     {
    //         dataitem("Gen. Journal Line"; "Gen. Journal Line")
    //         {
    //             DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");

    //             trigger OnAfterGetRecord()
    //             begin
    //                 if ("Applies-to Doc. No." = '') and ("Applies-to ID" = '') then
    //                     CurrReport.Skip;

    //                 TestField("Check Printed", true);

    //                 InvoiceVendorLedgerEntry.Reset;
    //                 if "Applies-to Doc. No." <> '' then begin
    //                     InvoiceVendorLedgerEntry.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open, Positive);
    //                     InvoiceVendorLedgerEntry.SetRange("Vendor No.", "Account No.");
    //                     InvoiceVendorLedgerEntry.SetRange("Document Type", InvoiceVendorLedgerEntry."Document Type"::Invoice);
    //                     InvoiceVendorLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
    //                 end else begin
    //                     InvoiceVendorLedgerEntry.SetCurrentKey("Vendor No.", Open, Positive);
    //                     InvoiceVendorLedgerEntry.SetRange("Vendor No.", "Account No.");
    //                     InvoiceVendorLedgerEntry.SetRange("Applies-to ID", "Applies-to ID");
    //                 end;
    //                 InvoiceVendorLedgerEntry.SetRange(Open, true);
    //                 if not InvoiceVendorLedgerEntry.FindFirst then
    //                     CurrReport.Skip;

    //                 repeat
    //                     //RebateRegister.Get(InvoiceVendorLedgerEntry."AQD Cust Rebate Register No.");

    //                     RebateDocSummary.Reset;
    //                     RebateDocSummary.SetCurrentKey("Rebate Register No.", "Vendor Ledger Entry No.");
    //                     RebateDocSummary.SetRange("Rebate Register No.", InvoiceVendorLedgerEntry."AQD Cust Rebate Register No.");
    //                     RebateDocSummary.SetRange("Vendor Ledger Entry No.", InvoiceVendorLedgerEntry."Entry No.");
    //                     if RebateDocSummary.FindFirst then begin
    //                         repeat
    //                             TmpRebateDocSummary.Init;
    //                             TmpRebateDocSummary := RebateDocSummary;
    //                             TmpRebateDocSummary."Check No." := "Document No.";
    //                             //TmpRebateDocSummary."Order Date" := RebateRegister."AQD Start Date";
    //                             //TmpRebateDocSummary."Rebate Approved Date" := RebateRegister."AQD End Date";
    //                             if TmpRebateDocSummary.Insert then;
    //                         until RebateDocSummary.Next = 0;
    //                     end;
    //                 until InvoiceVendorLedgerEntry.Next = 0;
    //             end;

    //             trigger OnPreDataItem()
    //             begin
    //                 TmpRebateDocSummary.Reset;
    //                 if TmpRebateDocSummary.IsTemporary then
    //                     TmpRebateDocSummary.DeleteAll;

    //                 if ReportRunFrom <> ReportRunFrom::"Payment Journal" then
    //                     CurrReport.Break;

    //                 SetRange("AQD Cust Rebate Journal", true);
    //                 SetRange("Document Type", "Document Type"::Payment);
    //             end;
    //         }
    //         // dataitem("AQD Rebate Register"; "AQD Customer Rebate Register")
    //         // {
    //         //     DataItemTableView = SORTING("AQD Entry No.");

    //         //     trigger OnAfterGetRecord()
    //         //     begin
    //         //         CalcFields("AQD Status");
    //         //         TestField("AQD Status", "AQD Status"::Paid);

    //         //         RebateDocSummary.Reset;
    //         //         RebateDocSummary.SetRange("Rebate Register No.", "AQD Entry No.");
    //         //         if RebateDocSummary.FindFirst then begin
    //         //             repeat
    //         //                 TmpRebateDocSummary.Init;
    //         //                 TmpRebateDocSummary := RebateDocSummary;
    //         //                 TmpRebateDocSummary."Check No." := "AQD Payment Ref. No.";
    //         //                 TmpRebateDocSummary."Order Date" := "AQD Start Date";
    //         //                 TmpRebateDocSummary."Rebate Approved Date" := "AQD End Date";
    //         //                 if TmpRebateDocSummary.Insert then;
    //         //             until RebateDocSummary.Next = 0;
    //         //         end;
    //         //     end;

    //         //     trigger OnPreDataItem()
    //         //     begin
    //         //         if ReportRunFrom <> ReportRunFrom::"Rebate Register" then
    //         //             CurrReport.Break;

    //         //         TmpRebateDocSummary.Reset;
    //         //         if TmpRebateDocSummary.IsTemporary then
    //         //             TmpRebateDocSummary.DeleteAll;
    //         //     end;
    //         // }
    //         dataitem(PrintRebateDocEntry; "Integer")
    //         {
    //             DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
    //             column(Name_CompanyInformation; CompanyInformation.Name)
    //             {
    //             }
    //             column(CompanyAddress1; CompanyAddress[1])
    //             {
    //             }
    //             column(CompanyAddress2; CompanyAddress[2])
    //             {
    //             }
    //             column(CompanyAddress3; CompanyAddress[3])
    //             {
    //             }
    //             column(CompanyAddress4; CompanyAddress[4])
    //             {
    //             }
    //             column(CompanyAddress5; CompanyAddress[5])
    //             {
    //             }
    //             column(CompanyAddress6; CompanyAddress[6])
    //             {
    //             }
    //             column(CompanyAddress7; CompanyAddress[7])
    //             {
    //             }
    //             column(CompanyAddress8; CompanyAddress[8])
    //             {
    //             }
    //             column(VendorAddress1; VendorAddress[1])
    //             {
    //             }
    //             column(VendorAddress2; VendorAddress[2])
    //             {
    //             }
    //             column(VendorAddress3; VendorAddress[3])
    //             {
    //             }
    //             column(VendorAddress4; VendorAddress[4])
    //             {
    //             }
    //             column(VendorAddress5; VendorAddress[5])
    //             {
    //             }
    //             column(VendorAddress6; VendorAddress[6])
    //             {
    //             }
    //             column(VendorAddress7; VendorAddress[7])
    //             {
    //             }
    //             column(VendorAddress8; VendorAddress[8])
    //             {
    //             }
    //             column(ListOfInvoiceText; ListOfInvoiceText)
    //             {
    //             }
    //             column(CheckDetailText; CheckDetailsText)
    //             {
    //             }
    //             column(No_Vendor; Vendor."No.")
    //             {
    //             }
    //             column(Name_Vendor; Vendor.Name)
    //             {
    //             }
    //             column(SalespersonCode_RebateDocLdgrEntry; TmpRebateDocSummary."Rebate Code")
    //             {
    //             }
    //             column(CheckNo_RebateDocLdgrEntry; TmpRebateDocSummary."Check No.")
    //             {
    //             }
    //             column(DocType_RebateDocLdgrEntry; Format(TmpRebateDocSummary."Document Type"))
    //             {
    //             }
    //             column(DocumentNo_RebateDocLdgrEntry; TmpRebateDocSummary."Document No.")
    //             {
    //             }
    //             column(CustomerNo_RebateDocLdgrEntry; TmpRebateDocSummary."Sell-to Customer No.")
    //             {
    //             }
    //             column(CustomerName_RebateDocLdgrEntry; TmpRebateDocSummary."Sell-to Customer Name")
    //             {
    //             }
    //             column(DocumentAmount_RebateDocLdgrEntry; TmpRebateDocSummary."Document Amount")
    //             {
    //             }
    //             column(RebateReceived_RebateDocLdgrEntry; TmpRebateDocSummary."Rebate Amount")
    //             {
    //             }

    //             trigger OnAfterGetRecord()
    //             begin
    //                 if Number = 1 then begin
    //                     if not TmpRebateDocSummary.FindFirst then
    //                         CurrReport.Break;
    //                 end else begin
    //                     if TmpRebateDocSummary.Next = 0 then
    //                         CurrReport.Break;
    //                 end;

    //                 Customer.Get(TmpRebateDocSummary."Bill-to Customer No.");

    //                 CheckDetailsText := StrSubstNo(Text0002, TmpRebateDocSummary."Check No.");
    //                 ListOfInvoiceText := StrSubstNo(Text0001, TmpRebateDocSummary."Order Date", TmpRebateDocSummary."Rebate Approved Date");

    //                 TmpRebateDocSummary.CalcFields("Rebate Amount");

    //                 if TmpRebateDocSummary."Rebate Type" = TmpRebateDocSummary."Rebate Type"::Vendor then begin
    //                     if not Vendor.Get(TmpRebateDocSummary."Rebate Code") then
    //                         Vendor.Init;
    //                     NameToPriint := Vendor.Name;
    //                     FormatAddress.Vendor(VendorAddress, Vendor);
    //                 end else
    //                     if TmpRebateDocSummary."Rebate Type" = TmpRebateDocSummary."Rebate Type"::Customer then begin
    //                         if not Customer.Get(TmpRebateDocSummary."Rebate Code") then
    //                             Customer.Init;
    //                         NameToPriint := Customer.Name;
    //                         FormatAddress.Customer(VendorAddress, Customer);
    //                     end;

    //                 CompressArray(VendorAddress);
    //                 VendorAddress[1] := TmpRebateDocSummary."Rebate Code" + ' - ' + NameToPriint;
    //                 CompressArray(VendorAddress);
    //             end;

    //             trigger OnPreDataItem()
    //             begin
    //                 if ReportRunFrom = ReportRunFrom::" " then
    //                     CurrReport.Break;

    //                 TmpRebateDocSummary.Reset;
    //                 SetRange(Number, 1, TmpRebateDocSummary.Count);
    //             end;
    //         }
    //     }

    //     requestpage
    //     {

    //         layout
    //         {
    //         }

    //         actions
    //         {
    //         }
    //     }

    //     labels
    //     {
    //         CustomerNoLbl = 'Customer No.';
    //         TypeLbl = 'Type';
    //         DocumentNoLbl = 'Document No.';
    //         CustomerNameLbl = 'Customer Name';
    //         InvoiceAmountLbl = 'Invoice Amount';
    //         RebateAmountLbl = 'Rebate Amount';
    //         ReportNameLbl = 'Rebate Remittance Report';
    //         TotalForLbl = 'Total For';
    //         AdjustmentCaptionLbl = 'Adjustments';
    //     }

    //     trigger OnPreReport()
    //     begin
    //         CompanyInformation.Get;
    //         FormatAddress.Company(CompanyAddress, CompanyInformation)
    //     end;

    //     var
    //         CompanyInformation: Record "Company Information";
    //         Vendor: Record Vendor;
    //         Customer: Record Customer;
    //         InvoiceVendorLedgerEntry: Record "Vendor Ledger Entry";
    //         //RebateRegister: Record "AQD Customer Rebate Register";
    //         RebateDocSummary: Record "AQD Cust Rebate Document Entry";
    //         TmpRebateDocSummary: Record "AQD Cust Rebate Document Entry" temporary;
    //         FormatAddress: Codeunit "Format Address";
    //         PaymentRefNo: Code[20];
    //         BegPostingDate: Date;
    //         EndPostingDate: Date;
    //         VendorAddress: array[8] of Text[50];
    //         CompanyAddress: array[8] of Text[50];
    //         Text0001: Label 'The following is a list of invoices paid included in your Rebate statement for the period from %1 to %2.';
    //         ListOfInvoiceText: Text[250];
    //         CheckDetailsText: Text[250];
    //         Text0002: Label 'Enclosed is check # %1';
    //         NameToPriint: Text[100];
    //         ReportRunFrom: Option " ","Payment Journal","Rebate Register";


    //     procedure SetReportRunFrom(ReportRunFromIn: Option " ","Payment Journal","Rebate Register")
    //     begin
    //         ReportRunFrom := ReportRunFromIn;
    //     end;
}

