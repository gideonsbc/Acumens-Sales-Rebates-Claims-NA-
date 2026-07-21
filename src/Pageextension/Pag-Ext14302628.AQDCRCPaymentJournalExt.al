pageextension 14302628 "AQD CRCPayment Journal Ext" extends "Payment Journal"
{
    layout
    {
        addafter("Account No.")
        {
            Field("AQD CR Rebate Program Code"; Rec."AQD CR Rebate Program Code")
            {
                ToolTip = 'Specifies the value of the Rebate Program Code field.';
                ApplicationArea = all;
            }
        }
    }
}
