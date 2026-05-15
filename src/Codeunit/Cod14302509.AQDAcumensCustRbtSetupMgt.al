codeunit 14302509 "AQD Acumens CustRbt Setup Mgt"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', "Item Rebate Enabled", true, false)]
    local procedure Table70900_RebateSetup_ItemRebateEnabled_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        Vendor: Record Vendor;
        Customer, CustomerRec : Record Customer;
        UserConfirmMsg: Label 'Do you want to update all existing Items?';
    begin
        IF Rec."Item Rebate Enabled" THEN BEGIN
            //IF CONFIRM(UserConfirmMsg) then BEGIN
            Item.ModifyAll("AQD Customer Rebate Enabled", Rec."Item Rebate Enabled");
            Vendor.ModifyAll("AQD Customer Rebate", Rec."Item Rebate Enabled");
            Customer.ModifyAll("AQD Enroll for Cust Rebate", Rec."Item Rebate Enabled");
            Customer.ModifyAll("AQD CustRbt Calculation Date", Customer."AQD CustRbt Calculation Date"::"Shipment Date");
            CustomerRec.Reset();
            CustomerRec.SetFilter("AQD Cust Rebate Customer No.", '=%1', '');
            if CustomerRec.FindSet() then begin
                repeat
                    IF CustomerRec."Bill-to Customer No." <> '' THEN
                        CustomerRec."AQD Cust Rebate Customer No." := CustomerRec."Bill-to Customer No."
                    ELSE
                        CustomerRec."AQD Cust Rebate Customer No." := CustomerRec."No.";
                    CustomerRec.Modify();
                until CustomerRec.Next() = 0;
            end;
            Item.Reset();
            Item.SetFilter("AQD Cust Rebate Category Code", '=%1', '');
            Item.SetFilter("Item Category Code", '<>%1', '');
            if Item.FindSet() then begin
                repeat
                    Item."AQD Cust Rebate Category Code" := Item."Item Category Code";
                    Item.Modify();
                until Item.Next() = 0;
            end;
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