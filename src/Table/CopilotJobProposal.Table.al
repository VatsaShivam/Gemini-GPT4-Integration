table 50100 "Copilot Job Proposal"
{
    TableType = Temporary;
    Caption = 'Copilot Job Proposal';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; Description; Text[2048])
        {
            Caption = 'Proposal Description';
        }
        field(3; CreatedAt; Date)
        {
            Caption = 'Created At';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }


    procedure SaveProposal(ProposalText: Text)
    var
        CopilotJobProposal: Record "Copilot Job Proposal";
    begin
        CopilotJobProposal.Init();
        CopilotJobProposal.Description := ProposalText;
        CopilotJobProposal.CreatedAt := Today();
        CopilotJobProposal.Insert();
    end;
}
