import Foundation

enum ProviderKind: String, Codable, CaseIterable {
    case openrouter
    case anthropic
    case openai
    
    var displayName: String {
        switch self {
        case .openrouter: return "OpenRouter"
        case .anthropic: return "Anthropic"
        case .openai: return "OpenAI"
        }
    }
}
