tableextension 14301913 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14301910; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;
        }
        field(14301920; "AQD Cust Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor WHERE("AQD Cust Rbt Vendor Type" = CONST("Rebate Vendor"));
            DataClassification = CustomerContent;
        }
        field(14301930; "AQD Rebate Payment Method"; Option)
        {
            Caption = 'Rebate Payment Method';
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Payee Type"; Option)
        {
            Caption = 'Payee Type';
            InitValue = "W2 Employee";
            OptionCaption = ' ,1099 Customer,W2 Employee';
            OptionMembers = " ","1099 Customer","W2 Employee";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            DataClassification = CustomerContent;
            TableRelation = "AQD Rebate Customer Type";
        }
        field(14301960; "AQD Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}