namespace AcumenseRebatesBC.AcumenseRebatesBC;

page 14277063 "AQD Rebate Vendor Type Eligib"
{
    ApplicationArea = All;
    Caption = 'Rebate Vendor Type Eligibility';
    PageType = List;
    SourceTable = "AQD RebateVendorTypeElig";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Rebate Vendor Type")
                {
                    ToolTip = 'Specifies the  Vendor Type for the Rebate Vendor Type.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Rebate Vendor Type.';
                }
                field("Purchase Amount Threshold"; Rec."Purchase Amount Threshold")
                {
                    ToolTip = 'Specifies the Purchase Amount Threshold of the Rebate Vendor Type.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the Block of the Rebate Vendor Type.';
                }
            }
        }
    }
}
