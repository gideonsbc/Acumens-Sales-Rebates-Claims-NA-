table 14301940 "AQD Customer Rebate Buffer"
{
    Caption = 'Customer Rebate Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "Buy-from Vendor Name"; Text[80])
        {
            Caption = 'Vendor Name';
        }
        field(3; Year; Integer)
        {
            Caption = 'Year';
        }
        field(4; "Data Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = Actual,Forecast;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "January Purchases"; Decimal)
        {
            Caption = 'January Purchases';
        }
        field(7; "January Rebate"; Decimal)
        {
            Caption = 'January Rebate';
        }
        field(10; "February Purchases"; Decimal)
        {
            Caption = 'February Purchases';
        }
        field(11; "February Rebate"; Decimal)
        {
            Caption = 'February Rebate';
        }
        field(20; "March Purchases"; Decimal)
        {
            Caption = 'March Purchases';
        }
        field(21; "March Rebate"; Decimal)
        {
            Caption = 'March Rebate';
        }
        field(30; "April Purchases"; Decimal)
        {
            Caption = 'April Purchases';
        }
        field(31; "April Rebate"; Decimal)
        {
            Caption = 'April Rebate';
        }
        field(40; "May Purchases"; Decimal)
        {
            Caption = 'May Purchases';
        }
        field(41; "May Rebate"; Decimal)
        {
            Caption = 'May Rebate';
        }
        field(50; "June Purchases"; Decimal)
        {
            Caption = 'June Purchases';
        }
        field(51; "June Rebate"; Decimal)
        {
            Caption = 'June Rebate';
        }
        field(60; "July Purchases"; Decimal)
        {
            Caption = 'July Purchases';
        }
        field(61; "July Rebate"; Decimal)
        {
            Caption = 'July Rebate';
        }
        field(70; "August Purchases"; Decimal)
        {
            Caption = 'August Purchases';
        }
        field(71; "August Rebate"; Decimal)
        {
            Caption = 'August Rebate';
        }
        field(80; "September Purchases"; Decimal)
        {
            Caption = 'September Purchases';
        }
        field(81; "September Rebate"; Decimal)
        {
            Caption = 'September Rebate';
        }
        field(90; "October Purchases"; Decimal)
        {
            Caption = 'October Purchases';
        }
        field(91; "October Rebate"; Decimal)
        {
            Caption = 'October Rebate';
        }
        field(100; "November Purchases"; Decimal)
        {
            Caption = 'November Purchases';
        }
        field(101; "November Rebate"; Decimal)
        {
            Caption = 'November Rebate';
        }
        field(110; "December Purchases"; Decimal)
        {
            Caption = 'December Purchases';
        }
        field(111; "December Rebate"; Decimal)
        {
            Caption = 'December Rebate';
        }
        field(130; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(131; "Pay-to Vendor Name"; Text[80])
        {
            Caption = 'Vendor Name';
        }
    }
    keys
    {
        key(PK; "Buy-from Vendor No.", Year, "Data Type")
        {
            Clustered = true;
        }
        key(SK1; "Buy-from Vendor No.", Year)
        {

        }
    }
}
