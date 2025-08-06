pageextension 50100 "Customer Page With AI" extends "Customer List"
{
    actions
    {
        addafter("&Customer")
        {
            action(GenerateCopilot)
            {
                Caption = 'Describe to copilot';
                Image = Sparkle;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Copilot Job Proposal")
                end;
            }
        }
    }
}