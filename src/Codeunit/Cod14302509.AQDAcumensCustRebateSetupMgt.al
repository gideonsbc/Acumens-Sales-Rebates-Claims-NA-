codeunit 14302509 "AQD Acumens CustRbt Setup Mgt"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', "Item Rebate Enabled", true, false)]
    local procedure Table70900_RebateSetup_ItemRebateEnabled_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        Customer: Record Vendor;
        UserConfirmMsg: Label 'Do you want to update all existing Items?';
    begin
        IF Rec."Item Rebate Enabled" THEN
            IF CONFIRM(UserConfirmMsg) then BEGIN
                Item.ModifyAll("AQD Customer Rebate Enabled", Rec."Item Rebate Enabled");
                Customer.ModifyAll("AQD Customer Rebate", Rec."Item Rebate Enabled");
            END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', 'G/L Account Rebate Enabled', true, false)]
    local procedure Table70900_RebateSetup_GLAccountRebateEnabled_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        GLAccount: Record "G/L Account";
        UserConfirmMsg: Label 'Do you want to update all existing G/L Accounts?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            GLAccount.ModifyAll("AQD Customer Rebate Enabled", Rec."G/L Account Rebate Enabled");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', 'Resource Rebate Enabled', true, false)]
    local procedure Table70900_RebateSetup_ResourceRebatable_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        Resource: Record Resource;
        UserConfirmMsg: Label 'Do you want to update all existing Resources?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            Resource.ModifyAll("AQD Customer Rebate Enabled", Rec."Resource Rebate Enabled");
    end;

}