codeunit 14301910 "AQD Acumens Rebate Setup Mgt"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', "Item Rebate Enabled", true, false)]
    local procedure Table70900_RebateSetup_ItemRebateEnabled_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        UserConfirmMsg: Label 'Do you want to update all existing Items?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            Item.ModifyAll("AQD Customer Rebate Enabled", Rec."Item Rebate Enabled");
    end;

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

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', 'Item Charge Rebate Enabled', true, false)]
    local procedure Table70900_RebateSetup_ItemChargeRebateEnabled_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        ItemCharge: Record "Item Charge";
        UserConfirmMsg: Label 'Do you want to update all existing Item Charges?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            ItemCharge.ModifyAll("AQD Customer Rebate Enabled", Rec."Item Charge Rebate Enabled");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', 'Fixed Asset Rebate Enabled', true, false)]
    local procedure Table70900_RebateSetup_FixedAssetRebatable_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        FixedAsset: Record "Fixed Asset";
        UserConfirmMsg: Label 'Do you want to update all existing Fixed Assets?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            FixedAsset.ModifyAll("AQD Customer Rebate Enabled", Rec."Fixed Asset Rebate Enabled");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens CustRbtClaim Setup", 'OnAfterValidateEvent', 'Def. Rebate Payment Method', true, false)]
    local procedure Table70900_RebateSetup_DefaultRebatePaymentMethod_OnAfterValidate(var Rec: Record "AQD Acumens CustRbtClaim Setup"; var xRec: Record "AQD Acumens CustRbtClaim Setup"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
        UserConfirmMessage: Label 'Do you want to update %1 for all Customers?';
    begin
        if Rec."Def. Rebate Payment Method" <> Rec."Def. Rebate Payment Method"::" " then
            if Confirm(StrSubstNo(UserConfirmMessage, Customer.FieldCaption("AQD Rebate Payment Method"))) then
                Customer.ModifyAll("AQD Rebate Payment Method", Rec."Def. Rebate Payment Method");
    end;

    [EventSubscriber(ObjectType::Page, Page::"AQD Customer Rebate User Setup", 'OnOpenPageEvent', '', true, false)]
    local procedure Page70902_RebateUserSetup_OnOpenPage(var Rec: Record "AQD Customer Rebate User Setup")
    var
        RebateUserSetup: Record "AQD Customer Rebate User Setup";
        UserSetup: Record "User Setup";
    begin
        UserSetup.Reset;
        if UserSetup.FindFirst then begin
            repeat
                if RebateUserSetup.Get(UserSetup."User ID") then begin
                    if RebateUserSetup."Salespers./Purch. Code" <> UserSetup."Salespers./Purch. Code" then begin
                        RebateUserSetup."Salespers./Purch. Code" := UserSetup."Salespers./Purch. Code";
                        RebateUserSetup.Modify;
                    end;
                end else begin
                    RebateUserSetup.Init;
                    RebateUserSetup."User ID" := UserSetup."User ID";
                    RebateUserSetup."Salespers./Purch. Code" := UserSetup."Salespers./Purch. Code";
                    RebateUserSetup."Salesperson Code Filter" := UserSetup."Salespers./Purch. Code";
                    RebateUserSetup.Insert;
                end;
            until UserSetup.Next = 0;
        end;
    end;
}