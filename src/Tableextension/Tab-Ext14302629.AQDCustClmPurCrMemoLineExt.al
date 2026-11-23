tableextension 14302629 "AQD CustClm PurCrMemoLine Ext" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(14302620; "AQD Claim Sell-to Cust No."; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim Sell-To Customer No.';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        field(14302630; "AQD Claim Bill-to Cust No."; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim Bill-To Customer No.';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        field(14302640; "AQD Customer Claim Code"; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Customer Claim Code';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        FIELD(14302650; "AQD Claim Line Type"; enum "AQD CustClmPrcMthClaimLineType")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Claim Line Type';
            Editable = FALSE;
            DataClassification = CustomerContent;
        }
        field(14302660; "AQD CustClaim Orig Order No."; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302670; "AQD CustClaim Orig OdrLine No."; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302680; "AQD CustClaim Claim No."; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Origianl Order No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
        field(14302690; "AQD CustClaim Claim Line No."; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'The Claims functionality has been discontinued and will be removed in a future release.';
            ObsoleteTag = 'Deprecated in v25.1023.1.45';
            Caption = 'Origianl Order Line No.';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            Editable = false;
        }
    }
}