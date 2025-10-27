
report 14277015 "AQD Vendor Rebate Details"
{
    ApplicationArea = All;
    Caption = 'Vendor Rebate Details';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Layout/Rep14277015.AQDVendorRebateDetails.rdl';

    dataset
    {
        dataitem("AQD Posted Ven Rebate Header"; "AQD Posted Vend Rebate Header")
        {
            RequestFilterFields = "No.";

            column(No_; "No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Pay_to_Vendor_No_; "Pay-to Vendor No.") { }
            column(Pay_to_Name; "Pay-to Name") { }
            column(Pay_to_Address; "Pay-to Address") { }
            column(Pay_to_Address_2; "Pay-to Address 2") { }
            column(Pay_to_Address_3; "Pay-to City" + ', ' + "Pay-to County" + ' ' + "Pay-to Post Code") { }
            column(Pay_to_Address_4; GetCountryName("Pay-to Country/Region Code")) { }
            dataitem("AQD Posted Ven Rebate Line"; "AQD Posted Vend Rebate Line")
            {
                DataItemLink = "Rebate No." = field("No.");
                DataItemTableView = sorting("Rebate No.", "Line No.");

                column(Document_Type; "Document Type") { }
                column(Document_No_; "Document No.") { }
                column(Line_Posting_Date; "Posting Date") { }
                column(Description; Description) { }
                column(Amount; Amount) { }
                column(Vendor_Rebate_Amount; "Vendor Rebate Amount") { }
            }
            dataitem("AQD Posted Ven Reb Comment"; "AQD Posted Ven Reb Comment")
            {
                DataItemLink = "Rebate No." = field("No.");
                DataItemTableView = sorting("Rebate No.", "Line No.");
                column(Comment; Comment) { }
            }
        }
    }
    local procedure GetCountryName(CountryCode: Code[10]): Text[50]
    var
        CountryRec: Record "Country/Region";
    begin
        if CountryRec.Get(CountryCode) then
            exit(CountryRec.Name)
    end;
}