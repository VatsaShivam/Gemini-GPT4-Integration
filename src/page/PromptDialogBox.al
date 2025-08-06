page 50100 "Copilot Job Proposal"
{
    Caption = 'Draft new job with copilot';
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    DataCaptionExpression = UserInput;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Prompt)
        {
            field(ProjectDescription; UserInput)
            {
                ShowCaption = false;
                MultiLine = true;
            }
        }
        area(Content)
        {
            field(ResponseText; ResponseText)
            {
                ShowCaption = false;
                MultiLine = true;
                ToolTip = 'AI-generated response will be displayed here.';
                Width = 1000;
            }
        }
        area(PromptOptions)
        {
            field(ModelType; ModelSelection)
            {
                ApplicationArea = All;
                Caption = 'Model';
                ToolTip = 'Select the AI model to use for generating responses.';
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                trigger OnAction()
                begin
                    if UserInput = '' then
                        Error('Please enter a prompt text.');

                    case ModelSelection of
                        "Model Type"::Gemini:
                            ResponseText := GeminiIntegration.GetGeminiResponse(UserInput);
                        "Model Type"::GPT4:
                            ResponseText := GPT4Integration.GetGPT4Response(UserInput);
                        else
                            Error('Unknown model selected.');
                    end;
                end;
            }
            systemaction(Attach)
            {
                Caption = 'Attach a file';
                ToolTip = 'Save the AI-generated response.';
                trigger OnAction()
                var
                    InStream: InStream;
                    OutStream: OutStream;
                    Filename: Text;
                    TempBlob: Codeunit "Temp Blob";
                begin
                    if UploadIntoStream('Select file', '', 'All files|*.json|*.txt|*.csv', Filename, InStream) then begin
                        TempBlob.CreateOutStream(OutStream);
                        CopyStream(OutStream, InStream);
                        TempBlob.CreateInStream(InStream);
                        InStream.ReadText(UserInput);
                    end;
                end;
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate the AI response using the selected model.';
                trigger OnAction()
                begin
                    case ModelSelection of
                        "Model Type"::Gemini:
                            ResponseText := GeminiIntegration.GetGeminiResponse(UserInput);
                        "Model Type"::GPT4:
                            ResponseText := GPT4Integration.GetGPT4Response(UserInput);
                        else
                            Error('Unknown model selected.');
                    end;
                end;
            }
            systemaction(OK)
            {
                Caption = 'Save';
                ToolTip = 'Save the AI-generated response.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard the AI-generated response.';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then begin
            ResponseText := CopyStr(ResponseText, 1, 2048);
            CopilotJobProposal.SaveProposal(ResponseText);
        end;


        exit(false);
    end;

    var
        UserInput: Text;
        ResponseText: Text;
        ModelSelection: Enum "Model Type";
        GeminiIntegration: Codeunit "GeminiIntegration";
        GPT4Integration: Codeunit "GPT4Integration";
        CopilotJobProposal: Record "Copilot Job Proposal";
}