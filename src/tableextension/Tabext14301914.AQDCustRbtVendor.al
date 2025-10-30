tableextension 14301914 "AQD CustRbt Vendor Ext" extends Vendor
{
    fields
    {
        field(14301910; "AQD Vendor Type"; Option)
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
        field(14301930; "AQD Rebate Customer No"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            TableRelation = Customer."No.";
            DataClassification = CustomerContent;
        }
        field(14301940; "AQD Rebate Payment Method"; Option)
        {
            Caption = 'Rebate Payment Method';
            OptionCaption = ' ,Check,Credit Memo';
            OptionMembers = " ",Check,"Credit Memo";
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            TableRelation = "AQD Rebate Customer Type";
        }
        field(14301970; "AQD Rebate Vendor No"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            TableRelation = Vendor WHERE("AQD Vendor Type" = CONST("Rebate Vendor"));
            DataClassification = CustomerContent;
        }
        field(14301960; "AQD Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
        }
    }
}