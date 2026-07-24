namespace AcumenseComissionsBCCloudWithoutRegistration.AcumenseComissionsBCCloudWithoutRegistration;

codeunit 14302614 "AQD Customer Rebate Access Mgt"
{

    VAR
        Text001: Label 'You do not have license to access %1.';
        appid: Label '6fe07eb4-80c8-48b7-8afb-298cc3af0a0c';
        appname: Label 'Acumens Sales Rebates & Claims (NA)';

    [EventSubscriber(ObjectType::Codeunit, 150, OnAfterLogin, '', false, false)]
    local procedure CU150_onafterlogin()
    var
        AcumensLicensing: Codeunit "AQD Acumens Licensing mgt";
    begin
        if not AcumensLicensing.Checkifappislicensed(appid, appname) then
            DisableAppAccess(true, true);
    end;

    procedure DisableAppAccess(ShowMessage: Boolean; CalledFromLogin: Boolean): Boolean
    var
        CustomerRebateSetup: Record "AQD Acumens CustRbtClaim Setup";
    begin
        //To implement later - SBC 2026-04-07

        // if VendorRebateSetup.Get() and true in [VendorRebateSetup."Item Rebate Enabled", VendorRebateSetup."G/L Account Rebate Enabled", VendorRebateSetup."Resource Rebate Enabled"] then begin
        //     VendorRebateSetup.Validate("Item Rebate Enabled", false);
        //     VendorRebateSetup.Validate("G/L Account Rebate Enabled", false);
        //     VendorRebateSetup.Validate("Resource Rebate Enabled", false);
        //     VendorRebateSetup.Modify();
        //     Commit();
        // end;

        // if ShowMessage and not CalledFromLogin then
        //     Error(Text001, appname);
    end;

    procedure CheckAppAccess(): Boolean
    var
        AcumensLicensing: Codeunit "AQD Acumens Licensing mgt";
    begin
        if not AcumensLicensing.Checkifappislicensed(appid, appname) then
            DisableAppAccess(true, false)
    end;
}
