codeunit 50101 GeminiCredentialManager
{
    procedure SaveGeminiApiKey(ApiKey: Text)
    begin
        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted('Gemini', ApiKey)
        else
            IsolatedStorage.Set('Gemini', ApiKey);
    end;

    procedure GetGeminiApiKey(): Text
    var
        ApiKey: Text;
    begin
        if IsolatedStorage.Get('Gemini', ApiKey) then
            exit(ApiKey)
        else
            exit('');
    end;

    procedure SaveGPT4ApiKey(ApiKey: Text)
    begin
        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted('OpenAI', ApiKey)
        else
            IsolatedStorage.Set('OpenAI', ApiKey);
    end;

    procedure GetGPT4ApiKey(): Text
    var
        ApiKey: Text;
    begin
        if IsolatedStorage.Get('OpenAI', ApiKey) then
            exit(ApiKey)
        else
            exit('');
    end;

    procedure ClearApiKeys(KeyName: Option "Gemini","OpenAI")
    begin
        if KeyName = KeyName::Gemini then
            IsolatedStorage.Delete('Gemini')
        else if KeyName = KeyName::OpenAI then
            IsolatedStorage.Delete('OpenAI')
    end;
}
