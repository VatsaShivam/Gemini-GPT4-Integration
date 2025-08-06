page 50102 "API Key Setup Page"
{`
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'API Key Setup';

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(KeyName; KeyName)
                {
                    ApplicationArea = All;
                    Caption = 'Model Name';
                    OptionCaption = 'Gemini, OpenAI';
                    ToolTip = 'Enter a name for the API key to be stored securely.';
                }
                field(ApiKey; ApiKey)
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ToolTip = 'Enter the API key to be stored securely.';
                    ExtendedDatatype = Masked;
                }
                field(PromptInput; PromptInput)
                {
                    ApplicationArea = All;
                    Caption = 'Prompt Input';
                    ToolTip = 'Enter the prompt input for the API call.';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveGeminiKey)
            {
                Caption = 'Save Gemini Key';
                ApplicationArea = All;
                trigger OnAction()
                var
                    CredentialManager: Codeunit 50101;
                begin
                    if ApiKey = '' then
                        Error('API key cannot be empty.');

                    CredentialManager.SaveGeminiApiKey(ApiKey);
                    Message('API Key saved successfully.');
                end;
            }

            action(SaveOpenAIKey)
            {
                Caption = 'Save OpenAI Key';
                ApplicationArea = All;
                trigger OnAction()
                var
                    CredentialManager: Codeunit 50101;
                begin
                    if ApiKey = '' then
                        Error('API key cannot be empty.');

                    CredentialManager.SaveGPT4ApiKey(ApiKey);
                    Message('API Key saved successfully.');
                end;
            }

            action(ClearKeys)
            {
                Caption = 'Clear API Keys';
                ApplicationArea = All;
                trigger OnAction()
                var
                    CredentialManager: Codeunit 50101;
                begin
                    CredentialManager.ClearApiKeys(KeyName);
                    Message('API keys cleared successfully.');
                end;
            }
        }
        area(Navigation)
        {
            action(CallAPI)
            {
                Caption = 'Call API';
                ApplicationArea = All;
                trigger OnAction()
                var
                    AzureOpenAiIntegration: Codeunit "Azure OpenAi Integration";
                    Response: Text;
                begin
                    Response := AzureOpenAiIntegration.GetChatCompletion(PromptInput);
                    Message('API Response: \\ %1', Response);
                end;
            }
            action(ResetPage)
            {
                Caption = 'Reset Page';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Clear(ApiKey);
                    Clear(KeyName);
                    Clear(PromptInput);
                    Message('Page reset successfully.');
                end;
            }
        }
    }

    var
        KeyName: Option "Gemini","OpenAI";
        ApiKey: Text;
        PromptInput: Text;

    trigger OnOpenPage()
    begin
        Clear(ApiKey);
    end;
}
