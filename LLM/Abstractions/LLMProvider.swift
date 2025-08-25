import Foundation

protocol LLMProvider {
    var kind: ProviderKind { get }
    var displayName: String { get }
    var isConfigured: Bool { get }
    
    func setAPIKey(_ key: String)
    func availableModels() -> [ModelDescriptor]

    @discardableResult
    func streamChat(
        model: ModelDescriptor,
        messages: [ChatMessage],
        temperature: Double?,
        maxTokens: Int?,
        jsonMode: Bool,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable
}
