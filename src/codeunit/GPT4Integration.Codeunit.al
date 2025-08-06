codeunit 50103 GPT4Integration
{
    var
        CredentialManager: Codeunit GeminiCredentialManager;

    procedure GetGPT4Response(PromptText: Text): Text
    var
        Response: Text;
    begin
        Response := CallGPT4API(PromptText);
        exit(Response);
    end;

    local procedure CallGPT4API(PromptText: Text): Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        LabelGPT4Endpoint: Label 'GPT4Endpoint', Locked = true;
        GPT4Endpoint: Text;
        GPT4ApiKey: Text;
        Payload: Text;
        ResponseText: Text;
        GPT4ResultToken: JsonToken;
        GPT4Result: Text;
        JsonResponse: JsonObject;
    begin
        GPT4Endpoint := LabelGPT4Endpoint;
        GPT4ApiKey := CredentialManager.GetGPT4ApiKey();
        if GPT4ApiKey = '' then
            Error('API key not found. Please set it in isolated storage.');

        Payload := Format(StrSubstNo(@' {
                        "messages": [
                            {"role": "system", "content": "You are a helpful assistant."},
                            {"role": "user", "content": "%1"}
                        ],
                        "temperature": 0.7,
                        "max_tokens": 3000
                    }', PromptText));

        RequestContent.WriteFrom(Payload);
        RequestContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(GPT4Endpoint);
        RequestMessage.Content(RequestContent);

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + GPT4ApiKey);

        if not HttpClient.Send(RequestMessage, ResponseMessage) then
            Error('Failed to call Gemini API');
        if not ResponseMessage.IsSuccessStatusCode() then
            Error('API call failed. Status: %1 %2', ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());

        ResponseMessage.Content().ReadAs(ResponseText);
        if not JsonResponse.ReadFrom(ResponseText) then
            Error('API returned invalid JSON!');

        if JsonResponse.SelectToken('choices[0].message.content', GPT4ResultToken) then begin
            GPT4Result := GPT4ResultToken.AsValue().AsText();
            exit(GPT4Result);
        end;

        exit(ResponseText);
    end;
}