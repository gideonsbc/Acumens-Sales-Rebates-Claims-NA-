report 14277044 "AQD Udt Rebate Vendor Type"
{
    ApplicationArea = All;
    Caption = 'Update Rebate Vendor Type';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
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
                    UpdateWindow(1, Vendor."No.");

                LocalRebateVendorType := '';
                LocalRebateVendorType := GetRebateVendorType();
                IF (Vendor."AQD Rebate Vendor Type" <> LocalRebateVendorType) AND
                  (LocalRebateVendorType <> '')
                THEN BEGIN
                    Vendor."AQD Rebate Vendor Type" := LocalRebateVendorType;
                    Vendor.Modify();
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
        Text001: Label 'Processing Vendor No: #1#####';

    local procedure GetRebateVendorType(): Code[20]
    var
        LocalRebateVendorTypeElig: Record "AQD RebateVendorTypeElig";
        AssignCurrentRebateVendorType: Boolean;
        LocalRebateVendorType: COde[20];
        LocalPurchAmtThreshold: Decimal;
        LastMaxPurchAmtThreshold: Decimal;
    Begin
        LocalPurchAmtThreshold := 0;
        Vendor.CalcFields("Purchases (LCY)");

        LocalRebateVendorTypeElig.Reset;
        LocalRebateVendorTypeElig.SetRange(Blocked, FALSE);
        IF LocalRebateVendorTypeElig.FindFirst() THEN Begin
            Repeat
                AssignCurrentRebateVendorType := FALSE;
                IF LocalRebateVendorTypeElig."Purchase Amount Threshold" <> 0 THEN BEGIN
                    IF LocalPurchAmtThreshold = 0 then
                        LocalPurchAmtThreshold := LocalRebateVendorTypeElig."Purchase Amount Threshold";

                    IF LastMaxPurchAmtThreshold = 0 then
                        LastMaxPurchAmtThreshold := LocalRebateVendorTypeElig."Purchase Amount Threshold";

                    IF Vendor."Purchases (LCY)" > LocalRebateVendorTypeElig."Purchase Amount Threshold" THEN BEGIN
                        IF LocalRebateVendorTypeElig."Purchase Amount Threshold" >= LastMaxPurchAmtThreshold THEN begin
                            AssignCurrentRebateVendorType := TRUE;
                            LastMaxPurchAmtThreshold := LocalRebateVendorTypeElig."Purchase Amount Threshold";
                        END;
                    END;
                END;

                // Add New Criteria checking here
                IF AssignCurrentRebateVendorType THEN
                    LocalRebateVendorType := LocalRebateVendorTypeElig."Rebate Vendor Type";

            UNTIL LocalRebateVendorTypeElig.Next() = 0;
        END;
        EXIT(LocalRebateVendorType);
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