import Foundation

final class AnthropicProvider: LLMProvider {
    static let shared = AnthropicProvider()
    
    private var apiKey: String?
    
    var kind: ProviderKind { .anthropic }
    var displayName: String { "Anthropic" }
    var isConfigured: Bool { false } // Stub implementation
    
    init() {
        self.apiKey = Secrets.anthropicAPIKey
    }
    
    func setAPIKey(_ key: String) {
        self.apiKey = key
        Secrets.anthropicAPIKey = key
    }
    
    func availableModels() -> [ModelDescriptor] {
        return [
            ModelDescriptor(
                id: "claude-3-5-sonnet-20241022",
                displayName: "Claude 3.5 Sonnet",
                provider: .anthropic,
                contextTokens: 200000,
                supportsJSON: true
            ),
            ModelDescriptor(
                id: "claude-3-haiku-20240307",
                displayName: "Claude 3 Haiku",
                provider: .anthropic,
                contextTokens: 200000,
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
