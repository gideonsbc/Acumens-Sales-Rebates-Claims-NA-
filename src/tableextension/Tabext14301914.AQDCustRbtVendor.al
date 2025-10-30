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
        field(14301920; "AQD Payee Type"; Option)
        {
            Caption = 'Payee Type';
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Vendor,W2 Employee';
            OptionMembers = " ","1099 Vendor","W2 Employee";
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Rebate Payment Method"; Option)
        {
            Caption = 'Rebate Payment Method';
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
            DataClassification = CustomerContent;
        }
        field(1430150; "AQD Cust Rbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Rebate Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}