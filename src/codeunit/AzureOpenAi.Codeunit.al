codeunit 50104 "Azure OpenAI Integration"
{
    procedure GetChatCompletion(UserPrompt: Text) Result: Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        AzureOpenAIEndpoint: Text;
        AzureOpenAIApiKey: Text;
        Payload: Text;
        ResponseText: Text;
        JsonResponse: JsonObject;
        GPT4ResultToken: JsonToken;
        GPT4Result: Text;
        GPT4ResultValue: JsonValue;
        LabelAzureOpenAIEndpoint: Label 'GPT4ENDPOINT', Locked = true;
        CredentialManager: Codeunit GeminiCredentialManager;
    begin
        AzureOpenAIEndpoint := LabelAzureOpenAIEndpoint;
        AzureOpenAIApiKey := CredentialManager.GetGPT4ApiKey();
        Payload := Format(StrSubstNo(@'{
                            "model": "gpt-4.1",
                            "messages": [
                                {"role": "system", "content": "You are a helpful assistant."},
                                {"role": "user", "content": "%1"}
                            ],
                            "temperature": 0.7,
                            "max_tokens": 3000
                        }', UserPrompt));

        RequestContent.WriteFrom(Payload);
        RequestContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(AzureOpenAIEndpoint);
        RequestMessage.Content(RequestContent);

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AzureOpenAIApiKey);

        if not HttpClient.Send(RequestMessage, ResponseMessage) then
            Error('Failed to call Azure OpenAI API');

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('Failed to call Azure OpenAI API: %1', ResponseMessage.ReasonPhrase());
        ResponseMessage.Content.ReadAs(ResponseText);
        if not JsonResponse.ReadFrom(ResponseText) then
            Error('Failed to parse JSON response from Azure OpenAI API');
        if not JsonResponse.Get('choices', GPT4ResultToken) then
            Error('No choices found in the response from Azure OpenAI API');

        if JsonResponse.SelectToken('choices[0].message.content', GPT4ResultToken) then begin
            GPT4Result := GPT4ResultToken.AsValue().AsText();
            exit(GPT4Result);
        end
    end;
}