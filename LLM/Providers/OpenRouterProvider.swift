import Foundation

final class OpenRouterProvider: LLMProvider {
    static let shared = OpenRouterProvider()
    
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private var apiKey: String?
    
    var kind: ProviderKind { .openrouter }
    var displayName: String { "OpenRouter" }
    var isConfigured: Bool { 
        guard let key = apiKey ?? Secrets.openRouterAPIKey else { return false }
        return !key.isEmpty
    }
    
    init() {
        self.apiKey = Secrets.openRouterAPIKey
    }
    
    func setAPIKey(_ key: String) {
        self.apiKey = key
        Secrets.openRouterAPIKey = key
    }
    
    func availableModels() -> [ModelDescriptor] {
        return [
            ModelDescriptor(
                id: "openai/gpt-4o",
                displayName: "GPT-4o",
                provider: .openrouter,
                contextTokens: 128000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "anthropic/claude-3.5-sonnet",
                displayName: "Claude 3.5 Sonnet",
                provider: .openrouter,
                contextTokens: 200000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "meta-llama/llama-3.1-70b-instruct",
                displayName: "Llama 3.1 70B",
                provider: .openrouter,
                contextTokens: 8192,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "mistralai/mistral-large-latest",
                displayName: "Mistral Large",
                provider: .openrouter,
                contextTokens: 128000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "google/gemini-pro",
                displayName: "Gemini Pro",
                provider: .openrouter,
                contextTokens: 32768,
                supportsJSON: true
            )
        ]
    }
    
    @discardableResult
    func streamChat(
        model: ModelDescriptor,
        messages: [ChatMessage],
        temperature: Double?,
        maxTokens: Int?,
        jsonMode: Bool,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable {
        
        let task = Task {
            do {
                guard let apiKey = self.apiKey ?? Secrets.openRouterAPIKey, !apiKey.isEmpty else {
                    await MainActor.run {
                        onComplete(.failure(LLMError.notConfigured))
                    }
                    return
                }
                
                let request = try buildRequest(
                    apiKey: apiKey,
                    model: model,
                    messages: messages,
                    temperature: temperature,
                    maxTokens: maxTokens,
                    jsonMode: jsonMode
                )
                
                let (bytes, response) = try await HTTPClient.shared.bytes(for: request)
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    guard httpResponse.statusCode == 200 else {
                        let errorMessage = try? await extractErrorMessage(from: bytes)
                        await MainActor.run {
                            onComplete(.failure(LLMError.http(httpResponse.statusCode, errorMessage)))
                        }
                        return
                    }
                }
                
                // Process stream
                var decoder = SSEStreamDecoder(onToken: onToken, onComplete: onComplete)
                await decoder.process(bytes: bytes)
                
            } catch {
                await MainActor.run {
                    if error is CancellationError {
                        onComplete(.failure(error))
                    } else {
                        onComplete(.failure(LLMError.unknown))
                    }
                }
            }
        }
        
        return TaskCancellable(task: task)
    }
    
    private func buildRequest(
        apiKey: String,
        model: ModelDescriptor,
        messages: [ChatMessage],
        temperature: Double?,
        maxTokens: Int?,
        jsonMode: Bool
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw LLMError.unknown
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("BYOK-iOS", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("BYOK", forHTTPHeaderField: "X-Title")
        request.timeoutInterval = 60
        
        var body: [String: Any] = [
            "model": model.id,
            "messages": messages.map { message in
                [
                    "role": message.role.rawValue,
                    "content": message.content
                ]
            },
            "stream": true
        ]
        
        if let temperature = temperature {
            body["temperature"] = temperature
        }
        
        if let maxTokens = maxTokens {
            body["max_tokens"] = maxTokens
        }
        
        if jsonMode {
            body["response_format"] = ["type": "json_object"]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }
    
    private func extractErrorMessage(from bytes: URLSession.AsyncBytes) async throws -> String? {
        var data = Data()
        for try await byte in bytes {
            data.append(byte)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }
        
        return String(data: data, encoding: .utf8)
    }
}
