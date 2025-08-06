codeunit 50100 GeminiIntegration
{
    var
        CredentialManager: Codeunit GeminiCredentialManager;

    procedure GetGeminiResponse(PromptText: Text): Text
    var
        Response: Text;
    begin
        Response := CallGeminiAPI(PromptText);
        exit(Response);
    end;

    local procedure CallGeminiAPI(PromptText: Text): Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        LabelGeminiEndpoint: Label 'GeminiEndpoint', Locked = true;
        GeminiEndpoint: Text;
        GeminiApiKey: Text;
        Payload: Text;
        ResponseText: Text;
        GeminiResultToken: JsonToken;
        GeminiResult: Text;
        JsonResponse: JsonObject;
    begin
        GeminiApiKey := CredentialManager.GetGeminiApiKey();
        GeminiEndpoint := LabelGeminiEndpoint + GeminiApiKey;
        if GeminiApiKey = '' then
            Error('Gemini API key not found. Please set it in isolated storage.');

        Payload := '{"contents":[{"parts":[{"text":"' + PromptText + '"}]}]}';

        RequestContent.WriteFrom(Payload);
        RequestContent.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(GeminiEndpoint);
        RequestMessage.Content(RequestContent);

        RequestMessage.GetHeaders(RequestHeaders);
        if not HttpClient.Send(RequestMessage, ResponseMessage) then
            Error('Failed to call Gemini API');
        if not ResponseMessage.IsSuccessStatusCode() then
            Error('Gemini API call failed. Status: %1 %2', ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());

        ResponseMessage.Content().ReadAs(ResponseText);
        if not JsonResponse.ReadFrom(ResponseText) then
            Error('API returned invalid JSON!');

        if JsonResponse.SelectToken('candidates[0].content.parts[0].text', GeminiResultToken) then begin
            GeminiResult := GeminiResultToken.AsValue().AsText();
            exit(GeminiResult);
        end;

        exit(ResponseText);
    end;
}