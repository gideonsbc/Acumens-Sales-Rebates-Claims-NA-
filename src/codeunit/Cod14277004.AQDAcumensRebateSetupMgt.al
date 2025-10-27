codeunit 14277004 "AQD Acumens Rebate Setup Mgt"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Item Rebatable", true, false)]
    local procedure Table70900_RebateSetup_ItemRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        UserConfirmMsg: Label 'Do you want to update all existing Items?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            Item.ModifyAll("AQD Customer Rebatable", Rec."Item Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Vendor Item Rebatable", true, false)]
    local procedure Table70900_RebateSetup_VendorItemRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        LocalItem: Record Item;
        UserConfirmMsg: Label 'Do you want to update all existing Item?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            LocalItem.ModifyAll("AQD Vendor Rebatable", Rec."Vendor Item Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'G/L Account Rebatable', true, false)]
    local procedure Table70900_RebateSetup_GLAccountRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        GLAccount: Record "G/L Account";
        UserConfirmMsg: Label 'Do you want to update all existing G/L Accounts?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            GLAccount.ModifyAll("AQD Customer Rebatable", Rec."G/L Account Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Vendor G/L Account Rebatable", true, false)]
    local procedure Table70900_RebateSetup_VendorGLAccountRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        GLAccount: Record "G/L Account";
        UserConfirmMsg: Label 'Do you want to update all existing G/L Accounts?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            GLAccount.ModifyAll("AQD Vendor Rebatable", Rec."Vendor G/L Account Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Resource Rebatable', true, false)]
    local procedure Table70900_RebateSetup_ResourceRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Resource: Record Resource;
        UserConfirmMsg: Label 'Do you want to update all existing Resources?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            Resource.ModifyAll("AQD Customer Rebatable", Rec."Resource Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Vendor Resource Rebatable', true, false)]
    local procedure Table70900_RebateSetup_VendorResourceRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Resource: Record Resource;
        UserConfirmMsg: Label 'Do you want to update all existing Resources?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            Resource.ModifyAll("AQD Vendor Rebatable", Rec."Vendor Resource Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Item Charge Rebatable', true, false)]
    local procedure Table70900_RebateSetup_ItemChargeRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        ItemCharge: Record "Item Charge";
        UserConfirmMsg: Label 'Do you want to update all existing Item Charges?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            ItemCharge.ModifyAll("AQD Customer Rebatable", Rec."Item Charge Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Vendor Item Charge Rebatable", true, false)]
    local procedure Table70900_RebateSetup_VendorItemChargeRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        ItemCharge: Record "Item Charge";
        UserConfirmMsg: Label 'Do you want to update all existing Item Charges?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            ItemCharge.ModifyAll("AQD Vendor Rebatable", Rec."Vendor Item Charge Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Fixed Asset Rebatable', true, false)]
    local procedure Table70900_RebateSetup_FixedAssetRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        FixedAsset: Record "Fixed Asset";
        UserConfirmMsg: Label 'Do you want to update all existing Fixed Assets?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            FixedAsset.ModifyAll("AQD Customer Rebatable", Rec."Fixed Asset Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Vendor Fixed Asset Rebatable", true, false)]
    local procedure Table70900_RebateSetup_VendorFixedAssetRebatable_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        FixedAsset: Record "Fixed Asset";
        UserConfirmMsg: Label 'Do you want to update all existing Fixed Assets?';
    begin
        IF CONFIRM(UserConfirmMsg) then
            FixedAsset.ModifyAll("AQD Vendor Rebatable", Rec."Vendor Fixed Asset Rebatable");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Def. Rebate Payment Method', true, false)]
    local procedure Table70900_RebateSetup_DefaultRebatePaymentMethod_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
        UserConfirmMessage: Label 'Do you want to update %1 for all Customers?';
    begin
        if Rec."Def. Rebate Payment Method" <> Rec."Def. Rebate Payment Method"::" " then
            if Confirm(StrSubstNo(UserConfirmMessage, Customer.FieldCaption("AQD Rebate Payment Method"))) then
                Customer.ModifyAll("AQD Rebate Payment Method", Rec."Def. Rebate Payment Method");
    end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Default Rebate %', true, false)]
    local procedure Table70900_RebateSetup_DefaultRebatePercentage_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        UserConfirmMessage: Label 'Do you want to update %1 for all Customers?';
    begin
        if Rec."Default Rebate %" <> xRec."Default Rebate %" then
            if Confirm(StrSubstNo(UserConfirmMessage, Customer.FieldCaption("AQD Rebate %"))) then begin
                Customer.SetRange("AQD Enroll for Rebate", TRUE);
                Customer.ModifyAll("AQD Rebate Type", Rec."Default Rebate Type");
                Customer.ModifyAll("AQD Rebate %", Rec."Default Rebate %");
            end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Vendor Default Rebate %', true, false)]
    // local procedure Table70900_RebateSetup_VendorDefaultRebatePercentage_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    // var
    //     Vendor: Record Vendor;
    //     UserConfirmMessageVen: Label 'Do you want to update %1 for all Vendors?';
    // begin
    //     if Rec."Vendor Default Rebate %" = xRec."Vendor Default Rebate %" then
    //         EXIT;

    //     if Confirm(StrSubstNo(UserConfirmMessageVen, Vendor.FieldCaption("AQD Rebate %"))) then begin
    //         Vendor.ModifyAll("AQD Rebate Type", Rec."Vendor Default Rebate Type");
    //         Vendor.ModifyAll("AQD Rebate %", Rec."Vendor Default Rebate %");
    //     end;
    // end;

    [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', 'Default Rebate Per Quantity', true, false)]
    local procedure Table70900_RebateSetup_DefaultRebatePerQuantity_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        UserConfirmMessageCust: Label 'Do you want to update %1 for all Customers?';
    begin
        IF Rec."Default Rebate Per Quantity" <> xRec."Default Rebate Per Quantity" THEN begin
            IF CONFIRM(STRSUBSTNO(UserConfirmMessageCust, Customer.FIELDCAPTION("AQD Rebate Per Quantity"))) THEN begin
                Customer.ModifyAll("AQD Rebate Type", Rec."Default Rebate Type");
                Customer.MODIFYALL("AQD Rebate Per Quantity", Rec."Default Rebate Per Quantity");
            end;
        end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"AQD Acumens Rebate Setup", 'OnAfterValidateEvent', "Vendor Def Rebate Per Quantity", true, false)]
    // local procedure Table70900_RebateSetup_VendorDefRebatePerQuantity_OnAfterValidate(var Rec: Record "AQD Acumens Rebate Setup"; var xRec: Record "AQD Acumens Rebate Setup"; CurrFieldNo: Integer)
    // var
    //     Vendor: Record Vendor;
    //     UserConfirmMessageVen: Label 'Do you want to update %1 for all Vendors?';
    // begin
    //     IF Rec."Vendor Def Rebate Per Quantity" = xRec."Vendor Def Rebate Per Quantity" THEN
    //         EXIT;

    //     IF CONFIRM(STRSUBSTNO(UserConfirmMessageVen, Rec.FIELDCAPTION("Vendor Def Rebate Per Quantity"))) THEN begin
    //         Vendor.ModifyAll("AQD Rebate Type", Rec."Vendor Default Rebate Type");
    //         Vendor.MODIFYALL("AQD Rebate Amount", Rec."Vendor Def Rebate Per Quantity");
    //     end;
    // end;

    [EventSubscriber(ObjectType::Page, Page::"AQD Rebate User Setup", 'OnOpenPageEvent', '', true, false)]
    local procedure Page70902_RebateUserSetup_OnOpenPage(var Rec: Record "AQD Rebate User Setup")
    var
        RebateUserSetup: Record "AQD Rebate User Setup";
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