enum 14302537 "AQD CRC Claims App. Status"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
    ObsoleteTag = 'Deprecated in v25.1023.1.45';
    Extensible = true;
    AssignmentCompatibility = true;

    value(10; "Open") { Caption = 'Open'; }
    value(20; "Pending Approval") { Caption = 'Pending Approval'; }
    value(30; "Approved") { Caption = 'Approved'; }
}
