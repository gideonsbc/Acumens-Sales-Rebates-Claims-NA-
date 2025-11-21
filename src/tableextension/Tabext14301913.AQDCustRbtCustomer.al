tableextension 14301913 "AQD CustRbt Customer Ext" extends Customer
{
    fields
    {
        field(14301910; "AQD Enroll for Cust Rebate"; Boolean)
        {
            Caption = 'Enroll for Rebate';
            DataClassification = CustomerContent;
        }
        field(14301950; "AQD Rebate Customer Type"; Code[20])
        {
            Caption = 'Rebate Customer Type';
            DataClassification = CustomerContent;
            TableRelation = "AQD CustRbt RebateCustomerType";
        }
        field(14301960; "AQD CustRbt Calculation Date"; Enum "AQD CustRebateCalculation Type")
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
    }
}