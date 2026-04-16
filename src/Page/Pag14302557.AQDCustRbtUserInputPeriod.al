namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14302557 "AQD CustRbt User Input Period"
{
    ApplicationArea = All;
    Caption = 'User Input Period';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(StartDate; StartDate)
            {
                ApplicationArea = All;
                Caption = 'Start Date';

                trigger OnValidate()
                BEGIN
                    IF StartDate <> 0D THEN BEGIN
                        IF (EndDate <> 0D) AND
                           (EndDate < StartDate)
                        THEN
                            ERROR(StartDateLbl, StartDate, EndDate)
                    END;
                END;
            }
            field(EndDate; EndDate)
            {
                ApplicationArea = All;
                Caption = 'End Date';

                trigger OnValidate()
                BEGIN
                    IF EndDate <> 0D THEN BEGIN
                        IF (StartDate <> 0D) AND
                           (EndDate < StartDate)
                        THEN
                            ERROR(EndDateLbl, EndDate, StartDate)
                    END;
                END;
            }
            field(DeleteOldRates; DeleteOldRates)
            {
                ApplicationArea = All;
                Caption = 'Delete Old Rates';
            }
        }
    }

    procedure GetInputDate(var StartDateIn: Date; var EndDateIn: Date; var DeleteOldRatesIn: Boolean)
    BEGIN
        StartDateIn := StartDate;
        EndDateIn := EndDate;
        DeleteOldRatesIn := DeleteOldRates;
    END;

    VAR
        StartDate: Date;
        EndDate: Date;
        DeleteOldRates: Boolean;
        StartDateLbl: Label 'Start Date %1 must be less than End Date %2.';
        EndDateLbl: Label 'End Date %1 must be greater than Start Date %2.';
}
