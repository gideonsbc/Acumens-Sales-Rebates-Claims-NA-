report 14277045 "AQD Udt Rebate Customer Type"
{
    ApplicationArea = All;
    Caption = 'Update Rebate Customer Type';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.") where("AQD Enroll for Rebate" = CONST(true));
            RequestFilterFields = "No.", "Location Code", "Responsibility Center";

            trigger OnPreDataItem()
            begin
                IF NOT DoNotShowDialog THEN
                    OpenWindow(Text001);
            end;

            trigger OnAfterGetRecord()
            var
                LocalRebateVendorType: COde[20];
            begin
                IF NOT DoNotShowDialog THEN
                    UpdateWindow(1, Customer."No.");

                LocalRebateVendorType := '';
                LocalRebateVendorType := GetRebateVendorType();
                IF (Customer."AQD Rebate Customer Type" <> LocalRebateVendorType) AND
                   (LocalRebateVendorType <> '')
                THEN BEGIN
                    Customer."AQD Rebate Customer Type" := LocalRebateVendorType;
                    Customer.Modify();
                END;
            END;

            trigger OnPostDataItem()
            begin
                IF NOT DoNotShowDialog THEN
                    CloseWindow();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }
    }

    var
        DoNotShowDialog: Boolean;
        Window: Dialog;
        Text001: Label 'Processing Customer No: #1#####';

    local procedure GetRebateVendorType(): Code[20]
    var
        LocalRebateCustTypeEligibility: Record "AQD RebateCustTypeEligibility";
        AssignCurrentRebateCustomerType: Boolean;
        LocalRebateCustomerType: COde[20];
        LocalSalesAmtThreshold: Decimal;
        LastMaxSalesAmtThreshold: Decimal;
    Begin
        LocalSalesAmtThreshold := 0;
        Customer.CalcFields("Sales (LCY)");

        LocalRebateCustTypeEligibility.Reset;
        LocalRebateCustTypeEligibility.SetRange(Blocked, FALSE);
        IF LocalRebateCustTypeEligibility.FindFirst() THEN Begin
            Repeat
                AssignCurrentRebateCustomerType := FALSE;
                IF LocalRebateCustTypeEligibility."Sales Amount Threshold" <> 0 THEN BEGIN
                    IF LocalSalesAmtThreshold = 0 then
                        LocalSalesAmtThreshold := LocalRebateCustTypeEligibility."Sales Amount Threshold";

                    IF LastMaxSalesAmtThreshold = 0 then
                        LastMaxSalesAmtThreshold := LocalRebateCustTypeEligibility."Sales Amount Threshold";

                    IF Customer."Sales (LCY)" > LocalRebateCustTypeEligibility."Sales Amount Threshold" THEN BEGIN
                        IF LocalRebateCustTypeEligibility."Sales Amount Threshold" >= LastMaxSalesAmtThreshold THEN begin
                            AssignCurrentRebateCustomerType := TRUE;
                            LastMaxSalesAmtThreshold := LocalRebateCustTypeEligibility."Sales Amount Threshold";
                        END;
                    END;
                END;

                // Add New Criteria checking here
                IF AssignCurrentRebateCustomerType THEN
                    LocalRebateCustomerType := LocalRebateCustTypeEligibility."Rebate Customer Type";

            UNTIL LocalRebateCustTypeEligibility.Next() = 0;
        END;
        EXIT(LocalRebateCustomerType);
    END;

    local procedure OpenWindow(Message: Text[80])
    begin
        IF GUIALLOWED THEN
            Window.OPEN(Message);
    end;

    local procedure UpdateWindow(UpdateNumber: Integer; UpdateValue: Text[80])
    begin
        IF GUIALLOWED THEN
            Window.UPDATE(UpdateNumber, UpdateValue);
    end;

    LOCAL procedure CloseWindow()
    begin
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    procedure SetDoNotShowDialog(DoNotShowDialogIn: Boolean)
    begin
        DoNotShowDialog := DoNotShowDialogIn;
    end;
}