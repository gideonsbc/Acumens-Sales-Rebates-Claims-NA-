namespace AcumenseCustomerRebatesAndClaims.AcumenseCustomerRebatesAndClaims;

page 14301957 "AQD CustRbt User Input Period"
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
        }
    }

    procedure GetInputDate(var StartDateIn: Date; var EndDateIn: Date)
    BEGIN
        StartDateIn := StartDate;
        EndDateIn := EndDate;
    END;

    VAR
        StartDate: Date;
        EndDate: Date;
        StartDateLbl: Label 'Start Date %1 must be less than End Date %2.';
        EndDateLbl: Label 'End Date %1 must be greater than Start Date %2.';
}
