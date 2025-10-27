table 14277009 "AQD Rebate Item Category"
{
    Caption = 'Rebate Item Category';
    LookupPageID = "AQD Rebate Item Categories";
    DrillDownPageId = "AQD Rebate Item Categories";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(30; Rebatable; Boolean)
        {
            Caption = 'Rebatable';

            trigger OnValidate()
            var
                LocalItem: Record Item;
                UserConfirmMsg: Label 'Do you want to update all existing Item?';
            begin
                IF (Rec.Rebatable <> xRec.Rebatable) AND
                  (NOT Rec.IsTemporary)
                THEN begin
                    IF CONFIRM(UserConfirmMsg) then begin
                        LocalItem.RESET;
                        LocalItem.SetRange("AQD Rebate Category Code", Rec.Code);
                        LocalItem.ModifyAll("AQD Vendor Rebatable", Rec.Rebatable);
                    end;
                end;
            end;
        }
        field(70; "Category Type"; Enum "AQD Rebate Category Type")
        {
            Caption = 'Type';
            trigger OnValidate()
            var
                RebateCategoryLines: Record "AQD Rebate Category Lines";
            begin
                IF Rec."Category Type" <> Rec."Category Type" then begin
                    RebateCategoryLines.RESET;
                    RebateCategoryLines.SetRange("Rebate Category Code", Rec.Code);
                    RebateCategoryLines.DeleteAll();
                end
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; "Code", Description, "Category Type")
        {
        }
        fieldgroup(Brick; "Code", Description, "Category Type")
        { }
    }
}