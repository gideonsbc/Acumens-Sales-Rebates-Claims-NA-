// report 14301912 "AQD Calculate Cust Rebate Jnl"
// {
//     Caption = 'Calculate Customer Rebate';
//     ProcessingOnly = true;
//     ApplicationArea = All;

//     dataset
//     {
//         dataitem(Customer; Customer)
//         {
//             DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("AQD Enroll for Cust Rebate" = CONST(true));

//             trigger OnAfterGetRecord()
//             begin
//                 if GuiAllowed then
//                     Window.Update(1, "No.");

//                 RebateCalculationMgt.CalVendorRebateJournal(Customer,
//                                                             StartPostingDate,
//                                                             EndPostingDate,
//                                                             RunFor);
//             end;

//             trigger OnPostDataItem()
//             begin
//                 if GuiAllowed then
//                     Window.Close;

//                 Message(Text70902);
//             end;

//             trigger OnPreDataItem()
//             begin
//                 if (StartPostingDate = 0D) or (EndPostingDate = 0D) then
//                     Error(Text70900);

//                 ApplyDefaultFilters();

//                 if SalespersonFilter <> '' then
//                     Customer.SetFilter("Salesperson Code", SalespersonFilter);

//                 if GuiAllowed then
//                     Window.Open(Text70901);

//                 Clear(RebateCalculationMgt);
//             end;
//         }
//     }

//     requestpage
//     {
//         Caption = 'Calculate Rebate';

//         layout
//         {
//             area(content)
//             {
//                 group(Options)
//                 {
//                     Caption = 'Options';
//                     field("Salesperson Filter"; SalespersonFilter)
//                     {
//                         Caption = 'Salesperson Filter';
//                         ApplicationArea = All;

//                         trigger OnLookup(var Text: Text): Boolean
//                         var
//                             SalespersonPurchaser: Record "Salesperson/Purchaser";
//                             SalespersonsPurchaserPage: Page "Salespersons/Purchasers";
//                         begin
//                             RebateUserSetup.Get(UserId);
//                             SalespersonPurchaser.Reset;
//                             SalespersonPurchaser.FilterGroup(2);
//                             SalespersonPurchaser.SetFilter(Code, RebateUserSetup."Salesperson Code Filter");
//                             SalespersonPurchaser.FilterGroup(0);

//                             Clear(SalespersonsPurchaserPage);
//                             SalespersonsPurchaserPage.SetTableView(SalespersonPurchaser);
//                             SalespersonsPurchaserPage.LookupMode(true);
//                             if SalespersonsPurchaserPage.RunModal = ACTION::LookupOK then
//                                 SalespersonFilter := SalespersonsPurchaserPage.GetSelectionFilter()
//                             else
//                                 SalespersonFilter := '';
//                         end;
//                     }
//                     field(DateSelection; DateSelection)
//                     {
//                         Caption = 'Date Selection';
//                         ShowMandatory = true;
//                         ApplicationArea = All;

//                         trigger OnValidate()
//                         begin
//                             SetEditableFields();
//                         end;
//                     }
//                     field(PeriodType; PeriodType)
//                     {
//                         Caption = 'Period Type';
//                         Editable = PeriodTypeEditable;
//                         ShowMandatory = true;
//                         ApplicationArea = All;

//                         trigger OnValidate()
//                         begin
//                             SetEditableFields();
//                         end;
//                     }
//                     field("Start Posting Date"; StartPostingDate)
//                     {
//                         ApplicationArea = Manufacturing;
//                         Caption = 'Start Posting Date';
//                         Editable = DateFieldsEditable;
//                         ShowMandatory = true;
//                         ToolTip = 'Specifies the date you want the program to calculate the quantity of the BOM lines.';
//                     }
//                     field("End Posting Date"; EndPostingDate)
//                     {
//                         ApplicationArea = Manufacturing;
//                         Caption = 'End Posting Date';
//                         Editable = DateFieldsEditable;
//                         ShowMandatory = true;
//                         ToolTip = 'Specifies the date you want the program to calculate the quantity of the BOM lines.';
//                     }
//                     field("Run For"; RunFor)
//                     {
//                         Caption = 'Run For';
//                         Editable = NOT RunForNonEditable;
//                         Enabled = NOT RunForNonEditable;
//                         ApplicationArea = All;

//                         trigger OnValidate()
//                         begin
//                             if RunFor = RunFor::Review then
//                                 StartPostingDateVisible := true
//                             else
//                                 StartPostingDateVisible := false;
//                         end;
//                     }
//                 }
//             }
//         }

//         actions
//         {
//         }

//         trigger OnOpenPage()
//         begin
//             RebateUserSetup.Get(UserId);
//             StartPostingDateVisible := false;
//             ApplyDefaultFilters();
//             if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then begin
//                 RunFor := RunFor::Review;
//                 RunForNonEditable := true;
//                 StartPostingDateVisible := true;
//             end else
//                 RunFor := RunFor::Process;
//             RequestPageExecuted := true;

//             DateSelection := DateSelection::Custom;
//             SetEditableFields();
//         end;

//         trigger OnQueryClosePage(CloseAction: Action): Boolean
//         begin
//             if CloseAction in [ACTION::OK, ACTION::LookupOK] then
//                 ValidateSelectedOptions();
//         end;
//     }

//     labels
//     {
//     }

//     trigger OnPreReport()
//     begin
//         if RebateUserSetup."User ID" <> UserId then
//             RebateUserSetup.Get(UserId);
//         if not RequestPageExecuted then begin
//             ApplyDefaultFilters();
//             if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then begin
//                 RunFor := RunFor::Review;
//                 RunForNonEditable := true;
//             end else
//                 RunFor := RunFor::Process;
//         end;
//     end;

//     var
//         RebateUserSetup: Record "AQD Customer Rebate User Setup";
//         RebateCalculationMgt: Codeunit "AQD Cust Rebate Calc Mgt";
//         Text70900: Label 'Please Fill in Start Posting Date and End Posting Date';
//         Text70901: Label 'Salesperson Code. #1########';
//         Text70902: Label 'Rebate Journal is calculated.';
//         RequestPageExecuted: Boolean;

//         RunForNonEditable: Boolean;
//         StartPostingDate: Date;
//         EndPostingDate: Date;
//         Window: Dialog;
//         RunFor: Option Review,Process;
//         SalespersonFilter: Code[250];
//         RebateType: Option " ",Vendor,Customer;
//         DateSelection: Option "  ",Period,Custom;
//         PeriodType: Option "  ",Weekly,Monthly;
//         Err0001: Label 'Date selection field cannot be blank';
//         Err0002: Label 'If date selection is %1 then Period Type not be blank';

//         DateFieldsEditable: Boolean;

//         PeriodTypeEditable: Boolean;

//         StartPostingDateVisible: Boolean;
//         SelectedPeriod: Date;

//     local procedure ApplyDefaultFilters()
//     begin
//         Customer.FilterGroup(2);
//         if RebateUserSetup."Rebate Role" = RebateUserSetup."Rebate Role"::Salesperson then
//             RebateUserSetup.TestField("Salesperson Code Filter");
//         if RebateUserSetup."Salesperson Code Filter" <> '' then
//             Customer.SetFilter("Salesperson Code", RebateUserSetup."Salesperson Code Filter");
//         if RebateUserSetup."Global Dimension 1 Filter" <> '' then
//             Customer.SetFilter("Global Dimension 1 Code", RebateUserSetup."Global Dimension 1 Filter");
//         if RebateUserSetup."Global Dimension 2 Filter" <> '' then
//             Customer.SetFilter("Global Dimension 2 Code", RebateUserSetup."Global Dimension 2 Filter");
//         if RebateUserSetup."Location Filter" <> '' then
//             Customer.SetFilter("Location Code", RebateUserSetup."Location Filter");
//         if RebateUserSetup."State Filter" <> '' then
//             Customer.SetFilter(County, RebateUserSetup."State Filter");
//         Customer.FilterGroup(0);
//     end;

//     local procedure ValidateSelectedOptions()
//     begin
//         if DateSelection = DateSelection::"  " then
//             Error(Err0001);

//         if (DateSelection = DateSelection::Period) and (PeriodType = PeriodType::"  ") then
//             Error(Err0002, Format(DateSelection::Period));
//     end;

//     local procedure SetEditableFields()
//     begin
//         if DateSelection = DateSelection::Period then begin
//             DateFieldsEditable := false;
//             PeriodTypeEditable := true;
//             StartPostingDate := 0D;
//             EndPostingDate := 0D;
//         end else
//             if DateSelection = DateSelection::Custom then begin
//                 DateFieldsEditable := true;
//                 PeriodTypeEditable := false;
//                 StartPostingDate := 0D;
//                 EndPostingDate := 0D;
//                 PeriodType := PeriodType::"  ";
//                 SelectedPeriod := 0D;
//             end else begin
//                 DateFieldsEditable := false;
//                 PeriodTypeEditable := false;
//                 StartPostingDate := 0D;
//                 EndPostingDate := 0D;
//                 PeriodType := PeriodType::"  ";
//                 SelectedPeriod := 0D;
//             end;
//     end;
// }