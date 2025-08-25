import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isStreaming: Bool = false
    @Published var temperature: Double = 0.7
    @Published var maxTokens: Int = 2048
    @Published var jsonMode: Bool = false
    @Published var selectedModel: ModelDescriptor?
    @Published var errorMessage: String?
    
    private let provider: LLMProvider = OpenRouterProvider.shared
    private var currentStreamCancellable: Cancellable?
    private let chatHistoryManager = ChatHistoryManager.shared
    
    init() {
        // Set default model
        selectedModel = provider.availableModels().first
        
        // Load persisted settings
        loadSettings()
        
        // Load current chat if available
        if let currentChat = chatHistoryManager.currentChat {
            messages = currentChat.messages
        }
    }
    
    func send() {
        guard provider.isConfigured else {
            showError("Please add your OpenRouter API key in Settings")
            return
        }
        
        guard let selectedModel = selectedModel else {
            showError("Please select an AI model in Settings")
            return
        }
        
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: input.trimmingCharacters(in: .whitespacesAndNewlines))
        messages.append(userMessage)
        
        // Create empty assistant message for streaming
        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        
        // Update chat history
        if let currentChat = chatHistoryManager.currentChat {
            chatHistoryManager.addMessage(userMessage, to: currentChat.id)
        }
        
        input = ""
        isStreaming = true
        errorMessage = nil
        
        Haptics.lightImpact()
        
        currentStreamCancellable = provider.streamChat(
            model: selectedModel,
            messages: Array(messages.dropLast()), // Don't include the empty assistant message
            temperature: temperature,
            maxTokens: maxTokens > 0 ? maxTokens : nil,
            jsonMode: jsonMode,
            onToken: { [weak self] token in
                self?.appendToken(token)
            },
            onComplete: { [weak self] result in
                self?.handleStreamComplete(result)
            }
        )
    }
    
    func stop() {
        currentStreamCancellable?.cancel()
        currentStreamCancellable = nil
        isStreaming = false
        
        Haptics.softImpact()
    }
    
    func retry() {
        guard !messages.isEmpty else { return }
        
        // Remove the last assistant message if it exists
        if messages.last?.role == .assistant {
            messages.removeLast()
        }
        
        // Get the last user message and resend
        if let lastUserMessage = messages.last(where: { $0.role == .user }) {
            input = lastUserMessage.content
            send()
        }
    }
    
    func clearChat() {
        messages.removeAll()
        errorMessage = nil
        
        // Create new chat
        chatHistoryManager.createNewChat()
    }
    
    private func appendToken(_ token: String) {
        guard !messages.isEmpty,
              messages.last?.role == .assistant else { return }
        
        messages[messages.count - 1].content += token
    }
    
    private func handleStreamComplete(_ result: Result<Void, Error>) {
        isStreaming = false
        currentStreamCancellable = nil
        
        switch result {
        case .success:
            errorMessage = nil
            
            // Save the completed assistant message to chat history
            if let lastMessage = messages.last,
               lastMessage.role == .assistant,
               !lastMessage.content.isEmpty,
               let currentChat = chatHistoryManager.currentChat {
                chatHistoryManager.addMessage(lastMessage, to: currentChat.id)
            }
            
        case .failure(let error):
            if error is CancellationError {
                // Stream was cancelled, don't show error
                return
            }
            
            // Handle specific error types
            if let llmError = error as? LLMError {
                switch llmError {
                case .http(let status, let message):
                    if status == 401 {
                        showError("Invalid API key. Please check your OpenRouter API key in Settings.")
                    } else {
                        showError("HTTP \(status): \(message ?? "Unknown error")")
                    }
                case .notConfigured:
                    showError("Please add your OpenRouter API key in Settings")
                default:
                    showError(llmError.localizedDescription)
                }
            } else {
                showError(error.localizedDescription)
            }
            
            // Remove empty assistant message on error
            if let lastMessage = messages.last, 
               lastMessage.role == .assistant && lastMessage.content.isEmpty {
                messages.removeLast()
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        // Auto-hide error after 5 seconds
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if errorMessage == message {
                errorMessage = nil
            }
        }
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "chat_settings"),
           let settings = try? JSONDecoder().decode(ChatSettings.self, from: data) {
            temperature = settings.temperature
            maxTokens = settings.maxTokens
            jsonMode = settings.jsonMode
            
            if let modelId = settings.selectedModelId {
                selectedModel = provider.availableModels().first { $0.id == modelId }
            }
        }
    }
    
    func saveSettings() {
        let settings = ChatSettings(
            temperature: temperature,
            maxTokens: maxTokens,
            jsonMode: jsonMode,
            selectedModelId: selectedModel?.id
        )
        
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "chat_settings")
        }
    }
}

private struct ChatSettings: Codable {
    let temperature: Double
    let maxTokens: Int
    let jsonMode: Bool
    let selectedModelId: String?
}
