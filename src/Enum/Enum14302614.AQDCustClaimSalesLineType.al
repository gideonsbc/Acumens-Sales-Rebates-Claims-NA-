enum 14302614 "AQD Cust Claim Sales Line Type"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ' '; }
    value(1; "G/L Account") { Caption = 'G/L Account'; }
    value(2; "") { Caption = ''; }
    value(3; "Resource") { Caption = 'Resource'; }
}
