tableextension 14301914 "AQD CustRbt Vendor Ext" extends Vendor
{
    fields
    {
        field(14301910; "AQD Cust Rbt Vendor Type"; Option)
        {
            Caption = 'Vendor Type';
            OptionCaption = ' ,Rebate Vendor';
            OptionMembers = " ","Rebate Vendor";
            DataClassification = CustomerContent;
        }
        field(1430150; "AQD Cust Rbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Rebate Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}