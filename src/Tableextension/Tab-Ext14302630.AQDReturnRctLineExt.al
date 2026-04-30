tableextension 14302630 "AQD Return Rct Line Ext" extends "Return Receipt Line"
{
    fields
    {
        field(14302705; "AQD Off-Invoice Rebate"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}