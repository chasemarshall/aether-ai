import Foundation

final class OpenAIProvider: LLMProvider {
    static let shared = OpenAIProvider()
    
    private var apiKey: String?
    
    var kind: ProviderKind { .openai }
    var displayName: String { "OpenAI" }
    var isConfigured: Bool { false } // Stub implementation
    
    init() {
        self.apiKey = Secrets.openAIAPIKey
    }
    
    func setAPIKey(_ key: String) {
        self.apiKey = key
        Secrets.openAIAPIKey = key
    }
    
    func availableModels() -> [ModelDescriptor] {
        return [
            ModelDescriptor(
                id: "gpt-4o",
                displayName: "GPT-4o",
                provider: .openai,
                contextTokens: 128000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "gpt-4o-mini",
                displayName: "GPT-4o Mini",
                provider: .openai,
                contextTokens: 128000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "gpt-3.5-turbo",
                displayName: "GPT-3.5 Turbo",
                provider: .openai,
                contextTokens: 16385,
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
            await MainActor.run {
                onComplete(.failure(LLMError.notImplemented))
            }
        }
        
        return TaskCancellable(task: task)
    }
}
